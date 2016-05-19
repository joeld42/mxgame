package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Energy
{
	public var energy: Float = 100.0;
    public var energyBar :  FlxSprite;
    public var energyBorder :  FlxSprite;
    public var name: String;
    public var color : FlxColor;

    public function new() {}

    public function setEnergy( e : Float )
    {
        if (e > 100.0) {
            e = 100.0;
        }
    	energy = e;
    	energyBar.scale.x = e / 100.0;
    }
}