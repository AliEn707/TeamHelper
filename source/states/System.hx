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
import haxe.ui.components.CheckBox;
import haxe.ui.core.MouseEvent;
import openfl.extension.Audiorecorder;
import openfl.media.Sound;
import NetworkManager.MsgType;
import NetworkManager.Client;
import platform.PlatformUtils;
/**
 * ...
 * @author ...
 */
class System extends StateBase{
	public static var instance:Null<StateBase>;
	
	private var _conn:Null<TcpConnection>;
	private var _gethosttimer:Timer;
	private var _localip:Null<String>=null;

	public function new(){
		_comp = ComponentMacros.buildComponent("assets/ui/system.xml");
		super();
		////initialisation that not needed to reset on resume
//		SoundManager.setupAudio([8000, 11025, 16000], [8, 16], [1, 2]);
		//test to start audiorecord for filling audio settings
		SoundManager.startRecording(function(b:Bytes){
			SoundManager.stopRecording();
		}, function(s:String){trace(s); }, function(){}, 700);
		setupClientHandlers();
		test();
	}
	
	function setupClientHandlers(){
		var handlers:Map<Int, Packet->Client->Void> = [
			MsgType.DEBUG => function(p:Packet, from:Client){
				trace("got " + p.chanks[1].data + " from " + from.id + "(" + from.host + ")"); 
			},
			MsgType.SOUND => function(p:Packet, from:Client){
				var sender:Int = p.chanks[0].data;
				SoundManager.addSound(p.chanks[1].data, sender);
				NetworkManager.broadcastPacket(p, from.id);
				trace("sound");
			}
		];
		for (key in handlers.keys()){
			NetworkManager.addMessageHandler(key, handlers[key]);
		}
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
					try{
						if (cast(_comp.findComponent("play_self"), CheckBox).value == true){
							Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(b)).play();//TODO: update
						}
					}catch(e:Dynamic){
						trace(e);
					}
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
		cast(_comp.findComponent("search"), Button).onClick = function(e:MouseEvent){
			trace("pressed");
			if (_localip != null){
				NetworkManager.findInLocal(
					function(h:String){
						trace("found "+h); 
					}, 
					function(arr:Array<Dynamic>){
						trace("searching done"); 
						trace("found " + arr.filter(function(e:Dynamic){return e.access;}).length); 
					}, 
					function(hostbase:String):Array<Dynamic>{
						var arr = [for (i in (0...255)) hostbase+(i + 1)];
						arr.remove(_localip);
						return [for (i in arr){host:i, access:false}]; 
					}(_localip.split('.').slice(0, 3).join('.') + ".")
				);
			}
		};
		
	}
	
	public function getIP(host:String){
		if (["localhost","127.0.0.1"].indexOf(host)==-1){
			_localip = host;
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
		_gethosttimer.run = function(){
			var ip = PlatfromUtils.getLocalIp();
			trace(ip);
			if (ip=="")
				TcpConnection.getMyHost(getIP);	
			else
				getIP(ip);
				
		};
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