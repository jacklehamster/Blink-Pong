package  {
	
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	
	public class InviteInterface extends MovieClip {
		
		private var code:String;
		private var digit:int = 1;
		private var cancelling:Boolean = false;
				
		public function InviteInterface() {
			Project.instance.blinkIO.host = true;
			Project.instance.playSound("shareCode",[new ShareCodeSound()],stopCode);
			cancelButton.addEventListener(MouseEvent.MOUSE_UP,onCancel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onCancel);
			addEventListener(Event.REMOVED_FROM_STAGE,offStage);
			fetchCode(null);
		}
		
		private function fetchCode(callback:Function):void {
			Project.instance.blinkIO.listRooms(
				function():void {
					code = null;
					for(var i:int=0;i<100;i++) {
						var str:String = generateCode();
						if(!Project.instance.blinkIO.roomExists("blinkpong"+str)) {
							code = str;
							Project.instance.blinkIO.room = "blinkpong"+str;
							break;
						}
					}
					if(callback!=null) {
						callback();
					}
				}
			);
		}
		
		private function offStage(e:Event):void {
			cancelButton.removeEventListener(MouseEvent.MOUSE_UP,onCancel);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,onCancel);
		}
		
		private function onCancel(e:Event):void {
			Project.instance.blinkIO.room = null;
			cancelButton.selected = true;
			cancelButton.deactivate();
			cancelling = true;
			Project.instance.playSound("cancel",[new CancelSound()],
				function():void {
					Project.instance.reset(false);
				});
		}
		
		private function stopCode():void {
			if(!code) {
				fetchCode(stopCode);
			}
			else {
				digit = 1;
				stopDigit();
			}
		}
		
		private function stopDigit():void {
			if(digit<=4 && root && !cancelling) {
				var d:int = parseInt(code.charAt(digit-1));
				this["digit"+digit].gotoAndStop(d+1);
				digit++;
				Voice.instance.speakSounds([Voice.instance.voices[d]],stopDigit);
			}
		}
		
		private function generateCode():String {
			var str:String = "";
			for(var i:int=0;i<4;i++) {
				str += int(Math.random()*9+1);
			}
			return str;
		}
	}
	
}
