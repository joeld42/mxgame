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

import motion.Actuate;

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

    public var goal : FlxSprite;

    public var _frameGameOver : FlxSprite;
    public var _btnRetry : FlxButton;
    public var _btnBack : FlxButton;
    public var _btnOkay : FlxButton;
	
    private var _isWalking : Bool = false;

    private var _levelComplete : Bool = false;
    private var _gameOverText : FlxText;
    private var gameOver : Bool = false;

    public var _frozenTimeout : Float = 0.0;

    private var energyBars : Array<Energy>;

    public var interlopers(default, null) : FlxSpriteGroup;

    public var items(default, null) : FlxSpriteGroup;

    // specific energy bar aliases for charaters
    var rdogEnergyRed : Energy;
    var rdogEnergyGreen : Energy;
    var rdogEnergyBlue : Energy;
    var rdogEnergyPurple : Energy;

    var codyEnergyFood : Energy;

	override public function create():Void
	{

		Reg.PS = this;

		player = new AnimSprite();
		player.makeGraphic( 100, 50, FlxColor.RED); 
		player.x = 200;
		player.acceleration.y = 2000;

		interlopers = new FlxSpriteGroup();

		// MapLoader.loadLevel( this, "forest_level1_joel");
		// MapLoader.loadLevel( this, "robodog_level1");
		MapLoader.loadLevel( this, info.options.tileset, info.options.charIdent, 1 );

		// Add the player after the map so they show up in front
		add(player);

		//player.attachSpriter( this, "assets/images/sampleplayer/", "assets/data/player.scml" );
		//player.attachSpriter( this, "assets/images/robodog/", "assets/data/robodog.scml" );
		// player.attachSpriter( this, "assets/images/tiger/", "assets/images/tiger/tiger.scml" );
		// player.attachSpriter( this, "assets/images/magickitty/", "assets/images/magickitty/magickitty.scml" );
		// player.attachSpriter( this, "assets/images/underworld/", "assets/images/underworld/ninjakitty.scml" );
		//player.attachSpriter( this, "assets/images/cody/", "assets/images/cody/cody.scml" );
		// player.attachSpriter( this, "assets/images/leopard/", "assets/images/leopard/leopard.scml" );
		player.attachSpriter( this, "assets/images/lavapool/", "assets/images/lavapool/lavapool.scml" );

		// FlxG.cameras.bgColor = new FlxColor( 0xd2e9fc );
		FlxG.camera.follow( player, FlxCameraFollowStyle.PLATFORMER );
		FlxG.camera.setScrollBoundsRect( 0, 0, map.width, map.height, true );


		createHudElements();

		super.create();
	}

	public function playerHitDeadlyTile( a:FlxObject, b:FlxObject ) {
		trace( 'Hit deadly tile... ${a} ${b}' );
		DoGameOver();
	}

	override public function update(elapsed:Float):Void
	{
		if ((!_levelComplete) && (!gameOver)) {

			movePlayer( elapsed );
			super.update(elapsed);
			FlxG.collide(map, player);

			FlxG.overlap( items, player, collideItems );

			if (goal != null)
			{
				FlxG.overlap( goal, player, collideGoal );
			}

			FlxG.overlap( interlopers, player, collideInterloper );

			player.updateSpriter(elapsed);
		} else {
			super.update(elapsed);
		}

	}

	private function movePlayer( elapsed : Float ) : Void
	{
		player.velocity.x = 0;

		if (_frozenTimeout > 0.0) {
			_frozenTimeout -= elapsed;
			return;			
		}

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

		// Fall off bottom of screen?
		if (player.y > map.height - player.height) {
			DoGameOver();
		}

		// Robodog updates
		if (rdogEnergyRed != null)
		{
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

		// Cody updates
		if (codyEnergyFood != null) {
			codyEnergyFood.setEnergy( codyEnergyFood.energy - 0.05 );

			if (codyEnergyFood.energy <= 0.0) {
				DoGameOver();
			}
		}


	}

	public function collideInterloper( interloper : Interloper, player : FlxSprite) 
	{		
		if (info.options.charIdent == "cody") {

			if ((_frozenTimeout <= 0.0) && (interloper._goodboyTimeout <= 0.0)) {
				_frozenTimeout = 2.0;
				interloper._goodboyTimeout = 5.0;
				FlxG.sound.play( "cody_goodboy");
			}
		}
	}

	public function collideGoal( item : FlxSprite, player : FlxSprite) 
	{
		_levelComplete = true;

		trace("GOAL REACHED, go to next level...");
		// FlxG.switchState( new CharSelectState() );
		DoLevelComplete();
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
		} else if (item.type_ == CodyFood) {
			FlxG.sound.play( "anja_pickup");
			codyEnergyFood.setEnergy( codyEnergyFood.energy + item.amount_ );
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
		} else if (info.options.charIdent == "cody") {
			codyEnergyFood = addEnergyBar( "Food", 0xffeaa52d );
			codyEnergyFood.setEnergy( 10.0 );
		}
	}

	private function DoLevelComplete()
	{
		gameOver = true;

		player.acceleration.x = 0.0;
		player.acceleration.y = 0.0;

		_frameGameOver = new FlxSprite( 0, 0 );
		_frameGameOver.loadGraphic( AssetPaths.gameover_frame__png, false );
		_frameGameOver.scrollFactor.set(0.0, 0.0 );
		add(_frameGameOver);

		_gameOverText = new FlxText( 127, 109 );
		_gameOverText.setFormat( AssetPaths.grobold__ttf, 18, FlxColor.WHITE );
		_gameOverText.setBorderStyle( FlxTextBorderStyle.OUTLINE, 0xff005784, 2 );
		_gameOverText.text = "Level Complete!";
		_gameOverText.scrollFactor.set(0.0, 0.0 );
		add( _gameOverText );

		_btnOkay = new FlxButton( 284, 231, clickBack ); 
		_btnOkay.loadGraphic(AssetPaths.btn_okay__png, false); 
		_btnOkay.scrollFactor.set(0.0, 0.0 );
		add(_btnOkay);
	}

	private function DoGameOver()
	{
		gameOver = true;

		player.acceleration.x = 0.0;
		player.acceleration.y = 0.0;

		_frameGameOver = new FlxSprite( 0, 0 );
		_frameGameOver.loadGraphic( AssetPaths.gameover_frame__png, false );
		_frameGameOver.scrollFactor.set(0.0, 0.0 );
		add(_frameGameOver);

		_gameOverText = new FlxText( 127, 109 );
		_gameOverText.setFormat( AssetPaths.grobold__ttf, 18, FlxColor.WHITE );
		_gameOverText.setBorderStyle( FlxTextBorderStyle.OUTLINE, 0xff005784, 2 );
		_gameOverText.text = info.options.gameOverText;
		_gameOverText.scrollFactor.set(0.0, 0.0 );
		add( _gameOverText );

		_btnRetry = new FlxButton( 284, 231, clickReplay ); 
		_btnRetry.loadGraphic(AssetPaths.btn_tryagain__png, false); 
		_btnRetry.scrollFactor.set(0.0, 0.0 );
		add(_btnRetry);

		_btnBack = new FlxButton( 120, 210, clickBack ); 
		_btnBack.loadGraphic(AssetPaths.btn_back__png, false); 
		_btnBack.scrollFactor.set(0.0, 0.0 );
		add(_btnBack);

	}


	private function clickReplay()
	{
		_levelComplete = true;

		var playState = new PlayState(); 		
		playState.info = info;
		Actuate.reset();

		FlxG.switchState( playState );
	}

	private function  clickBack()
	{
		_levelComplete = true;
		
		Actuate.reset();
		FlxG.switchState( new CharSelectState() );

	}
}




