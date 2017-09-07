package vision;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import objects.Wall;
import objects.Line;
import objects.Intersect;
using utils.Util;
import utils.Global;



class VisionManager {
	private static inline var HALFPI:Float = 1.57079632679;
	
	//arrays and variables for building vision
	private var points:Array<FlxPoint> = new Array<FlxPoint>();
	private var shadowPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var allPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var outputPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var averagePoint:FlxPoint = new FlxPoint();
	
	private var border:FlxRect;
	
	private var shadowLength:Float = 2203;
	
	public function new () {}
	
	public function buildVisionPolygon(source:FlxPoint, angle:Float, arc:Float):Array<FlxPoint>
	{
		var zero:FlxPoint = new FlxPoint(0, 0);
		var points:Array<FlxPoint> = new Array<FlxPoint>();
		
		//var c0:FlxPoint = new FlxPoint(Global.instance.screen.x, Global.instance.screen.y);
		//var c1:FlxPoint = new FlxPoint(Global.instance.screen.x + Global.instance.screen.width, Global.instance.screen.y);
		//var c2:FlxPoint = new FlxPoint(Global.instance.screen.x + Global.instance.screen.width, Global.instance.screen.y + Global.instance.screen.height);
		//var c3:FlxPoint = new FlxPoint(Global.instance.screen.x, Global.instance.screen.y + Global.instance.screen.height);
		
		var c0:FlxPoint = new FlxPoint(0 - Global.instance.screen.width / 2, 0 - Global.instance.screen.height / 2);
		var c1:FlxPoint = new FlxPoint(0 + Global.instance.screen.width / 2, 0 - Global.instance.screen.height / 2);
		var c2:FlxPoint = new FlxPoint(0 + Global.instance.screen.width / 2, 0 + Global.instance.screen.height / 2);
		var c3:FlxPoint = new FlxPoint(0 - Global.instance.screen.width / 2, 0 + Global.instance.screen.height / 2);
		
		var a0:Float = Util.getAngle(zero, c0);
		var a1:Float = Util.getAngle(zero, c1);
		var a2:Float = Util.getAngle(zero, c2);
		var a3:Float = Util.getAngle(zero, c3);
		
		
		
		var basePoint:FlxPoint = Util.rotate(new FlxPoint(shadowLength, 0), zero, angle);
		var basePoint0:FlxPoint = Util.rotate(new FlxPoint(1, 0), zero, angle);
		
		var p0:FlxPoint = Util.rotate(basePoint, zero, arc);
		var p1:FlxPoint = Util.rotate(basePoint, zero, -arc);
		
		var q0:String = new String("");
		var q1:String = new String("");
		
		var ap0:Float = Util.getAngle(zero, p0);
		var ap1:Float = Util.getAngle(zero, p1);
		
		if (ap0 > a0 && ap0 < a1)
		{
			q0 = "N";
		} else if (ap0 > a2 && ap0 < a3)
		{
			q0 = "S";
		} else if (ap0 > a3 && ap0 < a0)
		{
			q0 = "W";
		} else {
			q0 = "E";
		}
		
		if (ap1 > a0 && ap1 < a1)
		{
			q1 = "N";
		} else if (ap1 > a2 && ap1 < a3)
		{
			q1 = "S";
		} else if (ap1 > a3 && ap1 < a0)
		{
			q1 = "W";
		} else {
			q1 = "E";
		}
		
		
		
		if ((q0 == "N" && q1 == "W") || (q0 == "W" && q1 == "N"))
		{
		} else {
			points.push(new FlxPoint(c0.x, c0.y));
		}
		
		if ((q0 == "N" && q1 == "E") || (q0 == "E" && q1 == "N"))
		{
		} else {
			points.push(new FlxPoint(c1.x, c1.y));
		}
		
		if ((q0 == "S" && q1 == "E") || (q0 == "E" && q1 == "S"))
		{
		} else {
			points.push(new FlxPoint(c2.x, c2.y));
		}
		
		if ((q0 == "S" && q1 == "W") || (q0 == "W" && q1 == "S"))
		{
		} else {
			points.push(new FlxPoint(c3.x, c3.y));
		}
		
		
		points.push(p0);
		points.push(p1);

		points.push(basePoint0);
		
		points = Util.sortByAngle(points, zero);
		
		return points;
	}
	
	
	
	
	public function buildShadowPolygon(wall:Wall, source:FlxPoint, shadowLength:Float, offset:FlxPoint):Array<FlxPoint>
	{
		points = [];
		shadowPoints = [];
		allPoints = [];
		outputPoints = [];
		
		//go through each vertex
		for (p in wall.vertices)
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
			//if the projected point is farther away than the source point
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
		}
		else
		{
			points.splice(1, 2);
		}
		//append the shadow points to the source points
		allPoints = points.concat(shadowPoints);
		//get average position between each stored point
		averagePoint = Util.getAveragePosition(allPoints);
		//sort all points by angle from average (ensures the polygon draws properly)
		allPoints = Util.sortByAngle(allPoints, averagePoint);
		for (_p in allPoints)
		{
			outputPoints.push(new FlxPoint(_p.x - offset.x, _p.y - offset.y));
		}
		return outputPoints;
	}
}