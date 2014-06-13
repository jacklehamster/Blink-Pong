package  {
	
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	import flash.display.MovieClip;

	public class Kongregate {

		static private var root:Project;
		static private var kongregate:Object;
		
		static public function init(value:Project):void {
			root = value;
			root.stop();
			// Pull the API path from the FlashVars
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;

			// The API path. The "shadow" API will load if testing locally. 
			var apiPath:String = paramObj.kongregate_api_path || 
			  "http://www.kongregate.com/flash/API_AS3_Local.swf";

			// Allow the API access to this SWF
			Security.allowDomain(apiPath);

			// Load the API
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			root.addChild(loader);

			// Kongregate API reference

			// This function is called when loading is complete
			function loadComplete(event:Event):void
			{
				// Save Kongregate API reference
				kongregate = event.target.content;

				// Connect to the back-end
				kongregate.services.connect();

				root.play();
				// You can now access the API via:
				// kongregate.services
				// kongregate.user
				// kongregate.scores
				// kongregate.stats
				// etc...
			}
		}
		
		static public function postScore(value:Number):void {
			kongregate.stats.submit("High Scores",value);
		}
		
		static public function startGame():void {
			
		}
	}
	
}
