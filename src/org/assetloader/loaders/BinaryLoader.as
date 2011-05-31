package org.assetloader.loaders {

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import org.assetloader.base.AssetType;


	/**
	 * @author Matan Uberstein
	 */
	public class BinaryLoader extends BaseLoader {

		/**
		 * @private
		 */
		protected var _bytes:ByteArray;
		/**
		 * @private
		 */
		protected var _loader:URLStream;

		public function BinaryLoader(request:URLRequest, id:String = null) {
			super(request, AssetType.BINARY, id);
		}

		/**
		 * @private
		 */
		override protected function constructLoader():IEventDispatcher {
			_loader = new URLStream();
			return _loader;
		}

		/**
		 * @private
		 */
		override protected function invokeLoading():void {
			_loader.load(request);
		}

		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			if (_invoked) {
				try {
					_loader.close();
				} catch(error:Error) {
				}
			}

			super.stop();
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			_loader = null;
			_bytes = null;
		}

		/**
		 * @private
		 */
		override protected function complete_handler(event:Event):void {
			_bytes = new ByteArray();
			_loader.readBytes(_bytes);

			_data = _bytes;

			super.complete_handler(event);
		}

		/**
		 * Gets the resulting ByteArray after loading is complete.
		 * 
		 * @return ByteArray 
		 */
		public function get bytes():ByteArray {
			return _bytes;
		}
	}
}
