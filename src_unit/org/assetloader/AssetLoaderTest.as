package org.assetloader {

	import flash.utils.Dictionary;
	import org.assetloader.base.AssetType;
	import org.assetloader.base.Param;
	import org.assetloader.core.IAssetLoader;
	import org.assetloader.core.ILoader;
	import org.assetloader.events.AssetLoaderErrorEvent;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.events.AssetLoaderHTTPStatusEvent;
	import org.assetloader.loaders.BaseLoaderTest;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;




	/**
	 * @author Matan Uberstein
	 */
	public class AssetLoaderTest extends BaseLoaderTest
	{
		protected var _assetloader : IAssetLoader;

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
	}
}
