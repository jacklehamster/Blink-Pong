package  {
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.ui.Keyboard;
	
	public class MobileHandle {

		public function MobileHandle() {
			// Check if we are on a Android / iPhoney device.
			if(Capabilities.cpuArchitecture=="ARM")
			{
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys, false, 0, true);
			}
			 
		}

		private function handleActivate(event:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		 
		private function handleDeactivate(event:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		 
		private function handleKeys(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.BACK)
				NativeApplication.nativeApplication.exit();
		}
	}
	
}
