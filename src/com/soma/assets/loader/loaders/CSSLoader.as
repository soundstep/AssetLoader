package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;

	import flash.net.URLRequest;
	import flash.text.StyleSheet;

	/**
	 * @author Matan Uberstein
	 */
	public class CSSLoader extends TextLoader {

		/**
		 * @private
		 */
		protected var _styleSheet:StyleSheet;

		public function CSSLoader(request:URLRequest, id:String = null) {
			super(request, id);
			_type = AssetType.CSS;
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			_styleSheet = null;
		}

		/**
		 * @private
		 * 
		 * @inheritDoc
		 */
		override protected function testData(data:String):String {
			var errMsg:String = "";
			try {
				_styleSheet = new StyleSheet();
				_styleSheet.parseCSS(data);
				_data = _styleSheet;
			} catch(err:Error) {
				errMsg = err.message;
			}

			return errMsg;
		}

		/**
		 * Gets the resulting StyleSheet after loading is complete.
		 * 
		 * @return StyleSheet
		 */
		public function get styleSheet():StyleSheet {
			return _styleSheet;
		}
	}
}
