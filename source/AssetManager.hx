package;

import lime.app.Future;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import openfl.media.Sound;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

@:enum abstract AssetType(String) to String
{
	var IMAGE = 'image';
	var SPARROW = 'sparrow';
	var SOUND = 'sound';
	var FONT = 'font';
	var DIRECTORY = 'directory';
	var MODULE = 'module';
	var JSON = 'json';
}

@:enum abstract EngineImplementation(String) to String
{
	var FNF;
	var FNF_LEGACY;
	var FOREVER;
	var PSYCH;
}

typedef Pack =
{
	var name:String;
}

/*
 * This is the Asset Manager class, it manages the asset usage in the engine.
 * It's meant to both allow access to assets and at the same time manage and catalogue used assets.
 */
class AssetManager
{
	public static var keyedAssets:Map<String, Dynamic> = [];

	/**
	 * Returns an Asset based on the parameters and groups given.
	 * @param directory The asset directory, from within the assets folder (excluding 'assets/')
	 * @param group The asset group used to index the asset, like IMAGES or SONGS
	 * @return Dynamic
	 */
	public static function getAsset(directory:String, ?type:AssetType = DIRECTORY, ?group:String):Dynamic
	{
		var gottenPath = getPath(directory, group, type);
		switch (type)
		{
			case JSON:
				return #if sys File.getContent(gottenPath); #else Assets.getText(gottenPath); #end
			case IMAGE:
				return returnGraphic(gottenPath, false);
			case SPARROW:
				var graphicPath = getPath(directory, group, IMAGE);
				trace('sparrow graphic path $graphicPath');
				var graphic:FlxGraphic = returnGraphic(graphicPath, true);
				trace('sparrow xml path $gottenPath');
				return FlxAtlasFrames.fromSparrow(graphic, #if sys File.getContent(gottenPath) #else Assets.getText(gottenPath) #end);
			default:
				trace('returning directory $gottenPath');
				return gottenPath;
		}
		trace('returning null for $gottenPath');
		return null;
	}

	/**
	 * Returns a graphic or image as a bitmap readable by the game. 
	 * 
	 * It is not recommended to use this function unless you want to access 
	 * a specific directory or access GPU resources as getAsset(directory, IMAGE); 
	 * already provides a similar function that takes into account packs.
	 * 
	 * @param key The asset directory in its entirety. 
	 * @param textureCompression If the image should be rendered by the GPU. (default is false)
	 */
	public static function returnGraphic(key:String, ?textureCompression:Bool = false)
	{
		if (#if sys FileSystem.exists(key) #else Assets.exists(key) #end)
		{
			if (!keyedAssets.exists(key))
			{
				var newGraphic:FlxGraphic;

				#if !html5
				var bitmap = BitmapData.fromFile(key);
				if (textureCompression)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
					texture.uploadFromBitmapData(bitmap);
					keyedAssets.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					trace('new texture $key, bitmap is $bitmap');
					newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
				}
				else
				{
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
					trace('new bitmap $key, not textured');
				}
				#else
				newGraphic = FlxG.bitmap.add(key, false, key);
				#end
				localTrackedAssets.push(key);
				keyedAssets.set(key, newGraphic);
			}
			trace('graphic returning $key with gpu rendering $textureCompression');
			return keyedAssets.get(key);
		}
		trace('graphic returning null at $key with gpu rendering $textureCompression');
		return null;
	}

	/**
	 * [Returns a Sound when given a Key]
	 * @param key The asset directory in its entirety. 
	 */
	public static function returnSound(key:String)
	{
		if (#if sys FileSystem.exists(key) #else Assets.exists(key) #end)
		{
			if (!keyedAssets.exists(key))
			{
				#if html5
				keyedAssets.set(key, OpenFlAssets.getSound(key));
				#else
				keyedAssets.set(key, Sound.fromFile('./' + key));
				#end
				trace('new sound $key');
			}
			trace('sound returning $key');
			return keyedAssets.get(key);
		}
		trace('sound returning null at $key');
		return null;
	}

	/**
	 * Returns the path for an asset with avaliabled keyed assets and paths. Alternatively use getAsset(directory, DIRECTORY);
	 * @param directory The asset directory, from within the assets folder (excluding 'assets/')
	 * @param group The asset group used to index the asset, like IMAGES or SONGS
	 * @return String
	 */
	public static function getPath(directory:String, group:String, ?type:AssetType = DIRECTORY):String
	{
		var pathBase:String = 'assets/';
		var directoryExtension:String = '$group/$directory';
		return filterExtensions('$pathBase$directoryExtension', type);
	}

	public static function filterExtensions(directory:String, type:String)
	{
		if (! #if sys FileSystem.exists(directory) #else Assets.exists(directory) #end)
		{
			var extensions:Array<String> = [];
			switch (type)
			{
				case IMAGE:
					extensions = ['.png'];
				case JSON:
					extensions = ['.json'];
				case SPARROW:
					extensions = ['.xml'];
				case SOUND:
					extensions = ['.ogg', '.wav'];
				case FONT:
					extensions = ['.ttf'];
				case MODULE:
					extensions = ['.hxs'];
			}
			trace(extensions);
			// apply the extension of the directory
			for (i in extensions)
			{
				var returnDirectory:String = '$directory$i';
				trace('attempting directory $returnDirectory');
				if (#if sys FileSystem.exists(returnDirectory) #else Assets.exists(returnDirectory) #end)
				{
					trace('successful extension $i');
					return returnDirectory;
				}
			}
		}
		trace('no extension needed, returning $directory');
		return directory;
	}

	//using 0.5.2h cleaning mem feature
	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/tea-time.ogg'
	];

	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in keyedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) 
				&& !dumpExclusions.contains(key)) {
				// get rid of it
				var obj = keyedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					//obj.destroy(); i guess this fixed the thing
					keyedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		#if sys
		openfl.system.System.gc();
		#end
	}

	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !keyedAssets.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		localTrackedAssets = [];

		/* this will probably break everything
		// clear all sounds that are cached
		for (key in keyedAssets.keys()) {
			if (!dumpExclusions.contains(key) && key != null) {
				//trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				keyedAssets.remove(key);
			}
		}	
		// flags everything to be cleared out next unused memory clear
		openfl.Assets.cache.clear("songs");*/
	}

	public static function getAlphabet() 
	{
		//dumb ass graphics not working properly, just gonna throw the image and sparrow hardcoded
		return FlxAtlasFrames.fromSparrow('assets/images/alphabet.png', #if sys File.getContent #else Assets.getText #end ('assets/images/alphabet.xml'));
	}
}
