package extra;

import openfl.system.System;
import flixel.text.FlxText;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Assets;
import flixel.FlxG;
import states.MusicBeatState;
import funkin.Alphabet;

//this is not bound to forever engine rewrite at all, i just wanted to add this in order to let people choose what song to play
class SongSelectionState extends MusicBeatState
{
    var songs:Map<String, Array<String>> = new Map();
    var difficulties:Array<String> = ["Easy", "Normal", "Hard"];
    var weeks:Array<String> = ["Tutorial", "Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"];

    var grpItems:FlxTypedGroup<Alphabet>;

    var menuItems:Array<String> = [];

    var bgMusic:FlxSound;
    var bg:FlxSprite;

    public static var curSong:String = "test";
    public static var curDifficulty:Int = 1;

    var curWeek:Int = 0;
    var curSelected:Int = 0;
    var selectingWeek:Bool = true;
    var selectingSong:Bool = false;

    var diffText:FlxText;

    var canAccept:Bool = true;

    override function create()
    {
		AssetManager.clearStoredMemory();
		AssetManager.clearUnusedMemory();

        menuItems = weeks;

        bgMusic = new FlxSound().loadEmbedded(AssetManager.getAsset('tea-time', SOUND, "music"), true, false);
        bgMusic.volume = 0.7;
        FlxG.sound.list.add(bgMusic);
        bgMusic.play();

        songs.set('Tutorial', [
            "tutorial",
            "test",
            "triple-trouble"
        ]);

        songs.set('Week 1', [
            "bopeebo",
            "fresh",
            "dadbattle"
        ]);

        songs.set('Week 2', [
            "spookeez",
            "south",
            "monster"
        ]);

        songs.set('Week 3', [
            "pico",
            "philly-nice",
            "blammed"
        ]);

        songs.set('Week 4', [
            "satin-panties",
            "high",
            "milf"
        ]);

        songs.set('Week 5', [
            "cocoa",
            "eggnog",
            "winter-horrorland"
        ]);

        songs.set('Week 6', [
            "senpai",
            "roses",
            "thorns"
        ]);

		var bg:FlxSprite = new FlxSprite().loadGraphic(AssetManager.getAsset('menuBGBlue', IMAGE, "images"));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        grpItems = new FlxTypedGroup<Alphabet>();
        add(grpItems);

        for(i in 0...menuItems.length)
        {
            var weekText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i].toString(), true, false);
            weekText.isMenuItem = true;
            weekText.targetY = i;
            grpItems.add(weekText);
        }

		diffText = new FlxText(FlxG.width * 0.6, 5, 0, "", 32);
        diffText.setFormat(AssetManager.getAsset("vcr", FONT, "fonts"), 32, FlxColor.WHITE, RIGHT);
		add(diffText);

        changeSelection();
        changeDiff();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.UP){ changeSelection(-1); }
        if(FlxG.keys.justPressed.DOWN){ changeSelection(1); }

        if(FlxG.keys.justPressed.LEFT){ changeDiff(-1); }
        if(FlxG.keys.justPressed.RIGHT){ changeDiff(1); }

        if(FlxG.keys.justPressed.ENTER)
        {
            if(selectingWeek)
            {
                curWeek = curSelected;
                menuItems = songs.get(weeks[curWeek]);
                selectingWeek = false;
                selectingSong = true;
                regenMenu();
            }
            else
            {
                trace("Performing chart check");
                curSong = songs.get(weeks[curWeek])[curSelected];
                var diffSuffix = "";
                switch(curDifficulty)
                {
                    case 0:
                        diffSuffix = "-easy";
                    case 1:
                        diffSuffix = "";
                    case 2:
                        diffSuffix = "-hard";
                }
                var fullChart = AssetManager.getPath(curSong + diffSuffix + ".json", 'songs/$curSong');
                if(#if sys sys.FileSystem.exists #else Assets.exists #end(fullChart))
                {
                    FlxG.mouse.visible = false;
    
                    bgMusic.destroy();
        
                    System.gc();
    
                    FlxG.switchState(new PlayState());
                }
                else
                {
                    lime.app.Application.current.window.alert("hey we couldnt find the chart, check difficulty", "Chart not found");
                }
            }
        }

        if(FlxG.keys.justPressed.ESCAPE && selectingSong)
        {
            menuItems = weeks;
            selectingWeek = true;
            selectingSong = false;
            regenMenu();
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = grpItems.length - 1;
        if(curSelected >= grpItems.length)
            curSelected = 0;

        var what:Int = 0;

        //idk if i should use for item in grpsongs or the same method as always
        grpItems.forEach(function(item:Alphabet)
        {
            item.targetY = what - curSelected;
            what++;

            item.alpha = 0.5;

            if(item.targetY == 0){ item.alpha = 1; }
        });
    }

    function regenMenu()
    {
        canAccept = false;
        grpItems.clear();

        for(i in 0...menuItems.length)
        {
            var weekText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i].toString(), true, false);
            weekText.isMenuItem = true;
            weekText.targetY = i;
            grpItems.add(weekText);
        }

        curSelected = 0;
        changeSelection();
    }

    function changeDiff(change:Int = 0)
    {
        curDifficulty += change;
        
        if(curDifficulty < 0)
            curDifficulty = difficulties.length - 1;
        if(curDifficulty >= difficulties.length)
            curDifficulty = 0;

        diffText.text = "< " + difficulties[curDifficulty] + " >";
    }
}