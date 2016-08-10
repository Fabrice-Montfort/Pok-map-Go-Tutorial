package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import feathers.utils.ScreenDensityScaleFactorManager;
	
	import starling.core.Starling;
	
	[SWF(width="320", height="480", frameRate="60", backgroundColor="#ffffff")]
	public class PokemapGo extends Sprite
	{
		private var _starling:Starling;
		private var _scaler:ScreenDensityScaleFactorManager;
		
		public var _width:int;
		public var _height:int;
		
		public function PokemapGo()
		{
			if (this.stage)
			{
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align = StageAlign.TOP_LEFT;
			}
			
			this.mouseEnabled = this.mouseChildren = false;
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}
		
		protected function loaderInfo_completeHandler(event:Event):void
		{
			Starling.multitouchEnabled = true;
			
			_width = this.stage.stageWidth;
			_height = this.stage.stageHeight;
			trace (this.stage.stageWidth + " x " + this.stage.stageHeight);
			
			this._starling = new Starling(Main, this.stage, null, null, "auto", "auto");
			this._scaler = new ScreenDensityScaleFactorManager(this._starling);
			this._starling.antiAliasing = 1;
			this._starling.enableErrorChecking = true;
			this._starling.skipUnchangedFrames = true;
			this._starling.showStats = true;
			
			this._starling.start();
			this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
		}
		
		private function stage_deactivateHandler(event:Event):void
		{
			this._starling.stop();
			this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
		}
		
		private function stage_activateHandler(event:Event):void
		{
			this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
			this._starling.start();
		}
	}
}