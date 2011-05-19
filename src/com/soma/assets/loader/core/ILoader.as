package com.soma.assets.loader.core {

	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;

	/**
	 * Instances of ILoader will perform the actual loading of an asset. They only handle one file at a time.
	 * 
	 * @author Matan Uberstein
	 */
	public interface ILoader extends IEventDispatcher {

		/**
		 * Starts/resumes the loading operation.
		 */
		function start():void

		/**
		 * Stops/pauses the loading operation.
		 */
		function stop():void

		/**
		 * Removes all listeners and destroys references.
		 */
		function destroy():void

		/**
		 * Gets the parent loader of this loader.
		 * @return ILoader
		 * 
		 * @see org.assetloader.core.ILoader
		 */
		function get parent():ILoader

		/**
		 * Gets the current loading stats of loader.
		 * @return ILoadStats
		 * @see org.assetloader.core.ILoadStats
		 */
		function get stats():ILoadStats

		/**
		 * True if the load operation was started. False other wise.
		 * 
		 * @default false
		 * @return Boolean
		 * 
		 * @see #inProgress
		 */
		function get invoked():Boolean

		/**
		 * True if the load operation has been started.
		 * e.g. when <code>opOpen</code> fires.
		 * 
		 * <p>False before start is called and after load operation is complete.</p>
		 * 
		 * @default false
		 * @return Boolean
		 */
		function get inProgress():Boolean

		/**
		 * True if the load operation has been stopped via stop method.
		 * 
		 * <p>False every other state.</p>
		 * 
		 * @default false
		 * @return Boolean
		 */
		function get stopped():Boolean

		/**
		 * True if the loading has completed. False otherwise.
		 * 
		 * @default false
		 * @return Boolean
		 */
		function get loaded():Boolean

		/**
		 * True if the loader has failed after the set amount of retries.
		 * 
		 * @default false;
		 * @return Boolean
		 */
		function get failed():Boolean

		/**
		 * @return Data that was returned after loading operation completed.
		 */
		function get data():*

		/**
		 * Checks if a param with the passed id exists.
		 * 
		 * @param id String param id.
		 * @return Boolean
		 * 
		 * @see org.assetloader.core.IParam
		 * @see org.assetloader.base.Param
		 */
		function hasParam(id:String):Boolean

		/**
		 * Sets param value.
		 * 
		 * @param id String, param id.
		 * @param value Parameter value.
		 * 
		 * @see org.assetloader.core.IParam
		 * @see org.assetloader.base.Param
		 */
		function setParam(id:String, value:*):void

		/**
		 * Gets param value.
		 * 
		 * @param id String, param id.
		 * @return Parameter value.
		 * 
		 * @see org.assetloader.core.IParam
		 * @see org.assetloader.base.Param
		 */
		function getParam(id:String):*

		/**
		 * Adds parameter to ILoader. Same effect as calling setParam.
		 * 
		 * @param param IParam
		 * 
		 * @see org.assetloader.core.IParam
		 * @see org.assetloader.base.Param
		 */
		function addParam(param:IParam):void

		/**
		 * @return String of ILoader id.
		 */
		function get id():String

		/**
		 * @return URLRequest
		 */
		function get request():URLRequest

		/**
		 * @return String of ILoader type.
		 * 
		 * @see org.assetloader.base.AssetType
		 */
		function get type():String

		/**
		 * Object containing all parameters added to ILoader.
		 * Modifying this is not recommended as some params requires some work
		 * to be done once they are added. 
		 * 
		 * @return Object
		 * 
		 * @see org.assetloader.core.IParam
		 * @see org.assetloader.base.Param
		 */
		function get params():Object

		/**
		 * Gets the amount of times the loading operation failed and retried.
		 * @return uint
		 * 
		 * @see org.assetloader.base.Param#RETRIES
		 * @see org.assetloader.core.IParam
		 * @see org.assetloader.base.Param
		 */
		function get retryTally():uint
	}
}
