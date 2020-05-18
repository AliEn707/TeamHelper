package platform;
import haxe.io.Bytes;



#if android
import lime.system.JNI;
#elseif !flash
import lime.system.CFFI;
#end



class PlatfromUtils {
	
	public static function getLocalIp():String{
        #if android
           return native_getLocalIP();     
        #else
            return "";
        #end
	}
	
	public static function newAudioStream(samples:Int, bytes:Int, channels:Int):Int{
        #if android
           return native_newAudioStream(samples, channels, bytes);     
        #else
            return 0;
        #end
	}
		
	public static function addAudioStream(id:Int, s:Bytes){
        #if android
           native_addAudioStream(id, s.getData(), s.length);     
        #else

        #end
	}
	
	
	
#if android
	
	private static var native_getLocalIP = JNI.createStaticMethod ("org.haxe.platform.PlatformUtils", "getLocalIp", "()Ljava/lang/String;");
	private static var native_newAudioStream = JNI.createStaticMethod ("org.haxe.platform.PlatformUtils", "newAudioStream", "(III)I;");
	private static var native_addAudioStream = JNI.createStaticMethod ("org.haxe.platform.PlatformUtils", "addAudioStream", "(I[BI)V;");
	
//#elseif !flash
//	private static var native_getLocalIP = CFFI.load ("platfrom_utils", "getLocalIp", 1);	
	
//#else
    
#end
	
}

