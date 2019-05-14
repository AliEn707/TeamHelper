package states;

import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import openfl.Lib;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author ...
 */
class StateBase{
	private var _comp:Component; 
	
	public function new(){
		StateManager.app.addComponent(_comp);
		//;
	}
	
	public function onDestroy(){
		clean();
	}
	
	public function clean(){
		StateManager.app.removeComponent(_comp);
	}
	
	public function back(e:MouseEvent){
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 27, 27));
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, 27, 27));
	}
}