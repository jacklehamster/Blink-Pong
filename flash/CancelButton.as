package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class CancelButton extends MovieClip {
		
		
		public function CancelButton() {
			addEventListener(MouseEvent.ROLL_OUT,onSwitch);
			addEventListener(MouseEvent.ROLL_OVER,onSwitch);
		}
		
		public function deactivate():void {
			removeEventListener(MouseEvent.ROLL_OUT,onSwitch);
			removeEventListener(MouseEvent.ROLL_OVER,onSwitch);
		}
		
		private function onSwitch(e:MouseEvent):void {
			if(e.buttonDown) {
				selected = e.type==MouseEvent.ROLL_OVER;
			}
		}
		
		public function get selected():Boolean {
			return currentFrame==2;
		}
		
		public function set selected(value:Boolean):void {
			gotoAndStop(value?2:1);
		}
	}
	
}
