package org.assetloader.loaders {

	import flash.events.Event;
	import org.assetloader.AssetLoader;
	import org.assetloader.base.AbstractLoaderTest;
	import org.assetloader.base.Param;
	import org.assetloader.core.IAssetLoader;
	import org.assetloader.events.AssetLoaderErrorEvent;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.events.AssetLoaderHTTPStatusEvent;
	import org.assetloader.events.AssetLoaderProgressEvent;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;



	public class BaseLoaderTest extends AbstractLoaderTest
	{
		protected var _payloadType : Class ;
		protected var _payloadTypeName : String;
		protected var _payloadPropertyName : String;

		protected var _path : String = "assets/test/";

		protected var _hadParent : Boolean = false;

		[BeforeClass]
		public static function runBeforeEntireSuite() : void
		{
		}

		[AfterClass]
		public static function runAfterEntireSuite() : void
		{
		}

		[Before]
		override public function runBeforeEachTest() : void
		{
			_hadRequest = true;
		}

		[After]
		override public function runAfterEachTest() : void
		{
			super.runBeforeEachTest();
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// BOOLEAN STATES
		// --------------------------------------------------------------------------------------------------------------------------------//

		[Test]
		public function booleanStateBeforeLoad() : void
		{
			assertEquals(_loaderName + "#invoked state before loading starts", false, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state before loading starts", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state before loading starts", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state before loading starts", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state before loading starts", false, _loader.failed);
		}

		[Test (async)]
		public function booleanStateDuringLoad() : void
		{
			_loader.addEventListener(AssetLoaderEvent.OPEN, Async.asyncHandler(this, onOpen_booleanStateDuringLoad_handler, 500));
			_loader.start();
		}

		protected function onOpen_booleanStateDuringLoad_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertEquals(_loaderName + "#invoked state during loading", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state during loading", true, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state during loading", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state during loading", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state during loading", false, _loader.failed);
		}

		[Test]
		public function booleanStateAfterStoppedLoad() : void
		{
			_loader.start();
			_loader.stop();
			assertEquals(_loaderName + "#invoked state after loading stopped", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after loading stopped", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after loading stopped", true, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after loading stopped", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after loading stopped", false, _loader.failed);
		}

		[Test (async)]
		public function booleanStateAfterLoad() : void
		{
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onComplete_booleanStateAfterLoad_handler, 500));
			_loader.start();
		}

		protected function onComplete_booleanStateAfterLoad_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertEquals(_loaderName + "#invoked state after loading completed", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after loading completed", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after loading completed", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after loading completed", true, _loader.loaded);
			assertEquals(_loaderName + "#failed state after loading completed", false, _loader.failed);
		}

		[Test (async)]
		public function booleanStateAfterError() : void
		{
			// Change url to force error signal.
			_loader.request.url = _path + "DOES-NOT-EXIST.file";
			_loader.addEventListener(AssetLoaderErrorEvent.ERROR, Async.asyncHandler(this, onError_booleanStateAfterError_handler, 500));
			_loader.start();
		}

		protected function onError_booleanStateAfterError_handler(event:AssetLoaderErrorEvent, data : Object) : void
		{
			data;
			assertEquals(_loaderName + "#invoked state after loading error", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state after loading error", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state after loading error", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state after loading error", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state after loading error", true, _loader.failed);
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// SPECIAL PARAMS
		// --------------------------------------------------------------------------------------------------------------------------------//
		[Test]
		public function baseParamAdd() : void
		{
			var base : String = "http://www.matanuberstein.co.za/";
			_loader.setParam(Param.BASE, base);

			if(_hadRequest)
				assertEquals(_loaderName + "#request#url should be equal to BASE + _path", base + _path, _loader.request.url);

			assertEquals(_loaderName + " should retain the BASE value", base, _loader.getParam(Param.BASE));
		}

		[Test]
		public function preventCacheParamAdd() : void
		{
			_loader.setParam(Param.PREVENT_CACHE, true);

			if(_hadRequest)
				assertTrue(_loaderName + "#request#url should have the 'ck' url var added.", (_loader.request.url.indexOf("ck=") != -1));

			assertEquals(_loaderName + " should retain the PREVENT_CACHE value", true, _loader.getParam(Param.PREVENT_CACHE));
		}

		[Test]
		public function preventCacheParamRemove() : void
		{
			_loader.setParam(Param.PREVENT_CACHE, true);
			_loader.setParam(Param.PREVENT_CACHE, false);

			if(_hadRequest)
				assertEquals(_loaderName + "#request#url should equal to the original url", _path, _loader.request.url);

			assertEquals(_loaderName + " should retain the PREVENT_CACHE value", false, _loader.getParam(Param.PREVENT_CACHE));
		}

		[Test]
		public function weightParamAdd() : void
		{
			_loader.setParam(Param.WEIGHT, 1024);

			assertEquals(_loaderName + "#stats#bytesTotal should be equal to param value.", 1024, _loader.stats.bytesTotal);
			assertEquals(_loaderName + " should retain the WEIGHT value", 1024, _loader.getParam(Param.WEIGHT));
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// DESTROYING
		// --------------------------------------------------------------------------------------------------------------------------------//
		[Test]
		public function destroyBeforeLoad() : void
		{
			_loader.destroy();

			assertPostDestroy();
		}

		[Test (async)]
		public function destroyDuringLoad() : void
		{
			_loader.addEventListener(AssetLoaderEvent.OPEN, Async.asyncHandler(this, onOpen_destroyDuringLoad_handler, 500));
			_loader.start();
		}

		protected function onOpen_destroyDuringLoad_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			_loader.destroy();
			assertPostDestroy();
		}

		[Test (async)]
		public function destroyAfterLoad() : void
		{
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onComplete_destroyAfterLoad_handler, 500));
			_loader.start();
		}

		protected function onComplete_destroyAfterLoad_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			_loader.destroy();
			assertPostDestroy();
		}

		protected function assertPostDestroy() : void
		{

			assertNotNull(_loaderName + "#type should NOT be null after destroy", _loader.type);
			assertNotNull(_loaderName + "#params should NOT be null after destroy", _loader.params);

			assertNotNull(_loaderName + "#id should be NOT null after destroy", _loader.id);

			if(_hadRequest)
				assertNotNull(_loaderName + "#request should NOT be null after destroy", _loader.request);
			if(_hadParent)
				assertNotNull(_loaderName + "#parent should NOT be null after destroy", _loader.parent);

			assertNull(_loaderName + "#data should be null after destroy", _loader.data);
			assertNull(_loaderName + "#" + _payloadPropertyName + " should be null after destroy", _loader[_payloadPropertyName]);

			assertFalse(_loaderName + "#invoked should be false after destroy", _loader.invoked);
			assertFalse(_loaderName + "#inProgress should be false after destroy", _loader.inProgress);
			assertFalse(_loaderName + "#stopped should be false after destroy", _loader.stopped);
			assertFalse(_loaderName + "#loaded should be false after destroy", _loader.loaded);
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// STOPPING AND STARTING
		// --------------------------------------------------------------------------------------------------------------------------------//
		[Test (async)]
		public function stop() : void
		{
			_loader.start();
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, stopFailed, 500, null, stopSuccess));
			_loader.stop();
			_loader.addEventListener(AssetLoaderEvent.OPEN, Async.asyncHandler(this, stopFailed, 500, null, stopSuccess));
			_loader.addEventListener(AssetLoaderProgressEvent.PROGRESS, Async.asyncHandler(this, stopFailed, 500, null, stopSuccess));
			_loader.addEventListener(AssetLoaderErrorEvent.ERROR, Async.asyncHandler(this, stopFailed, 500, null, stopSuccess));
		}

		private function stopFailed(event:Event, data:Object):void {
			data;
			fail("stop failed" + event.type);
		}

		private function stopSuccess(event:Event):void {
			
		}

		[Test (async)]
		public function restartAfterStop() : void
		{
			_loader.addEventListener(AssetLoaderEvent.OPEN, Async.asyncHandler(this, onOpen_restartAfterStop_handler, 500, null, onOpen_restartAfterStop_handlerFailed));
			_loader.start();
		}

		protected function onOpen_restartAfterStop_handler(event:AssetLoaderEvent, data:Object) : void
		{
			data;
			_loader.stop();
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onComplete_restartAfterStop_handler, 500, null, onComplete_restartAfterStop_handlerFailed));
			_loader.start();
		}

		protected function onOpen_restartAfterStop_handlerFailed(event:AssetLoaderEvent) : void
		{
			fail("restartAfterStop failed on open" + event.type);
		}

		protected function onComplete_restartAfterStop_handler(event:AssetLoaderEvent, data:Object) : void
		{
			data;
		}

		protected function onComplete_restartAfterStop_handlerFailed(event:AssetLoaderEvent) : void
		{
			fail("restartAfterStop failed on complete" + event.type);
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// SIGNALS
		// --------------------------------------------------------------------------------------------------------------------------------//

		[Test (async)]
		public function onCompleteEvent() : void
		{
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, onComplete_handler, 500));
			_loader.start();
		}

		protected function onComplete_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;

			assertNotNull("#loader should NOT be null", event.currentTarget);
			assertNotNull("Second argument should NOT be null", event.data);
			assertTrue("Second argument should be " + _payloadTypeName, (event.data is _payloadType));

			assertNotNull(_loaderName + "#data should NOT be null", _loader.data);
			assertTrue(_loaderName + "#data should be " + _payloadTypeName, (_loader.data is _payloadType));

			assertNotNull(_loaderName + "#" + _payloadPropertyName + " should NOT be null", _loader[_payloadPropertyName]);
			assertTrue(_loaderName + "#" + _payloadPropertyName + " should be " + _payloadTypeName, (_loader[_payloadPropertyName] is _payloadType));

			assertEquals(_loaderName + "#data should be equal to " + _loaderName + "#" + _payloadPropertyName, _loader.data, _loader[_payloadPropertyName]);
		}
		
		[Test (async)]
		public function onStartEvent() : void
		{
			_loader.addEventListener(AssetLoaderEvent.START, Async.asyncHandler(this, onStart_handler, 500));
			_loader.start();
		}

		protected function onStart_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
			
			assertEquals(_loaderName + "#invoked state within onStart handler", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state within onStart handler", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state within onStart handler", false, _loader.stopped);
			assertEquals(_loaderName + "#loaded state within onStart handler", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state within onStart handler", false, _loader.failed);
		}
		
		[Test (async)]
		public function onStoptEvent() : void
		{
			_loader.addEventListener(AssetLoaderEvent.STOP, Async.asyncHandler(this, onStop_handler, 500));
			_loader.start();
			_loader.stop();
		}

		protected function onStop_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
			
			assertEquals(_loaderName + "#invoked state within onStop handler", true, _loader.invoked);
			assertEquals(_loaderName + "#inProgress state within onStop handler", false, _loader.inProgress);
			assertEquals(_loaderName + "#stopped state within onStop handler", true, _loader.stopped);
			assertEquals(_loaderName + "#loaded state within onStop handler", false, _loader.loaded);
			assertEquals(_loaderName + "#failed state within onStop handler", false, _loader.failed);
		}

		[Test (async)]
		public function onAddedToParentEvent() : void
		{
			var assetloader : IAssetLoader = new AssetLoader();
			_loader.addEventListener(AssetLoaderEvent.ADDED_TO_PARENT, Async.asyncHandler(this, onAddedToParent_handler, 500));
			assetloader.addLoader(_loader);
		}

		protected function onAddedToParent_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertTrue("Argument 2 should be IAssetLoader", (event.parent is IAssetLoader));

			assertNotNull("#loader should NOT be null", event.currentTarget);

			assertNotNull(_loaderName + "#parent should NOT be null", _loader.parent);
		}

		[Test (async)]
		public function onRemovedFromParentEvent() : void
		{
			var assetloader : IAssetLoader = new AssetLoader();
			assetloader.addLoader(_loader);
			_loader.addEventListener(AssetLoaderEvent.REMOVED_FROM_PARENT, Async.asyncHandler(this, onRemovedFromParent_handler, 500));
			assetloader.remove(_id);
		}

		protected function onRemovedFromParent_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertTrue("Argument 2 should be IAssetLoader", (event.parent is IAssetLoader));

			assertNotNull("#loader should NOT be null", event.currentTarget);

			assertNull(_loaderName + "#parent should be null", _loader.parent);
		}

		[Test (async)]
		public function onHttpStatusEvent() : void
		{
			_loader.addEventListener(AssetLoaderHTTPStatusEvent.STATUS, Async.asyncHandler(this, onHttpStatus_handler, 500));
			_loader.start();
		}

		protected function onHttpStatus_handler(event : AssetLoaderHTTPStatusEvent, data : Object) : void
		{
			data;
			assertNotNull("HttpStatusSignal#loader should NOT be null", event.currentTarget);
			assertNotNull("HttpStatusSignal#status should NOT be null", event.status);
		}

		[Test (async)]
		public function onOpenEvent() : void
		{
			_loader.addEventListener(AssetLoaderEvent.OPEN, Async.asyncHandler(this, onOpen_handler, 500));
			_loader.start();
		}

		protected function onOpen_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
		}

		[Test (async)]
		public function onProgressEvent() : void
		{
			_loader.addEventListener(AssetLoaderProgressEvent.PROGRESS, Async.asyncHandler(this, onProgress_handler, 500));
			_loader.start();
		}

		protected function onProgress_handler(event : AssetLoaderProgressEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);

			assertTrue("#latency should be more or equal than 0", event.latency >= 0);
			assertTrue("#speed should be more or equal than 0", event.speed >= 0);
			assertTrue("#averageSpeed should be more or equal than 0", event.averageSpeed >= 0);

			assertTrue("#progress should be more or equal than 0", event.progress >= 0);
			assertTrue("#bytesLoaded should be more or equal than 0", event.bytesLoaded >= 0);
			assertTrue("#bytesTotal should be more than 0", event.bytesTotal);
		}

		[Test (async)]
		public function onErrorEventIntended() : void
		{
			// Change url to force error signal.
			_loader.request.url = _path + "DOES-NOT-EXIST.file";

			_loader.addEventListener(AssetLoaderErrorEvent.ERROR, Async.asyncHandler(this, onErrorIntended_handler, 500));
			
			_loader.start();
		}

		protected function onErrorIntended_handler(event : AssetLoaderErrorEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
			assertNotNull("#type should NOT be null", event.errorType);
			assertNotNull("#message should NOT be null", event.message);
		}

		[Test (async)]
		public function onErrorEvent() : void
		{
			_loader.addEventListener(AssetLoaderErrorEvent.ERROR, Async.asyncHandler(this, onError_handler, 500, null, onError_handlerSuccess));
			_loader.start();
		}

		private function onError_handlerSuccess(event : AssetLoaderErrorEvent):void {
			
		}

		protected function onError_handler(event : AssetLoaderErrorEvent, data:Object) : void
		{
			data;
			fail("Error [type: " + event.errorType + "] | [message: " + event.message + "]");
		}
	}
}
