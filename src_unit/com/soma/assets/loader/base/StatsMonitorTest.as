package com.soma.assets.loader.base {

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import com.soma.assets.loader.events.AssetLoaderProgressEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.core.ILoadStats;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.loaders.ImageLoader;
	import com.soma.assets.loader.loaders.TextLoader;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.osflash.signals.utils.SignalAsyncEvent;
	import org.osflash.signals.utils.failOnSignal;
	import org.osflash.signals.utils.handleSignal;

	import flash.net.URLRequest;


	public class StatsMonitorTest
	{
		protected var _monitor : StatsMonitor;
		protected var _className : String = "StatsMonitor";
		protected var _path : String = "assets/test/";

		[BeforeClass]
		public static function runBeforeEntireSuite() : void
		{
		}

		[AfterClass]
		public static function runAfterEntireSuite() : void
		{
		}

		[Before]
		public function runBeforeEachTest() : void
		{
			_monitor = new StatsMonitor();
		}

		[After]
		public function runAfterEachTest() : void
		{
			_monitor.destroy();
			_monitor = null;
		}

		[Test]
		public function adding() : void
		{
			var l1 : ILoader = new TextLoader(new URLRequest(_path + "testTXT.txt"));
			_monitor.add(l1);
			assertEquals(_className + "#numLoaders should equal", 1, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);

			var l2 : ILoader = new ImageLoader(new URLRequest(_path + "testIMAGE.png"));
			_monitor.add(l2);
			assertEquals(_className + "#numLoaders should equal", 2, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);
		}

		[Test]
		public function removing() : void
		{
			var l1 : ILoader = new TextLoader(new URLRequest(_path + "testTXT.txt"));
			var l2 : ILoader = new ImageLoader(new URLRequest(_path + "testIMAGE.png"));

			_monitor.add(l1);
			_monitor.add(l2);

			_monitor.remove(l1);
			assertEquals(_className + "#numLoaders should equal", 1, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);

			_monitor.remove(l2);
			assertEquals(_className + "#numLoaders should equal", 0, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);
		}

		[Test]
		public function destroying() : void
		{
			var l1 : ILoader = new TextLoader(new URLRequest(_path + "testTXT.txt"));
			var l2 : ILoader = new ImageLoader(new URLRequest(_path + "testIMAGE.png"));

			_monitor.add(l1);
			_monitor.add(l2);

			_monitor.destroy();
			
			assertEquals(_className + "#numLoaders should equal", 0, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);
			
			// Should still be usable, thus test adding again after destroy.

			_monitor.add(l1);
			assertEquals(_className + "#numLoaders should equal", 1, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);

			_monitor.add(l2);
			assertEquals(_className + "#numLoaders should equal", 2, _monitor.numLoaders);
			assertEquals(_className + "#numComplete should equal", 0, _monitor.numComplete);
		}
		
		[Test (async)]
		public function onOpenEvent() : void
		{
			var l1 : ILoader = new TextLoader(new URLRequest(_path + "testTXT.txt"));
			var l2 : ILoader = new ImageLoader(new URLRequest(_path + "testIMAGE.png"));

			_monitor.add(l1);
			_monitor.add(l2);
			
			_monitor.addEventListener(AssetLoaderEvent.OPEN, Async.asyncHandler(this, onOpen_handler, 500, {l1:l1, l2:l2}, onOpen_handlerFailed), false, 0, true);
			
			//only tell the one loader to start, because we are checking the passed loader's value within handler.
			l1.start();
		}

		protected function onOpen_handler(event:AssetLoaderEvent, data:Object) : void
		{
			assertNotNull("#loader should NOT be null", event.statsLoaderTarget);
			assertEquals("#loader should equal", data.l1, event.statsLoaderTarget);
		}
		
		protected function onOpen_handlerFailed(event : SignalAsyncEvent, data : Object) : void
		{
			data;
			fail("#onOpenEvent timeout");
		}
		
		[Test (async)]
		public function onProgressEvent() : void
		{
			var l1 : ILoader = new TextLoader(new URLRequest(_path + "testTXT.txt"));
			var l2 : ILoader = new ImageLoader(new URLRequest(_path + "testIMAGE.png"));

			_monitor.add(l1);
			_monitor.add(l2);
			
			_monitor.addEventListener(AssetLoaderProgressEvent.PROGRESS, Async.asyncHandler(this, onProgress_handler, 500, {l1:l1, l2:l2}, onProgress_handlerFailed), false, 0, true);
			
			//only tell the one loader to start, because we are checking the passed loader's value within handler.
			l1.start();
		}

		protected function onProgress_handler(event : AssetLoaderProgressEvent, data:Object) : void
		{
			assertNotNull("#loader should NOT be null", event.statsLoaderTarget);
			assertEquals("#loader should equal", data.l1, event.statsLoaderTarget);
			
			assertTrue("ProgressSignal#latency should be more or equal than 0", event.latency >= 0);
			assertTrue("ProgressSignal#speed should be more or equal than 0", event.speed >= 0);
			assertTrue("ProgressSignal#averageSpeed should be more or equal than 0", event.averageSpeed >= 0);

			assertTrue("ProgressSignal#progress should be more or equal than 0", event.progress >= 0);
			assertTrue("ProgressSignal#bytesLoaded should be more or equal than 0", event.bytesLoaded >= 0);
			assertTrue("ProgressSignal#bytesTotal should be more than 0", event.bytesTotal);
		}
		
		protected function onProgress_handlerFailed(event:AssetLoaderProgressEvent, data:Object) : void
		{
			data;
			fail("#onProgressEvent timeout");
		}
		
		[Test (async)]
		public function onCompleteEvent() : void
		{
			var l1 : ILoader = new TextLoader(new URLRequest(_path + "testTXT.txt"));
			var l2 : ILoader = new ImageLoader(new URLRequest(_path + "testIMAGE.png"));

			_monitor.add(l1);
			_monitor.add(l2);
			
			_monitor.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onComplete_handler, 500, {l1:l1, l2:l2}, onComplete_handlerFailed), false, 0, true);
			
			//Tell both to start, otherwise onComplete will not fire.
			l1.start();
			l2.start();
		}

		protected function onComplete_handler(event:AssetLoaderEvent, data:Object):void
		{
			data;
			assertNull("LoaderSignal#loader should be null", event.statsLoaderTarget);
			assertNotNull("stats NOT be null", event.stats);
			assertTrue("stats should be ILoadStats", (event.stats is ILoadStats));
		}
		
		protected function onComplete_handlerFailed(event:AssetLoaderProgressEvent, data:Object) : void
		{
			data;
			fail("#onCompleteEvent timeout");
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// INTERNAL
		// --------------------------------------------------------------------------------------------------------------------------------//
		protected function dummy_onOpen_handler(event:AssetLoaderEvent) : void
		{
		}

		protected function dummy_onProgress_handler(event:AssetLoaderProgressEvent) : void
		{
		}

		protected function dummy_onComplete_handler(event:AssetLoaderEvent) : void
		{
		}
	}
}
