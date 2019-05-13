package states;

import haxe.network.TcpConnection;
import haxe.ui.HaxeUIApp;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.core.MouseEvent;

/**
 * ...
 * @author ...
 */
class System extends StateBase{
	
	private var _conn:TcpConnection;
	
	public function new(){
		_comp = ComponentMacros.buildComponent("assets/ui/system.xml");
		super();
		if (!cast(Settings.get("server_disabled", false), Bool))
			NetworkManager.startServer(function(i:Int){
				trace("client connected "+ NetworkManager.getClient(i).host);
			},function(){
				trace("server started");
			}, function(){
				trace("server error");
			});
	}
	
	private function test(){
		cast(_comp.findComponent("connect"), Button).onClick = function(e:MouseEvent){
				trace(cast(_comp.findComponent("host"), TextField).text);
				trace(Std.parseInt(cast(_comp.findComponent("port"), TextField).text));
				(new TcpConnection()).connect(
					cast(_comp.findComponent("host"), TextField).text,
					Std.parseInt(cast(_comp.findComponent("port"), TextField).text),
					function(conn:TcpConnection){
						trace("connected");
						_conn = conn;
						_conn.sendShort(0);//send first 2 bytes to show that we are not flash
					},
					function(e:Dynamic){
						trace(e);
					}
				);
			};
			
		#if !flash
			cast(_comp.findComponent("server"),Button).onClick = function(e:MouseEvent){	
				(new TcpConnection()).listen(
					Std.parseInt(cast(_comp.findComponent("port"), TextField).text),
					function(conn:TcpConnection){
						_conn = conn;
					},
					function(conn:TcpConnection){
						trace("started");
						_comp.removeComponent(_comp.findComponent("server"));
					},
					function(e:Dynamic){
						trace(e);
					}
				);
			};
		#end
	}
	
	override
	public function onDestroy(){
		StateManager.pushState(this);//can't be deleted
		//show popup "exit?"
		
		exit();
	}
	
	override
	public function clean(){
		super.clean();
	}
	
	private function exit(){
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