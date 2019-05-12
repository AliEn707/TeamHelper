package;

import states.StateBase;
import haxe.ui.HaxeUIApp;

/**
 * ...
 * @author ...
 */
class StateManager 
{
	public static var app:HaxeUIApp;
	public static var hidden:Bool = false;
	
	private static var _states:Array<StateBase> = new Array<StateBase>();
	
	public static function init(ready:Void->Void){
		app = new HaxeUIApp();
		app.ready(function(){
			ready();
			app.start();
		}, function(){
			trace("on app end");
		});
	}
	
	public static function pushState(state:StateBase){
		_states.push(state);
	}
	
	public static function popState(){
		_states.pop().onDestroy();
	}
}