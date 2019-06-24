package util;
import haxe.io.Bytes;
import haxe.ui.assets.ImageInfo;
import haxe.ui.components.Image;
import haxe.ui.core.ImageDisplay;
import openfl.display.BitmapData;

/**
 * ...
 * @author ...
 */
class ImageUtils
{
	public static function setImage(image:Image, data:Bytes){
		var display:ImageDisplay = image.getImageDisplay();
		if (display != null) {
			var bitmap:BitmapData = BitmapData.fromBytes(data);
			var imageInfo:ImageInfo = {data:bitmap, width:bitmap.width, height:bitmap.height};
			display.imageInfo = imageInfo;
			//image._originalSize = new Size(imageInfo.width, imageInfo.height);
			//if (image.autoSize() == true && image.parentComponent != null) {
			//	image.parentComponent.invalidateComponentLayout();
			//}
			//image.validateLayout();
			display.validate();
			image.width = imageInfo.width;
			image.height = imageInfo.height;
		}
	}
	//TileProvider.loadTile(2481, 1277, 12, function(b:Null<Bytes>){if (b!=null) ImageUtils.setImage(cast(_comp.findComponent("image"), Image), b); } );

}