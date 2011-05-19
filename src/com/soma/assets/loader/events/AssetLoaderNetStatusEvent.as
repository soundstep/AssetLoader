package com.soma.assets.loader.events {

	import flash.events.Event;

	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderNetStatusEvent extends Event {

		public static const STATUS:String = "AssetLoaderNetStatusEvent.NET_STATUS";
		public var status:Object;

		public function AssetLoaderNetStatusEvent(type:String, status:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.status = status;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new AssetLoaderNetStatusEvent(type, status, bubbles, cancelable);
		}
	}
}
