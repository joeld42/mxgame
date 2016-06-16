package;
import flixel.FlxObject;
import flixel.FlxSprite;

import flixel.addons.editors.tiled.TiledLayer; 
import flixel.addons.editors.tiled.TiledTileLayer; 
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer; 
import flixel.tile.FlxTilemap;
import flixel.math.FlxRandom;
import flixel.FlxSprite;

import motion.Actuate;
import motion.easing.Quad;
import motion.easing.Linear;

import flash.system.System;

class MapLoader
{
	private static var rng : FlxRandom = null;

	public static function loadLevel(state:PlayState, tilesetImage:String, charIdent:String, level : Int ) {

		if (rng==null) {
			rng = new FlxRandom();
		}

		var levelFile : String = 'assets/data/${charIdent}_level${level}.tmx';
		trace('Load level ${levelFile}');
		var tiledMap = new TiledMap( levelFile ); 
		if (tiledMap == null) {
			trace("ERROR: failed to load level file.");
			System.exit(0);
			return;
		}

		var mainLayer:TiledTileLayer = cast tiledMap.getLayer("Tiles");
		if (mainLayer == null) {
			trace("ERROR: Missing 'Tiles' layer.");
			System.exit(0);
			return;
		}

		state.map = new FlxTilemap(); 
		state.map.loadMapFromArray(mainLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             //AssetPaths.forest_joel_tilemap__png,
	                             tilesetImage,
	                             100, 100, 1);


		// Custom collision rules for tiles
		if (charIdent=="forest") {
			// Adjust collision flags 
			state.map.setTileProperties( 1, FlxObject.UP, null, null, 5); // jump-thru platforms
			state.map.setTileProperties( 29, FlxObject.ANY, state.playerHitDeadlyTile );
		} else if (charIdent=="robodog") {
			trace("TODO: robodog tiles...");
			state.map.setTileProperties( 15, FlxObject.ANY, state.playerHitDeadlyTile, null,  5);
		}


		var bgTileLayer:TiledTileLayer = cast tiledMap.getLayer("Background tiles");
		if (bgTileLayer == null) {
			trace("ERROR: Missing 'Background tiles' layer.");
			System.exit(0);
			return;
		}

		var bgTiles = new FlxTilemap(); 
		bgTiles.loadMapFromArray(bgTileLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             //AssetPaths.forest_joel_tilemap__png,
	                             tilesetImage, 100, 100, 1);
		bgTiles.solid = false;

		var skyLayer:TiledTileLayer = cast tiledMap.getLayer("BGSky");
		if (skyLayer == null) {
			trace("ERROR: Missing 'BGSky' layer.");
			System.exit(0);
			return;
		}

		var skyTiles = new FlxTilemap(); 
		skyTiles.loadMapFromArray(skyLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             tilesetImage, 100, 100, 1);
		skyTiles.solid = false;

		state.add(skyTiles);
		state.add(bgTiles);

		state.add(state.map);


		// Apply object layers
		var objectLayer:TiledObjectLayer = cast tiledMap.getLayer("objects");

		if (objectLayer == null) {
			trace("ERROR: Missing 'objects' layer.");			
			return;
		}

		for (object in objectLayer.objects) {
			trace('OBJECT: ${object.name}');
			if (object.name=="player") {
				state.player.x = object.x;
				state.player.y = object.y;

			} else if (object.name=="goal") {
				
				trace("Adding goal...");
				var goal = new FlxSprite( object.x, object.y  );
				goal.loadGraphic('assets/images/${charIdent}_goal.png', false );
				state.goal = goal;
				goal.y -= goal.height;
				state.add( goal );

			} else if (object.name=="anja") {
				trace("Adding an Anja");
				var interloper = new Interloper( object.x, object.y - 80 );
				interloper.patrolMin = object.x;
				interloper.patrolMax = object.x + object.width;
				interloper.loadGraphic('assets/images/interloper_${object.name}.png', true, 89, 166 );
				interloper.animation.add("walk", [0, 1], 4 );
				interloper.animation.play("walk");
				interloper.active = true;
				interloper.velocity.x = -2.0;				

				state.add( interloper );
				state.interlopers.add( interloper );

			// Tile objects	
			} 

			// Otherwise, create level specific objects
			if (charIdent=="robodog")
			{
				createLevelObjectsRobodog( state, object );
			} 
			else if (charIdent=="cody") 
			{
				createLevelObjectsCody( state, object );
			}
		}
	}

	static function createLevelObjectsRobodog( state: PlayState, object : TiledObject )
	{
		if (object.gid == 57) {				
			// Green energy ball
			addPowerUp( state, EnergyGreen, AssetPaths.robodog_energy_green__png, 10.0, object.x, object.y-100);
		} else if (object.gid == 58) {
			// Purple energy ball
			addPowerUp( state, EnergyPurple, AssetPaths.robodog_energy_purple__png, 30.0, object.x, object.y-100);
		} else if (object.gid == 67) {
			// Blue energy ball
			addPowerUp( state, EnergyBlue, AssetPaths.robodog_energy_blue__png, 100.0, object.x, object.y-100);
		} else if (object.gid == 68) {
			// Red energy ball
			addPowerUp( state, EnergyRed, AssetPaths.robodog_energy_red__png, 10.0, object.x, object.y-100);
		} else {
			trace( 'unhandled map object ${object.name} ${object.type} ${object.gid}');
		}
	}

	static function createLevelObjectsCody( state: PlayState, object : TiledObject )
	{
		trace( 'CreateLevelObjectsCody: ${object.gid}' );
		if ( (object.gid == 21) || (object.gid == 22) ||
			 (object.gid == 31) || (object.gid == 32) ||
			 (object.gid == 41) || (object.gid == 42) )			
		 {
			// Food
			trace("FOOD");
			addPowerUp( state, CodyFood, AssetPaths.cody_food1__png, 10.0, object.x, object.y-100);
		} else {
			trace( 'unhandled map object ${object.name} ${object.type} ${object.gid}');
		}
	}

	
	public static function addPowerUp(state:PlayState, type : Powerup.PowerupType, path : String, 
										amount : Float, X : Float, Y : Float ) {
		var powerUp =  new Powerup( type, amount, X, Y );
		powerUp.loadGraphic(  path, false );
		state.add( powerUp );
		
		Actuate.tween( powerUp, rng.floatNormal( 3.0, 0.5), { angle : 360.0 }).ease( Linear.easeNone ).repeat();

	}

}