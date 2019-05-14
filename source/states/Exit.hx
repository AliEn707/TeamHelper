package states;
import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.core.MouseEvent;
import haxe.ui.macros.ComponentMacros;

/**
 * ...
 * @author ...
 */
class Exit extends StateBase{

	public function new(){
		_comp = ComponentMacros.buildComponent("assets/ui/exit.xml");
		super();
		
		cast(_comp.findComponent("nobutton"), Button).onClick = back;
		cast(_comp.findComponent("yesbutton"), Button).onClick = exit;
	}
	
	private function exit(e:MouseEvent){
		StateManager.inited = false;
		
		NetworkManager.close();
		StateManager.clean();
		
	#if flash	
		openfl.system.System.exit(0);
	#else
		Sys.exit(0);
	#end
	}
}