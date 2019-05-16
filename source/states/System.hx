package states;

import haxe.Timer;
import haxe.Timer.delay;
import haxe.io.Bytes;
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
import openfl.extension.Audiorecorder;
import openfl.media.Sound;

import NetworkManager.MsgType;
/**
 * ...
 * @author ...
 */
class System extends StateBase{
	public static var instance:Null<StateBase>;
	
	private var _conn:Null<TcpConnection>;
	private var _gethosttimer:Timer;

	public function new(){
		_comp = ComponentMacros.buildComponent("assets/ui/system.xml");
		super();
		////initialisation that not needed to reset on resume
		
		test();
	}
	
	public static function get():StateBase {
		if (instance == null)
			instance = new System();
		instance._comp.show();
		return instance;
	}
	
	private function test(){
		cast(_comp.findComponent("sound"), Button).onClick = function(e:MouseEvent){
			delay(function(){SoundManager.stopRecording(); }, 9000);
			//SoundManager.setupAudio([8000], [8], [1]);
			SoundManager.startRecording(function(b:Bytes){
				trace(b.length);
				Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(b));
			}, function(s:String){
				
			}, function(){
				
			}, 3000);
		}
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
	}
	
	public function getIP(host:String){
		if (["localhost","127.0.0.1"].indexOf(host)==-1){
			cast(_comp.findComponent("iplabel"), Label).text = "Local ip address is '" + host + "'";
			_gethosttimer.stop();
		}
	}
	
	override 
	function init(){
		super.init();
		////initialisation that needed to reset on resume
		if (!cast(Settings.get("server_disabled", false), Bool)){
			NetworkManager.startServer(function(i:Int){
				trace("client connected "+ NetworkManager.getClient(i).host);
			},function(){
				trace("server started");
			}, function(){
				trace("server error");
			});
		}	
		_gethosttimer = new Timer(3000);
		_gethosttimer.run=TcpConnection.getMyHost.bind(getIP);		
	}
	
	override
	public function onDestroy(){
		StateManager.pushState(this);//can't be deleted
		//show popup "exit?"
		StateManager.pushState(Exit.get());
	}
	
	override
	public function clean(){
		super.clean();
		_gethosttimer.stop();
		instance == null;
	}
}