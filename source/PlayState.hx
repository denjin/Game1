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

using flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flash.geom.Rectangle;
import flash.display.BitmapDataChannel;
import flash.geom.ColorTransform;

import objects.Box;
import objects.Intersect;
import objects.Line;
import objects.MyPoint;

import vision.VisionManager;

import flixel.addons.nape.FlxNapeSpace;

import flixel.addons.nape.FlxNapeSprite;

class PlayState extends FlxState
{	
	private var screenWidth:Int;
	private var screenHeight:Int;
	
	private var floor:FlxSprite;
	private var wallSides:FlxSprite;
	private var wallTops:FlxSprite;
	
	
	
	
	private var boxes:Array<Box>;
	
	private var mousePosition:FlxPoint;
	
	private var visionMask:FlxSprite;
	private var fogMask:FlxSprite;
	
	private var visionShadow:FlxSprite;
	private var fogShadow:FlxSprite;
	
	private var faces:Array<Line>;
	private var intersects:Array<Intersect>;
	
	private var lineStyle:LineStyle = { color: FlxColor.TRANSPARENT, thickness: 1 };
	private var drawStyle:DrawStyle = { smoothing: true };
	
	
	
	override public function create():Void
	{
		//init some utility variables
		mousePosition = new FlxPoint(0, 0);
		screenWidth = FlxG.stage.stageWidth;
		screenHeight = FlxG.stage.stageHeight;
		//init the physics space
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 0);
		super.create();
		//init the graphics
		initGraphics();
		
		createBoxes();
	}

	override public function update(elapsed:Float):Void
	{
		//update mouse position
		mousePosition.x = FlxG.mouse.x;
		mousePosition.y = FlxG.mouse.y;
		
		super.update(elapsed);
		
		drawVision();
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
		
		//sprite that holds the sides of the wall graphics
		wallSides = new FlxSprite(0, 0);
		wallSides.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT);
		add(wallSides);
		
		//sprite that holds the tops of the wall graphics
		wallTops = new FlxSprite(0, 0);
		wallTops.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT);
		add(wallTops);
		
		//sprite that occludes the area of the map not currently visible
		visionShadow = new FlxSprite(0, 0);
		visionShadow.makeGraphic(screenWidth, screenHeight, 0x66000000, true);
		add(visionShadow);
		
		//sprite that occludes the area of the map that hasn't yet been visible
		fogShadow = new FlxSprite(0, 0);
		fogShadow.makeGraphic(screenWidth, screenHeight, 0x66000000, true);
		add(fogShadow);
		
		//sprite that masks the visible area
		visionMask = new FlxSprite(0, 0);
		visionMask.makeGraphic(FlxG.width, FlxG.height, 0x66000000, true);
		
		//sprite that masks the unrevealed area
		fogMask = new FlxSprite(0, 0);
		fogMask.makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
	}
	
	
	private function createBoxes():Void
	{
		boxes = new Array<Box>();
		
		boxes[0] = new Box(400, 0, 800, 10);
		add(boxes[0]);
		boxes[1] = new Box(400, 800, 800, 10);
		add(boxes[1]);
		boxes[2] = new Box(0, 400, 10, 800);
		add(boxes[2]);
		boxes[3] = new Box(800, 400, 10, 800);
		add(boxes[3]);
		
		for (i in 4...54)
		{
			boxes[i] = new Box(Math.random() * 700 + 50, Math.random() * 700 + 50, 30, 30);
			add(boxes[i]);
		}
		
		
		
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
		visionMask.fill(0x44000000);
		//get all points including "buffer" points
		var points:Array<FlxPoint> = getAllPoints(faces);
		//build the vision polygon
		var visionPolygon:Array<FlxPoint> = VisionManager.instance.buildVisionPolygon(mousePosition, faces, points);
		//draw visible area into the vision and fog masks
		visionMask.drawPolygon(visionPolygon, 0xff000000, lineStyle, drawStyle);
		fogMask.drawPolygon(visionPolygon, 0xff000000, lineStyle, drawStyle);
		//mask the floor
		invertedAlphaMaskFlxSprite(fogShadow, fogMask, fogShadow);
		invertedAlphaMaskFlxSprite(visionShadow, visionMask, visionShadow);
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
			points.push(f.a);
			points.push(new FlxPoint(f.a.x + 1, f.a.y));
			points.push(new FlxPoint(f.a.x, f.a.y + 1));
			points.push(new FlxPoint(f.a.x - 1, f.a.y));
			points.push(new FlxPoint(f.a.x, f.a.y - 1));
			
			points.push(f.b);
			points.push(new FlxPoint(f.b.x + 1, f.b.y));
			points.push(new FlxPoint(f.b.x, f.b.y + 1));
			points.push(new FlxPoint(f.b.x - 1, f.a.y));
			points.push(new FlxPoint(f.a.x, f.b.y - 1));
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