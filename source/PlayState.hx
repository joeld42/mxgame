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
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;

import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.FlixelLibrary;

class PlayState extends FlxState
{
	public var map:FlxTilemap;
    public var player:AnimSprite;
      
    public var info : GameInfo;
	
    private var _isWalking : Bool = false;

    private var energyBars : Array<Energy>;

    public var items(default, null) : FlxSpriteGroup;

    // specific energy bar aliases for charaters
    var rdogEnergyRed : Energy;
    var rdogEnergyGreen : Energy;
    var rdogEnergyBlue : Energy;
    var rdogEnergyPurple : Energy;

	override public function create():Void
	{
		player = new AnimSprite();
		player.makeGraphic( 100, 50, FlxColor.RED); 
		player.x = 200;
		player.acceleration.y = 2000;

		// MapLoader.loadLevel( this, "forest_level1_joel");
		// MapLoader.loadLevel( this, "robodog_level1");
		MapLoader.loadLevel( this, info.options.tileset, info.options.charIdent, 1 );
	
		// Add the player after the map so they show up in front
		add(player);

		//player.attachSpriter( this, "assets/images/sampleplayer/", "assets/data/player.scml" );
		player.attachSpriter( this, "assets/images/robodog/", "assets/data/robodog.scml" );

		// FlxG.cameras.bgColor = new FlxColor( 0xd2e9fc );
		FlxG.camera.follow( player, FlxCameraFollowStyle.PLATFORMER );
		FlxG.camera.setScrollBoundsRect( 0, 0, map.width, map.height, true );

		createHudElements();

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

		FlxG.overlap( items, player, collideItems );

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

		if ((FlxG.keys.pressed.X) && (rdogEnergyRed.energy > 0.0))
		{
			// trace('flying...');
			if (player.velocity.y > 50) {
				// immediately stop falling
				player.velocity.y = 0.0;
			} else if (player.velocity.y > -200) {
				// accelerate up
				player.velocity.y  -= 50.0;
			} else {
				// max up velocity
				player.velocity.y = -200.0;
			}
			rdogEnergyRed.setEnergy( rdogEnergyRed.energy - 0.2 );			
		}

		if (FlxG.keys.justPressed.Z) {
			trace('refill');
			rdogEnergyRed.setEnergy( 100.0 );
		}
	}

	public function collideItems( item : Powerup, player : AnimSprite )
	{
		// This is weird, not sure if this is expected to happen
		if (item == null) return;

		trace('collide items...');
		if (item.type_ == EnergyRed) {
			rdogEnergyRed.setEnergy( rdogEnergyRed.energy + item.amount_ );
			item.kill();
		} else if (item.type_ == EnergyGreen) {
			rdogEnergyGreen.setEnergy( rdogEnergyGreen.energy + item.amount_ );
			item.kill();
		} else if (item.type_ == EnergyBlue) {
			rdogEnergyBlue.setEnergy( rdogEnergyBlue.energy + item.amount_ );
			item.kill();			
		} else if (item.type_ == EnergyPurple) {
			rdogEnergyPurple.setEnergy( rdogEnergyPurple.energy + item.amount_ );
			item.kill();						
		}
	}

	private function addEnergyBar( name : String, color : FlxColor ) : Energy
	{
		// Energy bar
		var ee = new Energy();

		var baseY = 12 + energyBars.length * 25;
		ee.energyBorder = new FlxSprite( 612, baseY );
		ee.energyBorder.loadGraphic(AssetPaths.energybar__png, false); 
		ee.energyBorder.scrollFactor.set( 0.0, 0.0 );
		add(ee.energyBorder);

		ee.energyBar = new FlxSprite( 617, baseY + 5 );
		ee.energyBar.makeGraphic( 160, 12, color );
		ee.energyBar.origin.set( 0.0, ee.energyBar.origin.y );
		ee.energyBar.scrollFactor.set( 0.0, 0.0 );
		add( ee.energyBar );

		var title = new FlxText( 510, baseY + 3, 100 );
		title.text = name;
		title.alignment = FlxTextAlign.RIGHT;
		title.autoSize = false;
		title.scrollFactor.set( 0.0, 0.0 );
		ee.name = name;
		add(title);

		energyBars.push( ee );

		return ee;
	}

	private function createHudElements( )
	{
		energyBars = new Array<Energy>();

		if (info.options.charIdent == "robodog") {
			rdogEnergyRed = addEnergyBar( "RED", 0xfff80b2c );
			rdogEnergyRed.setEnergy( 75.0 );

			rdogEnergyGreen = addEnergyBar( "GREEN", 0xff80de5c );
			rdogEnergyGreen.setEnergy( 33.0 );

			rdogEnergyBlue = addEnergyBar( "BLUE", 0xff00eeff );
			rdogEnergyBlue.setEnergy( 100.0 );

			rdogEnergyPurple = addEnergyBar( "PURPLE", 0xffa366f7 );
			rdogEnergyPurple.setEnergy( 1.0 );
		}
	}
}




