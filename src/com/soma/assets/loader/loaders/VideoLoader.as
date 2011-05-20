package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;
	import com.soma.assets.loader.base.Param;
	import com.soma.assets.loader.events.AssetLoaderErrorEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.events.AssetLoaderNetStatusEvent;

	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * @author Matan Uberstein
	 */
	public class VideoLoader extends BaseLoader {

		/**
		 * @private
		 */
		protected var _netConnection:NetConnection;
		/**
		 * @private
		 */
		protected var _netStream:NetStream;
		/**
		 * @private
		 */
		protected var _progressTimer:Timer;
		/**
		 * @private
		 */
		protected var _hasDispatchedReady:Boolean;

		public function VideoLoader(request:URLRequest, id:String = null) {
			super(request, AssetType.VIDEO, id);
		}

		/**
		 * @private
		 */
		override protected function initParams():void {
			super.initParams();
			setParam(Param.CLIENT, {onMetaData:function():void {
			}});
		}

		/**
		 * @private
		 */
		override protected function constructLoader():IEventDispatcher {
			_netConnection = new NetConnection();
			_netConnection.connect(null);

			_netStream = new NetStream(_netConnection);
			_data = _netStream;

			_progressTimer = new Timer(50);
			_progressTimer.addEventListener(TimerEvent.TIMER, progressTimer_handler);

			_netStream.client = getParam(Param.CLIENT);

			return _netStream;
		}

		/**
		 * @private
		 */
		override protected function invokeLoading():void {
			try {
				_netStream.play(request.url, getParam(Param.CHECK_POLICY_FILE) || true);
			} catch(error:SecurityError) {
				dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.ERROR, error.name, error.message));
			}

			_progressTimer.start();
		}

		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			if (_invoked) {
				try {
					_netStream.close();
				} catch(error:Error) {
				}
				try {
					_netConnection.close();
				} catch(error:Error) {
				}
				_progressTimer.stop();
			}
			super.stop();
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();

			if (_progressTimer)
				_progressTimer.removeEventListener(TimerEvent.TIMER, progressTimer_handler);

			_hasDispatchedReady = false;
			_netConnection = null;
			_netStream = null;
		}

		/**
		 * @private
		 */
		protected function progressTimer_handler(event:TimerEvent):void {
			
			if (_netStream.bytesLoaded > 4 && !_hasDispatchedReady) {
				_netStream.pause();
				_netStream.seek(0);

				open_handler(new Event(Event.OPEN));

				dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.NET_STREAM_READY, null, null, _netStream));

				_hasDispatchedReady = true;
			} else if (_netStream.bytesLoaded != _stats.bytesTotal && _hasDispatchedReady)
				progress_handler(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _netStream.bytesLoaded, _netStream.bytesTotal));
			else if (_netStream.bytesLoaded > 8 && _netStream.bytesTotal > 8) {
				_progressTimer.stop();
				complete_handler(new Event(Event.COMPLETE));
			}
		}

		/**
		 * @private
		 */
		protected function netStatus_handler(event:NetStatusEvent):void {
			
			var code:String = event.info.code;
			var errorEvent:ErrorEvent;

			switch(code) {
				case "NetStream.Play.StreamNotFound":
					errorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
					errorEvent.text = code;
					error_handler(errorEvent);
					break;
				default:
					dispatchEvent(new AssetLoaderNetStatusEvent(AssetLoaderNetStatusEvent.INFO, event.info));
					break;
			}
		}

		/**
		 * @private
		 */
		override protected function addListeners(dispatcher:IEventDispatcher):void {
			if (dispatcher) {
				dispatcher.addEventListener(IOErrorEvent.IO_ERROR, error_handler);
				dispatcher.addEventListener(AsyncErrorEvent.ASYNC_ERROR, error_handler);
				dispatcher.addEventListener(NetStatusEvent.NET_STATUS, netStatus_handler);
			}
		}

		/**
		 * @private
		 */
		override protected function removeListeners(dispatcher:IEventDispatcher):void {
			if (dispatcher) {
				dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, error_handler);
				dispatcher.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, error_handler);
				dispatcher.removeEventListener(NetStatusEvent.NET_STATUS, netStatus_handler);
			}
		}

		/**
		 * Gets the NetConnection used with the NetStream.
		 * <p>Note: this instance will be available as soon as the VideoLoader's
		 * start method is invoked.</p>
		 * 
		 * @return NetConnection
		 */
		public function get netConnection():NetConnection {
			return _netConnection;
		}

		/**
		 * Gets the NetStream.
		 * 
		 * <p>Note: this instance will be available as soon as the VideoLoader's
		 * start method is invoked.</p>
		 * 
		 * @return NetStream
		 */
		public function get netStream():NetStream {
			return _netStream;
		}
	}
}
