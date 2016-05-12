package;

import openfl.Assets;
import openfl.events.MouseEvent;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

import motion.Actuate;
import motion.easing.Quad;

class CharSelectState extends FlxState
{
	private var _bg :FlxSprite;
	private var _btnPlay :FlxButton;

	private var _gameInfos : Array<GameInfo>;
	private var _selectedIndex: Int = -1;

	private var _charTitle : FlxText;
	private var _charDesc : FlxText;

	override public function create():Void
	{
		_bg = new FlxSprite( 0, 0 );
		_bg.loadGraphic( AssetPaths.char_select__png, false );

		_btnPlay = new FlxButton( 284, 473, clickPlay ); 
		_btnPlay.loadGraphic(AssetPaths.btn_play__png, false); 

        add(_bg);
        add(_btnPlay);

        _gameInfos = new Array<GameInfo>();

        var info : GameInfo = new GameInfo({ 
        			charIdent : 'robodog',
	        		charName : 'Robo-Dog',
	        		charDesc : 'Canis Robotus, this mechanized\nhero fights baddies with hover\nfeet, turbo-engines and more!'
	        });
		
		_gameInfos.push( info );

        while (_gameInfos.length < 10) {
        	var unkInfo : GameInfo = new GameInfo({ 
	        		charIdent : "unknown",
	        		charName : 'Unknown${_gameInfos.length+1}',
	        		charDesc : 'This is a test character ${_gameInfos.length+1}'
	        });	     

	        _gameInfos.push( unkInfo );   	        
    	}

        Actuate.tween( _btnPlay.scale, 1.6, { x : 1.1, y : 1.1 }).ease( Quad.easeOut ).repeat().reflect();

        // for (i in 0..._menuEntries.length) {
        // 	var entry: FlxText = new FlxText( _menuPos.x, _menuPos.y + _menuSpacing * i);
        // 	entry.text = _menuEntries[i];
        // 	add(entry);
        // }

        for ( i in 0..._gameInfos.length ) {
        	var gameInfo = _gameInfos[i];
        	var col = i % 5;
        	var row : Int = Std.int(i / 5);

        	gameInfo._charIcon = new FlxButton( 124 + 113*col, 114 + 104*row, clickChar.bind(i) );        	
        	trace('BTN_PLAY: ${AssetPaths.btn_play__png}');
        	trace('CHAR: assets/images/char_${gameInfo.options.charIdent}.png');
        	gameInfo._charIcon.loadGraphic( 'assets/images/char_${gameInfo.options.charIdent}.png', false );
        	add(gameInfo._charIcon);

			gameInfo._charPortrait = new FlxSprite( 141, 317 );
        	gameInfo._charPortrait.loadGraphic( 'assets/images/portrait_${gameInfo.options.charIdent}.png', false );
        	add(gameInfo._charPortrait);
        	gameInfo._charPortrait.alpha = 0.0;
        }

		_charTitle = new FlxText( 355, 320 );
		_charTitle.setFormat( AssetPaths.grobold__ttf, 40, FlxColor.WHITE );
		_charTitle.setBorderStyle( FlxTextBorderStyle.OUTLINE, 0xff005784, 2 );
		add(_charTitle);

		_charDesc = new FlxText( 355, 360 );
		_charDesc.setFormat( AssetPaths.grobold__ttf, 18, FlxColor.WHITE );
		_charDesc.setBorderStyle( FlxTextBorderStyle.OUTLINE, 0xff005784, 2 );
		add( _charDesc );
	
        showSelectedSprite( 0 );

		super.create();
	}

	public function clickChar( index: Int ) {		
		showSelectedSprite( index );
	}

	public function clickPlay() {
		
		var playState = new PlayState(); 		
		var gameInfo = _gameInfos[_selectedIndex];
		trace('Play game ${gameInfo.options.charIdent}');

		playState.info = gameInfo;

		FlxG.switchState( playState );
	}

	public function showSelectedSprite( index : Int ) {

		trace('showSelectedSprite ${index}');

		if (index == _selectedIndex) {
			return;
		}

		// Deselect currently selected
		// TODO: animate the portraits
		if (_selectedIndex >= 0) {
			var gameInfo = _gameInfos[_selectedIndex];
			gameInfo._charPortrait.alpha = 0.0;
		}

		_selectedIndex = index;
		var gameInfo = _gameInfos[_selectedIndex];
		gameInfo._charPortrait.alpha = 1.0;
		_charTitle.text = gameInfo.options.charName;
		_charDesc.text = gameInfo.options.charDesc;
	}
}





