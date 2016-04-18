package;
import flixel.FlxObject;

import flixel.addons.editors.tiled.TiledLayer; 
import flixel.addons.editors.tiled.TiledTileLayer; 
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer; 
import flixel.tile.FlxTilemap;

class MapLoader
{

	public static function loadLevel(state:PlayState, level:String) {
		var tiledMap = new TiledMap("assets/data/" + level + ".tmx"); 
		var mainLayer:TiledTileLayer = cast tiledMap.getLayer("Tile Layer 1");

		state.map = new FlxTilemap(); 
		state.map.loadMapFromArray(mainLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             AssetPaths.forest_joel_tilemap__png,
	                             100, 100, 1);

		// Adjust collision flags 
		state.map.setTileProperties( 1, FlxObject.UP, null, null, 5); // jump-thru platforms
		state.map.setTileProperties( 29, FlxObject.ANY, state.playerHitDeadlyTile );


		var bgTileLayer:TiledTileLayer = cast tiledMap.getLayer("Background tiles");

		var bgTiles = new FlxTilemap(); 
		bgTiles.loadMapFromArray(bgTileLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             AssetPaths.forest_joel_tilemap__png,
	                             100, 100, 1);
		bgTiles.solid = false;

		var skyLayer:TiledTileLayer = cast tiledMap.getLayer("BGSky");

		var skyTiles = new FlxTilemap(); 
		skyTiles.loadMapFromArray(skyLayer.tileArray,
	                             tiledMap.width,
	                             tiledMap.height,
	                             AssetPaths.forest_joel_tilemap__png,
	                             100, 100, 1);
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
			} else {
				trace( 'unhandled map object ${object.name} ${object.type} ${object.gid}');
			}
		}
	}

}