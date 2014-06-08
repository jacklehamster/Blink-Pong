package  {
	
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.display.MovieClip;
	
	
	public class JoinButton extends MovieClip {
		
		private var sound:Sound = new JoinSound();
		private var paddleSound:Sound = new PaddleSound();
		
		public function JoinButton() {
			buttonMode = true;
			addEventListener(MouseEvent.ROLL_OVER,onMouse);
			addEventListener(MouseEvent.MOUSE_DOWN,onMouse);
			addEventListener(MouseEvent.ROLL_OUT,onSwitch);
			addEventListener(MouseEvent.ROLL_OVER,onSwitch);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseUp(e:MouseEvent):void {
			start();
		}

		private function start():void {
			MovieClip(parent).invitePlayer.deactivate();
			MovieClip(parent).joinGame.deactivate();
			MovieClip(parent).gotoAndPlay(name.toUpperCase());
		}

		public function deactivate():void {
			removeEventListener(MouseEvent.ROLL_OVER,onMouse);
			removeEventListener(MouseEvent.MOUSE_DOWN,onMouse);
			removeEventListener(MouseEvent.ROLL_OUT,onSwitch);
			removeEventListener(MouseEvent.ROLL_OVER,onSwitch);
		}
		
		private function onSwitch(e:MouseEvent):void {
			selected = e.type==MouseEvent.ROLL_OVER;
		}
				
		private function onMouse(e:MouseEvent):void {
			if(e.buttonDown && Project.instance.soundPlaying!="join")
				press(false);
		}
		
		public function press(startWhenDone:Boolean):void {
			Project.instance.playSound("join",[paddleSound,sound],
				!startWhenDone?null:function():void {
					start();
				}
			);
		}
		
		public function get selected():Boolean {
			return currentFrame==2;
		}
		
		public function set selected(value:Boolean):void {
			gotoAndStop(value?2:1);
			if(value)
				MovieClip(parent).invitePlayer.selected = false;
		}
	}
	
}
