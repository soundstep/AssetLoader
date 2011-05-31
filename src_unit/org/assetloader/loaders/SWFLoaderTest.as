package org.assetloader.loaders {

	import flash.display.Sprite;
	import flash.net.URLRequest;
	import org.assetloader.base.AssetType;



	public class SWFLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();

			_loaderName = "SWFLoader";
			_payloadType = Sprite;
			_payloadTypeName = "Sprite";
			_payloadPropertyName = "swf";
			_path += "testSWF.swf";
			_type = AssetType.SWF;

			_loader = new SWFLoader(new URLRequest(_path), _id);
		}
	}
}
