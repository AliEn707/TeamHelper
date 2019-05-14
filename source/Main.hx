package;


import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.EventType;


class Main {
	//elements that can be stay in memmory for long time
    public static function main() {
		Settings.init();
		//Toolkit.scale = 1.5;
        //Toolkit.theme = "native";
		Toolkit.autoScale = true;
		//Toolkit.autoScaleDPIThreshold = 100;//168
		//Toolkit.pixelsPerRem = 32;//16
        StateManager.init(function() {			
			Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent){
//				trace(e);
				if (e.keyCode == 27) {
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
