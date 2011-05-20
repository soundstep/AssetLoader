package org.assetloader.example {

	import com.soma.assets.loader.AssetLoader;
	import com.soma.assets.loader.core.IAssetLoader;
	import com.soma.assets.loader.core.ILoadStats;
	import com.soma.assets.loader.events.AssetLoaderErrorEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * @author Matan Uberstein
	 */
	public class AddConfigExample extends Sprite
	{
		protected var _assetloader : IAssetLoader;
		protected var _field : TextField;

		public function AddConfigExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			initConsole();

			_assetloader = new AssetLoader();

			// Passing config as a URL.
			_assetloader.addConfig("simple-queue-config.xml");

			// Because we are passing the config as a URL, we need wait until AssetLoader fires onConfigLoaded before stating the queue.
			_assetloader.addEventListener(AssetLoaderEvent.CONFIG_LOADED, onConfigLoaded_handler);

			// Add listeners
			addListenersToLoader(_assetloader);
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		protected function onConfigLoaded_handler(event : AssetLoaderEvent) : void
		{
			// Do your clean up!
			_assetloader.removeEventListener(AssetLoaderEvent.CONFIG_LOADED, onConfigLoaded_handler);

			// Start!
			_assetloader.start();
		}

		protected function onChildOpen_handler(event : AssetLoaderEvent) : void
		{
			append("[" + event.child.id + "]\t[" + event.child.id + "]\t\topened  \tLatency\t: " + Math.floor(event.child.stats.latency) + "\tms");
		}

		protected function onChildError_handler(event : AssetLoaderErrorEvent) : void
		{
			append("[" + event.child.id + "]\t[" + event.child.id + "]\t\terror  \tType\t: " + event.errorType + " | Message: " + event.message);
		}

		protected function onChildComplete_handler(event : AssetLoaderEvent) : void
		{
			append("[" + event.child.id + "]\t[" + event.child.id + "]\t\tcomplete\tSpeed\t: " + Math.floor(event.child.stats.averageSpeed) + "\tkbps");
		}

		protected function onComplete_handler(event : AssetLoaderEvent) : void
		{
			var loader : IAssetLoader = IAssetLoader(event.currentTarget);

			// Do your clean up!
			removeListenersFromLoader(loader);

			// Our Primary AssetLoader's stats.
			var stats : ILoadStats = loader.stats;

			append("\n[" + loader.id + "]");
			append("LOADING COMPLETE:");
			append("Total Time: " + stats.totalTime + " ms");
			append("Average Latency: " + Math.floor(stats.latency) + " ms");
			append("Average Speed: " + Math.floor(stats.averageSpeed) + " kbps");
			append("Total Bytes: " + stats.bytesTotal);
			append("");
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// ADD / REMOVE LISTENERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		protected function addListenersToLoader(loader : IAssetLoader) : void
		{
			loader.addEventListener(AssetLoaderEvent.CHILD_OPEN, onChildOpen_handler);
			loader.addEventListener(AssetLoaderErrorEvent.CHILD_ERROR, onChildError_handler);
			loader.addEventListener(AssetLoaderEvent.CHILD_COMPLETE, onChildComplete_handler);
			loader.addEventListener(AssetLoaderEvent.COMPLETE, onComplete_handler);
		}

		protected function removeListenersFromLoader(loader : IAssetLoader) : void
		{
			loader.removeEventListener(AssetLoaderEvent.CHILD_OPEN, onChildOpen_handler);
			loader.removeEventListener(AssetLoaderErrorEvent.CHILD_ERROR, onChildError_handler);
			loader.removeEventListener(AssetLoaderEvent.CHILD_COMPLETE, onChildComplete_handler);
			loader.removeEventListener(AssetLoaderEvent.COMPLETE, onComplete_handler);
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// CONSOLE
		// --------------------------------------------------------------------------------------------------------------------------------//
		protected function initConsole() : void
		{
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat("Courier New", 12);
			_field.multiline = true;
			_field.selectable = true;
			_field.wordWrap = false;
			_field.width = stage.stageWidth;
			_field.height = stage.stageHeight;

			stage.addEventListener(Event.RESIZE, resize_handler);

			addChild(_field);
		}

		protected function append(text : String) : void
		{
			_field.appendText(text + "\n");
		}

		protected function resize_handler(event : Event) : void
		{
			_field.width = stage.stageWidth;
			_field.height = stage.stageHeight;
		}
	}
}
