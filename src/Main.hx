package;

import haxe.io.Bytes;
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

class Main {
	private static var _main:Null<Component>;
	static var app:HaxeUIApp;
	static var _conn:TcpConnection;
	
    public static function main() {
		socketTest();
        //Toolkit.scale = 2.5;
        //Toolkit.theme = "native";
		Toolkit.autoScale = true;
        app = new HaxeUIApp();
        app.ready(function() {
            _main = ComponentMacros.buildComponent("assets/ui/init.xml");

            app.addComponent(_main);

			cast(_main.findComponent("connect"), Button).onClick = function(e:MouseEvent){
				trace(cast(_main.findComponent("host"), TextField).text);
				trace(Std.parseInt(cast(_main.findComponent("port"), TextField).text));
				(new TcpConnection()).connect(
					cast(_main.findComponent("host"), TextField).text,
					Std.parseInt(cast(_main.findComponent("port"), TextField).text),
					function(conn:TcpConnection){
						trace("connected");
						_conn = conn;
						_conn.sendShort(0);
						switchToConn();
						_conn.sendString("qweqeqeq");
					},
					function(e:Dynamic){
						trace(e);
					}
				);
			};
			cast(_main.findComponent("server"),Button).onClick = function(e:MouseEvent){	
				(new TcpConnection()).listen(
					Std.parseInt(cast(_main.findComponent("port"), TextField).text),
					function(conn:TcpConnection){
						_conn = conn;
						switchToConn();
						_conn.sendString("qweqeqeq");
					},
					function(conn:TcpConnection){
						trace("started");
						_main.removeComponent(_main.findComponent("server"));
					},
					function(e:Dynamic){
						trace(e);
					}
				);
			};
            app.start();
        });
    }
		
	static function receiver(s:String){
		trace("got " + s);
		cast(_main.findComponent("text"), TextArea).text += s + "\n";
		_conn.recvString(receiver);
	}
	
	private static function switchToConn(){
		if (_main != null)
			app.removeComponent(_main);
		_main = ComponentMacros.buildComponent("assets/ui/conn.xml");
		app.addComponent(_main);
		cast(_main.findComponent("send"), Button).onClick = function(e:MouseEvent){
			trace("send " +cast(_main.findComponent("message"), TextField).text);
			_conn.sendString(cast(_main.findComponent("message"), TextField).text);
		};
		_conn.recvString(receiver);
	}
	
	
	
	static function socketTest(){
		#if !flash
		(new TcpConnection()).listen(8030, function(conn:TcpConnection){
			trace("send testString");
			conn.sendString("testString");
			conn.recvString(function(s:String){
				trace(s);
				conn.sendInt(100500);
				conn.recvString(function(s:String){
					trace(s);
					conn.sendBytes(Bytes.ofString("Good"));
					conn.recvString(function(s:String){
						trace(s);
					});
				});
			});
		}, function(e:TcpConnection){
			trace(e);
		}, function(e:Dynamic){
			trace(e);
		});
		Sys.sleep(2);
	#end
		var t:TcpConnection = new TcpConnection();
		trace("test");
		t.connect("localhost", 8030, function(tt:TcpConnection){
			tt.sendShort(0);
			tt.recvString(function(s:String){
				trace("connected");
				trace(s); 
				tt.sendString("Good");
				tt.recvInt(function(i:Int){
					trace(i);
					tt.sendString("Good2");
					tt.recvBytes(function(b:Bytes){
						trace(b);
						tt.close();
						tt.recvFloat(function(f:Float){
							trace(f);
						});
					}, 4);
				});
			}); 
		}, function(e:Dynamic){
			trace(e); 
		});
	}
}
