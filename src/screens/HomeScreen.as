package screens
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class HomeScreen extends PanelScreen
	{
		
		public static const GO_LOGIN:String = "goLogin";
		
		public function HomeScreen()
		{
			trace ("Home loaded");
			
			super();
		}
		
		override protected function initialize():void
		{
			trace ("Home initialize");
			
			super.initialize();
			
			this.title = "Pokémap Go : Home";
			
			var _layout:VerticalLayout = new VerticalLayout();
			_layout.gap = 20;
			_layout.padding = 20;
			_layout.horizontalAlign = HorizontalAlign.CENTER;
			_layout.verticalAlign = VerticalAlign.MIDDLE;
			this.layout = _layout;
			
			var _tutoLabel:Label = new Label();
			_tutoLabel.text = "FIREBASE & AS3 TUTORIAL";
			this.addChild(_tutoLabel);
			
			var _authorLabel:Label = new Label();
			_authorLabel.text = "Fabrice Montfort\nAugust 2016";
			_authorLabel.textRendererFactory = function():ITextRenderer
			{
				var _textRenderer:TextBlockTextRenderer = new TextBlockTextRenderer();
				_textRenderer.textAlign = TextBlockTextRenderer.TEXT_ALIGN_CENTER;
				return _textRenderer;
			}
			this.addChild(_authorLabel);
			
			var _goBtn:Button = new Button();
			_goBtn.label = "Pokémap Go!";
			_goBtn.addEventListener(Event.TRIGGERED, onGoBtnTriggered);
			this.addChild(_goBtn);
		}
		
		private function onGoBtnTriggered(e: Event):void
		{
			trace ("Home Go Button Triggered");
			
			this.dispatchEventWith(GO_LOGIN, false, null);
		}
	}
}