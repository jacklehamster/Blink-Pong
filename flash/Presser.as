package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Mouse;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	
	public class Presser extends MovieClip {
		
		private var mouseVisible:Boolean = true;
		
		public function Presser() {
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
		}
		
		private function onRemoved(e:Event):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKey);
		}
		
		private function onKey(e:KeyboardEvent):void {
			if(e.keyCode==Keyboard.SPACE) {
				alpha = 1;
				if(!MovieClip(root).joinGame.selected) {
					MovieClip(root).joinGame.selected = true;
					MovieClip(root).joinGame.press(true);
				}
				else {
					MovieClip(root).invitePlayer.selected = true;
					MovieClip(root).invitePlayer.press(true);
				}
			}
		}
	}
	
}
