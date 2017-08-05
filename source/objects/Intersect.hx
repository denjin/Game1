package objects;

import flixel.math.FlxPoint;

class Intersect extends FlxPoint
{
	public var t1:Float;

	public function new(X:Float = 0, Y:Float = 0, _t1:Float) 
	{
		super(X, Y);
		t1 = _t1;
	}
	
}