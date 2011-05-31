package org.assetloader.loaders {

	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import org.assetloader.base.AssetType;



	public class ImageLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();
			
			_loaderName = "ImageLoader";
			_payloadType = Bitmap;
			_payloadTypeName = "Bitmap";
			_payloadPropertyName = "bitmap";
			_path += "testIMAGE.png";
			_type = AssetType.IMAGE;

			_loader = new ImageLoader(new URLRequest(_path), _id);
		}
	}
}
