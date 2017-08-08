package;
import flixel.math.FlxPoint;

class Util
{
	static public var instance(get, null):Util;
	static function get_instance(): Util return (instance == null) ? instance = new Util() : instance;
	private function new() {}
	
	public function getAngle(a:FlxPoint, b:FlxPoint):Float
	{
		return Math.atan2(a.y - b.y, a.x - b.x) + Math.PI;
	}
	
}