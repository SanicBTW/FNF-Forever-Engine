package extra;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

//based of my 0.3.2h sidebar item
class Item extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var disptext:FlxText;
    //public var weekText:FlxText;

    public function new(text, x, y, id)
    {
        super();

        this.ID = id;

        bg = new FlxSprite().makeGraphic(310, 50, FlxColor.WHITE);
        bg.screenCenter();
        bg.x -= x;
        bg.y -= y;
        bg.alpha = 0.6;

        disptext = new FlxText(bg.x + 5, bg.y + 15 , 0, text, 20);
        disptext.setFormat(AssetManager.getAsset('vcr', FONT, "fonts"), 20, FlxColor.BLACK, LEFT);

        /*
        disptext = new FlxText(bg.x + 5, bg.y + 28 , 0, text, 20);
        disptext.setFormat(AssetManager.getAsset('vcr', FONT, "fonts"), 20, FlxColor.BLACK, LEFT);*/

        /*
        weekText = new FlxText(songText.x, songText.y - 22, 0, week, 16);
        weekText.setFormat(AssetManager.getAsset('vcr', FONT, "fonts"), 16, FlxColor.BLACK, LEFT);*/

        add(bg);
        add(disptext);
    }

    public function mouseOver()
    {
        this.bg.color = FlxColor.GRAY;
    }
}