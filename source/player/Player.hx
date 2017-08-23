package player;

import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import nape.constraint.LineJoint;
import nape.phys.BodyType;
import nape.phys.Material;
import objects.Box;

class Player extends FlxNapeSprite
{
	public var touchingBox:Bool = false;
	public var touchedBox:Box = null;
	public var coverJoint:LineJoint;
	
	public function new(_x:Float=0, _y:Float=0, _radius:Int, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool=false, EnablePhysics:Bool=false) 
	{
		super(_x, _y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		//init the graphics and physics body
		//this.makeGraphic(33, 43, FlxColor.TRANSPARENT);
		this.loadGraphic("assets/images/player/ne.png");
		this.createCircularBody(_radius, BodyType.DYNAMIC);
		this.physicsEnabled = true;
		//this.body.allowRotation = false;
		this.setBodyMaterial(Math.NEGATIVE_INFINITY, 0, 0);
		this.body.isBullet = true;
	}
	
	
	public function look(angle:Float):Void
	{
		if (angle < -112.5 && angle >= -157.5)
		{
			loadSprite("nw");
		}
		else if (angle < -67.5 && angle >= -112.5)
		{
			loadSprite("n");
		}
		else if (angle < -22.5 && angle >= -67.5)
		{
			loadSprite("ne");
		}
		else if (angle < 22.5 && angle >= -22.5)
		{
			loadSprite("e");
		}
		else if (angle < 67.5 && angle >= 22.5)
		{
			loadSprite("se");
		}
		else if (angle < 112.5 && angle >= 67.5)
		{
			loadSprite("s");
		}
		else if (angle < 157.5 && angle >= 112.5)
		{
			loadSprite("sw");
		}
		else
		{
			loadSprite("w");
		}
		
	}
	
	
	public function loadSprite(dir:String):Void
	{
		var str:String = "assets/images/player/" + dir + ".png";
		this.loadGraphic(str);
	}
}