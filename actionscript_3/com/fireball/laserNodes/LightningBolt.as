package com.fireball.laserNodes
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	
	public class LightningBolt extends Sprite
	{
		private var numberOfBolts = 2;       			// Number of bolts
		private var lightningBoltColor = 0xffffff;  	// Color of lightning
		private var lightningBoltThickness = 3.0;		// Thickness of bolt
		private var lightningBoltDetail = 1;       		// Must not be zero, and probably no less than 1
		private var lightningBoltDisplacement = 50;    	// Large values take longer to render
		
		private var graphicsObject:Graphics;
		
		private var parentSprite:Sprite;
		
		private var originXPos:Number;
		private var originYPos:Number;
		private var destinationXPos:Number;
		private var destinationYPos:Number;
		
		public function LightningBolt(argParentSprite:Sprite, argOriginXPos:Number, argOriginYPos:Number, argDestinationXPos:Number, argDestinationYPos:Number)
		{
			parentSprite = argParentSprite;
			
			var glow:GlowFilter = new GlowFilter();
			
			glow.color = lightningBoltColor;
			glow.strength = 3.0;
			glow.quality = 3;
			glow.blurX = 13;
			glow.blurY = 13;
			
			parentSprite.filters = [glow];
			
			originXPos = argOriginXPos;
			originYPos = argOriginYPos;
			
			destinationXPos = argDestinationXPos;
			destinationYPos = argDestinationYPos;
			
			addEventListener(Event.ENTER_FRAME, generateLightningBolts);
		}
		
		private function generateLightningBolts(event:Event) : void
		{			
			graphicsObject = parentSprite.graphics;
			graphicsObject.clear();
			graphicsObject.lineStyle(lightningBoltThickness, lightningBoltColor);
			
			for (var i = 0; i < numberOfBolts; ++i)
			{
				drawLightningBolt(originXPos, originYPos, destinationXPos, destinationYPos, lightningBoltDisplacement);
			}			
		}
		
		private function drawLightningBolt(x1, y1, x2, y2, displace) : void
		{			
			if (displace < lightningBoltDetail) {
				
				graphicsObject.moveTo(x1, y1);
				graphicsObject.lineTo(x2, y2);
				
			} else {
				
				var mid_x = (x2 + x1) / 2;
				var mid_y = (y2 + y1) / 2;
				
				mid_x += (Math.random() - .5) * displace;
				mid_y += (Math.random() - .5) * displace;
				
				drawLightningBolt(x1, y1, mid_x, mid_y, displace/2);
				drawLightningBolt(x2 ,y2, mid_x, mid_y, displace/2);
				
			}			
		}
	}
}