package org.haxe.extension;


import org.haxe.lime.HaxeObject;

import android.net.wifi.WifiManager;
import android.content.Context;
import java.util.Formatter;
import java.net.InetAddress;
import java.nio.ByteOrder; 
import java.nio.ByteBuffer; 

/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.
	
	You can access additional references from the Extension class,
	depending on your needs:
	
	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)
	
	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.
	
	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class PlatformUtils extends Extension {
	
	//todo change for update listener
	public static String getLocalIp() {
            try {
                WifiManager wm = (WifiManager) Extension.mainContext.getSystemService(Context.WIFI_SERVICE);
                    return InetAddress.getByAddress(
ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(wm.getConnectionInfo().getIpAddress()).array())
        .getHostAddress();
//                return Formatter.formatIpAddress(wm.getConnectionInfo().getIpAddress());
            }catch(Throwable e){
                return "";
            }
	}
	
}
