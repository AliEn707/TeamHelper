package;

import haxe.CallStack;
import haxe.io.Bytes;
import openfl.events.Event;
import openfl.extension.Audiorecorder;
import openfl.media.Sound;
import platform.PlatformUtils;

/**
 * ...
 * @author Denis Yarikov
 */
class SoundStream {
#if android
	public var id:Int;
#else
	public var stack:List<Sound> = new List<Sound>();
	public var playing:Bool = false;
#end
	public var RECORDER_SAMPLERATE:Int = 0;
	public var RECORDER_CHANNELS:Int = 0;
	public var RECORDER_BITS:Int = 0;
	
	public function new(samples:Int, bits:Int, channels:Int){
	#if android
		PlatfromUtils.newAudioStream(samples, Std.int(bits/8), channels);
	#end
		RECORDER_SAMPLERATE = samples;
		RECORDER_BITS = bits;
		RECORDER_CHANNELS = channels;
		trace("added "+samples+" "+bits+" "+channels);
	}
	
	public function add(s:Bytes){
	#if android
		PlatfromUtils.addAudioStream(id, s);
	#else
		var s:Sound = Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(s, RECORDER_SAMPLERATE, RECORDER_BITS, RECORDER_CHANNELS));
		if (playing){
			stack.add(s);
		}else if (stack.length == 0){
			playing = true;
			s.play().addEventListener(Event.SOUND_COMPLETE, onPlayed);
		}else{//TODO: is it posible?
			stack.add(s);
		}
	#end
	}
	
	private function onPlayed(e:Event){
	#if android
	#else
		try{
			stack.pop().play().addEventListener(Event.SOUND_COMPLETE, onPlayed);		
		}catch(e:Any){
			playing = false;
		}//can't play
	#end
	}
}