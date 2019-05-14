package states;

import haxe.Timer.delay;
import haxe.network.TcpConnection;
import haxe.network.Packet;
import haxe.ui.HaxeUIApp;
import haxe.ui.components.Label;
import haxe.ui.containers.dialogs.MessageDialog;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.core.MouseEvent;

import NetworkManager.MsgType;
/**
 * ...
 * @author ...
 */
class System extends StateBase{
	
	private var _conn:Null<TcpConnection>;
	
	public function new(){
		_comp = ComponentMacros.buildComponent("assets/ui/system.xml");
		super();
		if (!cast(Settings.get("server_disabled", false), Bool)){
			NetworkManager.startServer(function(i:Int){
				trace("client connected "+ NetworkManager.getClient(i).host);
			},function(){
				trace("server started");
			}, function(){
				trace("server error");
			});
		}	
		test();
	}
	
	private function test(){
		cast(_comp.findComponent("connect"), Button).onClick = function(e:MouseEvent){
			trace(cast(_comp.findComponent("host"), TextField).text);
			(new TcpConnection()).connect(
				cast(_comp.findComponent("host"), TextField).text,
				NetworkManager.port,
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
		cast(_comp.findComponent("send"), Button).onClick = function(e:MouseEvent){
			trace("pressed");
			var p:Packet = new Packet();
			p.addShort(NetworkManager.id);
			p.addShort(MsgType.DEBUG);
			p.addString(cast(_comp.findComponent("message"), TextField).text);
			if (_conn !=null)
				_conn.sendPacket(p);
		};
		TcpConnection.getMyHost(getIP);
	}
	
	public function getIP(host:String){
		if (["localhost","127.0.0.1"].indexOf(host)==-1){
			cast(_comp.findComponent("iplabel"), Label).text="Local ip address is '"+host+"'";
		}else{
			delay(TcpConnection.getMyHost.bind(getIP), 1000);
		}
	}
	
	override
	public function onDestroy(){
		StateManager.pushState(this);//can't be deleted
		//show popup "exit?"
		StateManager.pushState(new Exit());
	}
	
	override
	public function clean(){
		super.clean();
	}
}