package  {
	
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class JoinInterface extends MovieClip {
		
		private var voice:Voice = Voice.instance;
		private var beep:Sound = new PaddleSound();
		private var beepUp:Sound = new TableSound();
		private var nosound:Sound = new NoSound();
		private var cursor:int = 1;
		private var digitRotator:int = 0;
		private var timeout:Timer = new Timer(1000,8);
		
		public function JoinInterface() {
			Project.instance.blinkIO.host = false;
			d1.visible = d2.visible = d3.visible = d4.visible = false;
			Project.instance.playSound("enterCode",[new EnterCodeSound()],init);
		}
		
		private function init():void {
			stage.focus = root as MovieClip;
			timeout.addEventListener(TimerEvent.TIMER,onTimeout);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);					
			for(var i:int=0;i<numChildren;i++) {
				var child:ButtonBack = getChildAt(i) as ButtonBack;
				if(child) {
					child.addEventListener(MouseEvent.MOUSE_DOWN,onDigit);
					child.addEventListener(MouseEvent.ROLL_OVER,onDigit);
					child.addEventListener(MouseEvent.MOUSE_UP,onConfirmDigit);
				}
			}
		}
		
		private function deactivate():void {
			for(var i:int=0;i<numChildren;i++) {
				var child:ButtonBack = getChildAt(i) as ButtonBack;
				if(child) {
					child.removeEventListener(MouseEvent.MOUSE_DOWN,onDigit);
					child.removeEventListener(MouseEvent.ROLL_OVER,onDigit);
					child.removeEventListener(MouseEvent.MOUSE_UP,onConfirmDigit);
				}
			}
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKey);
		}
		
		private function onKey(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.NUMBER_1:
				case Keyboard.NUMPAD_1:
					pressDigit(1,true);
					break;
				case Keyboard.NUMBER_2:
				case Keyboard.NUMPAD_2:
					pressDigit(2,true);
					break;
				case Keyboard.NUMBER_3:
				case Keyboard.NUMPAD_3:
					pressDigit(3,true);
					break;
				case Keyboard.NUMBER_4:
				case Keyboard.NUMPAD_4:
					pressDigit(4,true);
					break;
				case Keyboard.NUMBER_5:
				case Keyboard.NUMPAD_5:
					pressDigit(5,true);
					break;
				case Keyboard.NUMBER_6:
				case Keyboard.NUMPAD_6:
					pressDigit(6,true);
					break;
				case Keyboard.NUMBER_7:
				case Keyboard.NUMPAD_7:
					pressDigit(7,true);
					break;
				case Keyboard.NUMBER_8:
				case Keyboard.NUMPAD_8:
					pressDigit(8,true);
					break;
				case Keyboard.NUMBER_9:
				case Keyboard.NUMPAD_9:
					pressDigit(9,true);
					break;
				case Keyboard.SPACE:
					rotateDigit();
					break;
			}
		}
		
		private function onDigit(e:MouseEvent):void {
			if(e.buttonDown) {
				var digitButton:MovieClip = e.currentTarget as MovieClip;
				var digit:int = parseInt(digitButton.name.split("digit")[1]);
				pressDigit(digit,false);
			}
		}
		
		private function pressDigit(digit:int,confirm:Boolean):void {
			if(cursor<=4) {
				(getChildByName("d"+cursor) as MovieClip).visible = true;
				(getChildByName("d"+cursor) as MovieClip).gotoAndStop(digit+1);
				if(confirm) {
					if(!voice.speaking) {
						speakDigitAtCursor(cursor);
					}
					beepUp.play();
					cursor++;
					resetNumPad();
				}
				else {
					voice.speakSounds([voice.voices[digit]],null,true);
				}
			}
		}
		
		private function speakDigitAtCursor(n:int):void {
			var d:int = (getChildByName("d"+n) as MovieClip).currentFrame-1;
			var nextCursor:int = n+1;
			voice.speakSounds([voice.voices[d]],
				function():void {
					if(nextCursor<cursor) {
						speakDigitAtCursor(nextCursor);
					}
					else {
						onConfirmed();
					}
				},true);
		}
		
		private function onConfirmDigit(e:MouseEvent):void {
			cursor++;
			voice.speakSounds([beep,beepUp],onConfirmed,false);
			resetNumPad();
		}
		
		private function rotateDigit():void {
			if(digitRotator) {
				key = getChildByName("digit"+digitRotator) as ButtonBack;
				key.gotoAndStop(1);
			}
			digitRotator = (digitRotator % 9)+1;
			var key:ButtonBack = getChildByName("digit"+digitRotator) as ButtonBack;
			key.gotoAndStop(2);
			(getChildByName("d"+cursor) as MovieClip).visible = true;
			(getChildByName("d"+cursor) as MovieClip).gotoAndStop(digitRotator+1);
			voice.speakSounds([beep,digitRotator],
				function():void {
					onConfirmDigit(null);
				}
			,true);
		}
		
		private function resetNumPad():void {
			digitRotator = 0;
			for(var i:int=0;i<numChildren;i++) {
				var child:ButtonBack = getChildAt(i) as ButtonBack;
				if(child) {
					child.gotoAndStop(1);
				}
			}
		}
		
		private function onConfirmed():void {
			if(cursor>4) {
				var code:String = "";
				var array:Array = [];
				for(var i:int=0;i<4;i++) {
					var d:int = (getChildByName("d"+(i+1)) as MovieClip).currentFrame-1;
					code += d;
					array.push(voice.voices[d]);
				}
				deactivate();
				joinGame(code);
			}
		}
		
		private function joinGame(code:String):void {
			Project.instance.blinkIO.room = "blinkpong"+code;
			timeout.reset();
			timeout.start();
		}
		
		private function onTimeout(e:TimerEvent):void {
			if(!stage) {
				e.currentTarget.removeEventListener(e.type,arguments.callee);
				return;
			}
			if(timeout.currentCount<timeout.repeatCount) {
				voice.speakSounds([nosound]);
			}
			else {
				gotoAndStop("NOTFOUND");
				voice.speakSounds([new GameNotFoundSound()],
					function():void {
						Project.instance.reset(false);
					},true);
			}
		}
	}
	
}
