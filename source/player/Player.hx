package player;

import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import nape.phys.BodyType;

class Player extends FlxNapeSprite
{

	public function new(_x:Float=0, _y:Float=0, ?SimpleGraphic:FlxGraphicAsset, CreateRectangularBody:Bool=false, EnablePhysics:Bool=false) 
	{
		super(_x, _y, SimpleGraphic, CreateRectangularBody, EnablePhysics);
		//init the graphics and physics body
		this.makeGraphic(33, 43, FlxColor.TRANSPARENT);
		this.loadGraphic("assets/images/player.png");
		this.createRectangularBody(33, 43, BodyType.DYNAMIC);
	}
	
}