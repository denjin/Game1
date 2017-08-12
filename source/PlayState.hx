package;

import flixel.FlxCamera;

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
import nape.geom.Vec2;

using flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flash.geom.Rectangle;
import flash.display.BitmapDataChannel;
import flash.geom.ColorTransform;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKeyboard;

import player.Player;

import objects.Box;
import objects.Intersect;
import objects.Line;
import objects.MyPoint;

import vision.VisionManager;
import Util;

import openfl.display.FPS;

import flixel.addons.nape.FlxNapeSpace;

import flixel.addons.nape.FlxNapeSprite;

class PlayState extends FlxState
{	
	private var visionManager:VisionManager = new VisionManager();
	
	private var screenWidth:Int;
	private var screenHeight:Int;
	
	private var shadowSize:Int = 2204;
	
	private var debugText:FlxText;
	private var fps:FPS;
	
	private var floor:FlxSprite;
	
	private var player:Player;
	private var speed:Float = 200;
	
	//private var visionArc:Float = Math.PI / 6;
	private var visionLength:Float = 640;
	
	
	private var boxes:Array<Box>;
	
	private var mousePosition:FlxPoint;
	private var playerPosition:FlxPoint;
	
	private var arcMask:FlxSprite;
	
	private var visionMask:FlxSprite;
	
	
	private var shadow:FlxSprite;
	
	private var lineStyle:LineStyle = { color: FlxColor.TRANSPARENT, thickness: 1 };
	private var drawStyle:DrawStyle = { smoothing: true };
	
	public var gamepad:FlxGamepad;
	private var moveAxis:FlxPoint;
	//private var moveYAxis:FlxPoint;
	
	private var shadowPolygon:Array<FlxPoint> = new Array<FlxPoint>();
	
	
	override public function create():Void
	{
		//init some utility variables
		mousePosition = new FlxPoint(0, 0);
		playerPosition = new FlxPoint(400, 400);
		screenWidth = FlxG.stage.stageWidth;
		screenHeight = FlxG.stage.stageHeight;
		//init the physics space
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 0);
		
		super.create();
		//init the graphics
		initGraphics();
		
		createBoxes();
		
		initPlayer();
		moveAxis = new FlxPoint();
		
		debugText = new FlxText(0, 0, 100);
		add(debugText);
		
		FlxG.addChildBelowMouse(fps = new FPS(FlxG.width - 60, 5, FlxColor.WHITE));
		
		FlxG.camera.follow(player, LOCKON, 1);
		
		arcMask = new FlxSprite(0, 0);
		arcMask.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		arcMask.loadGraphic("assets/images/mask.png");
		add(arcMask);
	}

	override public function update(elapsed:Float):Void
	{
		
		
		moveAxis.x = 0;
		moveAxis.y = 0;
		//update mouse position
		mousePosition.x = FlxG.mouse.x;
		mousePosition.y = FlxG.mouse.y;
		playerPosition.x = player.body.position.x;
		playerPosition.y = player.body.position.y;
		
		
		drawVision();
		
		gamepad = FlxG.gamepads.lastActive;
		
		if (gamepad != null)
		{
			var pressed = gamepad.pressed;
			var value = gamepad.analog.value;
			moveAxis.x = value.LEFT_STICK_X;
			moveAxis.y = value.LEFT_STICK_Y;
			
		} else {
			if (FlxG.keys.anyPressed([A, LEFT]))
			{
				player.body.velocity.x = -speed;
			}
			else if (FlxG.keys.anyPressed([D, RIGHT]))
			{
				player.body.velocity.x = speed;
			}
			else
			{
				player.body.velocity.x = 0;
			}
			
			if (FlxG.keys.anyPressed([W, UP]))
			{
				player.body.velocity.y = -speed;
			}
			else if (FlxG.keys.anyPressed([S, DOWN]))
			{
				player.body.velocity.y = speed;
			}
			else
			{
				player.body.velocity.y = 0;
			}
		}
		
		player.body.rotation = Util.instance.getAngle(mousePosition, playerPosition);
		arcMask.angle = Util.instance.radToDeg(Util.instance.getAngle(mousePosition, playerPosition));
		
		debugText.text = Std.string(player.body.velocity);
		
		//var dir:Vec2 = Vec2.weak(leftStick.x * acc, leftStick.y * acc);
		//player.body.velocity = impulse;
		
		//debutText.text = Std.string();
		super.update(elapsed);
		
	}
	
	private function initPlayer():Void
	{
		player = new Player(screenWidth / 2, screenHeight / 2);
		add(player);
	}
	
	/**
	 * Creates and adds the various graphics assets into the scene
	 */
	private function initGraphics():Void
	{	
		//sprite to hold the floor graphics
		floor = new FlxSprite(0, 0);
		floor.makeGraphic(screenWidth, screenHeight, 0xff88A2A0);
		//floor.loadGraphic("assets/images/floor.png");
		add(floor);
		
		//sprite that occludes the area of the map not currently visible
		shadow = new FlxSprite(0, 0);
		shadow.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT, true);
		shadow.alpha = 0.25;
		add(shadow);
		
		//sprite that masks the visible area
		visionMask = new FlxSprite(0, 0);
		visionMask.makeGraphic(FlxG.width, FlxG.height, 0x66000000, true);
		add(visionMask);
		
		
	}
	
	
	private function createBoxes():Void
	{
		boxes = new Array<Box>();
		for (i in 0...50)
		{
			boxes[i] = new Box(Math.random() * screenWidth, Math.random() * screenHeight, 30, 30);
			add(boxes[i]);
		}
	}
	
	/**
	 * Draws the visible area as a polygon and applies that polygon as an inverse mask to the given sprite
	 */
	private function drawVision():Void
	{	
		//clear the vision layer
		shadow.fill(FlxColor.TRANSPARENT);
		//go through each box
		for (b in boxes)
		{
			//check box is inside the range to actually have a visible shadow
			if (Util.instance.getDistance(b.or, playerPosition) < visionLength)
			{
				//build a shadow polygon for the given box
				shadowPolygon = visionManager.buildShadowPolygon(b, playerPosition, visionLength);
				//draw a polygon using the sorted points
				shadow.drawPolygon(shadowPolygon, 0xff000000, lineStyle, drawStyle);
			}
		}
		//add the arc mask to the shadow
		arcMask.x = playerPosition.x - shadowSize / 2;
		arcMask.y = playerPosition.y - shadowSize / 2;
	}
	
	
	
	/**
	 * applies the mask sprite as an inverse mask to the given sprite and returns it into the output sprite
	 * @param	sprite
	 * @param	mask
	 * @param	output
	 * @return
	 */
	public static function invertedAlphaMaskFlxSprite(sprite:FlxSprite, mask:FlxSprite, output:FlxSprite):FlxSprite
	{
		sprite.drawFrame();
		var data:BitmapData = sprite.pixels.clone();
		data.copyChannel(mask.pixels, new Rectangle(0, 0, sprite.width, sprite.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		data.colorTransform(new Rectangle(0, 0, sprite.width, sprite.height), new ColorTransform(0,0,0,-1,0,0,0,255));
		output.pixels = data;
		return output;
	}
	
}