package objects;

import flixel.math.FlxPoint;

class MyPoint extends FlxPoint
{
	public var angle:Float;

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		angle = Math.POSITIVE_INFINITY;
	}
	
}