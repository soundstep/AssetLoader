package org.assetloader.events {

	import flash.events.Event;
	import flash.net.NetStream;
	import org.assetloader.core.ILoadStats;
	import org.assetloader.core.ILoader;


	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class AssetLoaderEvent extends Event {

		public static const CHILD_OPEN:String = "AssetLoaderEvent.CHILD_OPEN";
		public static const CHILD_COMPLETE:String = "AssetLoaderEvent.CHILD_COMPLETE";
		public static const OPEN:String = "AssetLoaderEvent.OPEN";
		public static const START:String = "AssetLoaderEvent.START";
		public static const STOP:String = "AssetLoaderEvent.STOP";
		public static const COMPLETE:String = "AssetLoaderEvent.COMPLETE";
		public static const CONFIG_LOADED:String = "AssetLoaderEvent.CONFIG_LOADED";
		public static const ADDED_TO_PARENT:String = "AssetLoaderEvent.ADDED_TO_PARENT";
		public static const REMOVED_FROM_PARENT:String = "AssetLoaderEvent.REMOVED_FROM_PARENT";
		public static const ID3:String = "AssetLoaderEvent.ID3";
		public static const NET_STREAM_READY:String = "AssetLoaderEvent.NET_STREAM_READY";
		public static const SOUND_READY:String = "AssetLoaderEvent.SOUND_READY";
		
		public var parent:ILoader;
		public var child:ILoader;
		public var data:*;
		public var netstream:NetStream;
		public var netstatus:Object;
		public var stats:ILoadStats;
		public var statsLoaderTarget:ILoader;

		public function AssetLoaderEvent(type:String, parent:ILoader = null, child:ILoader = null, data:* = null, netstream:NetStream = null, stats:ILoadStats = null, statsLoaderTarget:ILoader = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.parent = parent;
			this.child = child;
			this.data = data;
			this.netstream = netstream;
			this.netstatus = netstatus;
			this.stats = stats;
			this.statsLoaderTarget = statsLoaderTarget;
			super(type, bubbles, cancelable);
		}

		override public function clone():Event {
			return new AssetLoaderEvent(type, parent, child, data, netstream, stats, statsLoaderTarget, bubbles, cancelable);
		}
	}
}
