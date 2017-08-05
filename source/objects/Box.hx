package objects;

import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import nape.phys.BodyType;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Box extends FlxNapeSprite
{
	public var vertices:Array<FlxPoint> = new Array<FlxPoint>();
	public var faces:Array<Line> = new Array<Line>();
	
	public function new(_x:Float=0, _y:Float=0, _width:Int, _height:Int, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool=false, EnablePhysics:Bool=false) 
	{	
		super(_x, _y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		
		this.makeGraphic(_width, _height, /*0xff708583*/FlxColor.TRANSPARENT);
		//this.loadGraphic("assets/images/box.png");
		this.createRectangularBody(_width, _height, BodyType.STATIC);
		
		vertices[0] = new FlxPoint(_x - _width / 2, _y - _height / 2);
		vertices[1] = new FlxPoint(_x + _width / 2, _y - _height / 2);
		vertices[2] = new FlxPoint(_x + _width / 2, _y + _height / 2);
		vertices[3] = new FlxPoint(_x - _width / 2, _y + _height / 2);
		
		faces[0] = new Line(vertices[0], vertices[1]);
		faces[1] = new Line(vertices[1], vertices[2]);
		faces[2] = new Line(vertices[2], vertices[3]);
		faces[3] = new Line(vertices[3], vertices[0]);
	}
	
}