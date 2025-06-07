package;

import openfl.system.System;
import openfl.utils.AssetCache;
import cpp.vm.Gc;
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
#if mobile
import mobile.CopyState;
#end

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsCounter:FPS;
	public static var fpsVar:FPS;
	

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		CrashHandler.init();

		#if windows
		@:functionCode("
		#include <windows.h>
		#include <winuser.h>
		setProcessDPIAware() // allows for more crisp visuals
		DisableProcessWindowsGhosting() // lets you move the window and such if it's not responding
		")
		#end
		
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}
	

	private function setupGame():Void
	{
		ClientPrefs.startControls();

		// Paths.getModFolders();
		addChild(new FlxGame(gameWidth, gameHeight, #if (mobile && MODS_ALLOWED) !CopyState.checkExistingFiles() ? CopyState : #end initialState, framerate, framerate, skipSplash, startFullscreen));

		FlxG.signals.gameResized.add(onResizeGame);
		FlxG.signals.preStateSwitch.add(function () {
	    Paths.clearStoredMemory(true);
		FlxG.bitmap.dumpCache();
		});
	    FlxG.signals.postStateSwitch.add(function () {
		Paths.clearUnusedMemory();
		trace(System.totalMemory);
		});
		
		fpsCounter = new FPS(10, 5, 0xFFFFFF);
		#if !mobile
		addChild(fpsCounter);
		#else
		FlxG.game.addChild(fpsCounter);
		#end

		if(fpsCounter != null) { 
			fpsCounter.visible = ClientPrefs.showFPS;
		}

		trace(FlxG.save.path);

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if mobile
		lime.system.System.allowScreenTimeout = ClientPrefs.screensaver;
		#if android
		FlxG.android.preventDefaultKeys = [BACK]; 
		#end
		#end
	}

	function onResizeGame(w:Int, h:Int) {
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam.filters != null || cam.filters != []))
				fixShaderSize(cam);
		}	
		
	}

	function fixShaderSize(camera:FlxCamera) // Shout out to Ne_Eo for bringing this to my attention
		{
			@:privateAccess {
				var sprite:Sprite = camera.flashSprite;
	
				if (sprite != null)
				{
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
					sprite.__cacheBitmapData2 = null;
					sprite.__cacheBitmapData3 = null;
					sprite.__cacheBitmapColorTransform = null;
				}
			}
		}

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

}
