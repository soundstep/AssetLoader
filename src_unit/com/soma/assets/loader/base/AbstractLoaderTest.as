package com.soma.assets.loader.base {

	import com.soma.assets.loader.core.ILoadStats;
	import com.soma.assets.loader.core.ILoader;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;

	public class AbstractLoaderTest
	{
		protected var _loaderName : String;

		protected var _id : String = "test-id";
		protected var _type : String;

		protected var _hadRequest : Boolean = false;

		protected var _loader : ILoader;

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
			_type = AssetType.IMAGE;

			_loader = new AbstractLoader(_id, _type);
		}

		[After]
		public function runAfterEachTest() : void
		{
			_loader = null;
		}

		[Test]
		public function implementing() : void
		{
			assertTrue(_loaderName + " should implement ILoader", _loader is ILoader);
		}

		[Test]
		public function idAndTypeMatchValuesPassed() : void
		{
			assertEquals(_loaderName + "#id must match the id passed via constructor", _id, _loader.id);
			assertEquals(_loaderName + "#type must match the type passed via constructor", _type, _loader.type);
		}

		[Test]
		public function statsReadyOnConstruction() : void
		{
			assertNotNull(_loader + "#stats should NOT be null after construction", _loader.stats);
		}

		[Test]
		public function statsImplementILoadStats() : void
		{
			assertTrue(_loaderName + "#stats should implement ILoadStats", (_loader.stats is ILoadStats));
		}
	}
}
