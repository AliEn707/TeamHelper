package states;

import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import lime.ui.KeyCode;
//import haxe.ui.focus.FocusManager;
import openfl.Lib;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author ...
 */
class StateBase{
	private var _comp:Component; 
	
	public static var instance:Null<StateBase>;
	
	public function new(){
		StateManager.app.addComponent(_comp);
//		FocusManager.instance.pushView(_comp);
		//;
	}
	
	public function onDestroy(){
		_comp.hide();
	}
	
	public function clean(){
//		FocusManager.instance.popView();
		StateManager.app.removeComponent(_comp);
		instance == null;
	}
	
	public function init(){
		
	}
	
	public function back(e:MouseEvent){
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, KeyCode.ESCAPE, KeyCode.ESCAPE));
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, KeyCode.ESCAPE, KeyCode.ESCAPE));
	}
}