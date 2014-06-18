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
			Gamejolt.init(this);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseAction);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyboardAction);
			if(AdHandler.isSupported) {
				AdHandler.initialize();
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

		private function onMouseAction(e:MouseEvent):void {
			dispatchEvent(new Event("action"));
		}
		
		private function onKeyboardAction(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.NUMBER_0:
				case Keyboard.NUMPAD_0:
				case Keyboard.NUMBER_1:
				case Keyboard.NUMPAD_1:
				case Keyboard.NUMBER_2:
				case Keyboard.NUMPAD_2:
				case Keyboard.NUMBER_3:
				case Keyboard.NUMPAD_3:
				case Keyboard.NUMBER_4:
				case Keyboard.NUMPAD_4:
				case Keyboard.NUMBER_5:
				case Keyboard.NUMPAD_5:
				case Keyboard.NUMBER_6:
				case Keyboard.NUMPAD_6:
				case Keyboard.NUMBER_7:
				case Keyboard.NUMPAD_7:
				case Keyboard.NUMBER_8:
				case Keyboard.NUMPAD_8:
				case Keyboard.NUMBER_9:
				case Keyboard.NUMPAD_9:
					break;
				case Keyboard.M:
					SoundMixer.soundTransform = new SoundTransform(1-SoundMixer.soundTransform.volume);
					break;
				case Keyboard.ESCAPE:
					if(currentScene.name!="Logo")
						reset(false);
					break;
				default:
					dispatchEvent(new Event("action"));
					break;
			}
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