package com.sempaigames.gafplayer.display.spritesimpl;

import com.sempaigames.gafplayer.tags.TagDefineAtlas;
import com.sempaigames.gafplayer.tags.TagDefineAtlas.Element;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;

class Atlas {

	public var elements : Map<Int, BitmapData>;
	public var elementsData : Map<Int, Element>;

	public function new () {
		elements = new Map<Int, BitmapData>();
		elementsData = new Map<Int, Element>();
	}

	public function fromTag (from : TagDefineAtlas, bitmap: BitmapData = null) : Void {
		function getAtlasBitmap(index : Int) : BitmapData {
			if (bitmap != null) {
				return bitmap;
			}
			for (atlas in from.atlases) {
				if (atlas.id != index) continue;
				if (atlas.sources.length > 0) {
					return Assets.getBitmapData(Parser.assetsPrefix + atlas.sources[0].fileName);
				}
			}
			return null;
		}
		for (element in from.elements) {
			var elementBitmap : BitmapData = null;
			var atlasBitmap = getAtlasBitmap(element.atlasIndex);
			if (atlasBitmap == null) continue;
			elementBitmap = new BitmapData(Std.int(element.width), Std.int(element.height));
			elementBitmap.copyPixels(
				atlasBitmap,
				new Rectangle(element.origin.x, element.origin.y, element.width, element.height),
				new Point(0, 0)
			);
			elements[element.elementAtlasIndex] = elementBitmap;
			elementsData[element.elementAtlasIndex] = element;
		}
	}

}
