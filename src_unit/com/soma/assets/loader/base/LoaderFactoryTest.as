package com.soma.assets.loader.base {

	import com.soma.assets.loader.AssetLoader;
	import com.soma.assets.loader.core.IAssetLoader;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.loaders.BinaryLoader;
	import com.soma.assets.loader.loaders.CSSLoader;
	import com.soma.assets.loader.loaders.DisplayObjectLoader;
	import com.soma.assets.loader.loaders.ImageLoader;
	import com.soma.assets.loader.loaders.JSONLoader;
	import com.soma.assets.loader.loaders.SWFLoader;
	import com.soma.assets.loader.loaders.SoundLoader;
	import com.soma.assets.loader.loaders.TextLoader;
	import com.soma.assets.loader.loaders.VideoLoader;
	import com.soma.assets.loader.loaders.XMLLoader;

	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;

	import flash.net.URLRequest;


	public class LoaderFactoryTest
	{
		protected var _path : String = "http://www.matan.co.za/AssetLoader/testAssets/";
		protected var _id : String = "test-id";
		protected var _factory : LoaderFactory;
		
		protected var _producedLoader : ILoader;

		[BeforeClass]
		public static function runBeforeEntireSuite() : void
		{
		}

		[AfterClass]
		public static function runAfterEntireSuite() : void
		{
		}

		[Before]
		public function runBeforeEachTest() : void
		{
			_factory = new LoaderFactory();
		}

		[After]
		public function runAfterEachTest() : void
		{
			assertNotNull("Produced loader should NOT be null", _producedLoader);			assertTrue("Produced loader should implement ILoader", (_producedLoader is ILoader));
			
			_factory = null;
			_producedLoader = null;
		}

		[Test]
		public function produceTextType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.TEXT, new URLRequest(_path + "sampleTXT.txt"));
			assertTrue("Produced loader should be an instance of TextLoader", (_producedLoader is TextLoader));
		}

		[Test]
		public function produceJsonType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.JSON, new URLRequest(_path + "sampleJSON.json"));
			assertTrue("Produced loader should be an instance of JSONLoader", (_producedLoader is JSONLoader));
		}

		[Test]
		public function produceXmlType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.XML, new URLRequest(_path + "sampleXML.xml"));
			assertTrue("Produced loader should be an instance of XMLLoader", (_producedLoader is XMLLoader));
		}

		[Test]
		public function produceCssType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.CSS, new URLRequest(_path + "sampleCSS.css"));
			assertTrue("Produced loader should be an instance of CSSLoader", (_producedLoader is CSSLoader));
		}

		[Test]
		public function produceBinaryType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.BINARY, new URLRequest(_path + "sampleZIP.zip"));
			assertTrue("Produced loader should be an instance of BinaryLoader", (_producedLoader is BinaryLoader));
		}

		[Test]
		public function produceDisplayObjectType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.DISPLAY_OBJECT, new URLRequest(_path + "sampleSWF.swf"));
			assertTrue("Produced loader should be an instance of DisplayObjectLoader", (_producedLoader is DisplayObjectLoader));
		}

		[Test]
		public function produceSwfType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.SWF, new URLRequest(_path + "sampleSWF.swf"));
			assertTrue("Produced loader should be an instance of SWFLoader", (_producedLoader is SWFLoader));
		}

		[Test]
		public function produceImageType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.IMAGE, new URLRequest(_path + "sampleIMAGE.jpg"));
			assertTrue("Produced loader should be an instance of ImageLoader", (_producedLoader is ImageLoader));
		}

		[Test]
		public function produceSoundType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.SOUND, new URLRequest(_path + "sampleSOUND.mp3"));
			assertTrue("Produced loader should be an instance of SoundLoader", (_producedLoader is SoundLoader));
		}
		
		[Test]
		public function produceVideoType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.VIDEO, new URLRequest(_path + "sampleVIDEO.mp4"));
			assertTrue("Produced loader should be an instance of VideoLoader", (_producedLoader is VideoLoader));
		}
		
		[Test]
		public function produceGroupType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.GROUP);
			assertTrue("Produced loader should implement IAssetLoader", (_producedLoader is IAssetLoader));
			assertTrue("Produced loader should be an instance of AssetLoader", (_producedLoader is AssetLoader));
		}
		
		//--------------------------------------------------------------------------------------------------------------------------------//
		// AUTO TYPE
		//--------------------------------------------------------------------------------------------------------------------------------//
		
		[Test]
		public function autoProduceTextType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleTXT.txt"));
			assertTrue("Produced loader should be an instance of TextLoader", (_producedLoader is TextLoader));
		}

		[Test]
		public function autoProduceJsonType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleJSON.json"));
			assertTrue("Produced loader should be an instance of JSONLoader", (_producedLoader is JSONLoader));
		}

		[Test]
		public function autoProduceXmlType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleXML.xml"));
			assertTrue("Produced loader should be an instance of XMLLoader", (_producedLoader is XMLLoader));
		}

		[Test]
		public function autoProduceCssType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleCSS.css"));
			assertTrue("Produced loader should be an instance of CSSLoader", (_producedLoader is CSSLoader));
		}

		[Test]
		public function autoProduceBinaryType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleZIP.zip"));
			assertTrue("Produced loader should be an instance of BinaryLoader", (_producedLoader is BinaryLoader));
		}

		[Test]
		public function autoProduceSwfType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleSWF.swf"));
			assertTrue("Produced loader should be an instance of SWFLoader", (_producedLoader is SWFLoader));
		}

		[Test]
		public function autoProduceImageType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleIMAGE.jpg"));
			assertTrue("Produced loader should be an instance of ImageLoader", (_producedLoader is ImageLoader));
		}

		[Test]
		public function autoProduceSoundType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleSOUND.mp3"));
			assertTrue("Produced loader should be an instance of SoundLoader", (_producedLoader is SoundLoader));
		}
		
		[Test]
		public function autoProduceVideoType() : void
		{
			_producedLoader = _factory.produce(_id, AssetType.AUTO, new URLRequest(_path + "sampleVIDEO.mp4"));
			assertTrue("Produced loader should be an instance of VideoLoader", (_producedLoader is VideoLoader));
		}
		
		[Test]
		public function autoProduceGroupType() : void
		{
			_producedLoader = _factory.produce(_id);
			assertTrue("Produced loader should implement IAssetLoader", (_producedLoader is IAssetLoader));
			assertTrue("Produced loader should be an instance of AssetLoader", (_producedLoader is AssetLoader));
		}
	}
}
