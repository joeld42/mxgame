package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;

import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.FlixelLibrary;

class PlayState extends FlxState
{
	public var map:FlxTilemap;
    public var player:AnimSprite;
      
	
    private var _isWalking : Bool = false;

	override public function create():Void
	{
		player = new AnimSprite();
		player.makeGraphic( 50, 100, FlxColor.RED); 
		player.x = 200;
		player.acceleration.y = 2000;

		MapLoader.loadLevel( this, "forest_level1_joel");


		// Add the player after the map so they show up in front
		add(player);

		player.attachSpriter( this, "assets/images/sampleplayer/", "assets/data/player.scml" );

		// FlxG.cameras.bgColor = new FlxColor( 0xd2e9fc );
		FlxG.camera.follow( player, FlxCameraFollowStyle.PLATFORMER );
		FlxG.camera.setScrollBoundsRect( 0, 0, map.width, map.height, true );

		super.create();
	}

	public function playerHitDeadlyTile( a:FlxObject, b:FlxObject ) {
		trace( 'Hit deadly tile... ${a} ${b}' );
	}

	override public function update(elapsed:Float):Void
	{
		movePlayer();

		super.update(elapsed);
		FlxG.collide(map, player);

		player.updateSpriter(elapsed);
	}

	private function movePlayer() : Void
	{
		player.velocity.x = 0;

		if (FlxG.keys.pressed.LEFT) {
			player.velocity.x -= 400;			
		}

		if (FlxG.keys.pressed.RIGHT) {
			player.velocity.x += 400;			
		}
		
		var walking = true;
		if (player.velocity.x == 0.0) walking = false;

		var walkDir = 1.0;
		if (player.velocity.x > 0.0) {
			walkDir = 1.0;
		} else {
			walkDir = -1.0;
		}

		if (FlxG.keys.justPressed.C && player.isTouching(FlxObject.FLOOR)) {
			player.velocity.y = -1500.0;
		}
	}
}




