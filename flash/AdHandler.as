package  {
	import com.purplebrain.adbuddiz.sdk.nativeExtensions.AdBuddiz;
	import com.purplebrain.adbuddiz.sdk.nativeExtensions.AdBuddizLogLevel;
	import com.purplebrain.adbuddiz.sdk.nativeExtensions.AdBuddizEvent;
	import flash.system.Capabilities;
	
	public class AdHandler {

		static public function get isSupported():Boolean {
			return (Capabilities.cpuArchitecture=="ARM");
		}
		
		static public function initialize() {

			AdBuddiz.setAndroidPublisherKey("47d42ff4-798e-4eae-928d-6ff2fbc3b711");
			AdBuddiz.setIOSPublisherKey("dabd11d4-60b8-4b3f-a133-1545442689f4");
			//AdBuddiz.setLogLevel(AdBuddizLogLevel.INFO); // or ERROR, SILENT
			//AdBuddiz.setTestModeActive();
			AdBuddiz.cacheAds();
			
			/*
			AdBuddiz.addEventListener(AdBuddizEvent.didCacheAd, function():void { 
				trace("didCacheAd");
				AdBuddiz.logNative("didCacheAd"); 
			});
			AdBuddiz.addEventListener(AdBuddizEvent.didShowAd, function():void { 
				trace("didShowAd");
				AdBuddiz.logNative("didShowAd");
			});
			AdBuddiz.addEventListener(AdBuddizEvent.didFailToShowAd, function(e:AdBuddizEvent):void { 
				trace("didFailToShowAd: "+e.error);
				AdBuddiz.logNative("didFailToShowAd: "+e.error);
			});
			AdBuddiz.addEventListener(AdBuddizEvent.didClick, function():void { 
				trace("didClick");
				AdBuddiz.logNative("didClick"); 
			});
			AdBuddiz.addEventListener(AdBuddizEvent.didHideAd, function():void { 
				trace("didHide");
				AdBuddiz.logNative("didHide"); 
			});
			*/
		}
		
		public function showAd():void {
			AdBuddiz.showAd();
		}

	}
	
}
