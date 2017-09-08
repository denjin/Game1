package objects;

import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import maths.Line;
import nape.phys.BodyType;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import objects.interfaces.ICastsShadow;
import objects.interfaces.IProvidesCover;

class Wall extends FlxNapeSprite
	implements IProvidesCover
	implements ICastsShadow
{
	public var or:FlxPoint;
	public var w:Int;
	public var h:Int;
	//an array that stores the vertices of this box as an array of points
	public var vertices:Array<FlxPoint> = new Array<FlxPoint>();
	public var coverFaces:Array<Line> = new Array<Line>();
	
	public function new(_x:Float=0, _y:Float=0, _width:Int, _height:Int, _playerRadius, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool=false, EnablePhysics:Bool=false) 
	{	
		super(_x, _y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		w = _width;
		h = _height;
		or = new FlxPoint(_x, _y);
		//init the graphics and physics body
		this.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		//this.loadGraphic("assets/images/box.png", false, 60, 140);
		this.createRectangularBody(_width, _height, BodyType.STATIC);
		this.physicsEnabled = true;
		//store the vertices
		vertices[0] = new FlxPoint(_x - _width / 2, _y - _height / 2);//top left
		vertices[1] = new FlxPoint(_x + _width / 2, _y - _height / 2);//top right
		vertices[2] = new FlxPoint(_x + _width / 2, _y + _height / 2);//bottom right
		vertices[3] = new FlxPoint(_x - _width / 2, _y + _height / 2);//bottom left
		//store the cover faces
		//top Left -> top right
		var f0a:FlxPoint = new FlxPoint(vertices[0].x, vertices[0].y - _playerRadius);
		var f0b:FlxPoint = new FlxPoint(vertices[1].x, vertices[1].y - _playerRadius);
		coverFaces[0] = new Line(f0a, f0b);
		//top right -> bottom right
		var f1a:FlxPoint = new FlxPoint(vertices[1].x + _playerRadius, vertices[1].y);
		var f1b:FlxPoint = new FlxPoint(vertices[2].x + _playerRadius, vertices[2].y);
		coverFaces[1] = new Line(f1a, f1b);
		//bottom right -> bottom left
		var f2a:FlxPoint = new FlxPoint(vertices[2].x, vertices[2].y + _playerRadius);
		var f2b:FlxPoint = new FlxPoint(vertices[3].x, vertices[3].y + _playerRadius);
		coverFaces[2] = new Line(f2a, f2b);
		//bottom left -> top left
		var f3a:FlxPoint = new FlxPoint(vertices[3].x - _playerRadius, vertices[3].y);
		var f3b:FlxPoint = new FlxPoint(vertices[0].x - _playerRadius, vertices[0].y);
		coverFaces[3] = new Line(f3a, f3b);
	}
	
}