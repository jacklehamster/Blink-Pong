package  {
	import flash.display.MovieClip;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.URLLoader;
	import by.blooddy.crypto.MD5;
	import flash.net.URLRequest;
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Gamejolt {
		
		static const GAMEJOLT_ID:String = "27025";
		static const GAMEJOLT_KEY:String = "1ce7323fc3bf1a9856b9073856685dfa";

		static private var root:Project;
		static private var trophies:Object;
		
		static private var pingTimer:Timer;
		
		static public function init(value:Project):void {
			root = value;
			//root.stop();
			if(username) {
				var url:String = "http://gamejolt.com/api/game/v1/trophies/?game_id="+GAMEJOLT_ID;
				url += "&username="+ (root.isAdmin()?"jacklehamster":username);
				url += "&user_token="+ (root.isAdmin()?"dobuki":token);
				url += "&format=json";
				url += "&time="+new Date().time;
				url += "&signature="+MD5.hash(url + GAMEJOLT_KEY);
				var urlloader:URLLoader = new URLLoader();
				urlloader.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						trace(e);
					});
				urlloader.addEventListener(Event.COMPLETE,
				   function(e:Event):void {
					   var obj:Object = by.blooddy.crypto.serialization.JSON.decode(urlloader.data);
					   for each(var trophy:Object in obj.response.trophies) {
						   trophies[trophy.title.toUpperCase()] = trophy;
					   }
					   //root.play();
				   });
				urlloader.load(new URLRequest(url));
			}
			else {
				//root.play();
			}
		}

		static public function get username():String {
		  return root.loaderInfo.parameters.gjapi_username;
		}

		static public function get token():String {
		  return root.loaderInfo.parameters.gjapi_token;
		}
		
		static public function startGame():void {
			if(username) {
				var url:String = "http://gamejolt.com/api/game/v1/sessions/open/?game_id="+GAMEJOLT_ID;
				url += "&username="+ (root.isAdmin()?"jacklehamster":username);
				url += "&user_token="+ (root.isAdmin()?"dobuki":token);
				url += "&signature="+MD5.hash(url + GAMEJOLT_KEY);
				var urlloader:URLLoader = new URLLoader();
				urlloader.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						trace(e);
					});
				urlloader.addEventListener(Event.COMPLETE,
				   function(e:Event):void {
					   pingTimer = new Timer(30000);
					   pingTimer.addEventListener(TimerEvent.TIMER,onPing);
					   pingTimer.start();
				   });
				urlloader.load(new URLRequest(url));
			}
		}
		
		static public function onPing(e:TimerEvent):void {
			var url:String = "http://gamejolt.com/api/game/v1/sessions/ping/?game_id="+GAMEJOLT_ID;
			url += "&username="+ (root.isAdmin()?"jacklehamster":username);
			url += "&user_token="+ (root.isAdmin()?"dobuki":token);
			url += "&signature="+MD5.hash(url + GAMEJOLT_KEY);
			var urlloader:URLLoader = new URLLoader();
			urlloader.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void {
					trace(e);
				});
			urlloader.addEventListener(Event.COMPLETE,
			   function(e:Event):void {
			   });
			urlloader.load(new URLRequest(url));
		}
		
		static public function unlock(trophy:String):void {
			if(username) {
				var url:String = "http://gamejolt.com/api/game/v1/trophies/add-achieved/?game_id="+GAMEJOLT_ID;
				url += "&time="+new Date().time;
				url += "&username="+ (root.isAdmin()?"jacklehamster":username);
				url += "&user_token="+ (root.isAdmin()?"dobuki":token);
				url += "&trophy_id="+ trophy;
				url += "&format=json";
				url += "&time="+new Date().time;
				url += "&signature="+MD5.hash(url + GAMEJOLT_KEY);
				var urlloader:URLLoader = new URLLoader();
				urlloader.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						trace(e);
					});
				urlloader.addEventListener(Event.COMPLETE,
				   function(e:Event):void {
				   });
				urlloader.load(new URLRequest(url));
			}
		}
		
		static public function postScore(level:int,score:Array):void {
			if(username) {
				var value:Number = level*100 + score[0] - score[1];
				
				var url:String = "http://gamejolt.com/api/game/v1/scores/add/?game_id="+GAMEJOLT_ID;
				url += "&score="+score[0]+"-"+score[1]+" (level "+level+")";
				url += "&sort="+value;
				url += "&time="+new Date().time;
				url += "&username="+ (root.isAdmin()?"jacklehamster":username);
				url += "&user_token="+ (root.isAdmin()?"dobuki":token);
				url += "&format=json";
				url += "&time="+new Date().time;
				url += "&signature="+MD5.hash(url + GAMEJOLT_KEY);
				var urlloader:URLLoader = new URLLoader();
				urlloader.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						trace(e);
					});
				urlloader.addEventListener(Event.COMPLETE,
				   function(e:Event):void {
				   });
				urlloader.load(new URLRequest(url));
			}
		}
	}
}
