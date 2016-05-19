package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

enum  PowerupType {

	EnergyRed;
	EnergyGreen;
	EnergyBlue;
	EnergyPurple;
}


class Powerup extends FlxSprite
{

	public var type_ : PowerupType;
	public var amount_ : Float;

	public function new ( type : PowerupType, amount : Float, ?X:Float = 0, ?Y:Float = 0 ) {
		super( X, Y );
		type_ = type;
		amount_ = amount;
	}
}