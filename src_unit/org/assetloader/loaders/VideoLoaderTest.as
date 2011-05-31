package org.assetloader.loaders {

	import flash.net.NetStream;
	import flash.net.URLRequest;
	import org.assetloader.base.AssetType;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.events.AssetLoaderHTTPStatusEvent;
	import org.assetloader.events.AssetLoaderNetStatusEvent;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;




	public class VideoLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();

			_loaderName = "VideoLoader";
			_payloadType = NetStream;
			_payloadTypeName = "NetStream";
			_payloadPropertyName = "netStream";
			// Make sure video is an FLV, flash player does not allow local loading of mp4 file format.
			_path += "testVIDEO.flv";
			_type = AssetType.VIDEO;

			_loader = new VideoLoader(new URLRequest(_path), _id);
		}

		// NON - STANDARD - LOADER - TESTS -------------------------------------------------------------------------------------------//

		[Test (async)]
		public function onNetStatusEvent() : void
		{
			_loader.addEventListener(AssetLoaderNetStatusEvent.INFO, Async.asyncHandler(this, onNetStatus_handler, 500));
			_loader.start();
		}

		protected function onNetStatus_handler(event : AssetLoaderNetStatusEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
			assertNotNull("#info should NOT be null", event.info);
		}

		[Test (async)]
		public function onReadyEvent() : void
		{
			_loader.addEventListener(AssetLoaderEvent.NET_STREAM_READY, Async.asyncHandler(this, onReady_handler, 500));
			_loader.start();
		}

		protected function onReady_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("LoaderSignal#loader should NOT be null", event.currentTarget);
		}

		// VIDEO LOADER DOES NOT DISPATCH HTTP STATUS SIGNAL
		[Test (async)]
		override public function onHttpStatusEvent() : void
		{
			_loader.addEventListener(AssetLoaderHTTPStatusEvent.STATUS, Async.asyncHandler(this, onHttpStatusEventFailed, 500, null, onHttpStatusEventSuccess));
			_loader.start();
		}

		private function onHttpStatusEventSuccess(event:AssetLoaderEvent):void {
		}

		private function onHttpStatusEventFailed(event:AssetLoaderEvent, data:Object):void {
			data;
			fail("onHttpStatusEvent should not be called");
		}

		[Test (async)]
		override public function stop() : void
		{
			_loader.addEventListener(AssetLoaderNetStatusEvent.INFO, Async.asyncHandler(this, onStopNetStatusEventFailed, 500, null, onStopNetStatusEventSuccess));
			_loader.addEventListener(AssetLoaderEvent.NET_STREAM_READY, Async.asyncHandler(this, onStopReadyEventFailed, 500, null, onStopReadyEventSuccess));
			super.stop();
		}
		
		private function onStopNetStatusEventFailed(event:AssetLoaderEvent, data:Object):void {
			data;
			fail("net status event should not occur after a stop");
		}

		private function onStopNetStatusEventSuccess(event:AssetLoaderEvent):void {
			
		}
		
		private function onStopReadyEventFailed(event:AssetLoaderEvent, data:Object):void {
			data;
			fail("net stream ready event should not occur after a stop");
		}

		private function onStopReadyEventSuccess(event:AssetLoaderEvent):void {
			
		}
	}
}
