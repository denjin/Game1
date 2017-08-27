package player;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import nape.constraint.LineJoint;
import nape.phys.BodyType;
import nape.phys.Material;
import objects.Wall;

class Player extends FlxNapeSprite
{
	public var touchingWall:Bool = false;
	public var touchedWall:Wall = null;
	public var coverJoint:LineJoint;
	private var sprite:FlxSprite;
	
	public function new(_x:Float=0, _y:Float=0, _radius:Int, _sprite:FlxSprite, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool=false, EnablePhysics:Bool=false) 
	{
		super(_x, _y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		sprite = _sprite;
		//init the graphics and physics body
		//this.loadGraphic("assets/images/player/ne.png");
		this.makeGraphic(1, 1, FlxColor.TRANSPARENT, true);
		this.createCircularBody(_radius, BodyType.DYNAMIC);
		this.physicsEnabled = true;
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
		sprite.loadGraphic(str);
	}
}