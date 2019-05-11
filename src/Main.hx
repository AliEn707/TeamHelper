package;

import haxe.Timer.delay;
import haxe.io.Bytes;
import haxe.network.Packet;
import haxe.network.TcpConnection;
import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.core.MouseEvent;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.macros.MacroHelpers;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import openfl.events.Event;
import openfl.system.System;
import openfl.utils.Assets;

import haxe.extension.Audiorecorder;


class Main {
	private static var _main:Null<Component>;
	static var app:HaxeUIApp;
	static var _conn:TcpConnection;
	

    public static function main() {
        //Toolkit.scale = 2.5;
        //Toolkit.theme = "native";
		Toolkit.autoScale = true;
        app = new HaxeUIApp();
				
		app.ready(function() {
            _main = ComponentMacros.buildComponent("assets/ui/init.xml");

            app.addComponent(_main);
            app.start();
        });
		
		cast(_main.findComponent("sound"), Button).onClick = function(e:MouseEvent){
			delay(function(){Audiorecorder.stopRecording(); }, 10000);
			Audiorecorder.startRecording(function(a:Bytes){
				//trace(a);
				Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(a)).play(0, 0);//.addEventListener(Event.SOUND_COMPLETE, function(e:Dynamic){trace("finished");});
			},function(e:Dynamic){
				trace(e);
			}, function(){
				trace("ready");
			},2000);
		};
    }
	
}

