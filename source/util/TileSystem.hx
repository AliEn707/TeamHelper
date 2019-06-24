package util;
import haxe.io.Bytes;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;

/**
 * ...
 * @author ...
 */
//------------------------------------------------------------------------------  
//original
// <copyright company="Microsoft">  
//     Copyright (c) 2006-2009 Microsoft Corporation.  All rights reserved.  
// </copyright>
//moved to haxe by Yarikov Dennis
//------------------------------------------------------------------------------   

class TileSystem{  
	private static inline var EarthRadius:Float = 6378137;  
	private static inline var MinLatitude:Float = -85.05112878;  
	private static inline var MaxLatitude:Float = 85.05112878;  
	private static inline var MinLongitude:Float = -180;  
	private static inline var MaxLongitude:Float = 180;  

	/// <summary>  
	/// Clips a number to the specified minimum and maximum values.  
	/// </summary>  
	/// <param name="n">The number to clip.</param>  
	/// <param name="minValue">Minimum allowable value.</param>  
	/// <param name="maxValue">Maximum allowable value.</param>  
	/// <returns>The clipped value.</returns>  
	private static function Clip(n:Float, minValue:Float, maxValue:Float):Float{  
		return Math.min(Math.max(n, minValue), maxValue);
	}  

	/// <summary>  
	/// Determines the map width and height (in pixels) at a specified level  
	/// of detail.  
	/// </summary>  
	/// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)  
	/// to 23 (highest detail).</param>  
	/// <returns>The map width and height in pixels.</returns>  
	public static function MapSize(levelOfDetail:Int):Int{  
		return 256 << levelOfDetail;  
	}  

	/// <summary>  
	/// Determines the ground resolution (in meters per pixel) at a specified  
	/// latitude and level of detail.  
	/// </summary>  
	/// <param name="latitude">Latitude (in degrees) at which to measure the  
	/// ground resolution.</param>  
	/// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)  
	/// to 23 (highest detail).</param>  
	/// <returns>The ground resolution, in meters per pixel.</returns>  
	public static function GroundResolution(latitude:Float, levelOfDetail:Int):Float{  
		latitude = Clip(latitude, MinLatitude, MaxLatitude);  
		return Math.cos(latitude * Math.PI / 180) * 2 * Math.PI * EarthRadius / MapSize(levelOfDetail);  
	}  

	/// <summary>  
	/// Determines the map scale at a specified latitude, level of detail,  
	/// and screen resolution.  
	/// </summary>  
	/// <param name="latitude">Latitude (in degrees) at which to measure the  
	/// map scale.</param>  
	/// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)  
	/// to 23 (highest detail).</param>  
	/// <param name="screenDpi">Resolution of the screen, in dots per inch.</param>  
	/// <returns>The map scale, expressed as the denominator N of the ratio 1 : N.</returns>  
	public static function MapScale(latitude:Float, levelOfDetail:Int, screenDpi:Int):Float{  
		return GroundResolution(latitude, levelOfDetail) * screenDpi / 0.0254;  
	}  

	/// <summary>  
	/// Converts a point from latitude/longitude WGS-84 coordinates (in degrees)  
	/// into pixel XY coordinates at a specified level of detail.  
	/// </summary>  
	/// <param name="latitude">Latitude of the point, in degrees.</param>  
	/// <param name="longitude">Longitude of the point, in degrees.</param>  
	/// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)  
	/// to 23 (highest detail).</param>  
	/// <param name="pixelX">Output parameter receiving the X coordinate in pixels.</param>  
	/// <param name="pixelY">Output parameter receiving the Y coordinate in pixels.</param>  
	public static function LatLongToPixelXY(latitude:Float, longitude:Float,levelOfDetail:Int):{x:Int,y:Int}{
		latitude = Clip(latitude, MinLatitude, MaxLatitude);  
		longitude = Clip(longitude, MinLongitude, MaxLongitude);  

		var x:Float = (longitude + 180) / 360;   
		var sinLatitude:Float = Math.sin(latitude * Math.PI / 180);  
		var y:Float = 0.5 - Math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * Math.PI);  

		var mapSize:Int = MapSize(levelOfDetail);  
		return {x:Math.floor(Clip(x * mapSize + 0.5, 0, mapSize - 1)),
				y:Math.floor(Clip(y * mapSize + 0.5, 0, mapSize - 1))}  
	}  

	/// <summary>  
	/// Converts a pixel from pixel XY coordinates at a specified level of detail  
	/// into latitude/longitude WGS-84 coordinates (in degrees).  
	/// </summary>  
	/// <param name="pixelX">X coordinate of the point, in pixels.</param>  
	/// <param name="pixelY">Y coordinates of the point, in pixels.</param>  
	/// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)  
	/// to 23 (highest detail).</param>  
	/// <param name="latitude">Output parameter receiving the latitude in degrees.</param>  
	/// <param name="longitude">Output parameter receiving the longitude in degrees.</param>  
	public static function PixelXYToLatLong(pixelX:Int, pixelY:Int, levelOfDetail:Int):{lat:Float, lng:Float}{  
		var mapSize:Float = MapSize(levelOfDetail);  
		var x:Float = (Clip(pixelX, 0, mapSize - 1) / mapSize) - 0.5;  
		var y:Float = 0.5 - (Clip(pixelY, 0, mapSize - 1) / mapSize);  

		return {lat:90 - 360 * Math.atan(Math.exp(-y * 2 * Math.PI)) / Math.PI, 
			lng:360 * x};  
	}  

	/// <summary>  
	/// Converts pixel XY coordinates into tile XY coordinates of the tile containing  
	/// the specified pixel.  
	/// </summary>  
	/// <param name="pixelX">Pixel X coordinate.</param>  
	/// <param name="pixelY">Pixel Y coordinate.</param>  
	/// <param name="tileX">Output parameter receiving the tile X coordinate.</param>  
	/// <param name="tileY">Output parameter receiving the tile Y coordinate.</param>  
	public static function PixelXYToTileXY(pixelX:Int, pixelY:Int):{x:Int,y:Int}{  
		return {x:Math.floor(pixelX / 256),  
				y:Math.floor(pixelY / 256)};  
	}  

	/// <summary>  
	/// Converts tile XY coordinates into pixel XY coordinates of the upper-left pixel  
	/// of the specified tile.  
	/// </summary>  
	/// <param name="tileX">Tile X coordinate.</param>  
	/// <param name="tileY">Tile Y coordinate.</param>  
	/// <param name="pixelX">Output parameter receiving the pixel X coordinate.</param>  
	/// <param name="pixelY">Output parameter receiving the pixel Y coordinate.</param>  
	public static function TileXYToPixelXY(tileX:Int, tileY:Int):{x:Int,y:Int}{
		return {x:tileX * 256,
				y:tileY * 256};  
	}  

	/// <summary>  
	/// Converts tile XY coordinates into a QuadKey at a specified level of detail.  
	/// </summary>  
	/// <param name="tileX">Tile X coordinate.</param>  
	/// <param name="tileY">Tile Y coordinate.</param>  
	/// <param name="levelOfDetail">Level of detail, from 1 (lowest detail)  
	/// to 23 (highest detail).</param>  
	/// <returns>A string containing the QuadKey.</returns>  
	public static function TileXYToQuadKey(tileX:Int, tileY:Int, levelOfDetail:Int):String{  
		var quadKey:String = "";  
		var i = levelOfDetail;
		while (i>0){  
			trace(i);
			var digit:Int = 0;  
			var mask:Int = 1 << (i - 1);  
			if ((tileX & mask) != 0)  
			{  
				digit++;  
			}  
			if ((tileY & mask) != 0)  
			{  
				digit++;  
				digit++;  
			}  
			quadKey += (digit);  
			i--;
		}  
		return quadKey;  
	}  

	/// <summary>  
	/// Converts a QuadKey into tile XY coordinates.  
	/// </summary>  
	/// <param name="quadKey">QuadKey of the tile.</param>  
	/// <param name="tileX">Output parameter receiving the tile X coordinate.</param>  
	/// <param name="tileY">Output parameter receiving the tile Y coordinate.</param>  
	/// <param name="levelOfDetail">Output parameter receiving the level of detail.</param>  
	public static function QuadKeyToTileXY(quadKey:String):{x:Int, y:Int, l:Int}{  
		var tileX:Int = 0; 
		var tileY:Int = 0;  
		var levelOfDetail:Int = quadKey.length;  
		var i = levelOfDetail;
		while (i>0){  
			var mask:Int = 1 << (i - 1);  
			switch (quadKey.charAt(levelOfDetail - i)){  
				case '0':   

				case '1':  
					tileX |= mask;   

				case '2':  
					tileY |= mask;   

				case '3':  
					tileX |= mask;  
					tileY |= mask;  

				default:  
//					throw new ArgumentException("Invalid QuadKey digit sequence.");  
			}  
			i--;
		}  
		return {x:tileX, y:tileY, l:levelOfDetail};
	}  
}  

class TileProvider{
	public static var provider:Int->Int->Int->String = OSM;
	public static function OSM(x:Int, y:Int, z:Int):String{return "http://tile.openstreetmap.org/"+z+"/"+x+"/"+y+".png";}	
	public static function OSMHot(x:Int, y:Int, z:Int):String{return "http://tile.openstreetmap.fr/hot/"+z+"/"+x+"/"+y+".png";}	
	public static function OSMGPS(x:Int, y:Int, z:Int):String{return "https://gps-tile.openstreetmap.org/lines/"+z+"/"+x+"/"+y+".png";}	
	public static function OpenTopoMap(x:Int, y:Int, z:Int):String{return "https://tile.opentopomap.org/"+z+"/"+x+"/"+y+".png";}
    public static function WmflabsHikeBike(x:Int, y:Int, z:Int):String{return "https://tiles.wmflabs.org/hikebike/"+z+"/"+x+"/"+y+".png";}	
	public static function WmflabsHillshading(x:Int, y:Int, z:Int):String{return "http://tiles.wmflabs.org/hillshading/"+z+"/"+x+"/"+y+".png";}	
	public static function OSMMapnicGS(x:Int, y:Int, z:Int):String{return "https://tiles.wmflabs.org/bw-mapnik/"+z+"/"+x+"/"+y+".png";}	
	public static function OSMNoLabels(x:Int, y:Int, z:Int):String{return "https://tiles.wmflabs.org/osm-no-labels/"+z+"/"+x+"/"+y+".png";}	
	public static function Sputnik(x:Int, y:Int, z:Int):String{return "http://tiles.maps.sputnik.ru/"+z+"/"+x+"/"+y+".png";}	
	public static function Google(x:Int, y:Int, z:Int):String{return "http://mt.google.com/vt/lyrs=m&x="+x+"&y="+y+"&z="+z;}
	public static function GoogleSatelite(x:Int, y:Int, z:Int):String{return "http://mt.google.com/vt/lyrs=s&x="+x+"&y="+y+"&z="+z;}
	public static function GoogleHybrig(x:Int, y:Int, z:Int):String{return "http://mt.google.com/vt/lyrs=y&x="+x+"&y="+y+"&z="+z;}
	public static function Wikimapia(x:Int, y:Int, z:Int):String{return "http://i" + (x % 4 + (y % 4) * 4) + ".wikimapia.org/?x=" + x + "&y=" + y + "&zoom=" + z + "&r=0&type=hybrid&lng=1"; }
    public static function StamenToner(x:Int, y:Int, z:Int):String{return "http://tile.stamen.com/toner/"+z+"/"+x+"/"+y+".png";}
    public static function StamenTerrain(x:Int, y:Int, z:Int):String{return "http://tile.stamen.com/terrain/"+z+"/"+x+"/"+y+".jpg";}
    public static function StamenWatercolor(x:Int, y:Int, z:Int):String{return "http://tile.stamen.com/watercolor/"+z+"/"+x+"/"+y+".jpg";}
    public static function TFCycle(x:Int, y:Int, z:Int):String{return "https://tile.thunderforest.com/cycle/"+z+"/"+x+"/"+y+".png";}
    public static function TFTransport(x:Int, y:Int, z:Int):String{return "http://tile.thunderforest.com/transport/"+z+"/"+x+"/"+y+".png";}
    public static function TFLandscape(x:Int, y:Int, z:Int):String{return "http://tile.thunderforest.com/landscape/"+z+"/"+x+"/"+y+".png";}
    public static function TFOutdoors(x:Int, y:Int, z:Int):String{return "http://tile.thunderforest.com/outdoors/"+z+"/"+x+"/"+y+".png";}
    public static function CartoLight(x:Int, y:Int, z:Int):String{return "https://cartodb-basemaps-"+Std.random(4)+".global.ssl.fastly.net/light_all/"+z+"/"+x+"/"+y+".png";}
    public static function CartoDark(x:Int, y:Int, z:Int):String{return "https://cartodb-basemaps-"+Std.random(4)+".global.ssl.fastly.net/dark_all/"+z+"/"+x+"/"+y+".png";}
    public static function BingSatelite(x:Int, y:Int, z:Int):String{return "http://ecn.t"+Std.random(4)+".tiles.virtualearth.net/tiles/a"+TileSystem.TileXYToQuadKey(x,y,z)+".jpeg?g=715";}
    public static function Yandex(x:Int, y:Int, z:Int):String{return "https://vec0"+Std.random(4)+".maps.yandex.net/tiles?l=map&x="+x+"&y="+y+"&z="+z+"&scale=1&lang=ru_RU";}
    public static function YandexSatelite(x:Int, y:Int, z:Int):String{return "https://sat0"+Std.random(4)+".maps.yandex.net/tiles?l=sat&x="+x+"&y="+y+"&z="+z+"&scale=1&lang=ru_RU";}
    public static function NightEarth(x:Int, y:Int, z:Int):String{return "http://www.nightearth.com/nightmaps2012/"+z+"/"+x+"/"+y+".png";}
	
	//public static function NokiaHERE(x:Int, y:Int, z:Int):String{return "https://" + Std.random(4) + ".base.maps.api.here.com/maptile/2.1/maptile/d1700f0f76/normal.day/" + z + "/" + x + "/" + y + "/256/png8?app_id=VgTVFr1a0dddftasdd1qGcLCVJ6&app_code=LJXqQ8ErW7aaa1UsRUK3R33Ow&lg=rus&ppi=72&pview=RUS";}
	
	public static function loadTile(x:Int, y:Int, z:Int, callback:Null<Bytes>->Void){
		var loader = new URLLoader();
		var status = 0;
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener( Event.COMPLETE, function (event:Event){
			if ( status == 200 ) {	// 200 is a successful HTTP status
				try{
					var b:Bytes = Bytes.ofString(cast(event.target, URLLoader).data.toString()); //TODO: improve
					callback(b);
					loader.close();
					return;
				}catch(e:Dynamic){
				}
			}
			callback(null);
		});
		loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, function(event:HTTPStatusEvent){
			status = event.status; // Hopefully this is 200
		});
		loader.addEventListener( IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):Void {
			callback(null);
		});
		loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):Void {
			callback(null);
		});
		//loader.contentLoaderInfo.addEventListener( Event.OPEN, onOpen );
		//loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgress );
		try{
			loader.load(new URLRequest(provider(x, y, z)));
			trace(provider(x, y, z));
		}catch (e:Dynamic){
			callback(null);
		}
	}

}