package;
import flash.geom.Point;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

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
	
	/**
	 * Gets a point that lies at the mean position from the positions of an array of points
	 * @param	points
	 * @return
	 */
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
	
	/**
	 * Converts an angle measured in radians to degrees
	 * @param	theta
	 * @return
	 */
	public function radToDeg(theta:Float):Float
	{
		return theta * 180 / Math.PI;
	}
	
	/**
	 * Converts an angle measured in degrees to radians
	 * @param	theta
	 * @return
	 */
	public function degToRad(theta:Float):Float
	{
		return theta * Math.PI / 180;
	}
	
	/**
	 * Takes an array of points and sorts it based on the point's angle from the given origin point
	 * @param	points
	 * @param	origin
	 * @return	the original array
	 */
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
	
	/**
	 * Takes an array of points and sorts it based on the point's distance from the given origin point
	 * @param	points
	 * @param	origin
	 * @return	the original array
	 */
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
	
	/**
	 * applies the mask sprite as an inverse mask to the given sprite and returns it into the output sprite
	 * @param	sprite
	 * @param	mask
	 * @param	output
	 * @return
	 */
	public static function invertedAlphaMaskFlxSprite(sprite:FlxSprite, mask:FlxSprite, output:FlxSprite):FlxSprite
	{
		sprite.drawFrame();
		var data:BitmapData = sprite.pixels.clone();
		data.copyChannel(mask.pixels, new Rectangle(0, 0, sprite.width, sprite.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		data.colorTransform(new Rectangle(0, 0, sprite.width, sprite.height), new ColorTransform(0,0,0,-1,0,0,0,255));
		output.pixels = data;
		return output;
	}
	
}