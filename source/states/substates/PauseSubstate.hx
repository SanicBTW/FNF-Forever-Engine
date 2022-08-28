package states.substates;

import extra.SongSelectionState;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import extra.Item;
import states.MusicBeatState;
import base.Conductor;

//heavily inspired by my psych 0.3.2h repo pause substate
class PauseSubstate extends MusicBeatSubState 
{
    var grpMenuShit:FlxTypedGroup<Item>;

    var menuItems:Array<String> = ['Resume', 'Exit to song selection'];
    var curSelected:Int = 0;

    var pauseMusic:FlxSound;

    public function new(x:Float, y:Float)
    {
        super();

        //its just tea time from psych 0.5.2h
        pauseMusic = new FlxSound().loadEmbedded(AssetManager.getAsset('song-selection-music', SOUND, "music"), true, false);
        pauseMusic.volume = 0;
        pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

        FlxG.sound.list.add(pauseMusic);

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

        grpMenuShit = new FlxTypedGroup<Item>();
        add(grpMenuShit);

        var curPos = 270;
        for(i in 0...menuItems.length)
        {
            grpMenuShit.add(new Item(menuItems[i], 0, curPos - 50, i));
            curPos -= 50;
        }

        changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float)
    {
        if(pauseMusic.volume < 0.5)
            pauseMusic.volume += 0.01 * elapsed;

        super.update(elapsed);

        if(FlxG.keys.justPressed.UP)
            changeSelection(-1);
        if(FlxG.keys.justPressed.DOWN)
            changeSelection(1);

        if(FlxG.keys.justPressed.ENTER)
        {
            switch(menuItems[curSelected])
            {
                case "Resume":
                    PlayState.paused = false;
                    Conductor.resyncTime();
                    Conductor.boundSong.play();
                    Conductor.boundVocals.play();

                    close();

                case 'Exit to song selection':
                    FlxG.switchState(new extra.SongSelectionState());
            }
        }
    }

    override function destroy()
    {
        pauseMusic.destroy();

        super.destroy();
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = menuItems.length - 1;
        if(curSelected >= menuItems.length)
            curSelected = 0;

        grpMenuShit.forEach(function(menuItem:Item)
        {
            menuItem.bg.color = FlxColor.WHITE;

            if(menuItem.ID == curSelected)
            {
                menuItem.bg.color = FlxColor.GRAY;
            }
        });
    }
}