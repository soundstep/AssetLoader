package org.assetloader.utils
{
	import org.assetloader.events.AssetLoaderLogEvent;
	import flash.events.EventDispatcher;
	import org.assetloader.events.AssetLoaderProgressEvent;
	import org.assetloader.events.AssetLoaderHTTPStatusEvent;
	import org.assetloader.events.AssetLoaderErrorEvent;
	import org.assetloader.events.AssetLoaderEvent;
	import org.assetloader.base.AssetType;
	import org.assetloader.core.ILoadStats;
	import org.assetloader.core.IAssetLoader;
	import org.assetloader.core.ILoader;

	/**
	 * ALLogger aka AssetLoaderLogger, this class will generate useful debugging information from any IAssetLoader and/or ILoader instances. <strong>Note:</strong> Only use this for debugging,
	 * it is highly advised to remove any ALLogger instances when releasing your app/whatever.
	 * <p>
	 * ALLogger also comes packed with a onLog signal, this will allow to to handle the resulting output in your own manner.
	 * </p>
	 * <p>
	 * Why the weird name you ask? Well, I don't want this logger to conflict with any other "Logger" you might have, also expanding
	 * the name to AssetLoaderLogger will hinder your auto-completing while coding. A simple "thanks" will do ;-)
	 * </p>
	 * 
	 * @author Matan Uberstein
	 */
	public class ALLogger extends EventDispatcher
	{

		/**
		 * If true the trace function will be called.
		 * @default true
		 */
		public var autoTrace : Boolean;

		/**
		 * Charchacter used for indentation.
		 * 
		 * @default \t;
		 */
		public var indentChar : String = "\t";

		/**
		 * Constructor, creates a new instance for outputting information.
		 * 
		 * @param autoTrace If true, ALLogger will automatically call the trace function.
		 */
		public function ALLogger(autoTrace : Boolean = true)
		{
			this.autoTrace = autoTrace;
		}

		/**
		 * Attach any ILoader/IAssetLoader to the Logger. This will cause the logger to log all the signal activity.
		 * 
		 * @param loader Any implementation of ILoader, includes IAssetLoader.
		 * @param verbosity The level of detail you'd like, max value 4.
		 * @param recurse Recusion depth, setting -1 will cause infinite recusion.
		 */
		public function attach(loader : ILoader, verbosity : int = 0, recurse : int = -1) : void
		{
			_attachDetach("addEventListener", loader, verbosity, recurse);
		}

		/**
		 * Detach any attached ILoader/IAssetLoader from the Logger. This will cause the logger to remove any signal listeners.
		 * 
		 * @param loader Any implementation of ILoader, includes IAssetLoader.
		 * @param verbosity The level of detail you'd like to remove, max value 4, setting -1 will remove all.
		 * @param recurse Recusion depth, setting -1 will cause infinite recusion.
		 */
		public function detach(loader : ILoader, verbosity : int = -1, recurse : int = -1) : void
		{
			_attachDetach("removeEventListener", loader, verbosity, recurse);
		}

		/**
		 * This will instantly produce a snapshot of the current ILoader/IAssetLoader state.
		 * 
		 * @param loader Any implementation of ILoader, includes IAssetLoader.
		 * @param verbosity The level of detail you'd like, max value 4.
		 * @param recurse Recusion depth, setting -1 will cause infinite recusion.
		 */
		public function explode(loader : ILoader, verbosity : int = 0, recurse : int = -1) : void
		{
			var str : String = "";

			var indentBy : int = 0;
			var parent : ILoader = loader.parent;
			while(parent)
			{
				indentBy++;
				parent = parent.parent;
			}
			var tbs : String = rptStr(indentChar, indentBy);

			if(loader is IAssetLoader)
			{
				var assetloader : IAssetLoader = IAssetLoader(loader);

				str += tbs + "[IASSETLOADER | id=" + assetloader.id + " | type=" + assetloader.type + "]\n";
				if(verbosity >= 2)
				{
					str += tbs + " [ids = " + assetloader.ids + "]\n";
					str += tbs + " [loadedIds = " + assetloader.loadedIds + "]\n";
				}
				if(verbosity >= 1)
				{
					str += tbs + " [numLoaders = " + assetloader.numLoaders + "]\n";
					str += tbs + " [numLoaded = " + assetloader.numLoaded + "]\n";
					str += tbs + " [numConnections = " + assetloader.numConnections + "]\n";
					str += tbs + " [failOnError = " + assetloader.failOnError + "]\n";
				}
				if(verbosity >= 3)
				{
					str += tbs + " [numFailed = " + assetloader.numFailed + "]\n";
					str += tbs + " [failedIds = " + assetloader.failedIds + "]\n";
				}
			}
			else
			{
				str += tbs + "[ILOADER | id=" + loader.id + " | type=" + loader.type + "]\n";
				if(verbosity >= 1)
				{
					if(loader.parent)
						str += tbs + " [parent.id = " + loader.parent.id + "]\n";
					str += tbs + " [invoked = " + loader.invoked + "]\n";
					str += tbs + " [loaded = " + loader.loaded + "]\n";
					str += tbs + " [failed = " + loader.failed + "]\n";
				}
				if(verbosity >= 2)
				{
					str += tbs + " [inProgress = " + loader.inProgress + "]\n";
					str += tbs + " [stopped = " + loader.stopped + "]\n";
					str += tbs + " [retryTally = " + loader.retryTally + "]\n";
				}
			}

			if(verbosity >= 3)
			{
				var paramsStr : String = " [params = {";
				var paramProps : Array = [];
				for(var param : String in loader.params)
				{
					paramProps.push(param);
				}
				paramProps.sort();
				var pL : int = paramProps.length;
				for(var p : int = 0;p < pL;p++)
				{
					paramsStr += ((p == 0) ? "" : " | ") + paramProps[p] + "=" + loader.getParam(paramProps[p]);
				}
				paramsStr += "}]\n";

				str += tbs + paramsStr;
			}

			if(verbosity >= 4)
			{
				str += _explodeStats(loader.stats, tbs);
			}

			str = str.slice(0, -1);

			log(str);

			if(loader is IAssetLoader)
			{
				if(recurse != 0)
				{
					recurse--;
					var ids : Array = assetloader.ids;
					var iL : int = ids.length;
					for(var i : int = 0; i < iL; i++)
					{
						explode(assetloader.getLoader(ids[i]), verbosity, recurse);
					}
				}
			}
		}

		/**
		 * This will instantly produce a snapshot of the current ILoader/IAssetLoader's ILoadStats.
		 * 
		 * @param loader Any implementation of ILoader, includes IAssetLoader.
		 * @param recurse Recusion depth, setting -1 will cause infinite recusion.
		 */
		public function explodeStats(loader : ILoader, recurse : int = -1) : void
		{
			var str : String;

			var indentBy : int = 0;
			var parent : ILoader = loader.parent;
			while(parent)
			{
				indentBy++;
				parent = parent.parent;
			}
			var tbs : String = rptStr(indentChar, indentBy);

			if(loader is IAssetLoader)
				str = tbs + "[IASSETLOADER";
			else
				str = tbs + "[ILOADER";

			str += " | id=" + loader.id + " | type=" + loader.type + "]\n";

			str += _explodeStats(loader.stats, tbs);

			str = str.slice(0, -1);

			log(str);

			if(loader is IAssetLoader)
			{
				if(recurse != 0)
				{
					var assetloader : IAssetLoader = IAssetLoader(loader);
					recurse--;
					var ids : Array = assetloader.ids;
					var iL : int = ids.length;
					for(var i : int = 0; i < iL; i++)
					{
						explodeStats(assetloader.getLoader(ids[i]), recurse);
					}
				}
			}
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// INTERNAL
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function rptStr(input : String, count : int = 1) : String
		{
			var output : String = "";
			for(var i : int = 0; i < count; i++)
			{
				output += input;
			}
			return output;
		}

		/**
		 * @private
		 */
		protected function _explodeStats(stats : ILoadStats, tbs : String = "") : String
		{
			var str : String = tbs + " [ILOADSTATS]\n";
			str += tbs + "  [Total Time: " + stats.totalTime + " ms]\n";
			str += tbs + "  [Latency: " + Math.floor(stats.latency) + " ms]\n";
			str += tbs + "  [Current Speed: " + Math.floor(stats.speed) + " kbps]\n";
			str += tbs + "  [Average Speed: " + Math.floor(stats.averageSpeed) + " kbps]\n";
			str += tbs + "  [Loaded Bytes: " + stats.bytesLoaded + "]\n";
			str += tbs + "  [Total Bytes: " + stats.bytesTotal + "]\n";
			str += tbs + "  [Progress: " + stats.progress + "%]\n";

			return str;
		}

		/**
		 * @private
		 * 
		 * So nice and dirty! But, this IS better than copy and paste.
		 */
		protected function _attachDetach(addRem : String, loader : ILoader, verbosity : int = 0, recurse : int = -1) : void
		{
			if(verbosity < 0) verbosity = int.MAX_VALUE;

			if(loader is IAssetLoader)
			{
				var assetloader : IAssetLoader = IAssetLoader(loader);

				if(recurse != 0)
				{
					recurse--;
					var ids : Array = assetloader.ids;
					var iL : int = ids.length;
					for(var i : int = 0; i < iL; i++)
					{
						_attachDetach(addRem, assetloader.getLoader(ids[i]), verbosity, recurse);
					}
				}

				assetloader[addRem](AssetLoaderEvent.CONFIG_LOADED, assetloader_onConfigLoaded);
				assetloader[addRem](AssetLoaderEvent.CHILD_COMPLETE, assetloader_onChildComplete);
				assetloader[addRem](AssetLoaderErrorEvent.CHILD_ERROR, assetloader_onChildError);

				if(verbosity >= 1)
					assetloader[addRem](AssetLoaderEvent.CHILD_OPEN, assetloader_onChildOpen);
			}

			loader[addRem](AssetLoaderEvent.COMPLETE, loader_onComplete);
			loader[addRem](AssetLoaderErrorEvent.ERROR, loader_onError);

			if(verbosity >= 1)
			{
				loader[addRem](AssetLoaderEvent.OPEN, loader_onOpen);
				loader[addRem](AssetLoaderHTTPStatusEvent.STATUS, loader_onHttpStatus);
			}
			if(verbosity >= 2)
			{
				loader[addRem](AssetLoaderEvent.STOP, loader_onStop);
				loader[addRem](AssetLoaderEvent.START, loader_onStart);
			}
			if(verbosity >= 3)
			{
				loader[addRem](AssetLoaderEvent.ADDED_TO_PARENT, loader_onAddedToParent);
				loader[addRem](AssetLoaderEvent.REMOVED_FROM_PARENT, loader_onRemovedFromParent);
			}
			if(verbosity >= 4)
				loader[addRem](AssetLoaderProgressEvent.PROGRESS, loader_onProgress);
		}

		/**
		 * @private
		 */
		protected function logPacket(packet : Packet) : void
		{
			var interfaceName : String = packet.type == AssetType.GROUP ? "IASSETLOADER" : "ILOADER";
			var tbs : String = rptStr(indentChar, packet.indentBy);
			var str : String = tbs + "[" + interfaceName + "] | id=" + packet.id + " | type=" + packet.type + ((packet.parentId) ? " | parent.id=" + packet.parentId : "") + "]\n";

			str += tbs + " " + packet.eventType + ": [";

			var properties : Array = packet.properties;
			var pL : int = properties.length;
			for(var i : int = 0;i < pL;i++)
			{
				str += ((i == 0) ? "" : " | ") + properties[i] + "=" + packet[properties[i]];
			}
			str += "]";

			log(str);
		}

		/**
		 * @private
		 */
		protected function log(str : String) : void
		{
			if(autoTrace)
				trace(str);
			dispatchEvent(new AssetLoaderLogEvent(AssetLoaderLogEvent.LOG, str));
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// ASSETLOADER HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function assetloader_onConfigLoaded(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function assetloader_onChildOpen(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function assetloader_onChildError(event : AssetLoaderErrorEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function assetloader_onChildComplete(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		// --------------------------------------------------------------------------------------------------------------------------------//
		// LOADER HANDLERS
		// --------------------------------------------------------------------------------------------------------------------------------//
		/**
		 * @private
		 */
		protected function loader_onAddedToParent(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onRemovedFromParent(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onStart(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onStop(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onHttpStatus(event : AssetLoaderHTTPStatusEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onOpen(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onProgress(event : AssetLoaderProgressEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onError(event : AssetLoaderErrorEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}

		/**
		 * @private
		 */
		protected function loader_onComplete(event : AssetLoaderEvent) : void
		{
			logPacket(new Packet(event, event.type));
		}
	}
}

import flash.events.Event;
import org.assetloader.core.ILoader;

import flash.utils.describeType;

dynamic class Packet
{
	protected var _properties : Array = [];

	public var target : ILoader;
	public var eventType : String;
	public var indentBy : int = 0;

	public var id : String;
	public var type : String;
	public var parentId : String;

	public function Packet(event : Event, eventType : String)
	{
		target = event.currentTarget as ILoader;
		id = target.id;
		this.eventType = eventType;
		type = target.type;

		if(target.parent)
			parentId = target.parent.id;

		var parent : ILoader = target.parent;
		while(parent)
		{
			indentBy++;
			parent = parent.parent;
		}

		// Get the description of the class
		var description : XML = describeType(event);

		// Get accessors from description
		for each(var a:XML in description.accessor)
		{
			_properties.push(String(a.@name));
		}

		// Get variables from description
		for each(var v:XML in description.variable)
		{
			_properties.push(String(v.@name));
		}

		_properties.splice(_properties.indexOf("loader"), 1);
		_properties.splice(_properties.indexOf("valueClasses"), 1);

		var pL : int = _properties.length;
		for(var i : int = 0; i < pL; i++)
		{
			this[_properties[i]] = event[_properties[i]];
		}

		_properties.sort();
	}

	public function get properties() : Array
	{
		return _properties;
	}
}
