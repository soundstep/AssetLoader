package org.assetloader.events {

	import flash.events.Event;


	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderLogEvent extends Event {

		public static const LOG:String = "AssetLoaderLogEvent.LOG";

		public var log:String;
		
		public function AssetLoaderLogEvent(type:String, log:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.log = log;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new AssetLoaderLogEvent(type, log, bubbles, cancelable);
		}
	}
}
