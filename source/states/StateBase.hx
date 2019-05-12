package states;

import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;

/**
 * ...
 * @author ...
 */
class StateBase{
	private var _comp:Component; 
	
	public function new(){
		StateManager.app.addComponent(_comp);
	}
	
	public function back(){
		StateManager.popState();
	}
	
	public function onDestroy(){
		clean();
	}
	
	public function clean(){
		StateManager.app.removeComponent(_comp);
	}
}