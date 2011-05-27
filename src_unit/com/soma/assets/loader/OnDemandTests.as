package com.soma.assets.loader {

	import com.soma.assets.loader.base.Param;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import com.soma.assets.loader.events.AssetLoaderEvent;
	import com.soma.assets.loader.core.IAssetLoader;


	/**
	 * @author Romuald
	 */
	public class OnDemandTests {

		private static var _configXML:XML;
		
		protected var _loader:IAssetLoader;
		
		[BeforeClass]
		public static function runBeforeClass():void {
			_configXML = 
			<loader connections="3">
				<asset id="swf" src="assets/test/testSWF.swf"/>
				<asset id="sound" src="assets/test/testSOUND.mp3" onDemand="true"/>
				<group id="group0">
					<asset id="img" src="assets/test/testIMAGE.png"/>
					<asset id="zip" src="assets/test/testZIP.zip"/>
				</group>
				<group id="group1" onDemand="true">
					<group id="group1a">
						<asset id="css" src="assets/test/testCSS.css"/>
					</group>
					<group id="group1b"onDemand="true">
						<asset id="video" src="assets/test/testVIDEO.flv"/>
					</group>
				</group>
			</loader>;
		}
		
		[AfterClass]
		public static function runAfterClass():void {
			
		} 
		
		[Before]
		public function runBeforeEachTest() : void {
			_loader = new AssetLoader();
			_loader.addConfig(_configXML);
		}

		[Before]
		public function runAfterEachTest() : void {
		}
	
		[Test(async)]
		public function testGroupDemanded():void {
			_loader.getLoader("group0").addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, testGroupDemandedSuccess, 500, null, testGroupDemandedFailed));
			_loader.start();
		}

		private function testGroupDemandedSuccess(event:AssetLoaderEvent, data:*):void {
			data;
			assertTrue(_loader.getLoader("group0").loaded);
			assertNotNull(_loader.getLoader("group0").data);
		}

		private function testGroupDemandedFailed(event:AssetLoaderEvent):void {
			fail("testGroupDemanded time out");
		}

		[Test(async)]
		public function testGroupNonDemandedNotLoaded():void {
			_loader.getLoader("group1").addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, testGroupNonDemandedNotFailed, 500, null, testGroupNonDemandedNotLoadedSuccess));
			_loader.start();
		}

		private function testGroupNonDemandedNotLoadedSuccess(event:AssetLoaderEvent):void {
			assertFalse(_loader.getLoader("group1").loaded);
			assertFalse(_loader.getLoader("group1").invoked);
			assertFalse(_loader.getLoader("group1").inProgress);
			assertNull(_loader.getLoader("group1").data);
		}

		private function testGroupNonDemandedNotFailed(event:AssetLoaderEvent, data:*):void {
			data;
			fail("testGroupNonDemandedNotLoaded group1 should have not been loaded");
		}

		[Test(async)]
		public function testGroupNonDemandedLoaded():void {
			assertFalse(_loader.getLoader("swf").getParam(Param.ON_DEMAND));
			assertTrue(_loader.getLoader("sound").getParam(Param.ON_DEMAND));
			assertFalse(_loader.getLoader("group0").getParam(Param.ON_DEMAND));
			assertTrue(_loader.getLoader("group1").getParam(Param.ON_DEMAND));
			assertFalse(IAssetLoader(_loader.getLoader("group1")).getLoader("group1a").getParam(Param.ON_DEMAND));
			assertTrue(IAssetLoader(_loader.getLoader("group1")).getLoader("group1b").getParam(Param.ON_DEMAND));
			_loader.getLoader("group0").addEventListener(AssetLoaderEvent.COMPLETE, onGroup0Loaded);
			IAssetLoader(_loader.getLoader("group1")).getLoader("group1a").addEventListener(AssetLoaderEvent.COMPLETE, onGroup1aLoaded);
			_loader.getLoader("group1").addEventListener(AssetLoaderEvent.COMPLETE, onGroup1Loaded);
			_loader.addEventListener(AssetLoaderEvent.COMPLETE, Async.asyncHandler(this, testGroupNonDemandedLoadedSuccess, 500, null, testGroupNonDemandedLoadedFailed));
			_loader.start();
		}

		public function onGroup0Loaded(event:AssetLoaderEvent):void {
			_loader.getLoader("group1").start();
		}
		
		public function onGroup1aLoaded(event:AssetLoaderEvent):void {
			IAssetLoader(_loader.getLoader("group1")).getLoader("group1b").start();
		}
		
		private function onGroup1Loaded(event:AssetLoaderEvent):void {
			_loader.getLoader("sound").start();
		}

		private function testGroupNonDemandedLoadedSuccess(event:AssetLoaderEvent, data:*):void {
			data;
		}

		private function testGroupNonDemandedLoadedFailed(event:AssetLoaderEvent):void {
			fail("testGroupNonDemandedLoaded time out");
		}

	}
}
