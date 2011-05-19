package com.soma.assets.loader.events {

	import com.soma.assets.loader.core.ILoader;
	import flash.events.Event;

	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderProgressEvent extends Event {

		public static const PROGRESS:String = "AssetLoaderProgressEvent.PROGRESS";
		
		public var latency:Number;
		public var speed:Number;
		public var averageSpeed:Number;
		public var progress:Number;
		public var bytesLoaded:uint;
		public var bytesTotal:uint;
		
		public var statsLoaderTarget:ILoader;

		public function AssetLoaderProgressEvent(type:String, statsLoaderTarget:ILoader = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.statsLoaderTarget = statsLoaderTarget;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			var event:AssetLoaderProgressEvent = new AssetLoaderProgressEvent(type, statsLoaderTarget, bubbles, cancelable);
			event.latency = latency;
			event.speed = speed;
			event.averageSpeed = averageSpeed;
			event.progress = progress;
			event.bytesLoaded = bytesLoaded;
			event.bytesTotal = bytesTotal;
			event.statsLoaderTarget = statsLoaderTarget;
			return event;
		}
	}
}
