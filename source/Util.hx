package;
import flash.geom.Point;
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
	
	public function getAveragePosition(points:Array<FlxPoint>):FlxPoint
	{
		var ax:Float = 0;
		var ay:Float = 0;
		
		for (p in points)
		{
			ax += p.x;
			ay += p.y;
		}
		
		ax /= points.length;
		ay /= points.length;
		
		return new FlxPoint(ax, ay);
	}
	
	public function radToDeg(theta:Float):Float
	{
		return theta * 180 / Math.PI;
	}
	
	public function degToRad(theta:Float):Float
	{
		return theta * Math.PI / 180;
	}
	
	public function sortByAngle(points:Array<FlxPoint>, origin:FlxPoint):Array<FlxPoint>
	{
		points.sort(function(a:FlxPoint, b:FlxPoint) {
			var a_angle:Float = getAngle(a, origin);
			var b_angle:Float = getAngle(b, origin);
			if(a_angle < b_angle) return -1;
			else if(a_angle > b_angle) return 1;
			else return 0;
		});
		return points;
	}
	
	public function sortByDistance(points:Array<FlxPoint>, origin:FlxPoint):Array<FlxPoint>
	{
		points.sort(function(a:FlxPoint, b:FlxPoint) {
			var a_dist:Float = getDistance(a, origin);
			var b_dist:Float = getDistance(b, origin);
			if(a_dist < b_dist) return -1;
			else if(a_dist > b_dist) return 1;
			else return 0;
		});
		return points;
	}
	
}