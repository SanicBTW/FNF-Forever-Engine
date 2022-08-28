package extra;

import flixel.text.FlxText;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Assets;
import flixel.FlxG;
import states.MusicBeatState;
import extra.Item;

//this is not bound to forever engine rewrite at all, i just wanted to add this in order to let people choose what song to play
class SongSelectionState extends MusicBeatState
{
    var songs:Map<String, Array<String>> = new Map();
    var difficulties:Array<String> = ["Easy", "Normal", "Hard"];
    //to iterate through the songs map
    var weeks:Array<String> = ["Tutorial", "Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"];

    //sprite shit
    var weekItems:FlxTypedGroup<Item>;
    var songItems:FlxTypedGroup<Item>;
    var diffItems:FlxTypedGroup<Item>;

    //bg music to give it some life
    var bgMusic:FlxSound;

    public static var songSelected:String = "test";
    public static var diffSelected:Int = 1;
    var curWeekSelected:Int = 0;

    var curWeekText:FlxText;
    var curSongText:FlxText;
    var curDiffText:FlxText;
    var enterToPlay:FlxText;
    override function create()
    {
		AssetManager.clearUnusedMemory();
		AssetManager.clearStoredMemory();

        //its just tea time music from psych 0.5.2h
        bgMusic = new FlxSound().loadEmbedded(AssetManager.getAsset('song-selection-music', SOUND, "music"), true, false);
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

        FlxG.mouse.visible = true;

        //had to remove bg :(

        weekItems = new FlxTypedGroup<Item>();
        add(weekItems);

        songItems = new FlxTypedGroup<Item>();
        add(songItems);

        diffItems = new FlxTypedGroup<Item>();
        add(diffItems);

        var curItemPos = 270;
        for(i in 0...weeks.length)
        {
            //more spacing
            weekItems.add(new Item(weeks[i], 460, curItemPos - 55, i));
            curItemPos -= 55;
        }

        var curItemPos = 270;
        for(i in 0...difficulties.length)
        {
            diffItems.add(new Item(difficulties[i], -220, curItemPos - 55, i));
            curItemPos -= 55;
        }

        curWeekText = new FlxText(0, 0, 0, 'Cur week: ?\n');
		curWeekText.setFormat(AssetManager.getAsset('vcr', FONT, 'fonts'), 18, FlxColor.BLACK);
		curWeekText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		curWeekText.setPosition((FlxG.width - (curWeekText.width + 5)) - 200, 5);
		curWeekText.antialiasing = true;
		add(curWeekText);

        curSongText = new FlxText(0, 0, 0, 'Cur song: ?\n');
		curSongText.setFormat(AssetManager.getAsset('vcr', FONT, 'fonts'), 18, FlxColor.BLACK);
		curSongText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		curSongText.setPosition((FlxG.width - (curSongText.width + 5)) - 200, 30);
		curSongText.antialiasing = true;
		add(curSongText);

        curDiffText = new FlxText(0, 0, 0, 'Cur diff: ?\n');
		curDiffText.setFormat(AssetManager.getAsset('vcr', FONT, 'fonts'), 18, FlxColor.BLACK);
		curDiffText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		curDiffText.setPosition((FlxG.width - (curDiffText.width + 5)) - 200, 60);
		curDiffText.antialiasing = true;
		add(curDiffText);

        enterToPlay = new FlxText(0, 0, 0, "Press ENTER to play the song", 18);
        enterToPlay.setFormat(AssetManager.getAsset("vcr", FONT, "fonts"), 18, FlxColor.BLACK);
        enterToPlay.screenCenter();
        enterToPlay.y = FlxG.height - 50;
        enterToPlay.antialiasing = true;
        enterToPlay.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
        add(enterToPlay);

        super.create();
    }

    override function update(elapsed:Float)
    {
        //couldnt do funky overlapping and selection color
        weekItems.forEach(function(weekItem:Item)
        {
            if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(weekItem))
            {
                curWeekSelected = weekItem.ID;
                curWeekText.text = "Cur week: " + curWeekSelected;
                generateSongs();
            }
        });

        diffItems.forEach(function(diffItem:Item)
        {
            if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(diffItem))
            {
                diffSelected = diffItem.ID;
                curDiffText.text = "Cur diff: " + difficulties[diffSelected];
            }
        });

        songItems.forEach(function(song:Item)
        {
            if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(song))
            {
                songSelected = song.disptext.text;
                curSongText.text = "Cur song: " + songSelected;
            }
        });

        if(FlxG.keys.justPressed.ENTER)
        {
            trace("Performing chart check");
            var diffSuffix = "";
            switch(diffSelected)
            {
                case 0:
                    diffSuffix = "-easy";
                case 1:
                    diffSuffix = "";
                case 2:
                    diffSuffix = "-hard";
            }
            var fullChart = AssetManager.getPath(songSelected + diffSuffix + ".json", 'songs/$songSelected');
            if(#if sys sys.FileSystem.exists #else Assets.exists #end(fullChart))
            {
                FlxG.mouse.visible = false;

                weekItems.destroy();
                songItems.destroy();
                diffItems.destroy();
    
                bgMusic.destroy();
    
                curWeekText.destroy();
                curSongText.destroy();
                curDiffText.destroy();
                enterToPlay.destroy();
    
                #if sys
                openfl.system.System.gc();
                #end

                FlxG.switchState(new PlayState());
            }
            else
            {
                lime.app.Application.current.window.alert("hey we couldnt find the chart, check difficulty", "Chart not found");
            }
        }

        super.update(elapsed);
    }

    function generateSongs()
    {
        var curItemPos = 270;
        if(songItems.length > 0)
        {
            songItems.clear();
        }
        var weekSongs = songs.get(weeks[curWeekSelected]);
        for(i in 0...weekSongs.length)
        {
            songItems.add(new Item(weekSongs[i], 120, curItemPos - 55, i));
            curItemPos -= 55;
        }
        #if sys
        openfl.system.System.gc();
        #end
    }
}