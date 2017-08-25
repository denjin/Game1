package;
import flash.geom.Point;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import nape.geom.Vec2;
import nape.shape.Edge;
import nape.shape.Polygon;
import objects.Box;
import objects.Line;

class Util
{
	
	/**
	 * Gets the angle between two points (vectors)
	 * @param	a
	 * @param	b
	 * @return
	 */
	public static function getAngle(a:FlxPoint, b:FlxPoint):Float
	{
		return Math.atan2(a.y - b.y, a.x - b.x);
	}
	
	/**
	 * Gets the distance between two points
	 * @param	a
	 * @param	b
	 * @return
	 */
	public static function getDistance(a:FlxPoint, b:FlxPoint):Float
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
	public static function getAveragePosition(points:Array<FlxPoint>):FlxPoint
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
	
	
	public static function getMidPointFace(face:Line):FlxPoint
	{
		var ax:Float = (face.a.x + face.b.x) / 2;
		var ay:Float = (face.a.y + face.b.y) / 2;
		return new FlxPoint(ax, ay);
	}
	
	public static function getClosestCoverFace(box:Box, origin:FlxPoint):Line
	{
		var face:Line = null;
		var shortestDistance:Float = Math.NEGATIVE_INFINITY;
		
		for (f in box.coverFaces)
		{
			var d:Float = getDistance(origin, getMidPointFace(f));
			if (face == null || d <= shortestDistance)
			{
				face = f;
				shortestDistance  = d;
			}
		}
		return face;
	}
	
	/**
	 * Gets the flxpoint on a line a->b that lies closest to point p
	 * @param	a
	 * @param	b
	 * @param	p
	 * @return
	 */
	public static function getClosestPoint(a:FlxPoint, b:FlxPoint, p:FlxPoint):FlxPoint
	{
		//vector from a to b
		var ab:Vec2 = new Vec2(b.x - a.x, b.y - a.y);
		//vector from a to p
		var ap:Vec2 = new Vec2(p.x - a.x, p.y - a.y);
		//size of vector from a to b
		var abMagnitude:Float = ab.lsq();
		//dot product of ab and ap
		var dot:Float = ab.dot(ap);
		//normalised distance from a to p
		var d:Float = dot / abMagnitude;
		
		if (d < 0)
		{
			return a;
		}
		else if (d > 1)
		{
			return b;
		}
		else
		{
			return new FlxPoint(a.x + ab.x * d, a.y + ab.y * d);
		}
	}
	
	
	
	public static function lineDirection(line:Line):Vec2
	{
		var dir:Vec2 = new Vec2(line.b.x - line.a.x, line.b.y - line.a.y);
		return dir.normalise();
	}
	
	/**
	 * Converts an angle measured in radians to degrees
	 * @param	theta
	 * @return
	 */
	public static function radToDeg(theta:Float):Float
	{
		return theta * 180 / Math.PI;
	}
	
	/**
	 * Converts an angle measured in degrees to radians
	 * @param	theta
	 * @return
	 */
	public static function degToRad(theta:Float):Float
	{
		return theta * Math.PI / 180;
	}
	
	/**
	 * Takes an array of points and sorts it based on the point's angle from the given origin point
	 * @param	points
	 * @param	origin
	 * @return	the original array
	 */
	public static function sortByAngle(points:Array<FlxPoint>, origin:FlxPoint):Array<FlxPoint>
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
	
	public static function sortByY(objects:Array<Dynamic>):Array<Dynamic>
	{
		objects.sort(function(a, b) {
			if (a.y == b.y) return 0;
			if (a.y > b.y) return 1;
			return -1;
		});
		return objects;
	}
	
	/**
	 * Takes an array of points and sorts it based on the point's distance from the given origin point
	 * @param	points
	 * @param	origin
	 * @return	the original array
	 */
	public static function sortByDistance(points:Array<FlxPoint>, origin:FlxPoint):Array<FlxPoint>
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