package com.soma.assets.loader.base {

	import com.soma.assets.loader.core.IAssetLoader;
	import com.soma.assets.loader.core.IConfigParser;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.events.AssetLoaderErrorEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.events.AssetLoaderProgressEvent;
	import com.soma.assets.loader.parsers.XmlConfigParser;

	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * @author Matan Uberstein
	 */
	public class AssetLoaderBase extends AbstractLoader {

		/**
		 * @private
		 */
		protected var _loaders:Dictionary;
		/**
		 * @private
		 */
		protected var _assets:Dictionary;
		/**
		 * @private
		 */
		protected var _ids:Array;
		/**
		 * @private
		 */
		protected var _loaderFactory:LoaderFactory;
		/**
		 * @private
		 */
		protected var _configParser:IConfigParser;
		/**
		 * @private
		 */
		protected var _numLoaders:int;
		/**
		 * @private
		 */
		protected var _numConnections:int = 3;

		public function AssetLoaderBase(id:String) {
			_loaders = new Dictionary(true);
			_data = _assets = new Dictionary(true);
			_loaderFactory = new LoaderFactory();
			_ids = [];

			super(id, AssetType.GROUP);
		}

		/**
		 * @inheritDoc
		 */
		public function addLazy(id:String, url:String, type:String = "AUTO", ...params):ILoader {
			return add(id, new URLRequest(url), type, params);
		}

		/**
		 * @inheritDoc
		 */
		public function add(id:String, request:URLRequest, type:String = "AUTO", ...params):ILoader {
			var loader:ILoader = _loaderFactory.produce(id, type, request, params);
			addLoader(loader);
			return loader;
		}

		/**
		 * @inheritDoc
		 */
		public function addLoader(loader:ILoader):void {
			if (hasLoader(loader.id)) {
				throw new AssetLoaderError(AssetLoaderError.ALREADY_CONTAINS_LOADER_WITH_ID(_id, loader.id));
			}
			if (loader.parent) {
				throw new AssetLoaderError(AssetLoaderError.ALREADY_CONTAINED_BY_OTHER(loader.id, loader.parent.id));
			}
			_loaders[loader.id] = loader;
			_ids.push(loader.id);
			_numLoaders = _ids.length;
			if (loader.getParam(Param.PRIORITY) == 0) {
				loader.setParam(Param.PRIORITY, -(_numLoaders - 1));
			}
			loader.addEventListener(AssetLoaderEvent.START, start_handler);
			updateTotalBytes();
			if (hasCircularReference(_id)) {
				throw new AssetLoaderError(AssetLoaderError.CIRCULAR_REFERENCE_FOUND(loader.id));
			}
			loader.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.ADDED_TO_PARENT, this));
		}

		/**
		 * @inheritDoc
		 */
		public function remove(id:String):ILoader {
			var loader:ILoader = getLoader(id);
			if (loader) {
				_ids.splice(_ids.indexOf(id), 1);
				delete _loaders[id];
				delete _assets[id];

				loader.removeEventListener(AssetLoaderEvent.START, start_handler);
				removeListeners(loader);

				_numLoaders = _ids.length;
			}

			updateTotalBytes();

			loader.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.REMOVED_FROM_PARENT, this));

			return loader;
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			var idsCopy:Array = _ids.concat();
			var loader:ILoader;

			for each (var id : String in idsCopy) {
				loader = remove(id);
				loader.destroy();
			}

			super.destroy();
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PROTECTED
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function updateTotalBytes():void {
			var bytesTotal:uint = 0;

			for each (var loader : ILoader in _loaders) {
				if (!loader.getParam(Param.ON_DEMAND))
					bytesTotal += loader.stats.bytesTotal;
			}

			_stats.bytesTotal = bytesTotal;
		}

		/**
		 * @private
		 */
		protected function get configParser():IConfigParser {
			if (_configParser)
				return _configParser;

			_configParser = new XmlConfigParser();
			return _configParser;
		}

		/**
		 * @private
		 */
		protected function addListeners(loader:ILoader):void {
			if (loader) {
				loader.addEventListener(AssetLoaderErrorEvent.ERROR, error_handler);
				loader.addEventListener(AssetLoaderEvent.OPEN, open_handler);
				loader.addEventListener(AssetLoaderProgressEvent.PROGRESS, progress_handler);
				loader.addEventListener(AssetLoaderEvent.COMPLETE, complete_handler);
			}
		}

		/**
		 * @private
		 */
		protected function removeListeners(loader:ILoader):void {
			if (loader) {
				loader.removeEventListener(AssetLoaderErrorEvent.ERROR, error_handler);
				loader.removeEventListener(AssetLoaderEvent.OPEN, open_handler);
				loader.removeEventListener(AssetLoaderProgressEvent.PROGRESS, progress_handler);
				loader.removeEventListener(AssetLoaderEvent.COMPLETE, complete_handler);
			}
		}

		/**
		 * @private
		 */
		protected function hasCircularReference(id:String):Boolean {
			for each (var loader : ILoader in _loaders) {
				if (loader is AssetLoaderBase) {
					var assetloader:AssetLoaderBase = AssetLoaderBase(loader);
					if (assetloader.hasLoader(id) || assetloader.hasCircularReference(id))
						return true;
				}
			}
			return false;
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PROTECTED HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		override protected function addedToParent_handler(event:AssetLoaderEvent):void {
			if (hasCircularReference(_id)) {
				throw new AssetLoaderError(AssetLoaderError.CIRCULAR_REFERENCE_FOUND(_id));
			}
			super.addedToParent_handler(event);
		}

		protected function start_handler(event:AssetLoaderEvent):void {
			var loader:ILoader = event.currentTarget as ILoader;

			loader.removeEventListener(AssetLoaderEvent.START, start_handler);
			loader.addEventListener(AssetLoaderEvent.STOP, stop_handler);

			addListeners(loader);
		}

		protected function stop_handler(event:AssetLoaderEvent):void {
			var loader:ILoader = event.currentTarget as ILoader;

			loader.addEventListener(AssetLoaderEvent.START, start_handler);
			loader.removeEventListener(AssetLoaderEvent.STOP, stop_handler);

			removeListeners(loader);
		}

		/**
		 * @private
		 */
		protected function error_handler(event:AssetLoaderErrorEvent):void {
			_failed = true;
			dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.ERROR, event.errorType, event.message));
		}

		/**
		 * @private
		 */
		protected function open_handler(event:AssetLoaderEvent):void {
			_stats.open();
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.OPEN));
		}

		/**
		 * @private
		 */
		protected function progress_handler(event:AssetLoaderProgressEvent):void {
			_inProgress = true;

			var bytesLoaded:uint = 0;
			var bytesTotal:uint = 0;
			

			for each (var loader : ILoader in _loaders) {
				bytesLoaded += loader.stats.bytesLoaded;
				bytesTotal += loader.stats.bytesTotal;
			}

			_stats.update(bytesLoaded, bytesTotal);

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
		protected function complete_handler(event:AssetLoaderEvent, data:* = null):void {
			_loaded = true;
			_inProgress = false;
			_stats.done();

			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.COMPLETE, _parent, null, data));
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PUBLIC GETTERS/SETTERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @inheritDoc
		 */
		public function get numConnections():int {
			return _numConnections;
		}

		/**
		 * @inheritDoc
		 */
		public function set numConnections(value:int):void {
			_numConnections = value;
		}

		/**
		 * @inheritDoc
		 */
		public function getLoader(id:String):ILoader {
			if (hasLoader(id))
				return _loaders[id];
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function getAssetLoader(id:String):IAssetLoader {
			if (hasAssetLoader(id))
				return _loaders[id];
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function getAsset(id:String):* {
			return _assets[id];
		}

		/**
		 * Gets a Dictionary of the loaded assets.
		 * @return Dictionary
		 */
		override public function get data():* {
			return _data;
		}

		/**
		 * @inheritDoc
		 */
		public function hasLoader(id:String):Boolean {
			return _loaders[id] != undefined;
		}

		/**
		 * @inheritDoc
		 */
		public function hasAssetLoader(id:String):Boolean {
			return (_loaders[id] != undefined && _loaders[id] is IAssetLoader);
		}

		/**
		 * @inheritDoc
		 */
		public function hasAsset(id:String):Boolean {
			return _assets[id] != undefined;
		}

		/**
		 * @inheritDoc
		 */
		public function get ids():Array {
			return _ids;
		}

		/**
		 * @inheritDoc
		 */
		public function get numLoaders():int {
			return _numLoaders;
		}
		// --------------------------------------------------------------------------------------------------------------------------------//
		// PUBLIC SIGNALS
		// --------------------------------------------------------------------------------------------------------------------------------//
	}
}