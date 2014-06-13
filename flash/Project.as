package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	
	public class Project extends MovieClip {
		
		static public var instance:Project;
		private var adHandler:AdHandler;
		private var soundChannel:SoundChannel, soundName:String;
		public var blinkIO:BlinkIO;
		public var frameRate:Number;
		
		public function Project() {
			frameRate = stage.frameRate;
			instance = this;
			Kongregate.init(this);
			Gamejolt.init(this);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onAction);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onAction);
			if(AdHandler.isSupported) {
				adHandler = new AdHandler();
			}
			addEventListener(Event.DEACTIVATE,onDeactivate);
		}
		
		public function connectMultiplayer(callback:Function):void {
			blinkIO = new BlinkIO(stage);
			blinkIO.addEventListener(Event.INIT,
				function(e:Event):void {
					e.currentTarget.removeEventListener(e.type,arguments.callee);
					callback();
				});
			blinkIO.addEventListener(Event.CONNECT,playerConnected);
		}
		
		private function playerConnected(e:Event):void {
			gotoAndStop(1,"Game");
		}
		
		private function clearMultiplayer():void {
			if(blinkIO) {
				blinkIO.deactivate();
				blinkIO = null;
			}
		}
		
		private function onDeactivate(e:Event):void {
//			if(currentScene.name!="Logo")
//				reset(true);
		}
				
		public function showAd():void {
			if(adHandler)
				adHandler.showAd();
		}
		
		private function onAction(e:Event):void {
			if(e.type==KeyboardEvent.KEY_DOWN && (e as KeyboardEvent).keyCode==Keyboard.M) {
				SoundMixer.soundTransform = new SoundTransform(1-SoundMixer.soundTransform.volume);
			}
			else if(e.type==MouseEvent.MOUSE_DOWN 
				|| e.type==KeyboardEvent.KEY_DOWN && (e as KeyboardEvent).keyCode==Keyboard.SPACE)
				dispatchEvent(new Event("action"));
		}
		
		public function isAdmin():Boolean {
			return false;
		}
		
		public function reset(waitToActivate:Boolean):void {
			clearSound();
			clearMultiplayer();
			if(waitToActivate) {
				gotoAndStop("DOBUKI","Intro");
				addEventListener(Event.ACTIVATE,
					function(e:Event):void {
						e.currentTarget.removeEventListener(e.type,arguments.callee);
						play();
					});
			}
			else {
				gotoAndPlay("DOBUKI","Intro");
			}
		}
		
		private function clearSound():void {
			if(soundChannel) {
				soundChannel.stop();
			}
			soundChannel = null;
			soundName = null;
		}
		
		public function playSound(soundName:String,sounds:Array,callback:Function=null):void {
			clearSound();
			this.soundName = soundName;
			soundChannel = sounds[0].play();
			soundChannel.addEventListener(Event.SOUND_COMPLETE,
				function(e:Event):void {
					clearSound();
					if(sounds.length>1) {
						playSound(soundName,sounds.slice(1),callback);
					}
					else if(callback!=null) {
						callback();
					}
				});
		}
		
		public function get soundPlaying():String {
			return soundName;
		}
	}
}
