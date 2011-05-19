package com.soma.assets.loader.base {

	import com.soma.assets.loader.AssetLoader;
	import com.soma.assets.loader.core.ILoader;
	import com.soma.assets.loader.core.IParam;
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
	import com.soma.assets.loader.parsers.URLParser;

	import flash.net.URLRequest;

	/**
	 * LoaderFactory purly generates ILoader instances.
	 * 
	 * @see org.assetloader.core.ILoader
	 * 
	 * @author Matan Uberstein
	 */
	public class LoaderFactory {

		/**
		 * @private
		 */
		protected var _loader:AbstractLoader;

		public function LoaderFactory() {
		}

		/**
		 * Produces an ILoader instance according to parameters passed.
		 * 
		 * @param id Unique Loader id.
		 * @param type Type of the new ILoader.
		 * @param request URLRequest to be loaded.
		 * @param params Rest argument of parameters to be passed to ILoader.
		 * 
		 * @return Resulting ILoader.
		 * 
		 * @see org.assetloader.base.AssetType
		 */
		public function produce(id:String, type:String = "AUTO", request:URLRequest = null, params:Array = null):ILoader {
			if (request) {
				var urlParser:URLParser = new URLParser(request.url);
				if (urlParser.isValid) {
					if (type == AssetType.AUTO)
						type = getTypeFromExtension(urlParser.fileExtension);
				} else
					throw new AssetLoaderError(AssetLoaderError.INVALID_URL);
			} else if (type == AssetType.AUTO)
				type = AssetType.GROUP;

			constructLoader(type, id, request);

			if (params)
				processParams(params);

			return _loader;
		}

		/**
		 * @private
		 */
		protected function processParams(assetParams:Array):void {
			var pL:int = assetParams.length;
			for (var i:int = 0;i < pL;i++) {
				if (assetParams[i] is IParam) {
					var param:IParam = assetParams[i];
					_loader.setParam(param.id, param.value);
				} else if (assetParams[i] is Array)
					processParams(assetParams[i]);
			}
		}

		/**
		 * @private
		 */
		protected function getTypeFromExtension(extension:String):String {
			if (!extension)
				extension = "";

			extension = extension.toLowerCase();

			var textExt:Array = ["txt", "js", "html", "htm", "php", "asp", "aspx", "jsp", "cfm"];
			var imageExt:Array = ["jpg", "jpeg", "png", "gif"];
			var videoExt:Array = ["flv", "f4v", "f4p", "mp4", "mov"];

			if (testExtenstion(textExt, extension))
				return AssetType.TEXT;

			if (extension == "json")
				return AssetType.JSON;

			if (extension == "xml")
				return AssetType.XML;

			if (extension == "css")
				return AssetType.CSS;

			if (extension == "zip")
				return AssetType.BINARY;

			if (extension == "swf")
				return AssetType.SWF;

			if (testExtenstion(imageExt, extension))
				return AssetType.IMAGE;

			if (extension == "mp3")
				return AssetType.SOUND;

			if (testExtenstion(videoExt, extension))
				return AssetType.VIDEO;

			throw new AssetLoaderError(AssetLoaderError.ASSET_AUTO_TYPE_NOT_FOUND);

			return "";
		}

		/**
		 * @private
		 */
		protected function testExtenstion(extensions:Array, extension:String):Boolean {
			if (extensions.indexOf(extension) != -1)
				return true;
			return false;
		}

		/**
		 * @private
		 */
		protected function constructLoader(type:String, id:String, request:URLRequest):void {
			switch(type) {
				case AssetType.TEXT:
					_loader = new TextLoader(request, id);
					break;
				case AssetType.JSON:
					_loader = new JSONLoader(request, id);
					break;
				case AssetType.XML:
					_loader = new XMLLoader(request, id);
					break;
				case AssetType.CSS:
					_loader = new CSSLoader(request, id);
					break;
				case AssetType.BINARY:
					_loader = new BinaryLoader(request, id);
					break;
				case AssetType.DISPLAY_OBJECT:
					_loader = new DisplayObjectLoader(request, id);
					break;
				case AssetType.SWF:
					_loader = new SWFLoader(request, id);
					break;
				case AssetType.IMAGE:
					_loader = new ImageLoader(request, id);
					break;
				case AssetType.SOUND:
					_loader = new SoundLoader(request, id);
					break;
				case AssetType.VIDEO:
					_loader = new VideoLoader(request, id);
					break;
				case AssetType.GROUP:
					_loader = new AssetLoader(id);
					break;
				default:
					throw new AssetLoaderError(AssetLoaderError.ASSET_TYPE_NOT_RECOGNIZED);
			}
		}
	}
}