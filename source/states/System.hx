package states;

import haxe.Timer;
import haxe.Timer.delay;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.network.TcpConnection;
import haxe.network.Packet;
import haxe.ui.HaxeUIApp;
import haxe.ui.components.HProgress;
import haxe.ui.components.Label;
import haxe.ui.containers.dialogs.MessageDialog;
import haxe.ui.core.UIEvent;
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
//		SoundManager.setupAudio([8000, 11025, 16000], [8, 16], [1, 2]);
		//test to start audiorecord for filling audio settings
		SoundManager.startRecording(function(b:Bytes){
			SoundManager.stopRecording();
		}, function(s:String){trace(s);}, function(){}, 700);
		test();
	}
	
	public static function get():StateBase {
		if (instance == null)
			instance = new System();
		instance._comp.show();
		return instance;
	}
	
	private var playing:Bool = false;
	private function test(){
		cast(_comp.findComponent("sound"), Button).onClick = function(e:MouseEvent){
			if (!playing){
				playing = true;
				SoundManager.startRecording(function(b:Bytes){
//					//trace(b.length);
//					Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(b)).play();
					NetworkManager.broadcastSound(b);
				}, function(s:String){
					trace(s);
				}, function(){
					trace("ok");
				}, 1100);
//				cast(_comp.findComponent("sound"), Button).text = "stop";
			}else{
				playing = false;
				SoundManager.stopRecording();
//				cast(_comp.findComponent("sound"), Button).text = "sound";
			}
		}
		cast(_comp.findComponent("connect"), Button).onClick = function(e:MouseEvent){
			trace(cast(_comp.findComponent("host"), TextField).text);
			NetworkManager.connect(
				cast(_comp.findComponent("host"), TextField).text,
				function(i:Int){
					trace("connected");
				},
				function(){
					trace(e);
				}
			);
		};
		cast(_comp.findComponent("send"), Button).onClick = function(e:MouseEvent){
			trace("pressed");
			if (cast(_comp.findComponent("message"), TextField).text!=null){
				var p:Packet = new Packet();
				p.type = MsgType.DEBUG;
				p.addShort(NetworkManager.id);
				p.addString(cast(_comp.findComponent("message"), TextField).text);
				NetworkManager.broadcastPacket(p, 0);
			}
		};
		//NetworkManager.findInLocal(function(h:String){trace(h); }, function(arr:Array<Dynamic>){trace("done"); }, "172.16.1.");
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