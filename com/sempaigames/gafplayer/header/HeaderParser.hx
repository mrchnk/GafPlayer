package com.sempaigames.gafplayer.header;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import openfl.Assets;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.utils.CompressionAlgorithm;

class HeaderParser {

	public static function parse (bytes : ByteArray) : { header : Header, body : ByteArray } {

		var header = new Header();

		bytes.endian = Endian.LITTLE_ENDIAN;
		var footprint = bytes.readUnsignedInt();

		var valid = (footprint == 0x00474146) || (footprint == 0x00474143);
		if (!valid) throw "Data is not a valid GAF file";

		var compressed = (footprint == 0x00474143);

		header.majorVersion = bytes.readUnsignedByte();
		header.minorVersion = bytes.readUnsignedByte();

		var fileLength = bytes.readUnsignedInt();

		var headerEnd = new ByteArray();
		headerEnd.endian = Endian.LITTLE_ENDIAN;
		bytes.readBytes(headerEnd, 0, bytes.bytesAvailable);
		if (compressed) {
			headerEnd.uncompress(CompressionAlgorithm.ZLIB);
		}
		if (headerEnd.length != fileLength) {
			throw "Data is corrupted";
		}

		if (header.majorVersion>=4) {
			readHeaderEndV4(headerEnd, header);
		} else {
			throw "Older GAF format is not implemented";
		}

		return { header : header, body : headerEnd };

	}

	public static function readHeaderEndV4 (bytes : ByteArray, header : Header) {

		var scaleValuesCount = bytes.readUnsignedInt();
		header.scaleValues = [];
		while (scaleValuesCount>0) {
			header.scaleValues.push(bytes.readFloat());
			scaleValuesCount--;
		}

		var csfValuesCount = bytes.readUnsignedInt();
		header.csfValues = [];
		while (csfValuesCount>0) {
			header.csfValues.push(bytes.readFloat());
			csfValuesCount--;
		}

	}

	public static function loadFromFile (path : String) {
		var bytes = Assets.getBytes(path);
		return HeaderParser.parse(bytes);
	}

}
