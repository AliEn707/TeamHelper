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
	public static var instance:Null<StateBase>;

	public function new(){
		_comp = ComponentMacros.buildComponent("assets/ui/exit.xml");
		super();
		////initialisation that needed to reset on resume
		
		cast(_comp.findComponent("nobutton"), Button).onClick = back;
		cast(_comp.findComponent("yesbutton"), Button).onClick = exit;
	}
	
	public static function get():StateBase {
		if (instance == null)
			instance = new Exit();
		instance._comp.show();
		return instance;
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

	override 
	function init(){
		super.init();
		////initialisation that needed to reset on resume
		
	}

	override
	public function clean(){
		super.clean();
		instance == null;
	}
}