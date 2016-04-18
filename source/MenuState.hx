package;

import openfl.Assets;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

import flash.system.System;

class MenuState extends FlxState
{
	private var _bg :FlxSprite;
	private var _cursor: FlxSprite;
	private var _selected:Int = 0;

	private static var _menuEntries:Array<String> = [ "START GAME", "QUIT"];
	private static var _menuPos : FlxPoint = new FlxPoint( 300, 350 );
	private static var _menuSpacing: Int = 60;

	override public function create():Void
	{
		_bg = new FlxSprite( 0, 0 );
		_bg.loadGraphic( AssetPaths.title__png, false, 320, 180 );

		_cursor = new FlxSprite(_menuPos.x - 80, _menuPos.y - 10); 
		_cursor.loadGraphic(AssetPaths.menucursor__png, true, 60, 60); 
		// _cursor.animation.add("cursor", [1]); 
		_cursor.animation.play("cursor");
        

        add(_bg);
        add(_cursor);

        for (i in 0..._menuEntries.length) {
        	var entry: FlxText = new FlxText( _menuPos.x, _menuPos.y + _menuSpacing * i);
        	entry.text = _menuEntries[i];
        	add(entry);
        }

        forEachOfType( FlxText, function(member) {
        	member.setFormat( AssetPaths.grobold__ttf, 48, FlxColor.WHITE );
        	member.setBorderStyle( FlxTextBorderStyle.OUTLINE, 0xff005784, 2 );
        });

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP ) {
			_selected -= 1;
		}

		if (FlxG.keys.justPressed.DOWN ) {
			_selected += 1;
		}

		_selected = FlxMath.wrap( _selected, 0, _menuEntries.length - 1);

		_cursor.y = _menuPos.y - 10 + _menuSpacing * _selected;

		if (FlxG.keys.justPressed.ENTER ) {
			switch(_selected) {
				case 0: FlxG.switchState( new PlayState() );
				case 1: System.exit(0);
			}
		}
	}
}
