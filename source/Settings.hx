package;

import sys.FileSystem;
import yaml.Yaml;
import yaml.util.ObjectMap.AnyObjectMap;
/**
 * ...
 * @author ...
 */
class Settings{
	private static var _path:String = lime.system.System.applicationStorageDirectory + "TeamHelper";
	private static var _file:String = "/settings.yaml";
	private static var _data:Map<String, Any>= new Map<String, Any>();

	public static function init(){
		var data:AnyObjectMap;
		if (!FileSystem.exists(_path))
			FileSystem.createDirectory(_path);
		try{
			data = Yaml.read(_path+_file);
		}catch(e:Dynamic){
			trace(e);
			try{
				Yaml.write(_path+_file, new Map<String, Dynamic>());
			}catch(e1:Dynamic){
				trace(e1); 
			}
			data = Yaml.read(_path+_file);// Yaml.parse("{}");
		}
		try{
			for (o in data.keys())
				_data.set(o, data.get(o));
		}catch(e:Any){}
	}
	
	public static function get(key:String, ?def:Any):Any{
		var val = _data.get(key);
		if (val == null && def != null){
			val = def;
			set(key, def);
		}
		return val;
	}
	
	public static function set(key:String, val:Any){
		_data.set(key, val);
		save();
	}
	
	private static function save(){
		try{
			Yaml.write(_path + _file, _data);
		}catch(e:Any){}
	}
	
}