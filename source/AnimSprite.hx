package;

// This is a flxSprite with a Spriter animation attached. This is really simplified 
// and it assumes a single entity named 'Player' in each spriter file.

import openfl.Assets;

import spriter.engine.Spriter;
import spriter.engine.SpriterEngine;
import spriter.library.FlixelLibrary;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

enum AnimState {
	Idle; 
	Walking;
	Jumping;
	Falling;
}

class AnimSprite extends flixel.FlxSprite {

	private var _spriterGroup:FlxSpriteGroup;
    private var _spriterEngine:SpriterEngine;
    private var _spriterLib:FlixelLibrary;

    private var _spriter:Spriter;

    public var animState : AnimState;

    public var _scl : Float = 1.0;

    public function attachSpriter( state:PlayState, assetPath : String,  scmlFile : String ) {

    	_spriterGroup = new FlxSpriteGroup();
        _spriterGroup.antialiasing = true;
        _spriterGroup.pixelPerfectRender = false;    

        for (spr in _spriterGroup.members) {
			spr.antialiasing = true;
        	spr.pixelPerfectRender = false;            	
        }
        
        _spriterLib = new FlixelLibrary(_spriterGroup.group, assetPath );
        var scmlText = Assets.getText( scmlFile );
        //trace( 'SCML $scmlText');
        _spriterEngine = new SpriterEngine( scmlText, _spriterLib, false);

        //update on enter frame
        _spriter = _spriterEngine.addSpriter( 'Player', 200, 200);
        
        // hacked on scale for the game
        _spriter.info.scaleX = _scl;
        _spriter.info.scaleY = _scl;

        animState = Idle;
        
        state.add(_spriterGroup);
    }

    public function updateSpriter(elapsed:Float):Void 
    {
    	if (_spriter!=null) {

	    	var currState = Idle;
			if (this.velocity.x != 0.0) {
				currState = Walking;
				if (this.velocity.x > 0.0) {
					_spriter.info.scaleX = _scl;	
				} else {
					_spriter.info.scaleX = -_scl;
				}
			}

			if (!this.isTouching(FlxObject.FLOOR)) {
				if (this.velocity.y > 0.0) {
					currState = Falling;
				} else {
					currState = Jumping;
				}
			}

			// Switch animation if state changed
			if (currState != animState) {
				animState = currState;
				if (animState==Idle) {
					_spriter.playAnim("idle");
				} else if (animState==Walking) {
					_spriter.playAnim("walk");
				} else if (animState==Falling) {
					_spriter.playAnim("fall_loop");
				} else if (animState==Jumping) {
					_spriter.playAnim("jump_loop");
				}
			}

			// Update spriter position
			_spriter.info.x = (this.x + this.width / 2.0);
			_spriter.info.y = -(this.y + this.height);
			_spriterEngine.update();
		}
    }

}