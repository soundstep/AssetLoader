package org.assetloader {

	import org.assetloader.base.AssetType;
	import org.assetloader.base.Param;
	import org.assetloader.base.StatsMonitor;
	import org.assetloader.core.IAssetLoader;
	import org.assetloader.core.ILoader;
	import org.assetloader.events.AssetLoaderErrorEvent;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.events.AssetLoaderHTTPStatusEvent;
	import org.assetloader.loaders.BaseLoaderTest;
	import org.assetloader.loaders.TextLoader;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;

	import flash.net.URLRequest;
	import flash.utils.Dictionary;




	/**
	 * @author Matan Uberstein
	 */
	public class AssetLoaderTest extends BaseLoaderTest
	{
		protected var _assetloader : IAssetLoader;
		protected var _foreignLoader : ILoader;

		[Before]
		override public function runBeforeEachTest() : void
		{
			_loaderName = "AssetLoader";
			_payloadType = Dictionary;
			_payloadTypeName = "Dictionary";
			_payloadPropertyName = "data";
			_type = AssetType.GROUP;

			_id = "PrimaryLoaderGroup";

			_loader = _assetloader = new AssetLoader(_id);
			_assetloader.setParam(Param.BASE, _path);

			_assetloader.addLazy("id-01", "testCSS.css");
			_assetloader.addLazy("id-02", "testIMAGE.png");
			_assetloader.addLazy("id-03", "testJSON.json");
			_assetloader.addLazy("id-04", "testSOUND.mp3");
			_assetloader.addLazy("id-05", "testSWF.swf");
			_assetloader.addLazy("id-06", "testTXT.txt");
			_assetloader.addLazy("id-07", "testVIDEO.flv");
			_assetloader.addLazy("id-08", "testXML.xml");
			_assetloader.addLazy("id-09", "testZIP.zip");
		}

		[After]
		override public function runAfterEachTest() : void
		{
			super.runAfterEachTest();

			if(_foreignLoader)
			{
				_foreignLoader.destroy();
				_foreignLoader = null;
			}
		}

		[Test]
		override public function implementing() : void
		{
			super.implementing();
			assertTrue("AssetLoader should implement IAssetLoader", _loader is IAssetLoader);
		}

		[Test (async)]
		override public function booleanStateAfterError() : void
		{
			// Change url to force error signal.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";
			
			_loader.addEventListener(AssetLoaderErrorEvent.ERROR, Async.asyncHandler(this, onError_booleanStateAfterError_handler, 500));
			_loader.start();
		}
		
		override protected function onError_booleanStateAfterError_handler(event : AssetLoaderErrorEvent, data : Object) : void
		{
			data;
			assertEquals(_loaderName + "#invoked state after loading error", true, _loader.invoked);
			// inProgress will be true for this IAssetLoader, because it will still continue loader the other assets.
			assertEquals(_loaderName + "#inProgress state after loading error", true, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after loading error", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after loading error", false, _loader.loaded);
			// although the not all the child loader have failed, failed is flaged is true. Loosing one asset should be seen as failure.
			assertEquals(_loaderName + "#failed state after loading error", true, _loader.failed);
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// STATE
		// --------------------------------------------------------------------------------------------------------------------------------//
		[Test]
		public function stateAfterAdd() : void
		{
			assertNotNull(_loaderName + "#ids should not be null", _assetloader.ids);
			assertNotNull(_loaderName + "#loadedIds should not be null", _assetloader.loadedIds);
			assertNotNull(_loaderName + "#failedIds should not be null", _assetloader.failedIds);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 0, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 0, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// STATE - FOREIGN CHILD
		// --------------------------------------------------------------------------------------------------------------------------------//

		[Test]
		public function stateAfterForeignChildAdded() : void
		{
			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");

			_assetloader.addLoader(_foreignLoader);

			assertEquals(_loaderName + "#invoked state after foreign child added", false, _loader.invoked);
			assertEquals(_loaderName + "#inProgress after foreign child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after foreign child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after foreign child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after foreign child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 10, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 0, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 10, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 0, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", "foreignChild", _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}
		
		[Test]
		public function stateAfterForeignChildRemoved() : void
		{
			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");

			_assetloader.addLoader(_foreignLoader);
			_assetloader.remove("foreignChild");

			assertEquals(_loaderName + "#invoked state after foreign child added", false, _loader.invoked);
			assertEquals(_loaderName + "#inProgress after foreign child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after foreign child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after foreign child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after foreign child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 0, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 0, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", undefined, _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}

		[Test (async)]
		public function stateAfterForeignLoadedChildAdded() : void
		{
			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");
			Async.handleEvent(this, _foreignLoader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterForeignLoadedChildAdded_handler);
			_foreignLoader.start();
		}

		protected function onComplete_stateAfterForeignLoadedChildAdded_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(event.currentTarget as ILoader);

			assertEquals(_loaderName + "#invoked state after foreign loaded child added", false, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after foreign loaded child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after foreign loaded child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after foreign loaded child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after foreign loaded child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 10, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 1, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 10, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 1, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", "foreignChild", _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") != -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNotNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}
		
		[Test (async)]
		public function stateAfterForeignLoadedChildRemoved() : void
		{
			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");

			Async.handleEvent(this, _foreignLoader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterForeignLoadedChildRemoved_handler);
			_foreignLoader.start();
		}

		protected function onComplete_stateAfterForeignLoadedChildRemoved_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(event.currentTarget as ILoader);
			_assetloader.remove("foreignChild");

			assertEquals(_loaderName + "#invoked state after foreign loaded child added", false, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after foreign loaded child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after foreign loaded child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after foreign loaded child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after foreign loaded child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 0, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 0, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", undefined, _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}

		[Test (async)]
		public function stateAfterLoadAndForeignChildAdded() : void
		{
			Async.handleEvent(this, _assetloader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignChildAdded_handler);
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignChildAdded_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");
			_assetloader.addLoader(_foreignLoader);

			assertEquals(_loaderName + "#invoked state after load complete and then foreign child added", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 10, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 10, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", "foreignChild", _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}
		
		[Test (async)]
		public function stateAfterLoadAndForeignChildRemoved() : void
		{
			Async.handleEvent(this, _assetloader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignChildRemoved_handler);
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignChildRemoved_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");
			_assetloader.addLoader(_foreignLoader);
			_assetloader.remove("foreignChild");

			assertEquals(_loaderName + "#invoked state after load complete and then foreign child added", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", undefined, _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}

		[Test (async)]
		public function stateAfterLoadAndForeignLoadedChildAdded() : void
		{
			var monitor : StatsMonitor = new StatsMonitor();

			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");

			monitor.add(_foreignLoader);
			monitor.add(_assetloader);

			Async.handleEvent(this, monitor, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignLoadedChildAdded_handler);

			_foreignLoader.start();
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignLoadedChildAdded_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(_foreignLoader);

			assertEquals(_loaderName + "#invoked state after load complete and then foreign loaded child added", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign loaded child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign loaded child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign loaded child added", true, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign loaded child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 10, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 10, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 10, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 10, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", "foreignChild", _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") != -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNotNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}
		
		[Test (async)]
		public function stateAfterLoadAndForeignLoadedChildRemoved() : void
		{
			var monitor : StatsMonitor = new StatsMonitor();

			_foreignLoader = new TextLoader(new URLRequest(_path + "testTXT.txt"), "foreignChild");

			monitor.add(_foreignLoader);
			monitor.add(_assetloader);

			Async.handleEvent(this, monitor, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignLoadedChildRemoved_handler);

			_foreignLoader.start();
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignLoadedChildRemoved_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(_foreignLoader);
			_assetloader.remove("foreignChild");

			assertEquals(_loaderName + "#invoked state after load complete and then foreign loaded child added", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign loaded child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign loaded child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign loaded child added", true, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign loaded child added", false, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", undefined, _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}

		[Test (async)]
		public function stateAfterLoadAndForeignFailedChildAdded() : void
		{
			_foreignLoader = new TextLoader(new URLRequest(_path + "DOES-NOT-EXIST.file"), "foreignChild");

			Async.handleEvent(this, _assetloader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignFailedChildAdded_handler);

			// Foreign Loader should fail before Assetloader dispatches complete.
			_foreignLoader.start();
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignFailedChildAdded_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(_foreignLoader);

			assertEquals(_loaderName + "#invoked state after load complete and then foreign failed child added", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign failed child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign failed child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign failed child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign failed child added", true, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 10, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 1, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 10, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 1, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", "foreignChild", _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") != -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}
		
		[Test (async)]
		public function stateAfterLoadAndForeignFailedChildRemoved() : void
		{
			_foreignLoader = new TextLoader(new URLRequest(_path + "DOES-NOT-EXIST.file"), "foreignChild");

			Async.handleEvent(this, _assetloader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignFailedChildRemoved_handler);

			// Foreign Loader should fail before Assetloader dispatches complete.
			_foreignLoader.start();
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignFailedChildRemoved_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(_foreignLoader);
			_assetloader.remove("foreignChild");

			assertEquals(_loaderName + "#invoked state after load complete and then foreign failed child added", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign failed child added", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign failed child added", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign failed child added", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign failed child added", true, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", undefined, _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}

		[Test (async)]
		public function stateAfterLoadAndForeignFailedChildAdded2() : void
		{
			_assetloader.failOnError = false;

			_foreignLoader = new TextLoader(new URLRequest(_path + "DOES-NOT-EXIST.file"), "foreignChild");

			Async.handleEvent(this, _assetloader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignFailedChildAdded2_handler);

			// Foreign Loader should fail before Assetloader dispatches complete.
			_foreignLoader.start();
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignFailedChildAdded2_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(_foreignLoader);

			assertEquals(_loaderName + "#invoked state after load complete and then foreign failed child added with failOnError=false", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign failed child added with failOnError=false", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign failed child added with failOnError=false", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign failed child added with failOnError=false", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign failed child added with failOnError=false", true, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 10, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 1, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 10, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 1, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", "foreignChild", _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") != -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}
		
		[Test (async)]
		public function stateAfterLoadAndForeignFailedChildRemoved2() : void
		{
			_assetloader.failOnError = false;

			_foreignLoader = new TextLoader(new URLRequest(_path + "DOES-NOT-EXIST.file"), "foreignChild");
			
			Async.handleEvent(this, _assetloader, AssetLoaderEvent.COMPLETE, onComplete_stateAfterLoadAndForeignFailedChildRemoved2_handler);

			// Foreign Loader should fail before Assetloader dispatches complete.
			_foreignLoader.start();
			_assetloader.start();
		}

		protected function onComplete_stateAfterLoadAndForeignFailedChildRemoved2_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			_assetloader.addLoader(_foreignLoader);
			_assetloader.remove("foreignChild");

			assertEquals(_loaderName + "#invoked state after load complete and then foreign failed child added with failOnError=false", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after load complete and then foreign failed child added with failOnError=false", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after load complete and then foreign failed child added with failOnError=false", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after load complete and then foreign failed child added with failOnError=false", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after load complete and then foreign failed child added with failOnError=false", true, _loader.failed);

			assertEquals(_loaderName + "#ids.length", 9, _assetloader.ids.length);
			assertEquals(_loaderName + "#loadedIds.length", 9, _assetloader.loadedIds.length);
			assertEquals(_loaderName + "#failedIds.length", 0, _assetloader.failedIds.length);

			assertEquals(_loaderName + "#numLoaders", 9, _assetloader.numLoaders);
			assertEquals(_loaderName + "#numLoaded", 9, _assetloader.numLoaded);
			assertEquals(_loaderName + "#numFailed", 0, _assetloader.numFailed);

			for(var i : int = 0; i < 9; i++)
			{
				var id : String = "id-0" + (i + 1);
				assertEquals(_loaderName + "#ids[" + i + "]", id, _assetloader.ids[i]);
				assertNotNull(_loaderName + "#getAsset(" + id + ")", _assetloader.getAsset(id));
			}
			assertEquals(_loaderName + "#ids[9]", undefined, _assetloader.ids[9]);
			assertTrue(_loaderName + "#loadedIds.indexOf(foreignChild)", _assetloader.loadedIds.indexOf("foreignChild") == -1);
			assertTrue(_loaderName + "#failedIds.indexOf(foreignChild)", _assetloader.failedIds.indexOf("foreignChild") == -1);
			assertNull(_loaderName + "#getAsset(foreignChild)", _assetloader.getAsset("foreignChild"));
		}

		[Test (async)]
		public function onChildCompleteEvent() : void
		{
			_assetloader.addEventListener(AssetLoaderEvent.CHILD_COMPLETE, Async.asyncHandler(this, onChildCompleteSignal_handler, 500));
			_assetloader.start();
		}

		protected function onChildCompleteSignal_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			assertTrue("Argument 2 should be ILoader", (event.currentTarget is ILoader));
			assertNotNull("#loader should NOT be null", event.currentTarget);
		}

		[Test (async)]
		public function onChildOpenSignal() : void
		{
			_assetloader.addEventListener(AssetLoaderEvent.CHILD_OPEN, Async.asyncHandler(this, onChildOpen_handler, 500));
			_loader.start();
		}

		protected function onChildOpen_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			assertTrue("Argument 2 should be ILoader", (event.currentTarget is ILoader));
			assertNotNull("#loader should NOT be null", event.currentTarget);
		}

		[Test (async)]
		override public function onErrorEventIntended() : void
		{
			// Change url to force error signal.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";
			_assetloader.addEventListener(AssetLoaderErrorEvent.ERROR, Async.asyncHandler(this, onErrorIntended_handler, 500));
			_loader.start();
		}

		override protected function onErrorIntended_handler(event : AssetLoaderErrorEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
			assertNotNull("#type should NOT be null", event.errorType);
			assertNotNull("#message should NOT be null", event.message);
		}

		[Test (async)]
		public function onChildErrorEvent() : void
		{
			_assetloader.addEventListener(AssetLoaderErrorEvent.CHILD_ERROR, Async.asyncHandler(this, onChildErrorEvent_handler, 500, null, onChildErrorEvent_handlerSuccess));
			_assetloader.start();
		}

		protected function onChildErrorEvent_handler(event : AssetLoaderErrorEvent, data : *) : void
		{
			data;
			fail("Error [type: " + event.errorType + "] | [message: " + event.message + "]");
		}

		protected function onChildErrorEvent_handlerSuccess(event : AssetLoaderErrorEvent) : void
		{
			
		}

		[Test (async)]
		public function onChildErrorEventIntended() : void
		{
			// Change url to force error signal.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";
			_assetloader.addEventListener(AssetLoaderErrorEvent.CHILD_ERROR, Async.asyncHandler(this, onChildErrorEventIntended_handler, 500));
			_assetloader.start();
		}

		protected function onChildErrorEventIntended_handler(event : AssetLoaderErrorEvent, data : Object) : void
		{
			data;
			assertTrue("Argument 2 should be ILoader", (event.currentTarget is ILoader));
			assertNotNull("#loader should NOT be null", event.currentTarget);
			assertNotNull("#type should NOT be null", event.errorType);
			assertNotNull("#message should NOT be null", event.message);
		}

		[Test (async)]
		override public function onHttpStatusEvent() : void
		{
			_loader.addEventListener(AssetLoaderHTTPStatusEvent.STATUS, Async.asyncHandler(this, onHttpStatusEventFailed, 500, null, onHttpStatusEventSuccess));
			_loader.start();
		}

		private function onHttpStatusEventSuccess(event:AssetLoaderHTTPStatusEvent):void {
			
		}

		private function onHttpStatusEventFailed(event:AssetLoaderHTTPStatusEvent, data:Object):void {
			data;
			fail("http status event should not be called");
		}

		[Test (async)]
		public function onConfigLoadedEvent() : void
		{
			_assetloader.addEventListener(AssetLoaderEvent.CONFIG_LOADED, Async.asyncHandler(this, onConfigLoadedEvent_handler, 500));
			_assetloader.addConfig(_path + "testXML.xml");
		}

		protected function onConfigLoadedEvent_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
			assertNotNull("#loader should NOT be null", IAssetLoader(event.currentTarget).config);
			assertTrue("#loader should NOT be null", IAssetLoader(event.currentTarget).config is XML);
		}
		
		[Test (async)]
		public function onCompleteEventWithError() : void
		{
			// Change url to force error event.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";
			
			_assetloader.failOnError = false;
			
			// onComplete must dispatch regardless of child error
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onComplete_handler, 500));
			_loader.start();
		}

		protected function onCompleteWithError_handler(event : AssetLoaderEvent, data : Object) : void
		{
			super.onComplete_handler(event, data);
			assertEquals(_loaderName + "#loaded state after loading complete with error", true, _loader.loaded);
			assertEquals(_loaderName + "#failed state after loading complete with error", true, _loader.failed);
		}
		
		[Test (async)]
		public function onCompleteSignalWithErrorAndFailOnErrorSetToTrue() : void
		{
			// Change url to force error signal.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";
			
			_assetloader.failOnError = true;
			
			// onComplete must NOT dispatch, because flag is set to true.
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onCompleteSignalWithErrorAndFailOnErrorSetToTrueFailed, 500, null, onCompleteSignalWithErrorAndFailOnErrorSetToTrueSuccess));
			_loader.start();
		}
		
		protected function onCompleteSignalWithErrorAndFailOnErrorSetToTrueFailed(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			fail("FAIL onCompleteSignalWithErrorAndFailOnErrorSetToTrue complete dispatched");
		}
		
		protected function onCompleteSignalWithErrorAndFailOnErrorSetToTrueSuccess(event : AssetLoaderEvent) : void
		{
			assertEquals(_loaderName + "#loaded state after loading complete with error", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after loading complete with error", true, _loader.failed);
		}

		[Test (async)]
		public function proceedWithQueueWithErrorAndFailOnErrorSetToFalse() : void
		{
			// Change url to force error signal.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";

			_assetloader.numConnections = 1;
			_assetloader.failOnError = false;

			Async.proceedOnEvent(this, _assetloader.getLoader("id-02"), AssetLoaderEvent.COMPLETE);
			
			
			_loader.start();
		}

		[Test (async)]
		public function proceedWithQueueWithErrorAndFailOnErrorSetToTrue() : void
		{
			// Change url to force error signal.
			_assetloader.getLoader("id-01").request.url = _path + "DOES-NOT-EXIST.file";

			_assetloader.numConnections = 1;
			_assetloader.failOnError = true;

			Async.proceedOnEvent(this, _assetloader.getLoader("id-02"), AssetLoaderEvent.COMPLETE);
			_loader.start();
		}
	}
}
