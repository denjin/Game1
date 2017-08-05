package;

import flash.display.BitmapData;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import haxe.io.Float32Array;
import objects.Intersect;
import objects.Line;
import objects.MyPoint;
using flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flash.geom.Rectangle;
import flash.display.BitmapDataChannel;
import flash.geom.ColorTransform;

class TestState extends FlxState
{
	var bg:FlxSprite;
	var test_h:FlxSprite;
	var test_v:FlxSprite;
	
	override public function create():Void
	{
		super.create();
		
		var screenW = FlxG.stage.stageWidth;
		var screenH = FlxG.stage.stageHeight;
		
		bg = new FlxSprite(0, 0);
		test_h = new FlxSprite(0, 0);
		test_v = new FlxSprite(0, 0);
		
		bg.makeGraphic(screenW, screenH, FlxColor.WHITE);
		test_h.makeGraphic(screenW, screenH);
		test_v.makeGraphic(screenW, screenH);
		
		test_h.loadGraphic("assets/images/test_h.png", false, screenW, screenH, true);
		test_v.loadGraphic("assets/images/test_v.png", false, screenW, screenH, true);
		
		add(bg);
		add(test_h);
		add(test_v);
		
		/*
		bg.makeGraphic(screenW, screenH, 0xffffffff);
		_dummy.makeGraphic(20, 50, 0xFFFF0000);
		_player.makeGraphic(20, 50, 0xFF0000FF);
		_curtain.makeGraphic(screenW, screenH, 0x66000000);
		_mask.makeGraphic(screenW, screenH, FlxColor.TRANSPARENT);
		
		add(bg);
		add(_curtain);
		add(_dummy);
		add(_player);
		add(_mask);
		
		_mask.drawCircle(350, 400, 100, 0xffffffff);
		
		//FlxSpriteUtil.drawCircle(_mask, _player.getMidpoint().x, _player.getMidpoint().y, 50, FlxColor.WHITE);
		//FlxSpriteUtil.alphaMaskFlxSprite(_curtain, _mask, _curtain);
		*/
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
	}
	
	private function invertAlphaChannel(sprite:FlxSprite):FlxSprite
	{
		var output:FlxSprite = new FlxSprite();
		var data:BitmapData = sprite.pixels.clone();
		data.colorTransform(new Rectangle(0, 0, sprite.width, sprite.height), new ColorTransform(0, 0, 0, -1, 0, 0, 0, 255));
		output.pixels = data;
		return output;
	}
}