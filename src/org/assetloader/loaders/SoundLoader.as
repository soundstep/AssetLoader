package org.assetloader.loaders {

	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.events.AssetLoaderErrorEvent;
	import org.assetloader.base.Param;
	import flash.utils.Timer;
	import org.assetloader.base.AssetType;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
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
		/**
		 * @private
		 */
		protected var _readyTimer : Timer;
		/**
		 * @private
		 */
		protected var _hasDispatchedReady : Boolean;
		
		public function SoundLoader(request : URLRequest, id : String = null)
		{
			super(request, AssetType.SOUND, id);
		}

		/**
		 * @private
		 */
		override protected function constructLoader() : IEventDispatcher
		{
			_sound = _data = new Sound();

			_readyTimer = new Timer(50);
			_readyTimer.addEventListener(TimerEvent.TIMER, readyTimer_handler);

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
			_readyTimer.start();
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
				_readyTimer.stop();
			}
			super.stop();
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();

			if(_readyTimer)
				_readyTimer.removeEventListener(TimerEvent.TIMER, readyTimer_handler);

			_sound = null;
			_readyTimer = null;
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
		override protected function complete_handler(event : Event) : void
		{
			readyTimer_handler();
			super.complete_handler(event);
		}

		/**
		 * @private
		 */
		protected function readyTimer_handler(event : TimerEvent = null) : void
		{
			if(!_hasDispatchedReady && !_sound.isBuffering)
			{
				dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.SOUND_READY, parent, null, _sound));
				_hasDispatchedReady = true;

				_readyTimer.stop();
			}
		}

		/**
		 * @private
		 */
		protected function id3_handler(event : Event) : void
		{
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.ID3));
		}

		/**
		 * Gets the Sound instance.
		 * <p>Note: this instance will be available as soon as the SoundLoader's
		 * start method is invoked.</p>
		 * 
		 * @return Sound
		 */
		public function get sound() : Sound
		{
			return _sound;
		}
	}
}
