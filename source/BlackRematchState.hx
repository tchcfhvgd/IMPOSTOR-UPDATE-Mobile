package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

#if sys
import sys.FileSystem;
#end

class BlackRematchState extends MusicBeatState
{

	override function create()
	{
		super.create();

        startVideo('finale');
    }

   function goToMenu(){
        if(ClientPrefs.finaleState != NOT_PLAYED || ClientPrefs.finaleState != COMPLETED)
            ClientPrefs.finaleState = NOT_PLAYED;

        ClientPrefs.saveSettings();
        LoadingState.loadAndSwitchState(new TitleState(), true);
   }

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

    public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			goToMenu();
			return;
		}

		var video:FlxVideo = new FlxVideo();
		video.load(filepath);
		video.play();
		video.onEndReached.add(function()
		{
			video.dispose();
			goToMenu();
			return;
		}, true);

		#else
		FlxG.log.warn('Platform not supported!');
		goToMenu();
		return;
		#end
	}

}
