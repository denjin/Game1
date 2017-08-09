package;
import flixel.math.FlxPoint;

class Util
{
	static public var instance(get, null):Util;
	static function get_instance(): Util return (instance == null) ? instance = new Util() : instance;
	private function new() {}
	
	/**
	 * Gets the angle between two points (vectors)
	 * @param	a
	 * @param	b
	 * @return
	 */
	public function getAngle(a:FlxPoint, b:FlxPoint):Float
	{
		return Math.atan2(a.y - b.y, a.x - b.x);
	}
	
	/**
	 * Gets the distance between two points
	 * @param	a
	 * @param	b
	 * @return
	 */
	public function getDistance(a:FlxPoint, b:FlxPoint):Float
	{
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
}