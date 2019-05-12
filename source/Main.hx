package;


import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import states.System;

class Main {
    public static function main() {
        //Toolkit.scale = 2.5;
        //Toolkit.theme = "native";
		Toolkit.autoScale = true;
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
				//trace("go to background");
				StateManager.hidden = true;
				//add notification
			});
			Lib.current.stage.addEventListener(Event.ACTIVATE, function(e:Dynamic){
				//trace("return from background");
				StateManager.hidden = false;
				//remove notification
			});
			Lib.current.stage.addEventListener(Event.CLOSE, function(e:Dynamic){
				//trace("on closing");
				//remove notification
			});
			

			StateManager.pushState(new System());//add base stage
        });
    }
	
	private static function initBackButton(){
		
	}
}
