package;
import haxe.CallStack;
import haxe.Timer.delay;
import haxe.io.Bytes;
import openfl.events.Event;
import openfl.extension.Audiorecorder;
import openfl.media.Sound;

/**
 * ...
 * @author ...
 */
class SoundManager{
	private static var _confs:Map<Int, SoundConfig> = new Map<Int, SoundConfig>();
	private static var _bluetooth:Bool = false;
	
	public static function addSound(s:Bytes, id:Int){
		try{
			_confs.get(id).addAndPlay(s);
		}catch (e:Any){
			trace("cant play sound");
			trace(CallStack.toString(CallStack.exceptionStack()));
		}
	}
	
	public static function addConfig(i:Int, samples:Int, bits:Int, channels:Int){
		_confs.set(i, new SoundConfig(i, samples, bits, channels));
	}
	
	public static function getConfig(i:Int){
		return _confs.get(i);
	}
	
	public static function startRecording(cb:Bytes->Void, fail:String->Void, ready:Void->Void, size:Int){
		(_bluetooth?Audiorecorder.startRecordingBluetooth:Audiorecorder.startRecording)(cb, fail, ready, size);
	}
	
	public static function stopRecording(){
		Audiorecorder.stopRecording();
	}
	
	public static function enableBluetooth(mode:Bool){
		if (_bluetooth != mode){
			_bluetooth = mode;
			stopRecording();//must call fail callback
		}
	}	
	
	public static function setupAudio(s:Array<Int>, b:Array<Int>, c:Array<Int>){
		Audiorecorder.channels = c;
		Audiorecorder.bits = b;
		Audiorecorder.sampleRates = s;		
	}
	
	public static function updateLoudness(cb:Int->Void, b:Bytes){
		var bps = Audiorecorder.RECORDER_SAMPLERATE * Audiorecorder.RECORDER_CHANNELS * Audiorecorder.RECORDER_BITS / 8;
		_updateLoudness(cb,b,0,cast(bps/5));
	}
	
	private static function _updateLoudness(cb:Int->Void, b:Bytes, from:Int, size:Int){
		var to:Int = from + size;
		var coef:Float = 0;
		if (to > b.length)
			to = b.length;
		var sum:Int = 0;
		if (Audiorecorder.RECORDER_BITS==8){
			var i = from;
			while (i<to){
				try{
					var s:Int = b.get(i)-127;
					sum += s * s;
				}catch(e:Dynamic){}
				i++;
			}
			coef = 100 / 127.0;
			sum = cast (sum / i);
		}else if (Audiorecorder.RECORDER_BITS==16){
			var i = from;
			while (i<to){
				try{
					var s:Int = b.getUInt16(i)-32767;
					sum += s * s;
				}catch(e:Dynamic){}
				i+=2;
			}
			coef = 100 / 32767.0;
			sum = cast (sum / (i / 2));
		}
		cb(Math.floor(Math.sqrt(sum) * coef));
		if (to<b.length)
			delay(_updateLoudness.bind(cb, b, to, size), 200);
	}
}

class SoundConfig{
	public var id:Int;
	public var stack:List<Sound> = new List<Sound>();
	public var playing:Bool = false;
	public var RECORDER_SAMPLERATE:Int = 0;
	public var RECORDER_CHANNELS:Int = 0;
	public var RECORDER_BITS:Int = 0;
	
	public function new(i:Int, samples:Int, bits:Int, channels:Int){
		id = i;
		RECORDER_SAMPLERATE = samples;
		RECORDER_BITS = bits;
		RECORDER_CHANNELS = channels;
		trace("added "+samples+" "+bits+" "+channels);
	}
	
	public function addAndPlay(s:Bytes){
		var s:Sound = Sound.fromAudioBuffer(Audiorecorder.getAudioBuffer(s, RECORDER_SAMPLERATE, RECORDER_BITS, RECORDER_CHANNELS));
		if (playing){
			stack.add(s);
		}else if (stack.length == 0){
			playing = true;
			s.play().addEventListener(Event.SOUND_COMPLETE, onPlayed);
		}else{//TODO: is it posible?
			stack.add(s);
		}
	}
	
	private function onPlayed(e:Event){
		try{
			stack.pop().play().addEventListener(Event.SOUND_COMPLETE, onPlayed);		
		}catch(e:Any){
			playing = false;
		}//can't play
	}
}