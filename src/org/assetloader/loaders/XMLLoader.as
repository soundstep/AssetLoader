package org.assetloader.loaders {

	import flash.net.URLRequest;
	import org.assetloader.base.AssetType;


	/**
	 * @author Matan Uberstein
	 */
	public class XMLLoader extends TextLoader {

		/**
		 * @private
		 */
		protected var _xml:XML;

		public function XMLLoader(request:URLRequest, id:String = null) {
			super(request, id);
			_type = AssetType.XML;
		}

		/**
		 * @private
		 */
		override public function destroy():void {
			super.destroy();
			_xml = null;
		}

		/**
		 * @private
		 * 
		 * @inheritDoc
		 */
		override protected function testData(data:String):String {
			try {
				_data = _xml = new XML(data);
			} catch(err:Error) {
				return err.message;
			}

			if (xml)
				if (xml.nodeKind() != "element")
					return "Not valid XML.";

			return "";
		}

		/**
		 * Gets the resulting XML after loading and parsing is complete.
		 * 
		 * @return XML
		 */
		public function get xml():XML {
			return _xml;
		}
	}
}
