package platform;



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
	
#if android
	
	private static var native_getLocalIP = JNI.createStaticMethod ("org.haxe.platform.PlatformUtils", "getLocalIp", "()Ljava/lang/String;");
	
//#elseif !flash
//	private static var native_getLocalIP = CFFI.load ("platfrom_utils", "getLocalIp", 1);	
	
//#else
    
#end
	
}

