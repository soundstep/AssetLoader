package org.assetloader.events {

	import flash.events.Event;
	import org.assetloader.core.ILoader;


	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderErrorEvent extends Event {

		public static const ERROR:String = "AssetLoaderError.ERROR";
		public static const CHILD_ERROR:String = "AssetLoaderError.CHILD_ERROR";
		public var errorType:String;
		public var message:String;
		public var child:ILoader;

		public function AssetLoaderErrorEvent(type:String, errorType:String, message:String, child:ILoader = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.message = message;
			this.errorType = errorType;
			this.child = child;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new AssetLoaderErrorEvent(type, errorType, message, child, bubbles, cancelable);
		}
	}
}
