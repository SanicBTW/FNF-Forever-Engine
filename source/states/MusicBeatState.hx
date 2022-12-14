package states;

import extra.SongSelectionState;
import flixel.FlxG;
import base.Conductor;
import flixel.FlxBasic;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUISubState;
import states.ScriptableState.ScriptableSubState;

/**
 * The Music Beat State, bindable to the Conductor through implementing the Music Handler
 */
class MusicBeatState extends ScriptableState implements MusicHandler
{
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateContents(elapsed);
	}

	public function updateContents(elapsed:Float)
	{
		if (Conductor.boundState == this && Conductor.boundSong != null)
			Conductor.updateTimePosition(elapsed);
	}

	override public function onFocusLost()
	{
		if (Conductor.boundState == this)
			Conductor.onFocusLost();
	}

	override public function onFocus()
	{
		if (Conductor.boundState == this)
			Conductor.onFocus();
	}

	public function beatHit() {}

	public function stepHit() {}

	public function finishSong() 
	{
		FlxG.switchState(new SongSelectionState());
	}
}

class MusicBeatSubState extends ScriptableSubState implements MusicHandler
{
	// create a new music beat state
	public function new()
	{
		super();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateContents(elapsed);
	}

	public function updateContents(elapsed:Float)
	{
		if (Conductor.boundState == this && Conductor.boundSong != null)
			Conductor.updateTimePosition(elapsed);
	}

	override public function onFocusLost()
	{
		if (Conductor.boundState == this)
			Conductor.onFocusLost();
	}

	override public function onFocus()
	{
		if (Conductor.boundState == this)
			Conductor.onFocus();
	}

	public function beatHit() {}

	public function stepHit() {}

	public function finishSong() {}
}

interface MusicHandler
{
	public function updateContents(elapsed:Float):Void;
	public function beatHit():Void;
	public function stepHit():Void;
	public function finishSong():Void;
	public function add(basic:FlxBasic):FlxBasic;
}
