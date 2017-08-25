package vision;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import objects.Box;
using Util;

class VisionManager {
	private static inline var HALFPI:Float = 1.57079632679;
	
	//arrays and variables for building vision
	private var points:Array<FlxPoint> = new Array<FlxPoint>();
	private var shadowPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var allPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var averagePoint:FlxPoint = new FlxPoint();
	
	private var shadowLength:Float = 640;
	
	public function new () {}
	
	public function buildShadowPolygon(box:Box, source:FlxPoint, shadowLength:Float):Array<FlxPoint>
	{
		points = [];
		shadowPoints = [];
		allPoints = [];
		
		//go through each vertex
		for (p in box.vertices)
		{
			//add this vertex to the array
			points.push(p);
			//get the angle between source and vertex
			var theta:Float = Util.getAngle(p, source);
			//get the x & y distances
			var dx1:Float = p.x - source.x;
			var dy1:Float = p.y - source.y;
			//get the projected x & y distances
			var dx2:Float = Math.cos(theta) * shadowLength * 2;
			var dy2:Float = Math.sin(theta) * shadowLength * 2;
			//get projected point
			var p2:FlxPoint = new FlxPoint(source.x + dx2, source.y + dy2);
			//get the distance between the point and the projected point
			var d_abs1:Float = Util.getDistance(source, p);
			var d_abs2:Float = Util.getDistance(source, p2);
			//if the project point is farther away than the source point
			if (d_abs1 < d_abs2)
				//add the shadow point to the array
				shadowPoints.push(p2);
		}
		//sort the points by their angle from the source
		points = Util.sortByAngle(points, source);
		//remove the 2 points who have the angles between the greatest and smallest, taking into account the weirdness with atan2
		if (Util.getAngle(points[0], source) < 0 - HALFPI && Util.getAngle(points[3], source) > HALFPI)
		{
			points.pop();
			points.shift();
		} else {
			points.splice(1, 2);
		}
		//append the shadow points to the source points
		allPoints = points.concat(shadowPoints);
		//get average position between each stored point
		averagePoint = Util.getAveragePosition(allPoints);
		//sort all points by angle from average (ensures the polygon draws properly)
		allPoints = Util.sortByAngle(allPoints, averagePoint);
		return allPoints;
	}
	
	
	
}