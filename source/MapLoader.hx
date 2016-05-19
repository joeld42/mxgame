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

import motion.Actuate;
import motion.easing.Quad;
import motion.easing.Linear;

class MapLoader
{
	private static var rng : FlxRandom = null;

	public static function loadLevel(state:PlayState, level:String) {

		if (rng==null) {
			rng = new FlxRandom();
		}


		var tiledMap = new TiledMap("assets/data/" + level + ".tmx"); 
		var mainLayer:TiledTileLayer = cast tiledMap.getLayer("Tiles");
		var tilesetImage = AssetPaths.robodog_xander_tilemap__png;



		state.map = new FlxTilemap(); 
		state.map.loadMapFromArray(mainLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             //AssetPaths.forest_joel_tilemap__png,
	                             tilesetImage,
	                             100, 100, 1);


		// Custom collision rules for tiles
		if (level=="forest") {
			// Adjust collision flags 
			state.map.setTileProperties( 1, FlxObject.UP, null, null, 5); // jump-thru platforms
			state.map.setTileProperties( 29, FlxObject.ANY, state.playerHitDeadlyTile );
		} else if (level=="robodog") {
			trace("TODO: robodog tiles...");
			state.map.setTileProperties( 15, FlxObject.ANY, state.playerHitDeadlyTile, null,  5);
		}


		var bgTileLayer:TiledTileLayer = cast tiledMap.getLayer("Background tiles");

		var bgTiles = new FlxTilemap(); 
		bgTiles.loadMapFromArray(bgTileLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             //AssetPaths.forest_joel_tilemap__png,
	                             tilesetImage, 100, 100, 1);
		bgTiles.solid = false;

		var skyLayer:TiledTileLayer = cast tiledMap.getLayer("BGSky");

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
		for (object in objectLayer.objects) {
			if (object.name=="player") {
				state.player.x = object.x;
				state.player.y = object.y;
			} else if (object.gid == 57) {				
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
	}

	
	public static function addPowerUp(state:PlayState, type : Powerup.PowerupType, path : String, 
										amount : Float, X : Float, Y : Float ) {
		var powerUp =  new Powerup( type, amount, X, Y );
		powerUp.loadGraphic(  path, false );
		state.add( powerUp );
		
		Actuate.tween( powerUp, rng.floatNormal( 3.0, 0.5), { angle : 360.0 }).ease( Linear.easeNone ).repeat();

	}

}