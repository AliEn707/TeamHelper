package;

import haxe.Timer.delay;
import haxe.crypto.Crc32;
import haxe.crypto.Md5;
import haxe.io.Bytes;
import haxe.network.Lock;
import haxe.network.Packet;
import haxe.network.TcpConnection;
import lime.net.oauth.OAuthClient;
import openfl.extension.Audiorecorder;

/**
 * ...
 * @author ...
 */
class NetworkManager{
	public static inline var port:Int = 21308;
	
	public static var id:Int = 0;
	public static var host:String = "";
	
	private static var _lock:Lock = new Lock();
	private static var _channels:Map<Int, Client> = new Map<Int, Client>();//connected hosts
	private static var _server:Null<TcpConnection> = null; 
	private static var _host:Null<TcpConnection> = null; //connection to host

	public static function startServer(onconnected:Int->Void, ready:Void->Void, error:Void->Void){
		(_server = new TcpConnection()).listen(port, function(conn:TcpConnection){
			var c:Client = new Client(conn);
			addClient(c);
			conn.setFailCallback(function(e:Dynamic){
				removeClient(c.id);
			});
			if (id==0){
				setId(conn);
			}
			onconnected(c.id);
		}, function(conn:TcpConnection){
			ready();
		}, function(e:Dynamic){
			error();
		});
	}
	
	public static function close(){
		_server.close();
		for (c in _channels){
			c.conn.close();
		}
	} 
	
	public static function connect(host:String, ?success:Int->Void, ?fail:Void->Void, ?onDisconnect:Void->Void){
		(new TcpConnection()).connect(host, port, function(conn:TcpConnection){
			conn.sendShort(0);//important
			_host = conn;
			var c:Client = new Client(conn);
			addClient(c);
			conn.setFailCallback(function(e:Dynamic){
				removeClient(c.id);
				if (onDisconnect != null)
					onDisconnect();
//				delay(connect.bind(host), 1000);//reconnect
			});
			if (success!=null)
				success(c.id);
			if (id==0){
				setId(conn);
			}
			//sent info about self 
			var p:Packet = new Packet();
				p.addShort(id);
				p.addByte(MsgType.CLIENTINFO);
				p.addShort(c.id);
				p.addString(c.host);
				p.addInt(Audiorecorder.RECORDER_SAMPLERATE);
				p.addInt(Audiorecorder.RECORDER_CHANNELS);
				p.addInt(Audiorecorder.RECORDER_BITS);
			//add other data
			conn.sendPacket(p);
		}, function(e:Dynamic){
			if (fail != null)
				fail();
		});
	}	
	
	public static function broadcastPacket(p:Packet, except:Int){
		var bytes = p.getBytes();
		broadcastBytesSize(bytes, bytes.length, except);
	}

	public static function broadcastBytesSize(bytes:Bytes, length:Int, except:Int){
		_lock.lock();
			for (c in _channels){
				if (c.over==null && except==c.id){
					c.conn.sendUShort(length);
					c.conn.sendBytes(bytes);
				}
			}
		_lock.unlock();
	}
	
	public static function proceedMessage(message:Bytes, from:Int){
		var p:Packet = Packet.fromBytes(message);
		if (!p.chanks[0].isShort()){
			trace("Wrong message!");
			return;
		}
		var sender:Int = p.chanks[0].data;
		if (getClient(sender)==null){
			var c:Client = new Client();
			c.id = sender;
			c.over = from;
		}
		switch(p.chanks[1].data){
			case MsgType.DEBUG:
				trace("got "+p.chanks[2].data);
			case MsgType.CLIENTINFO:
				trace("client info");
			case MsgType.ASKCLIENTINFO:
				trace("need to answer client data");
			case MsgType.SOUND:
				trace("need to play sound");
				broadcastBytesSize(message, message.length, from);
		}
	}
	
	private static function setId(conn:TcpConnection){
		host=conn.sock.host().host.toString();
		id=get16from32(Crc32.make(Bytes.ofString(host)));
	}
	
	private static function addClient(c:Client){
		_lock.lock();
			_channels.set(c.id, c);
		_lock.unlock();
	}
	
	public static function getClient(id:Int){
		var o:Null<Client>;
		_lock.lock();
			o=_channels.get(id);
		_lock.unlock();
		return o;
	}
	
	private static function removeClient(id:Int){
		_lock.lock();
			var rem = new List<Int>();
			rem.add(id);
			for (c in _channels){
				if (c.over==id){
					rem.add(c.id);
				}
			}
			for (i in rem){
				_channels.remove(i);
			}
		_lock.unlock();
	}
	
	public static function searchLocalHosts(hosts:Array<String>, onFound:String->Void, onEnd:Void->Void){
		TcpConnection.checkHosts(hosts.map(function(s:String):Any{return {host:s, port:port}; }), function(host:String, port:Int){
			onFound(host);
		}, onEnd);
	}
	
	
	public static function get16from32(i:Int):Int{
		var b = Bytes.alloc(2);
		b.setUInt16(0,i);
		return b.getUInt16(0);
	}
}

class Client{
	public var conn:Null<TcpConnection>;
	public var id:Int;
	public var host:String;
	public var over:Null<Int> = null;
	
	public function new(?c:TcpConnection){
		conn = c;
		if (conn != null){
			host = conn.sock.peer().host.toString();
			id = NetworkManager.get16from32(Crc32.make(Bytes.ofString(host)));
			conn.recvUShort(getMessage);
		}
	}
	
	private function getMessage(b:Int){
		conn.recvBytes(function(bytes:Bytes){
			NetworkManager.proceedMessage(bytes, id);
		}, b);
		conn.recvUShort(getMessage);
	}
}

class MsgType{
	public static inline var CLIENTINFO:Int = 1;
	public static inline var SOUND:Int = 2;
	public static inline var ASKCLIENTINFO:Int = 3;
	public static inline var DEBUG:Int = 4;
}