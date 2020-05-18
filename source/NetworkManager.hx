package;

import haxe.Timer.delay;
import haxe.crypto.Crc32;
import haxe.crypto.Md5;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
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
			var p:Packet = new Packet();
				p.type = MsgType.CLIENTINFO;
				p.addShort(id);//sender id
				p.addShort(id);//info id
				p.addString(host);
				p.addInt(Audiorecorder.RECORDER_SAMPLERATE);
				p.addInt(Audiorecorder.RECORDER_BITS);
				p.addInt(Audiorecorder.RECORDER_CHANNELS);
			//add other data
			conn.sendPacket(p);

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
			try{
				c.conn.close();
			}catch(e:Any){}
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
				p.type = MsgType.CLIENTINFO;
				p.addShort(id);//sender
				p.addShort(id);//info id
				p.addString(host);
				p.addInt(Audiorecorder.RECORDER_SAMPLERATE);
				p.addInt(Audiorecorder.RECORDER_BITS);
				p.addInt(Audiorecorder.RECORDER_CHANNELS);
			//add other data
			conn.sendPacket(p);
		}, function(e:Dynamic){
			if (fail != null)
				fail();
		});
	}	
	
	public static function broadcastSound(bytes:Bytes){
		var p:Packet = new Packet();
		p.type = MsgType.SOUND;
		p.addShort(id);
		p.addCompressGZIP(bytes);
		broadcastPacket(p, 0);
	}
	
	public static function broadcastPacket(p:Packet, except:Int){
		var bytes = p.getBytes();
		broadcastBytesSize(bytes, bytes.length, except);
	}

	public static function broadcastBytesSize(bytes:Bytes, length:Int, except:Int){
		_lock.lock();
			for (c in _channels){
				if (c.over==null && except!=c.id && c.conn!=null){
					c.conn.sendUShort(length);
					c.conn.sendBytes(bytes);
//					trace("sended");
				}
			}
		_lock.unlock();
	}
	
	private static var _handlers:Map<Int,Null<Packet->Client->Void>> = [
		MsgType.CLIENTINFO => function(p:Packet, from:Client){
			var client = getClient(p.chanks[1].data);
			if (client == null){//TODO: check if needed
				client = new Client();
				addClient(client);
				client.id = p.chanks[1].data;
				client.over = from.id;
			}
			client.host = p.chanks[2].data;
			SoundManager.addConfig(client.id, p.chanks[3].data, p.chanks[4].data, p.chanks[5].data);//TODO: add try catch
			trace("git client info " + p.chanks[1].data + " " + p.chanks[2].data);
		},
		MsgType.ASKCLIENTINFO => function(p:Packet, from:Client){
			var sender:Int = p.chanks[0].data;
			if (p.chanks[1].data == id){
				
			}else{
				var co:Null<Client> = getClient(p.chanks[1].data);
				if (co != null){
					var client = getClient(sender);
					if (client.conn!=null){
						var conf = SoundManager.getConfig(co.id);
						if (conf != null){
							var p:Packet = new Packet();
								p.addShort(id);
								p.addByte(MsgType.CLIENTINFO);
								p.addShort(co.id);
								p.addString(co.host);
								p.addInt(conf.stream.RECORDER_SAMPLERATE);
								p.addInt(conf.stream.RECORDER_BITS);
								p.addInt(conf.stream.RECORDER_CHANNELS);
							client.conn.sendPacket(p);
						}
					}
				}else if (_host!=null){//TODO: check if it needed
					var p:Packet = new Packet();
						p.type=MsgType.ASKCLIENTINFO;
						p.addShort(id);
						p.addShort(sender);		
					_host.sendPacket(p);
				}
			}
		}
	];
	
	public static function addMessageHandler(id:Int, h:Packet->Client->Void){
		_handlers[id] = h;
	}
	
	public static function proceedMessage(message:Bytes, from:Client){
		var p:Packet = Packet.fromBytes(message);
		var sender:Int = p.chanks[0].data;
		if (getClient(sender) == null){
			var c:Client = new Client();
			addClient(c);
			c.id = sender;
			c.over = from.id;
			//if we get info about client where we got package
			var p:Packet = new Packet();
				p.type=MsgType.ASKCLIENTINFO;
				p.addShort(id);
				p.addShort(c.id);		
			from.conn.sendPacket(p);
		}
//		trace(p.type);
//		trace(sender);
		try{
			_handlers[p.type](p, from);
		}catch(e:Dynamic){
			trace(e);
		}
	}
	
	private static function setId(conn:TcpConnection){
		host=conn.sock.host().host.toString();
		id = Packet.get16from32(Crc32.make(Bytes.ofString(host)));
/*		var c = new Client();
		c.id = id;
		c.host = host;
		addClient(c);
*/	}
	
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
	
	public static function findInLocal(callback:String->Void, onFinish:Array<Dynamic>->Void, arr:Array<Dynamic>){
		Thread.create(function(){
			var th:Thread = Thread.current();
			for (a in arr)
				Thread.create(function(e:Dynamic){
					e.access = TcpConnection.isAvailable(e.host, port);
					th.sendMessage(true);
					if (e.access)
						callback(e.host);
				}.bind(a));
			for (a in arr)
				Thread.readMessage(true);
			onFinish(arr);
		});
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
			trace(conn.sock.peer());
			trace(conn.sock.host());
			host = conn.sock.peer().host.toString();
			id = Packet.get16from32(Crc32.make(Bytes.ofString(host)));
			conn.recvUShort(getMessage);
			trace("Client added "+id);
		}
	}
	
	private function getMessage(b:Int){
		conn.recvBytes(function(bytes:Bytes){
			NetworkManager.proceedMessage(bytes, this);
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