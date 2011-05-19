package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;

	import flash.net.URLRequest;


	public class JSONLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();

			_loaderName = "ImageLoader";
			_payloadType = Object;
			_payloadTypeName = "Object";
			_payloadPropertyName = "jsonObject";
			_path += "testJSON.json";
			_type = AssetType.JSON;

			_loader = new JSONLoader(new URLRequest(_path), _id);
		}
	}
}
