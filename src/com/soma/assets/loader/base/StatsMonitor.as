package com.soma.assets.loader.base {

	import com.soma.assets.loader.core.ILoadStats;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.events.AssetLoaderProgressEvent;

	import flash.events.EventDispatcher;

	/**
	 * @author Matan Uberstein
	 * 
	 * Consolidates multiple ILoader's stats.
	 */
	public class StatsMonitor extends EventDispatcher {

		protected var _loaders:Array;
		protected var _stats:ILoadStats;
		protected var _numLoaders:int;
		protected var _numComplete:int;

		public function StatsMonitor() {
			_loaders = [];
			_stats = new LoaderStats();
		}

		/**
		 * Adds ILoader for monitoring.
		 * 
		 * @param loader Instance of ILoader or IAssetLoader.
		 * 
		 * @throws org.assetloader.base.AssetLoaderError ALREADY_CONTAINS_LOADER
		 */
		public function add(loader:ILoader):void {
			if (_loaders.indexOf(loader) == -1) {
				addListener(loader);

				_loaders.push(loader);
				_numLoaders = _loaders.length;
			} else
				throw new AssetLoaderError(AssetLoaderError.ALREADY_CONTAINS_LOADER);
		}

		/**
		 * Removes ILoader from monitoring.
		 * 
		 * @param loader An instance of an ILoader already added.
		 * 
		 * @throws org.assetloader.base.AssetLoaderError DOESNT_CONTAIN_LOADER
		 */
		public function remove(loader:ILoader):void {
			var index:int = _loaders.indexOf(loader);
			if (index != -1) {
				removeListener(loader);

				if (loader.loaded)
					_numComplete--;

				_loaders.splice(index, 1);
				_numLoaders = _loaders.length;
			} else
				throw new AssetLoaderError(AssetLoaderError.DOESNT_CONTAIN_LOADER);
		}

		/**
		 * Removes all internal listeners and clears the monitoring list.
		 * 
		 * <p>Note: After calling destroy, this instance of StatsMonitor is still usable.
		 * Simply rebuild your monitor list via the add() method.</p>
		 */
		public function destroy():void {
			for each (var loader : ILoader in _loaders) {
				removeListener(loader);
			}

			_loaders = [];
			_numLoaders = 0;
			_numComplete = 0;
		}

		/**
		 * @private
		 */
		protected function addListener(loader:ILoader):void {
			loader.addEventListener(AssetLoaderEvent.START, start_handler);
			loader.addEventListener(AssetLoaderEvent.OPEN, open_handler);
			loader.addEventListener(AssetLoaderProgressEvent.PROGRESS, progress_handler);
			loader.addEventListener(AssetLoaderEvent.COMPLETE, complete_handler);
		}

		/**
		 * @private
		 */
		protected function removeListener(loader:ILoader):void {
			loader.removeEventListener(AssetLoaderEvent.START, start_handler);
			loader.removeEventListener(AssetLoaderEvent.OPEN, open_handler);
			loader.removeEventListener(AssetLoaderProgressEvent.PROGRESS, progress_handler);
			loader.removeEventListener(AssetLoaderEvent.COMPLETE, complete_handler);
		}

		/**
		 * @private
		 */
		protected function start_handler(event:AssetLoaderEvent):void {
			for each (var loader : ILoader in _loaders) {
				loader.removeEventListener(AssetLoaderEvent.START, start_handler);
			}
			_stats.start();
		}

		/**
		 * @private
		 */
		protected function open_handler(event:AssetLoaderEvent):void {
			_stats.open();
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.OPEN, null, null, null, null, null, ILoader(event.currentTarget)));
		}

		/**
		 * @private
		 */
		protected function progress_handler(event:AssetLoaderProgressEvent):void {
			var bytesLoaded:uint;
			var bytesTotal:uint;
			for each (var loader : ILoader in _loaders) {
				bytesLoaded += loader.stats.bytesLoaded;
				bytesTotal += loader.stats.bytesTotal;
			}
			_stats.update(bytesLoaded, bytesTotal);
			var progressEvent:AssetLoaderProgressEvent = new AssetLoaderProgressEvent(AssetLoaderProgressEvent.PROGRESS, ILoader(event.currentTarget));
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
		protected function complete_handler(event:AssetLoaderEvent):void {
			_numComplete++;
			if (_numComplete == _numLoaders) {
				_stats.done();
				dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.COMPLETE, null, null, null, null, _stats));
			}
		}

		/**
		 * Get the overall stats of all the ILoaders in the monitoring list.
		 * 
		 * @return ILoadStats
		 */
		public function get stats():ILoadStats {
			return _stats;
		}

		/**
		 * Gets the amount of loaders added to the monitoring queue.
		 * 
		 * @return int
		 */
		public function get numLoaders() : int
		{
			return _numLoaders;
		}

		/**
		 * Gets the amount of loaders that have finished loading.
		 * 
		 * @return int
		 */
		public function get numComplete() : int
		{
			return _numComplete;
		}
	}
}
