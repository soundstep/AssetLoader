package com.soma.assets.loader.loaders {

	import com.adobe.serialization.json.JSON;
	import com.soma.assets.loader.base.AssetType;

	import flash.net.URLRequest;

	/**
	 * @author Matan Uberstein
	 */
	public class JSONLoader extends TextLoader {

		/**
		 * @private
		 */
		protected var _jsonObject:Object;

		public function JSONLoader(request:URLRequest, id:String = null) {
			super(request, id);
			_type = AssetType.JSON;
		}

		/**
		 * @private
		 */
		override public function destroy():void {
			super.destroy();
			_jsonObject = null;
		}

		/**
		 * @private
		 * 
		 * @inheritDoc
		 */
		override protected function testData(data:String):String {
			var errMsg:String = "";
			try {
				_data = _jsonObject = JSON.decode(data);
			} catch(err:Error) {
				errMsg = err.message;
			}

			return errMsg;
		}

		/**
		 * Gets the resulting Json Object after loading and parsing is complete.
		 * 
		 * @return Object
		 */
		public function get jsonObject():Object {
			return _jsonObject;
		}
	}
}
