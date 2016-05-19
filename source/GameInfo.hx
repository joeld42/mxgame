package;

import flixel.FlxSprite;

typedef GameInfoOptions = {
	var charName : String;
	var charIdent : String;
	var charDesc : String;
} // GameInfoOptions

class GameInfo
{
	public var options : GameInfoOptions;

	// Used for char select screen
	public var _charIcon : FlxSprite;
	public var _charPortrait : FlxSprite;


	public function new ( _options : GameInfoOptions ) 
	{
		options = _options;

		//default_options();
	}
}