package org.assetloader.events {

	import flash.events.Event;

	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderHTTPStatusEvent extends Event {

		public static const STATUS:String = "AssetLoaderHTTPStatusEvent.STATUS";
		public var status:int;

		public function AssetLoaderHTTPStatusEvent(type:String, status:int, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.status = status;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new AssetLoaderHTTPStatusEvent(type, status, bubbles, cancelable);
		}
	}
}
