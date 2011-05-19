package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AbstractLoader;
	import com.soma.assets.loader.base.Param;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.events.AssetLoaderErrorEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.events.AssetLoaderHTTPStatusEvent;
	import com.soma.assets.loader.events.AssetLoaderProgressEvent;
	import com.soma.assets.loader.parsers.URLParser;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	/**
	 * @author Matan Uberstein
	 */
	public class BaseLoader extends AbstractLoader implements ILoader {

		/**
		 * @private
		 */
		protected var _eventDispatcher:IEventDispatcher;

		public function BaseLoader(request:URLRequest, type:String, id:String = null) {
			super(id || request.url, type, request);
		}

		/**
		 * @inheritDoc
		 */
		override public function start():void {
			if (!_invoked) {
				_invoked = true;
				_stopped = false;

				_eventDispatcher = constructLoader();

				addListeners(_eventDispatcher);

				super.start();

				invokeLoading();
			} else {
				_invoked = false;
				stop();
				start();
			}
		}

		/**
		 * @private
		 */
		protected function constructLoader():IEventDispatcher {
			return null;
		}

		/**
		 * @private
		 */
		protected function invokeLoading():void {
		}

		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			removeListeners(_eventDispatcher);
			_eventDispatcher = null;

			super.stop();
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			removeListeners(_eventDispatcher);
			_eventDispatcher = null;

			super.destroy();
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function error_handler(event:ErrorEvent):void {
			_inProgress = false;
			if (_retryTally < getParam(Param.RETRIES) - 1) {
				_retryTally++;
				start();
			} else {
				_failed = true;
				removeListeners(_eventDispatcher);
				dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.ERROR, event.type, event.text));
			}
		}

		/**
		 * @private
		 */
		protected function httpStatus_handler(event:HTTPStatusEvent):void {
			dispatchEvent(new AssetLoaderHTTPStatusEvent(AssetLoaderHTTPStatusEvent.STATUS, event.status));
		}

		/**
		 * @private
		 */
		protected function open_handler(event:Event):void {
			_stats.open();
			_inProgress = true;
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.OPEN));
		}

		/**
		 * @private
		 */
		protected function progress_handler(event:ProgressEvent):void {
			_stats.update(event.bytesLoaded, event.bytesTotal);

			var progressEvent:AssetLoaderProgressEvent = new AssetLoaderProgressEvent(AssetLoaderProgressEvent.PROGRESS);
			progressEvent.latency = _stats.latency;
			progressEvent.speed = _stats.speed;
			progressEvent.averageSpeed = _stats.averageSpeed;
			progressEvent.progress = _stats.progress;
			progressEvent.bytesLoaded = _stats.bytesLoaded;
			progressEvent.bytesTotal = _stats.bytesTotal;
			dispatchEvent(progressEvent);
		}

		/**
		 * @private
		 */
		protected function complete_handler(event:Event):void {
			_stats.done();

			var progressEvent:AssetLoaderProgressEvent = new AssetLoaderProgressEvent(AssetLoaderProgressEvent.PROGRESS);
			progressEvent.latency = _stats.latency;
			progressEvent.speed = _stats.speed;
			progressEvent.averageSpeed = _stats.averageSpeed;
			progressEvent.progress = _stats.progress;
			progressEvent.bytesLoaded = _stats.bytesLoaded;
			progressEvent.bytesTotal = _stats.bytesTotal;
			// dispatchEvent(progressEvent);

			removeListeners(_eventDispatcher);

			_inProgress = false;
			_loaded = true;
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.COMPLETE, null, null, _data));
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PROTECTED
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function addListeners(dispatcher:IEventDispatcher):void {
			if (dispatcher) {
				dispatcher.addEventListener(IOErrorEvent.IO_ERROR, error_handler);
				dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error_handler);

				dispatcher.addEventListener(Event.OPEN, open_handler);
				dispatcher.addEventListener(ProgressEvent.PROGRESS, progress_handler);
				dispatcher.addEventListener(Event.COMPLETE, complete_handler);

				dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus_handler);
			}
		}

		/**
		 * @private
		 */
		protected function removeListeners(dispatcher:IEventDispatcher):void {
			if (dispatcher) {
				dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, error_handler);
				dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, error_handler);

				dispatcher.removeEventListener(Event.OPEN, open_handler);
				dispatcher.removeEventListener(ProgressEvent.PROGRESS, progress_handler);
				dispatcher.removeEventListener(Event.COMPLETE, complete_handler);

				dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus_handler);
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function setParam(id:String, value:*):void {
			var success:Boolean = true;

			switch(id) {
				case Param.BASE:
					success = setBase(value);
					break;
				case Param.PREVENT_CACHE:
					setPreventCache(value);
					break;
				case Param.HEADERS:
					_request.requestHeaders = value;
					break;
			}

			if (success)
				super.setParam(id, value);
		}

		/**
		 * @private
		 */
		protected function setBase(value:String):Boolean {
			if (!value)
				return false;

			var urlParser:URLParser = new URLParser(_request.url);

			if (!urlParser.host) {
				_request.url = value + urlParser.url;
				return true;
			}

			return false;
		}

		/**
		 * @private
		 */
		protected function setPreventCache(value:Boolean):void {
			var url:String = _request.url;
			if (value) {
				if (url.indexOf("ck=") == -1)
					url += ((url.indexOf("?") == -1) ? "?" : "&") + "ck=" + new Date().time;
			} else if (url.indexOf("ck=") != -1) {
				var vrs:URLVariables = new URLVariables(url.slice(url.indexOf("?") + 1));
				var cleanUrl:String = url.slice(0, url.indexOf("?"));
				var cleanVrs:URLVariables = new URLVariables();

				for (var queryKey : String in vrs) {
					if (queryKey != "ck")
						cleanVrs[queryKey] = vrs[queryKey];
				}

				var queryString:String = cleanVrs.toString();

				url = cleanUrl + ((queryString != "") ? "?" + queryString : "");
			}
			_request.url = url;
		}
	}
}
