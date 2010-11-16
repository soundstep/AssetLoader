package org.assetloader
{

	import org.assetloader.base.BaseTestSuite;
	import org.assetloader.loaders.LoadersTestSuite;
	import org.assetloader.parsers.ConfigParsersTestSuite;
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class AssetLoaderTestSuit
	{
		public var baseTestSuite : BaseTestSuite;
		public var loadersTestSuite : LoadersTestSuite;
	}
}