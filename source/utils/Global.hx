package utils;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class Global
{
	static public var instance(get, null):Global;
	static function get_instance(): Global return (instance == null) ? instance = new Global() : instance;
	private function new() {}
	
	public var mousePosition:FlxPoint;
	//public var cameraPosition:FlxPoint;
	
	public var screen:FlxRect;
	
	public var levelWidth:Int;
	public var levelHeight:Int;
	
	//public var screenWidth:Int;
	//public var screenHeight:Int;
}