package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;

	import flash.net.URLRequest;


	public class XMLLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();

			_loaderName = "XMLLoader";
			_payloadType = XML;
			_payloadTypeName = "XML";
			_payloadPropertyName = "xml";
			_path += "testXML.xml";
			_type = AssetType.XML;

			_loader = new XMLLoader(new URLRequest(_path), _id);
		}
	}
}
