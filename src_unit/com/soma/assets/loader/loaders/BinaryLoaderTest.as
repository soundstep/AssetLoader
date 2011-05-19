package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;

	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class BinaryLoaderTest extends BaseLoaderTest
	{
		[Before]
		override public function runBeforeEachTest() : void
		{
			super.runBeforeEachTest();
			
			_loaderName = "BinaryLoader";
			_payloadType = ByteArray;
			_payloadTypeName = "ByteArray";
			_payloadPropertyName = "bytes";
			_path += "testZIP.zip";
			_type = AssetType.BINARY;

			_loader = new BinaryLoader(new URLRequest(_path), _id);
		}
	}
}
