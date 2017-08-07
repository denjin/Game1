package vision;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import objects.Intersect;
import objects.Line;

class VisionManager {
	static public var instance(get, null):VisionManager;
	static function get_instance(): VisionManager return (instance == null) ? instance = new VisionManager() : instance;
	private function new() {}
	
	/**
	 * Creates an array of points that define a polygon of space visible from a source point
	 * @param	source
	 * @param	points
	 * @return
	 */
	public function buildVisionPolygon(source:FlxPoint, faces:Array<Line>, points:Array<FlxPoint>):Array<FlxPoint>
	{
		//get all intersects
		var intersects:Array<Intersect> = new Array<Intersect>();
		var ray:Line;
		for (p in points)
		{
			ray = new Line(source, p);
			intersects.push(findClosestIntersect(ray, faces));
		}
		
		//sort intersects by angle
		intersects.sort(function(a:Intersect, b:Intersect) {
			var a_angle:Float = getAngle(new FlxPoint(a.x, a.y), source);
			var b_angle:Float = getAngle(new FlxPoint(b.x, b.y), source);
			if(a_angle < b_angle) return -1;
			else if(a_angle > b_angle) return 1;
			else return 0;
		});
		
		//convert intersects into FlxPoints
		var sorted:Array<FlxPoint> = new Array<FlxPoint>();
		for (i in intersects)
		{
			sorted.push(new FlxPoint(i.x, i.y));
		}
		
		//return the array of points
		return sorted;
	}
	
	
	/**
	 * Runs through all faces and checks for which intersect is the closest one and returns that intersect
	 * @param	ray
	 * @return	intersect or null if none found
	 */
	private static function findClosestIntersect(ray:Line, faces:Array<Line>):Intersect
	{
		var closestIntersect:Intersect = null;
		
		var thisIntersect:Intersect;
		//loop through all faces and find the closet intersect with the given ray
		
		for (j in faces)
		{
			//get the intersect between this face and the ray
			thisIntersect = getIntersect(ray, j);
			//if there was no intersect found
			if (thisIntersect == null)
			{
				//carry on to the next face
				continue;
			}
			//if this is the first intersect found
			if (closestIntersect == null)
			{
				//make this intersect the new closest
				closestIntersect = thisIntersect;
				//carry on to the next face
				continue;
			}
			//if this intersect is closer than the previous closest intersect
			if (thisIntersect.t1 < intersect1.t1)
			{
				//make this intersect the new closest
				intersect1 = thisIntersect;
				//carry on to the next face
			}
		}
		return closestIntersect;
	}
	
	/**
	 * Gets the point (if it exists) where the given ray and the given face intersect
	 * @param	ray	
	 * @param	face
	 * @return	intersect if one exists and is within correct limits, null if not
	 */
	private static function getIntersect(ray:Line, face:Line):Intersect
	{
		//ray in parametric form 
		var r_px:Float = ray.a.x;
		var r_py:Float = ray.a.y;
		var r_dx:Float = ray.b.x - ray.a.x;
		var r_dy:Float = ray.b.y - ray.a.y;
		
		//face in parametric form
		var f_px:Float = face.a.x;
		var f_py:Float = face.a.y;
		var f_dx:Float = face.b.x - face.a.x;
		var f_dy:Float = face.b.y - face.a.y;
		
		//are they parallel?
		var r_magnitude:Float = Math.sqrt(r_dx * r_dx + r_dy * r_dy);
		var f_magnitude:Float = Math.sqrt(f_dx * f_dx + f_dy * f_dy);
		if (r_dx / r_magnitude == f_dx / f_magnitude && r_dy / r_magnitude == f_dy / f_magnitude)//the directions are the same
		{
			return null;
		}
		
		//solve for T1 & T2
		var t2:Float = (r_dx * (f_py - r_py) + r_dy * (r_px - f_px)) / (f_dx * r_dy - f_dy * r_dx);
		var t1:Float = (f_px + f_dx * t2 - r_px) / r_dx;
		
		//if parametric outside correct limits
		if (t1 < 0)
		{
			return null;
		}
		
		if (t2 < 0 || t2 > 1)
		{
			return null;
		}
		
		//return the intersect
		return new Intersect(r_px + r_dx * t1, r_py + r_dy * t1, t1);
	}
	
	private function getAngle(a:FlxPoint, b:FlxPoint):Float
	{
		return Math.atan2(a.y - b.y, a.x - b.x) + Math.PI;
	}
	
}