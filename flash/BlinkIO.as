package  {
	import playerio.PlayerIO;
	import playerio.Connection;
	import playerio.Client;
	import playerio.PlayerIOError;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import playerio.RoomInfo;
	import playerio.Message;
	import flash.net.SharedObject;
	import by.blooddy.crypto.MD5;
	
	[Event(name="connect",type="flash.events.Event")]
	[Event(name="init",type="flash.events.Event")]
	public class BlinkIO extends EventDispatcher {
		
		private var connection:Connection, client:Client;
		private var roomname:String = null, roomHash:Object = null;
		public var host:Boolean = false;
		
		public var hook:Function;
		
		public function BlinkIO(stage:Stage) {
			PlayerIO.connect(
				stage,								//Referance to stage
				"blinkpong-dab8fkkydkozyjnkgnagma",	//Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")
				"public",							//Connection id, default is public
				user,								//Username
				"",									//User auth. Can be left blank if authentication is disabled on connection
				null,								//Current PartnerPay partner.
				handleConnect,						//Function executed on successful connect
				handleError							//Function executed if we recive an error
			);
		}
		
		private function get user():String {
			var so:SharedObject = SharedObject.getLocal("blinkpong");
			if(!so.data.user) {
				so.setProperty("user","user"+MD5.hash("" + new Date().time + Math.random()));
			}
			return so.data.user;
		}
		
		private function handleError(error:PlayerIOError):void{
			trace(error);
		}
		
		public function deactivate():void {
			room = null;
		}
		
		public function get room():String {
			return roomname;
		}
		
		public function set room(value:String):void {
			if(value!=roomname) {
				if(connection) {
					trace("Left room",connection.roomId);
					connection.disconnect();
				}
				joinRoom(value);
			}
		}
		
		private function handleConnect(client:Client):void {
			trace("Sucessfully connected to Yahoo Games Network");
			trace("user",client.connectUserId);
			this.client = client;
			joinRoom(room);
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function joinRoom(name:String):void {
			roomname = name;
			if(roomname && client) {
				client.multiplayer.createJoinRoom(room,"bounce",true,{},{},onJoin,handleError);
			}
		}
		
		private function waitReady(func:Function,params:Array):void {
			addEventListener(Event.INIT,
				function(e:Event):void {
					func.apply(null,params);
				});
		}
		
		public function listRooms(callback:Function):void {
			if(!client) {
				waitReady(listRooms,[callback]);
			}
			else {
				client.multiplayer.listRooms("bounce",{},100,0,
					function(rooms:Array):void {
						roomHash = {};
						for each(var room:RoomInfo in rooms) {
							roomHash[room.id] = room;
						}
						callback();
					});
				}
		}
		
		public function roomExists(name:String):Boolean {
			return roomHash[name];
		}
		
		private function onJoin(connection:Connection):void {
			trace("Sucessfully joined room:",room);
			this.connection = connection;	
			connection.addMessageHandler("joinedGame",function(m:Message,id:String,hosted:Boolean):void {
				if(id!=client.connectUserId) {
					dispatchEvent(new Event(Event.CONNECT));
					if(!hosted)
						joinedGame(true);
				}
			});
			connection.addMessageHandler("action",
				function(m:Message,action:String,id:String,...params):void {
					if(hook!=null && id!=client.connectUserId) {
						hook.apply(null,[action].concat(params));
					}
				});
			joinedGame(false);
		}
		
		private function joinedGame(host:Boolean):void {
			connection.send("joinedGame",client.connectUserId,host);
		}
		
		public function send(action:String,...params):void {
			connection.send.apply(connection,["action",action,client.connectUserId].concat(params));
		}
		
	}
	
}
