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
	private var screenWidth:Int;
	private var screenHeight:Int;
	
	private var debugText:FlxText;
	private var fps:FPS;
	
	private var floor:FlxSprite;
	
	private var player:Player;
	private var speed:Float = 200;
	
	private var visionArc:Float = Math.PI / 6;
	private var visionLength:Float = 300;
	
	
	private var boxes:Array<Box>;
	
	private var mousePosition:FlxPoint;
	private var playerPosition:FlxPoint;
	
	private var arcMask:FlxSprite;
	
	private var visionMask:FlxSprite;
	private var fogMask:FlxSprite;
	
	
	
	private var visionShadow:FlxSprite;
	private var fogShadow:FlxSprite;
	
	private var faces:Array<Line>;
	private var intersects:Array<Intersect>;
	
	private var lineStyle:LineStyle = { color: FlxColor.TRANSPARENT, thickness: 1 };
	private var drawStyle:DrawStyle = { smoothing: true };
	
	public var gamepad:FlxGamepad;
	private var moveAxis:FlxPoint;
	//private var moveYAxis:FlxPoint;
	
	
	
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
		visionShadow = new FlxSprite(0, 0);
		visionShadow.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT, true);
		visionShadow.alpha = 0.5;
		add(visionShadow);
		
		//sprite that occludes the area of the map that hasn't yet been visible
		fogShadow = new FlxSprite(0, 0);
		fogShadow.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT, true);
		visionShadow.alpha = 0.5;
		add(fogShadow);
		
		//sprite that masks the visible area
		visionMask = new FlxSprite(0, 0);
		visionMask.makeGraphic(FlxG.width, FlxG.height, 0x66000000, true);
		add(visionMask);
		
		//sprite that masks the unrevealed area
		fogMask = new FlxSprite(0, 0);
		fogMask.makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
		add(fogMask);
		
		arcMask = new FlxSprite(0, 0);
		arcMask.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		arcMask.loadGraphic("assets/images/mask.png");
		//add(arcMask);
	}
	
	
	private function createBoxes():Void
	{
		boxes = new Array<Box>();
		
		boxes[0] = new Box(400, 400, 50, 50);
		add(boxes[0]);
		/*
		boxes[1] = new Box(400, 800, 800, 10);
		add(boxes[1]);
		boxes[2] = new Box(0, 400, 10, 800);
		add(boxes[2]);
		boxes[3] = new Box(800, 400, 10, 800);
		add(boxes[3]);
		
		for (i in 4...5)
		{
			boxes[i] = new Box(Math.random() * 700 + 50, Math.random() * 700 + 50, 30, 30);
			add(boxes[i]);
		}
		*/
		
		
		
		faces = new Array<Line>();
		for (i in boxes)
		{
			for (j in i.faces)
			{
				faces.push(j);
			}
		}
	}
	
	/**
	 * Draws the visible area as a polygon and applies that polygon as an inverse mask to the given sprite
	 */
	private function drawVision():Void
	{	
		//clear the vision layer
		visionShadow.fill(FlxColor.TRANSPARENT);
		
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		var shadowPoints:Array<FlxPoint> = new Array<FlxPoint>();
		//go through each box
		for (b in boxes)
		{
			//clear the points
			points = [];
			shadowPoints = [];
			//go through each vertex
			for (p in b.vertices)
			{
				//add this vertex to the array
				points.push(p);
				//get the angle between player and point
				var theta:Float = Util.instance.getAngle(p, playerPosition);
				//get the x & y distances
				var dx1:Float = p.x - playerPosition.x;
				var dy1:Float = p.y - playerPosition.y;
				//get the projected x & y distances
				var dx2:Float = Math.cos(theta) * visionLength * 2;
				var dy2:Float = Math.sin(theta) * visionLength * 2;
				//get projected point
				var p2:FlxPoint = new FlxPoint(playerPosition.x + dx2, playerPosition.y + dy2);
				//get the distance between the point and the projected point
				var d_abs1:Float = Util.instance.getDistance(playerPosition, p);
				var d_abs2:Float = Util.instance.getDistance(playerPosition, p2);
				//if the project point is farther away than the source point
				if (d_abs1 < d_abs2)
					//add the shadow point to the array
					shadowPoints.push(p2);
			}
			//sort points by angle
			points = Util.instance.sortByAngle(points, playerPosition);
			
			var halfPi:Float = Math.PI / 2;
			//remove the 2 points who have the angles between the greatest and smallest, taking into account the weirdness with atan2
			if (Util.instance.getAngle(points[0], playerPosition) < 0 - halfPi && Util.instance.getAngle(points[3], playerPosition) > halfPi)
			{
				points.pop();
				points.shift();
			} else {
				points.splice(1, 2);
			}
			//append the shadow points to the source points
			var allPoints:Array<FlxPoint> = points.concat(shadowPoints);
			//get average position between each stored point
			var average:FlxPoint = Util.instance.getAveragePosition(allPoints);
			//sort all points by angle from average (ensures the polygon draws properly)
			allPoints = Util.instance.sortByAngle(allPoints, average);
			//draw a polygon using the sorted points
			visionShadow.drawPolygon(allPoints, 0xff000000, lineStyle, drawStyle);
			//add the arc mask to the shadow
			visionShadow.stamp(arcMask, Std.int(playerPosition.x - 400), Std.int(playerPosition.y - 400));
		}
	}
	
	/**
	 * Gets an array of points, including "buffer" points around each one (ensures that rays cast towards the points reach the walls behind
	 * @param	faces
	 * @return
	 */
	private function getAllPoints(faces:Array<Line>):Array<FlxPoint>
	{
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		for (f in faces)
		{
			if (Util.instance.getDistance(f.a, playerPosition) <= visionLength)
			{
				points.push(f.a);
				//points.push(new FlxPoint(f.a.x + 1, f.a.y));
				//points.push(new FlxPoint(f.a.x, f.a.y + 1));
				//points.push(new FlxPoint(f.a.x - 1, f.a.y));
				//points.push(new FlxPoint(f.a.x, f.a.y - 1));
			}
			
			if (Util.instance.getDistance(f.b, playerPosition) <= visionLength)
			{
				points.push(f.b);
				//points.push(new FlxPoint(f.b.x + 1, f.b.y));
				//points.push(new FlxPoint(f.b.x, f.b.y + 1));
				//points.push(new FlxPoint(f.b.x - 1, f.a.y));
				//points.push(new FlxPoint(f.a.x, f.b.y - 1));
			}
			
		}
		return points;
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