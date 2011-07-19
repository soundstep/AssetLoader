package org.assetloader.loaders {

	import org.assetloader.base.AssetType;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.events.AssetLoaderHTTPStatusEvent;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;

	import flash.media.Sound;
	import flash.net.URLRequest;




	public class SoundLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();

			_loaderName = "SoundLoader";
			_payloadType = Sound;
			_payloadTypeName = "Sound";
			_payloadPropertyName = "sound";
			_path += "testSOUND.mp3";
			_type = AssetType.SOUND;

			_loader = new SoundLoader(new URLRequest(_path), _id);
		}

		// NON - STANDARD - LOADER - TESTS -------------------------------------------------------------------------------------------//

		[Test (async)]
		public function onId3Event() : void
		{
			// Make sure that the mp3 loaded has ID3 data, otherwise this test will fail.
			_loader.addEventListener(AssetLoaderEvent.ID3, Async.asyncHandler(this, onId3_handler, 500));
			_loader.start();
		}

		protected function onId3_handler(event:AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("#loader should NOT be null", event.currentTarget);
		}

		[Test (async)]
		public function onReadyEvent() : void
		{
			_loader.addEventListener(AssetLoaderEvent.SOUND_READY, Async.asyncHandler(this, onReady_handler, 500));
			_loader.start();
		}

		protected function onReady_handler(event : AssetLoaderEvent, data : Object) : void
		{
			data;
			assertNotNull("loader should NOT be null", event.currentTarget);
			assertNotNull("sound in SoundLoader", event.currentTarget.data);
			assertTrue(event.currentTarget.data is Sound);
		}

		// SOUND LOADER DOES NOT DISPATCH HTTP STATUS SIGNAL
		[Test (async)]
		override public function onHttpStatusEvent() : void
		{
			_loader.addEventListener(AssetLoaderHTTPStatusEvent.STATUS, Async.asyncHandler(this, onHttpStatusEventFailed, 500, null, onHttpStatusEventSuccess));
			_loader.start();
		}

		private function onHttpStatusEventFailed(event:AssetLoaderHTTPStatusEvent, data:Object):void {
			data;
			fail("onHttpStatusEvent should not be called");
		}
		
		private function onHttpStatusEventSuccess(event:AssetLoaderHTTPStatusEvent):void {
			
		}
		
		[Test (async)]
		override public function stop() : void
		{
			_loader.addEventListener(AssetLoaderEvent.ID3, Async.asyncHandler(this, onStopID3EventFailed, 500, null, onStopID3EventSuccess));
			super.stop();
		}

		private function onStopID3EventFailed(event:AssetLoaderEvent, data:Object):void {
			data;
			fail("ID3 event should not occur after a stop");
		}

		private function onStopID3EventSuccess(event:AssetLoaderEvent):void {
			
		}
	}
}
