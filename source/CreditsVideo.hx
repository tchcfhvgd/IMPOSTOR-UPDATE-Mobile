package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

using StringTools;

class CreditsVideo extends FlxState
{
	var titleState = new TitleState();

	override public function create():Void
	{

		super.create();

		#if VIDEOS_ALLOWED
		var filepath:String = Paths.video('credits');
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + 'credits');
			next();
			return;
		}

		var video:FlxVideo = new FlxVideo();
		video.load(filepath);
		video.play();
		video.onEndReached.add(function()
		{
			video.dispose();
			next();
			return;
		}, true);

		#else
		FlxG.log.warn('Platform not supported!');
		next();
		return;
		#end

	}

	override public function update(elapsed:Float){

		super.update(elapsed);

	}

	function next():Void{
		FlxG.switchState(titleState);
	}
	
}
