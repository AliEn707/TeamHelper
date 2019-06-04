package;


import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import lime.ui.KeyCode;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.EventType;


class Main {
	//elements that can be stay in memmory for long time
    public static function main() {
		Settings.init();
		//TODO: add lenguage depends on system settings (Settings.get("lang", openfl.system.Capabilities.language))
		Toolkit.autoScale = true;
		
		//Toolkit.autoScaleDPIThreshold = 100;//168
		//Toolkit.pixelsPerRem = 32;//16
		Toolkit.styleSheet.addRules("*{font-size: "+11+"pt !important;}"); //TODO: set size depends on screen DPI and resolution (openfl.system.Capabilities .screenDPI .screenResolutionX .screenResolutionY)
        StateManager.init(function() {			
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent){
//				trace(e);
				if ([KeyCode.ESCAPE, KeyCode.APP_CONTROL_BACK].indexOf(e.keyCode)!=-1) {
					e.preventDefault(); 
					e.stopImmediatePropagation(); 
					e.stopPropagation(); 
					StateManager.popState();
				}
			});
			Lib.current.stage.addEventListener(Event.DEACTIVATE, function(e:Dynamic){
				trace("go to background");
				StateManager.hidden = true;
				if (StateManager.inited){
					//we steel running
					//TODO: add notification
				}else{
					//app finished
				}
			});
			Lib.current.stage.addEventListener(Event.ACTIVATE, function(e:Dynamic){
				trace("return from background");
				StateManager.hidden = false;
				if (StateManager.inited){
					//app get from background
					//TODO: remove notification
				}else{
					//app started, need to reinit 
					StateManager.init(function(){trace("restarted"); });
				}
			});
        });
    }
}
