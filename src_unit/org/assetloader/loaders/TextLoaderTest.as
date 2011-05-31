package org.assetloader.loaders {

	import flash.net.URLRequest;
	import org.assetloader.base.AssetType;



	public class TextLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();

			_loaderName = "TextLoader";
			_payloadType = String;
			_payloadTypeName = "String";
			_payloadPropertyName = "text";
			_path += "testTXT.txt";
			_type = AssetType.TEXT;

			_loader = new TextLoader(new URLRequest(_path), _id);
		}
	}
}
