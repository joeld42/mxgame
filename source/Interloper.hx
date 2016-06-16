package;

// "Enemy" or "Bad Guy" just seems too negative. Also some of the opponents are not bad, just
// distracting, such as Anja in the Cody game. :) So I'm calling them "Interloper"

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class Interloper extends FlxSprite 
{
	public var patrolMin : Float;
	public var patrolMax : Float;
	public var walkSpeed :Float = 40.0;

	private var _direction : Float = 1.0;

	private var _appeared: Bool = false;

	public var _goodboyTimeout : Float = 0.0;

	override public function update( elapsed:Float )
	{
		if (!inWorldBounds()) {
			exists = false;			
		}

		if (isOnScreen()) {
			_appeared = true;
		}

		if (_appeared && alive) {
			
			if (_goodboyTimeout > 0.0) {
				velocity.x = 0.0;
				_goodboyTimeout -= elapsed;
			} else {
				velocity.x = _direction * walkSpeed;
				if ((_direction > 0.0) && (x > patrolMax)) {
					_direction = -1.0;
				} else if ((_direction < 0.0) && (x < patrolMin)) {
					_direction = 1.0;
				}
			}
		}
		
		super.update(elapsed);
	}
}