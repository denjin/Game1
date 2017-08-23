package;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import nape.constraint.DistanceJoint;
import nape.constraint.LineJoint;
import nape.shape.Edge;
import nape.shape.Polygon;
import nape.shape.Shape;

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

import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.InteractionCallback;

using flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import flixel.util.FlxSpriteUtil.DrawStyle;

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
	
	private var levelWidth:Int = 3840;
	private var levelHeight:Int = 3840;
	
	private var screenWidth:Int;
	private var screenHeight:Int;
	
	private var shadowSize:Int = 2204;
	
	private var debugText:FlxText;
	private var fps:FPS;
	
	private var floor:FlxSprite;
	
	private var player:Player;
	private var speed:Float = 200;
	private static var playerRadius:Int = 21;
	
	//private var visionArc:Float = Math.PI / 6;
	private var visionLength:Float = 640;
	
	private var hudCam:FlxCamera;
	private var hud:FlxGroup;
	
	private var boxes:Array<Box>;
	
	private var mousePosition:FlxPoint;
	private var playerPosition:FlxPoint;
	private var cameraPosition:FlxPoint;
	
	private var arcMask:FlxSprite;
	
	private var visionMask:FlxSprite;
	
	
	private var shadow:FlxSprite;
	private var fog:FlxSprite;
	private var fogMask:FlxSprite;
	private var overlay:FlxSprite;
	
	private var lineStyle:LineStyle = { color: FlxColor.TRANSPARENT, thickness: 1 };
	private var lineStyle1:LineStyle = { color: FlxColor.RED, thickness: 1 };
	private var drawStyle:DrawStyle = { smoothing: true };
	
	public var gamepad:FlxGamepad;
	private var moveAxis:FlxPoint;
	private var lookAxis:FlxPoint;
	private var lookAngle:Float;
	//private var moveYAxis:FlxPoint;
	
	private var shadowPolygon:Array<FlxPoint> = new Array<FlxPoint>();
	
	
	private var playerCbType:CbType = new CbType();
	private var boxCbType:CbType = new CbType();
	
	private var collisionListener:InteractionListener;
	private var collisionEndListener:InteractionListener;
	
	private var coverJoint:LineJoint;
	
	
	override public function create():Void
	{
		//init some utility variables
		mousePosition = new FlxPoint();
		playerPosition = new FlxPoint(400, 400);
		cameraPosition = new FlxPoint();
		screenWidth = FlxG.stage.stageWidth;
		screenHeight = FlxG.stage.stageHeight;
		//init the physics space
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 0);
		//FlxNapeSpace.drawDebug = true;
		
		super.create();
		//init the graphics
		initGraphics();
		
		createBoxes();
		
		initPlayer();
		moveAxis = new FlxPoint();
		lookAxis = new FlxPoint();
		
		debugText = new FlxText(0, 0, 100);
		//add(debugText);
		
		FlxG.addChildBelowMouse(fps = new FPS(FlxG.width - 60, 5, FlxColor.WHITE));
		
		FlxG.camera.follow(player, LOCKON, 1);
		FlxG.camera.minScrollX = 0;
		FlxG.camera.minScrollY = 0;
		FlxG.camera.maxScrollX = levelWidth;
		FlxG.camera.maxScrollY = levelHeight;
		
		//hudCam = new FlxCamera(0, 0, screenWidth, screenHeight);
		//hud = new FlxGroup();
		
		collisionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, boxCbType, playerCbType, onPlayerTouchesBox);
		FlxNapeSpace.space.listeners.add(collisionListener);
		
		collisionEndListener = new InteractionListener(CbEvent.END, InteractionType.COLLISION, boxCbType, playerCbType, onPlayerStopsTouchingBox);
		FlxNapeSpace.space.listeners.add(collisionEndListener);
		
		arcMask = new FlxSprite(0, 0);
		arcMask.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		arcMask.loadGraphic("assets/images/mask.png");
		add(arcMask);
		
		overlay = new FlxSprite();
		overlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(overlay);
	}

	override public function update(elapsed:Float):Void
	{
		//clear the movement axis
		moveAxis.x = 0;
		moveAxis.y = 0;
		lookAxis.x = 0;
		lookAxis.y = 0;
		
		//update the player's position
		playerPosition.x = player.body.position.x;
		playerPosition.y = player.body.position.y;
		//get the camera's position
		cameraPosition.x = FlxG.camera.scroll.x;
		cameraPosition.y = FlxG.camera.scroll.y;
		//move the shadow sprite
		//shadow.x = cameraPosition.x;
		//shadow.y = cameraPosition.y;
		
		
		//draw the shadow polygons
		drawVision();
		//get any connected gamepad
		gamepad = FlxG.gamepads.lastActive;
		
		if (gamepad != null)//if using a gamepad
		{
			var pressed = gamepad.pressed;
			var value = gamepad.analog.value;
			moveAxis.x = value.LEFT_STICK_X;
			moveAxis.y = value.LEFT_STICK_Y;
			lookAxis.x = value.RIGHT_STICK_X;
			lookAxis.y = value.RIGHT_STICK_Y;
			player.body.velocity.x = moveAxis.x * speed;
			player.body.velocity.y = moveAxis.y * speed;
			lookAngle = Util.instance.getAngle(lookAxis, new FlxPoint(0, 0));
			
		} else {//if using a keyboard and mouse
			//update mouse position
			mousePosition.x = FlxG.mouse.x;
			mousePosition.y = FlxG.mouse.y;
			//x axis movement
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
			//y axis movement
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
			//enter cover
			if (FlxG.keys.anyJustPressed([SHIFT]))
			{
				//if player is actually touching a box
				if (player.touchingBox)
					enterCover(player.touchedBox);
			}
			//exit cover
			if (FlxG.keys.anyJustReleased([SHIFT]))
			{
				//if player was actually in cover
				if (player.coverJoint != null)
					exitCover();
			}
			lookAngle = Util.instance.getAngle(mousePosition, playerPosition);
		}
		
		//rotate the player
		//player.body.rotation = lookAngle;
		lookAngle = Util.instance.radToDeg(lookAngle);
		//trace(lookAngle);
		
		player.look(lookAngle);
		
		super.update(elapsed);
	}
	
	private function initPlayer():Void
	{
		player = new Player(screenWidth / 2, screenHeight / 2, playerRadius);
		player.body.cbTypes.add(playerCbType);
		add(player);
	}
	
	/**
	 * Creates and adds the various graphics assets into the scene
	 */
	private function initGraphics():Void
	{	
		//sprite to hold the floor graphics
		floor = new FlxSprite(0, 0);
		floor.makeGraphic(levelWidth, levelHeight, 0xff88A2A0);
		//floor.loadGraphic("assets/images/floor.png");
		add(floor);
		
		//sprite that occludes the area of the map not currently visible
		shadow = new FlxSprite(0, 0);
		shadow.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT, true);
		//shadow.alpha = 0.25;
		add(shadow);
	}
	
	
	private function createBoxes():Void
	{
		boxes = new Array<Box>();
		for (i in 0...50)
		{
			boxes[i] = new Box(Math.random() * screenWidth, Math.random() * screenHeight, 60, 60, playerRadius);
			boxes[i].body.userData.box = boxes[i];
			boxes[i].body.cbTypes.add(boxCbType);
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
		//move the arc mask
		arcMask.x = playerPosition.x - shadowSize / 2;
		arcMask.y = playerPosition.y - shadowSize / 2;
	}
		
	private function enterCover(box:Box):Void
	{	
		//find the cover face to build the line joint from
		var coverFace:Line = Util.instance.getClosestCoverFace(box, playerPosition);
		//get the length of the cover face
		var length:Float = Util.instance.getDistance(coverFace.a, coverFace.b);
		//get the direction
		var dir:Vec2 = Util.instance.lineDirection(coverFace);
		//get the start point for the joint (converts cover joint in world space to local space)
		var anchor:Vec2 = new Vec2(coverFace.a.x - box.body.position.x, coverFace.a.y - box.body.position.y);
		//build the line joint
		coverJoint = new LineJoint(
			box.body,			//body 1
			player.body,		//body 2
			anchor,				//anchor 1
			new Vec2(),			//anchor 2
			dir,				//direction
			0,					//joint min
			length				//joint max
		);
		//add the joint to the nape space
		FlxNapeSpace.space.constraints.add(coverJoint);
		//store the joint within the player
		player.coverJoint = coverJoint;
		//change sprite
		player.loadGraphic("assets/images/player_touching.png");
	}
	
	private function exitCover():Void
	{
		FlxNapeSpace.space.constraints.remove(player.coverJoint);
		overlay.fill(FlxColor.TRANSPARENT);
	}
	
	private function onPlayerTouchesBox(cb:InteractionCallback):Void
	{
		player.touchingBox = true;
		player.touchedBox = cb.int1.userData.box;
		player.loadGraphic("assets/images/player.png");
	}
	
	private function onPlayerStopsTouchingBox(cb:InteractionCallback):Void
	{
		
		player.touchingBox = false;
		player.touchedBox = null;
	}
	
}