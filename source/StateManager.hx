package;

import states.StateBase;
import states.System;
import haxe.ui.HaxeUIApp;

/**
 * ...
 * @author ...
 */
class StateManager 
{
	public static var app:HaxeUIApp;
	public static var hidden:Bool = false;
	public static var inited:Bool = false;
	
	private static var _states:Array<StateBase> = new Array<StateBase>();
	
	//elements to restart on after closing application on android
	public static function init(ready:Void->Void){ 
		app = new HaxeUIApp();
		app.ready(function(){
			StateManager.pushState(System.get());//add base stage
			ready();
			inited = true;
			app.start();
		}, function(){
			trace("on app end");
		});
	}
	
	public static function pushState(state:StateBase){
		_states.push(state);
		state.init();
	}
	
	public static function popState(){
		_states.pop().onDestroy();
	}
	
	public static function clean(){
		var s:Null<StateBase>;
		do{
			s = _states.pop();
			if (s != null)
				s.clean();
		}while (s != null);
	}
}