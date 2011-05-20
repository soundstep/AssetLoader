package com.soma.assets.loader.events {

	import flash.events.Event;

	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderNetStatusEvent extends Event {

		public static const INFO:String = "AssetLoaderNetStatusEvent.INFO";
		
		public var info:Object;

		public function AssetLoaderNetStatusEvent(type:String, info:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.info = info;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new AssetLoaderNetStatusEvent(type, info, bubbles, cancelable);
		}
	}
}
