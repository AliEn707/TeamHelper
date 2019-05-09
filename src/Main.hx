package;

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
		
		Audiorecorder.startRecording(function(a:Array<Int>){
			trace(a);
			trace(Type.getClassName(Type.getClass(a)));
			trace(a.length);
			var aa:Array<Int> = a;
			trace(aa.length);
			Audiorecorder.stopRecording();
		});
		
		app.ready(function() {
            _main = ComponentMacros.buildComponent("assets/ui/init.xml");

            app.addComponent(_main);
            app.start();
        });
		
		cast(_main.findComponent("sound"), Button).onClick = function(e:MouseEvent){	
			var wav:Bytes = Assets.getBytes("assets/sample.wav");
			var audio:AudioBuffer = AudioBuffer.fromBytes(wav);
			trace(audio.bitsPerSample);
			trace(audio.sampleRate);
			var sound:Sound = Sound.fromAudioBuffer(audio);
			sound.play(0, 0).addEventListener(Event.SOUND_COMPLETE, function(e:Dynamic){
				trace("finished"); 
				sound.play(0, 0);
			});
		};
		
    }
}

