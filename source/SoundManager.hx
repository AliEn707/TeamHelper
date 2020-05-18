package;
import haxe.CallStack;
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
}

class SoundConfig{
	public var id:Int;
	public var stream:SoundStream;
	
	public function new(i:Int, samples:Int, bits:Int, channels:Int){
		id = i;
		stream = new SoundStream(samples, bits, channels);
		trace("added "+samples+" "+bits+" "+channels);
	}
	
	public function addAndPlay(s:Bytes){
		stream.add(s);
	}
}