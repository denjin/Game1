package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
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
import objects.Line;
import openfl.display.FPS;
import player.Player;
import vision.VisionManager;

using flixel.util.FlxSpriteUtil;
using Util;

class PlayState extends FlxState
{	
	private var visionManager:VisionManager = new VisionManager();
	
	private var wallSprites:FlxSpriteGroup;
	
	private var levelWidth:Int = 3840;
	private var levelHeight:Int = 3840;
	
	private var screenWidth:Int;
	private var screenHeight:Int;
	
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
	private var visionLength:Float = 640;
	
	private var hudCam:FlxCamera;
	private var hud:FlxGroup;
	
	private var walls:Array<Wall>;
	//private var boxSprites:Array<FlxSprite>;
	
	private var mousePosition:FlxPoint;
	private var playerPosition:FlxPoint;
	private var cameraPosition:FlxPoint;
	
	private var shadow:FlxSprite;
	
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
		
		wallSprites = new FlxSpriteGroup();
		add(wallSprites);
		
		createWalls();
		
		
		initPlayer();
		moveAxis = new FlxPoint();
		lookAxis = new FlxPoint();
		
		debugText = new FlxText(0, 0, 100);
		//add(debugText);
		
		FlxG.addChildBelowMouse(fps = new FPS(FlxG.width - 60, 5, FlxColor.WHITE));
		
		FlxG.camera.follow(playerSprite, LOCKON, 1);
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
			lookAngle = Util.getAngle(lookAxis, new FlxPoint(0, 0));
			
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
			lookAngle = Util.getAngle(mousePosition, playerPosition);
		}
		
		//rotate the player
		lookAngle = Util.radToDeg(lookAngle);
		player.look(lookAngle);
		//move the player sprite
		playerSprite.setPosition(playerPosition.x - playerSpriteOffset.x, playerPosition.y - playerSpriteOffset.y);
		
		//sortableObjects.sort(FlxSort.byY, FlxSort.ASCENDING);
		super.update(elapsed);
	}
	
	private function initPlayer():Void
	{
		playerSprite = new FlxSprite(screenWidth / 2, screenHeight / 2 - 50);
		playerSprite.loadGraphic("assets/images/player/e.png");
		add(playerSprite);
		
		player = new Player(screenWidth / 2, screenHeight / 2, playerRadius, playerSprite);
		player.body.cbTypes.add(playerCbType);
		//add(player);
		
		//sortableObjects.add(playerSprite);
	}
	
	/**
	 * Creates and adds the various graphics assets into the scene
	 */
	private function initGraphics():Void
	{	
		//sprite to hold the floor graphics
		floor = new FlxSprite(0, 0);
		floor.makeGraphic(levelWidth, levelHeight, 0xff364156);
		add(floor);
		
		//sprite that occludes the area of the map not currently visible
		shadow = new FlxSprite(0, 0);
		shadow.makeGraphic(screenWidth, screenHeight, FlxColor.TRANSPARENT, true);
		//shadow.alpha = 0.25;
		add(shadow);
	}
	
	
	private function createWalls():Void
	{
		walls = new Array<Wall>();
		//boxSprites = new Array<FlxSprite>();
		var _x:Float;
		var _y:Float;
		for (i in 0...10)
		{
			_x = Math.random() * screenWidth;
			_y = Math.random() * screenHeight;
			walls[i] = new Wall(_x, _y, 60, 60, playerRadius);
			walls[i].body.userData.wall = walls[i];
			walls[i].body.cbTypes.add(boxCbType);
			
			var _wall:FlxSprite = new FlxSprite(_x - 30, _y - 30);
			_wall.makeGraphic(60, 60, 0xff212D40, false);
			wallSprites.add(_wall);
			
			add(walls[i]);
		}
	}
	
	/**
	 * Draws the visible area as a polygon and applies that polygon as an inverse mask to the given sprite
	 */
	private function drawVision():Void
	{	
		//clear the shadow sprite
		shadow.fill(FlxColor.TRANSPARENT);
		
		//go through each box
		for (w in walls)
		{
			//check box is inside the range to actually have a visible shadow
			if (Util.getDistance(w.or, playerPosition) < visionLength)
			{
				//build a shadow polygon for the given box
				shadowPolygon = visionManager.buildShadowPolygon(w, playerPosition, visionLength);
				//draw the polygon in the shadow sprite
				shadow.drawPolygon(shadowPolygon, 0xff11151C, lineStyle, drawStyle);
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