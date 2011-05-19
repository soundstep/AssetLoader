package com.soma.assets.loader {

	import com.soma.assets.loader.base.AssetLoaderBase;
	import com.soma.assets.loader.base.AssetLoaderError;
	import com.soma.assets.loader.base.AssetType;
	import com.soma.assets.loader.base.Param;
	import com.soma.assets.loader.core.IAssetLoader;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.events.AssetLoaderErrorEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.parsers.URLParser;

	import flash.net.URLRequest;

	/**
	 * @author Matan Uberstein
	 */
	public class AssetLoader extends AssetLoaderBase implements IAssetLoader {

		/**
		 * @private
		 */
		protected var _loadedIds:Array;
		/**
		 * @private
		 */
		protected var _numLoaded:int;
		private var _config:XML;

		public function AssetLoader(id:String = "PrimaryGroup") {
			super(id);
			_loadedIds = [];
		}

		/**
		 * @inheritDoc
		 */
		public function addConfig(config:String):Boolean {
			var urlParser:URLParser = new URLParser(config);
			if (urlParser.isValid) {
				var loader:ILoader = _loaderFactory.produce("config", AssetType.TEXT, new URLRequest(config));
				loader.setParam(Param.PREVENT_CACHE, true);

				loader.addEventListener(AssetLoaderErrorEvent.ERROR, error_handler);
				loader.addEventListener(AssetLoaderEvent.COMPLETE, configLoader_complete_handler);

				loader.start();

				return false;
			} else {
				try {
					_config = configParser.parse(this, config);

					return true;
				} catch(error:Error) {
					throw new AssetLoaderError(AssetLoaderError.COULD_NOT_PARSE_CONFIG(_id, error.message), error.errorID);
				}
			}
			return false;
		}

		/**
		 * @inheritDoc
		 */
		override public function remove(id:String):ILoader {
			var loader:ILoader = super.remove(id);
			if (loader) {
				if (loader.loaded)
					_loadedIds.splice(_loadedIds.indexOf(id), 1);

				_numLoaded = _loadedIds.length;
			}

			return loader;
		}

		/**
		 * @inheritDoc
		 */
		override public function start():void {
			_data = _assets;
			_invoked = true;
			_stopped = false;

			sortIdsByPriority();

			if (numConnections == 0)
				numConnections = _numLoaders;

			super.start();

			for (var k:int = 0;k < numConnections;k++) {
				startNextLoader();
			}
		}

		/**
		 * @inheritDoc
		 */
		public function startLoader(id:String):void {
			var loader:ILoader = getLoader(id);
			if (loader)
				loader.start();

			updateTotalBytes();
		}

		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			var loader:ILoader;

			for (var i:int = 0;i < _numLoaders;i++) {
				loader = getLoader(_ids[i]);

				if (!loader.loaded)
					loader.stop();
			}

			super.stop();
		}

		/**
		 * @inheritDoc
		 */
		public function get loadedIds():Array {
			return _loadedIds;
		}

		/**
		 * @inheritDoc
		 */
		public function get numLoaded():int {
			return _numLoaded;
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PROTECTED FUNCTIONS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function sortIdsByPriority():void {
			var priorities:Array = [];
			for (var i:int = 0;i < _numLoaders;i++) {
				var loader:ILoader = getLoader(_ids[i]);
				priorities.push(loader.getParam(Param.PRIORITY));
			}

			var sortedIndexs:Array = priorities.sort(Array.NUMERIC | Array.DESCENDING | Array.RETURNINDEXEDARRAY);
			var idsCopy:Array = _ids.concat();

			for (var j:int = 0;j < _numLoaders;j++) {
				_ids[j] = idsCopy[sortedIndexs[j]];
			}
		}

		/**
		 * @private
		 */
		protected function startNextLoader():void {
			if (_invoked) {
				var loader:ILoader;
				var ON_DEMAND:String = Param.ON_DEMAND;
				for (var i:int = 0;i < _numLoaders;i++) {
					loader = getLoader(_ids[i]);

					if (!loader.loaded && !loader.failed && !loader.getParam(ON_DEMAND)) {
						if (!loader.invoked || (loader.invoked && loader.stopped)) {
							startLoader(loader.id);
							return;
						}
					}
				}
			}
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// PROTECTED HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		override protected function open_handler(event:AssetLoaderEvent):void {
			_inProgress = true;
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.CHILD_OPEN, null, ILoader(event.currentTarget)));
			super.open_handler(event);
		}

		/**
		 * @private
		 */
		override protected function error_handler(event:AssetLoaderErrorEvent):void {
			dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.CHILD_ERROR, event.errorType, event.message, ILoader(event.currentTarget)));
			super.error_handler(event);
			startNextLoader();
		}

		/**
		 * @private
		 */
		override protected function complete_handler(event:AssetLoaderEvent, data:* = null):void {
			data;
			var loader:ILoader = event.currentTarget as ILoader;
			removeListeners(loader);

			_assets[loader.id] = loader.data;
			_loadedIds.push(loader.id);
			_numLoaded = _loadedIds.length;

			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.CHILD_COMPLETE, null, ILoader(event.currentTarget)));

			if (_numLoaded == _numLoaders)
				super.complete_handler(event, _assets);
			else
				startNextLoader();
		}

		/**
		 * @private
		 */
		protected function configLoader_complete_handler(event:AssetLoaderEvent):void {
			var loader:ILoader = event.currentTarget as ILoader;
			loader.removeEventListener(AssetLoaderEvent.COMPLETE, configLoader_complete_handler);
			loader.removeEventListener(AssetLoaderErrorEvent.ERROR, error_handler);

			if (!configParser.isValid(loader.data))
				dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.ERROR, "config-error", "Could not parse config after it has been loaded."));
			else {
				addConfig(loader.data);
				dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.CONFIG_LOADED));
			}

			loader.destroy();
		}

		public function get config():XML {
			if (!_config) return null;
			return _config.copy();
		}

		override public function destroy():void {
			super.destroy();
			_config = null;
		}
	}
}