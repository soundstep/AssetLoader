package com.soma.assets.loader.loaders {

	import com.soma.assets.loader.base.AssetType;
	import com.soma.assets.loader.base.Param;
	import com.soma.assets.loader.events.AssetLoaderErrorEvent;
	import com.soma.assets.loader.events.AssetLoaderEvent;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.net.URLRequest;

	/**
	 * @author Matan Uberstein
	 */
	public class SoundLoader extends BaseLoader {

		/**
		 * @private
		 */
		protected var _sound:Sound;

		public function SoundLoader(request:URLRequest, id:String = null) {
			super(request, AssetType.SOUND, id);
		}

		/**
		 * @private
		 */
		override protected function constructLoader():IEventDispatcher {
			_sound = _data = new Sound();
			return _sound;
		}

		/**
		 * @private
		 */
		override protected function invokeLoading():void {
			try {
				_sound.load(request, getParam(Param.SOUND_LOADER_CONTEXT));
			} catch(error:SecurityError) {
				dispatchEvent(new AssetLoaderErrorEvent(AssetLoaderErrorEvent.ERROR, error.name, error.message));
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			if (_invoked) {
				try {
					_sound.close();
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
			_sound = null;
		}

		/**
		 * @private
		 */
		override protected function addListeners(dispatcher:IEventDispatcher):void {
			super.addListeners(dispatcher);
			if (dispatcher)
				dispatcher.addEventListener(Event.ID3, id3_handler);
		}

		/**
		 * @private
		 */
		override protected function removeListeners(dispatcher:IEventDispatcher):void {
			super.removeListeners(dispatcher);
			if (dispatcher)
				dispatcher.removeEventListener(Event.ID3, id3_handler);
		}

		/**
		 * @private
		 */
		protected function id3_handler(event:Event):void {
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.ID3));
		}

		/**
		 * Gets the Sound instance.
		 * <p>Note: this instance will be available as soon as the SoundLoader's
		 * start method is invoked.</p>
		 * 
		 * @return Sound
		 */
		public function get sound():Sound {
			return _sound;
		}
	}
}
