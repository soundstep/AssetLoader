package com.soma.assets.loader
{

	import com.soma.assets.loader.base.BaseTestSuite;
	import com.soma.assets.loader.loaders.LoadersTestSuite;
	import com.soma.assets.loader.parsers.ParsersTestSuite;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class AssetLoaderTestSuit
	{
		public var baseTestSuite : BaseTestSuite;
		public var loadersTestSuite : LoadersTestSuite;
		public var assetLoaderlTest : AssetLoaderTest;
		public var parsersTestSuite : ParsersTestSuite;
		public var onDemandeTests : OnDemandTests;
	}
}
