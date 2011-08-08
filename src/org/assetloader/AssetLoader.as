package org.assetloader {

	import flash.net.URLRequest;
	import org.assetloader.base.AssetLoaderBase;
	import org.assetloader.base.AssetLoaderError;
	import org.assetloader.base.AssetType;
	import org.assetloader.base.Param;
	import org.assetloader.core.IAssetLoader;
	import org.assetloader.core.ILoader;
	import org.assetloader.events.AssetLoaderErrorEvent;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.parsers.URLParser;


	/**
	 * @author Matan Uberstein
	 */
	public class AssetLoader extends AssetLoaderBase implements IAssetLoader {

		/**
		 * @private
		 */
		private var _config:XML;

		public function AssetLoader(id : String = "PrimaryGroup")
		{
			super(id);
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
		override public function start():void {
			_data = _assets;
			_invoked = true;
			_stopped = false;

			sortIdsByPriority();

			if (numConnections == 0)
				numConnections = _numLoaders;

			super.start();
			
			for(var k : int = 0;k < numConnections;k++)
			{
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

		/**
		 * @private
		 */
		protected function checkForComplete(event:AssetLoaderEvent) : void
		{
			var sum : int = _failOnError ? _numLoaded : _numLoaded + _numFailed;
			if(sum == _numLoaders)
				super.complete_handler(event, _assets);
			else
				startNextLoader();
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
			
			var loader:ILoader = event.currentTarget as ILoader;
			
			_failedIds.push(loader.id);
			_numFailed = _failedIds.length;
			
			dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.CHILD_ERROR, event.errorType, event.message, loader));
			super.error_handler(event);
			
			if(!_failOnError)
				checkForComplete(null);
			else
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

			checkForComplete(null);
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
