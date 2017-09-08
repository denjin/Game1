package vision;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import objects.Wall;
import maths.Line;
using utils.Util;
import utils.Global;

using flixel.math.FlxMath;

import flixel.util.FlxCollision;

class VisionManager {
	private static inline var HALFPI:Float = 1.57079632679;
	
	//arrays and variables for building vision
	private var points:Array<FlxPoint> = new Array<FlxPoint>();
	private var shadowPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var allPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var outputPoints:Array<FlxPoint> = new Array<FlxPoint>();
	private var averagePoint:FlxPoint = new FlxPoint();
	
	private var zero:FlxPoint = new FlxPoint(0, 0);
	
	private var shadowLength:Float = 2203;
	
	private var c0:FlxPoint;
	private var c1:FlxPoint;
	private var c2:FlxPoint;
	private var c3:FlxPoint;
	
	private var a0:Float = 0;
	private var a1:Float = 0;
	private var a2:Float = 0;
	private var a3:Float = 0;
	
	private var basePoint:FlxPoint = new FlxPoint();
	private var basePoint0:FlxPoint = new FlxPoint();
	
	private var p0:FlxPoint = new FlxPoint();
	private var p1:FlxPoint = new FlxPoint();
	
	private var q0:String = "";
	private var q1:String = "";
	
	private var ap0:Float = 0;
	private var ap1:Float = 0;
	
	
	public function new () {
		c0 = new FlxPoint(0 - Global.instance.screen.width / 2, 0 - Global.instance.screen.height / 2);
		c1 = new FlxPoint(0 + Global.instance.screen.width / 2, 0 - Global.instance.screen.height / 2);
		c2 = new FlxPoint(0 + Global.instance.screen.width / 2, 0 + Global.instance.screen.height / 2);
		c3 = new FlxPoint(0 - Global.instance.screen.width / 2, 0 + Global.instance.screen.height / 2);
		
		a0 = Util.getAngle(zero, c0);
		a1 = Util.getAngle(zero, c1);
		a2 = Util.getAngle(zero, c2);
		a3 = Util.getAngle(zero, c3);
	}
	
	/**
	 * Creates and array of points for drawing an area that lies outside the given arc in the given angle
	 * The output polygon is position agnostic and everything is centered around [0,0] so must be moved appropriately by the calling method
	 * @param	angle	the angle the arc is pointing towards
	 * @param	arc		the length of the arc in each direction away from the given angle
	 * @return			an array of points that describes the polygon to be drawn
	 */
	public function buildVisionPolygon(angle:Float, arc:Float):Array<FlxPoint>
	{
		//clear array
		points = [];
		//project point off the screen in the given angle
		basePoint = Util.rotate(new FlxPoint(shadowLength, 0), zero, angle);
		//priject point just in front of the player in the given angle
		basePoint0 = Util.rotate(new FlxPoint(1, 0), zero, angle);
		//create points at upper and lower bound of the vision arc
		p0 = Util.rotate(basePoint, zero, arc);
		p1 = Util.rotate(basePoint, zero, -arc);
		//empty strings for quadrant check
		q0 = new String("");
		q1 = new String("");
		//angle between the source and the two bounding points
		ap0 = Util.getAngle(zero, p0);
		ap1 = Util.getAngle(zero, p1);
		//check which quadrant the projected lines lie in (N/E/S/W)
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
		//check which corner points to add based on the quadrants of the bounding points
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
		//add bounding points to output
		points.push(p0);
		points.push(p1);
		//add base point to the output array
		points.push(basePoint0);
		//sort output points by angle from source to prepare for drawing
		points = Util.sortByAngle(points, zero);
		
		return points;
	}
	
	/**
	 * Creates an array of points for drawing a shadow being cast by the given wall from a given source
	 * @param	wall
	 * @param	source
	 * @param	shadowLength
	 * @param	offset
	 * @return
	 */
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
			var dx2:Float = FlxMath.fastCos(theta) * shadowLength * 2;
			var dy2:Float = FlxMath.fastSin(theta) * shadowLength * 2;
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