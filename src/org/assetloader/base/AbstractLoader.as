package org.assetloader.base {

	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import org.assetloader.core.ILoadStats;
	import org.assetloader.core.ILoader;
	import org.assetloader.core.IParam;
	import org.assetloader.events.AssetLoaderEvent;


	/**
	 * @author Matan Uberstein
	 */
	public class AbstractLoader extends EventDispatcher implements ILoader {

		/**
		 * @private
		 */
		protected var _id:String;
		/**
		 * @private
		 */
		protected var _type:String;
		/**
		 * @private
		 */
		protected var _parent:ILoader;
		/**
		 * @private
		 */
		protected var _request:URLRequest;
		/**
		 * @private
		 */
		protected var _stats:ILoadStats;
		/**
		 * @private
		 */
		protected var _params:Object;
		/**
		 * @private
		 */
		protected var _retryTally:uint;
		/**
		 * @private
		 */
		protected var _invoked:Boolean;
		/**
		 * @private
		 */
		protected var _inProgress:Boolean;
		/**
		 * @private
		 */
		protected var _stopped:Boolean;
		/**
		 * @private
		 */
		protected var _loaded:Boolean;
		/**
		 * @private
		 */
		protected var _failed:Boolean;
		/**
		 * @private
		 */
		protected var _data:*;

		public function AbstractLoader(id:String, type:String, request:URLRequest = null) {
			_id = id;
			_type = type;
			_request = request;

			_stats = new LoaderStats();

			initParams();

			addEventListener(AssetLoaderEvent.ADDED_TO_PARENT, addedToParent_handler);
			addEventListener(AssetLoaderEvent.REMOVED_FROM_PARENT, removedFromParent_handler);
		}

		/**
		 * @private
		 */
		protected function initParams():void {
			_params = {};

			setParam(Param.PRIORITY, 0);
			setParam(Param.RETRIES, 3);
			setParam(Param.ON_DEMAND, false);
			setParam(Param.WEIGHT, 0);
		}

		/**
		 * @inheritDoc
		 */
		public function start():void {
			_stats.start();
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.START));
		}

		/**
		 * @inheritDoc
		 */
		public function stop():void {
			_stopped = true;
			_inProgress = false;
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STOP));
		}

		/**
		 * @inheritDoc
		 */
		public function destroy():void {
			removeEventListener(AssetLoaderEvent.ADDED_TO_PARENT, addedToParent_handler);
			removeEventListener(AssetLoaderEvent.REMOVED_FROM_PARENT, removedFromParent_handler);

			stop();

			_stats.reset();

			_data = null;

			_invoked = false;
			_inProgress = false;
			_stopped = false;
			_loaded = false;
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PROTECTED HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function addedToParent_handler(event:AssetLoaderEvent):void {
			
			if (_parent) {
				throw new AssetLoaderError(AssetLoaderError.ALREADY_CONTAINED_BY_OTHER(_id, _parent.id));
			}
			_parent = event.parent;

			// Inherit prevent cache from parent if undefinded
			if (_params[Param.PREVENT_CACHE] == undefined)
				setParam(Param.PREVENT_CACHE, _parent.getParam(Param.PREVENT_CACHE));

			// Inherit base from parent if undefinded
			if (_params[Param.BASE] == undefined || _params[Param.BASE] == null)
				setParam(Param.BASE, _parent.getParam(Param.BASE));
		}

		/**
		 * @private
		 */
		protected function removedFromParent_handler(event:AssetLoaderEvent):void {
			_parent = null;
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PUBLIC GETTERS/SETTERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @inheritDoc
		 */
		public function get parent():ILoader {
			return _parent;
		}

		/**
		 * @inheritDoc
		 */
		public function get stats():ILoadStats {
			return _stats;
		}

		/**
		 * @inheritDoc
		 */
		public function get invoked():Boolean {
			return _invoked;
		}

		/**
		 * @inheritDoc
		 */
		public function get inProgress():Boolean {
			return _inProgress;
		}

		/**
		 * @inheritDoc
		 */
		public function get stopped():Boolean {
			return _stopped;
		}

		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return _loaded;
		}

		/**
		 * @inheritDoc
		 */
		public function get data():* {
			return _data;
		}

		/**
		 * @inheritDoc
		 */
		public function hasParam(id:String):Boolean {
			if (_parent)
				return (_params[id] != undefined) || parent.hasParam(id);
			return (_params[id] != undefined);
		}

		/**
		 * @inheritDoc
		 */
		public function setParam(id:String, value:*):void {
			_params[id] = value;

			switch(id) {
				case Param.WEIGHT:
					_stats.bytesTotal = value;
					break;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getParam(id:String):* {
			if (_parent && _params[id] == undefined)
				return parent.getParam(id);
			return _params[id];
		}

		/**
		 * @inheritDoc
		 */
		public function addParam(param:IParam):void {
			setParam(param.id, param.value);
		}

		/**
		 * @inheritDoc
		 */
		public function get id():String {
			return _id;
		}

		/**
		 * @inheritDoc
		 */
		public function get request():URLRequest {
			return _request;
		}

		/**
		 * @inheritDoc
		 */
		public function get type():String {
			return _type;
		}

		/**
		 * @inheritDoc
		 */
		public function get params():Object {
			return _params;
		}

		/**
		 * @inheritDoc
		 */
		public function get retryTally():uint {
			return _retryTally;
		}

		/**
		 * @inheritDoc
		 */
		public function get failed():Boolean {
			return _failed;
		}
	}
}
