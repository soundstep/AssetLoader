package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;

	import flash.net.URLRequest;
	import flash.text.StyleSheet;


	public class CSSLoaderTest extends BaseLoaderTest
	{

		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();
			
			_loaderName = "CSSLoader";
			_payloadType = StyleSheet;
			_payloadTypeName = "StyleSheet";
			_payloadPropertyName = "styleSheet";
			_path += "testCSS.css";
			_type = AssetType.CSS;

			_loader = new CSSLoader(new URLRequest(_path), _id);
		}
	}
}
