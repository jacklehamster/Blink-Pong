package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	
	public class Project extends MovieClip {
		
		static public var instance:Project;
		
		public function Project() {
			instance = this;
			Gamejolt.init(this);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onAction);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onAction);
		}
		
		private function onAction(e:Event):void {
			dispatchEvent(new Event("action"));
		}
		
		public function isAdmin():Boolean {
			return false;
		}
	}
	
}
