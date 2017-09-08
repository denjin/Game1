package;

import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.constraint.LineJoint;
import nape.geom.Vec2;
import objects.Wall;
import maths.Line;
import openfl.display.FPS;
import player.Player;
import vision.VisionManager;

import flixel.util.FlxCollision;

import utils.Global;

using flixel.util.FlxSpriteUtil;
using utils.Util;


class PlayState extends FlxState
{	
	private var visionManager:VisionManager;
	
	private var wallSprites:FlxSpriteGroup;
	
	private var shadowSize:Int = 2204;
	
	private var debugText:FlxText;
	private var fps:FPS;
	
	private var floor:FlxSprite;
	
	private var player:Player;
	private var playerSprite:FlxSprite;
	private var playerSpriteOffset:FlxPoint = new FlxPoint(24, 65);
	
	private var speed:Float = 200;
	private static var playerRadius:Int = 21;
	
	//private var visionArc:Float = Math.PI / 6;
	private var visionLength:Float = 1000;
	
	private var hudCam:FlxCamera;
	private var hud:FlxGroup;
	
	private var walls:Array<Wall>;
	//private var boxSprites:Array<FlxSprite>;
	
	private var playerPosition:FlxPoint;
	
	private var shadow:FlxSprite;
	private var visionSprite:FlxSprite;
	
	private var lineStyle:LineStyle = { color: FlxColor.TRANSPARENT, thickness: 1 };
	private var lineStyle1:LineStyle = { color: FlxColor.RED, thickness: 1 };
	private var drawStyle:DrawStyle = { smoothing: true };
	
	public var gamepad:FlxGamepad;
	private var moveAxis:FlxPoint;
	private var lookAxis:FlxPoint;
	private var lookAngle:Float;
	
	private var shadowPolygon:Array<FlxPoint> = new Array<FlxPoint>();
	
	
	private var playerCbType:CbType = new CbType();
	private var boxCbType:CbType = new CbType();
	
	private var collisionListener:InteractionListener;
	private var collisionEndListener:InteractionListener;
	
	private var coverJoint:LineJoint;
	
	
	override public function create():Void
	{
		//init some utility variables
		Global.instance.mousePosition = new FlxPoint();
		playerPosition = new FlxPoint();
		Global.instance.screen = new FlxRect(0, 0, FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		
		visionManager = new VisionManager();
		
		Global.instance.levelWidth = 3840;
		Global.instance.levelHeight = 3840;
		
		//init the physics space
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 0);
		//FlxNapeSpace.drawDebug = true;
		
		
		
		
		super.create();
		
		//sprite to hold the floor graphics
		floor = new FlxSprite(0, 0);
		floor.makeGraphic(Global.instance.levelWidth, Global.instance.levelHeight, 0xff364156);
		add(floor);
		
		createWalls();
		
		//init the shadow
		initShadow();
		
		initPlayer();
		
		moveAxis = new FlxPoint();
		lookAxis = new FlxPoint();
		
		debugText = new FlxText(0, 0, 100);
		//add(debugText);
		
		FlxG.addChildBelowMouse(fps = new FPS(FlxG.width - 60, 5, FlxColor.WHITE));
		
		FlxG.camera.follow(playerSprite, LOCKON, 1);
		//FlxG.camera.minScrollX = 0;
		//FlxG.camera.minScrollY = 0;
		//FlxG.camera.maxScrollX = Global.instance.levelWidth;
		//FlxG.camera.maxScrollY = Global.instance.levelHeight;
		
		//hudCam = new FlxCamera(0, 0, screenWidth, screenHeight);
		//hud = new FlxGroup();
		
		collisionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, boxCbType, playerCbType, onPlayerTouchesBox);
		FlxNapeSpace.space.listeners.add(collisionListener);
		
		collisionEndListener = new InteractionListener(CbEvent.END, InteractionType.COLLISION, boxCbType, playerCbType, onPlayerStopsTouchingBox);
		FlxNapeSpace.space.listeners.add(collisionEndListener);
	}
	
	private function initPlayer():Void
	{
		playerSprite = new FlxSprite(Global.instance.screen.width / 2, Global.instance.screen.height / 2 - 50);
		playerSprite.loadGraphic("assets/images/player/e.png");
		add(playerSprite);
		
		player = new Player(Global.instance.screen.width / 2, Global.instance.screen.height / 2, playerRadius, playerSprite);
		player.body.cbTypes.add(playerCbType);
	}
	
	/**
	 * Creates and adds the shadow graphics into the scene
	 */
	private function initShadow():Void
	{	
		//sprite that occludes the area of the map not currently visible
		shadow = new FlxSprite(0, 0);
		shadow.makeGraphic(Std.int(Global.instance.screen.width), Std.int(Global.instance.screen.height), FlxColor.TRANSPARENT, true);
		shadow.alpha = 0.5;
		add(shadow);
	}
	
	
	private function createWalls():Void
	{
		wallSprites = new FlxSpriteGroup();
		add(wallSprites);
		
		walls = new Array<Wall>();
		//boxSprites = new Array<FlxSprite>();
		var _x:Float;
		var _y:Float;
		for (i in 0...50)
		{
			_x = Math.random() * Global.instance.levelWidth;
			_y = Math.random() * Global.instance.levelHeight;
			walls[i] = new Wall(_x, _y, 60, 60, playerRadius);
			walls[i].body.userData.wall = walls[i];
			walls[i].body.cbTypes.add(boxCbType);
			
			var _wall:FlxSprite = new FlxSprite(_x - 30, _y - 30);
			_wall.makeGraphic(60, 60, 0xff212D40, false);
			wallSprites.add(_wall);
			
			add(walls[i]);
		}
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
		Global.instance.screen.x = FlxG.camera.scroll.x;
		Global.instance.screen.y = FlxG.camera.scroll.y;
		//move the shadow sprite
		shadow.x = Global.instance.screen.x;
		shadow.y = Global.instance.screen.y;
		
		
		
		
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
			lookAngle = Util.getAngle(lookAxis, new FlxPoint(0, 0));
			
		} else {//if using a keyboard and mouse
			//update mouse position
			Global.instance.mousePosition.x = FlxG.mouse.x;
			Global.instance.mousePosition.y = FlxG.mouse.y;
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
				if (player.touchingWall)
					enterCover(player.touchedWall);
			}
			//exit cover
			if (FlxG.keys.anyJustReleased([SHIFT]))
			{
				//if player was actually in cover
				if (player.coverJoint != null)
					exitCover();
			}
			lookAngle = Util.getAngle(Global.instance.mousePosition, playerPosition);
		}
		
		//rotate the player
		lookAngle = Util.radToDeg(lookAngle);
		player.look(lookAngle);
		//move the player sprite
		playerSprite.setPosition(playerPosition.x - playerSpriteOffset.x, playerPosition.y - playerSpriteOffset.y);
		//sortableObjects.sort(FlxSort.byY, FlxSort.ASCENDING);
		//draw the shadow polygons
		drawVision();
		
		//trace(lookAngle);
		super.update(elapsed);
	}
	
	
	
	/**
	 * Draws the visible area as a polygon and applies that polygon as an inverse mask to the given sprite
	 */
	private function drawVision():Void
	{	
		//clear the shadow sprite
		shadow.fill(FlxColor.TRANSPARENT);
		//clear the drawing array
		shadowPolygon = [];
		//create shadow of the area outside the player's vision
		shadowPolygon = visionManager.buildVisionPolygon(lookAngle, 40);
		//move shadow polygon from 0,0 to the centre of the screen
		for (p in shadowPolygon)
		{
			p.x += Global.instance.screen.width / 2;
			p.y += Global.instance.screen.height / 2;
		}
		//draw this shadow
		shadow.drawPolygon(shadowPolygon, 0xff11151C, lineStyle, drawStyle);
		
		//cast shadow on player's vision
		//go through each wall
		for (w in walls)
		{
			if (Util.getDistance(w.or, playerPosition) < visionLength)
			{
				//clear the drawing array
				shadowPolygon = [];
				//build a shadow polygon for the given box
				shadowPolygon = visionManager.buildShadowPolygon(w, playerPosition, visionLength, FlxPoint.weak(Global.instance.screen.x, Global.instance.screen.y));
				//draw the polygon in the shadow sprite
				shadow.drawPolygon(shadowPolygon, 0xff11151C, lineStyle, drawStyle);
				shadow.drawRect(w.x - w.w / 2 - Global.instance.screen.x, w.y - w.h / 2 - Global.instance.screen.y, w.w, w.h, 0xff11151C, lineStyle, drawStyle);
			}
		}
		
	}
		
	private function enterCover(wall:Wall):Void
	{	
		//find the cover face to build the line joint from
		var coverFace:Line = Util.getClosestCoverFace(wall, playerPosition);
		//get the length of the cover face
		var length:Float = Util.getDistance(coverFace.a, coverFace.b);
		//get the direction
		var dir:Vec2 = Util.lineDirection(coverFace);
		//get the start point for the joint (converts cover joint in world space to local space)
		var anchor:Vec2 = new Vec2(coverFace.a.x - wall.body.position.x, coverFace.a.y - wall.body.position.y);
		//build the line joint
		coverJoint = new LineJoint(
			wall.body,			//body 1
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
		//player.loadGraphic("assets/images/player_touching.png");
	}
	
	private function exitCover():Void
	{
		FlxNapeSpace.space.constraints.remove(player.coverJoint);
	}
	
	private function onPlayerTouchesBox(cb:InteractionCallback):Void
	{
		player.touchingWall = true;
		player.touchedWall = cb.int1.userData.wall;
	}
	
	private function onPlayerStopsTouchingBox(cb:InteractionCallback):Void
	{
		player.touchingWall = false;
		player.touchedWall = null;
	}
	
}