package
{

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.data.ListCollection;
	import feathers.motion.Slide;
	import feathers.themes.MetalWorksMobileTheme;
	
	import models.pokemapGoUserData;
	
	import screens.FormScreen;
	import screens.HomeScreen;
	import screens.LoginScreen;
	import screens.MapScreen;
	
	public class Main extends StackScreenNavigator
	{
		
		private static const HOME_SCREEN:String = "homeScreen";
		private static const LOGIN_SCREEN:String = "loginScreen";
		private static const MAP_SCREEN:String = "mapScreen";
		private static const FORM_SCREEN:String = "formScreen";
		
		private var user:pokemapGoUserData;
		
		private var myTextLoader:URLLoader;
		
		public function Main()
		{
			trace ("Main loaded");

			user = pokemapGoUserData.instance();
			
			super();
		}
		
		override protected function initialize():void
		{
			trace ("Main initialize");
			
			super.initialize();
			
			new MetalWorksMobileTheme();
						
			this.pushTransition = Slide.createSlideLeftTransition();
			this.popTransition = Slide.createSlideRightTransition();
			
			var HomeScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(HomeScreen);
			HomeScreenItem.setScreenIDForReplaceEvent(HomeScreen.GO_LOGIN, LOGIN_SCREEN);
			this.addScreen(HOME_SCREEN, HomeScreenItem);
			
			var LoginScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(LoginScreen);
			LoginScreenItem.setScreenIDForReplaceEvent(LoginScreen.GO_MAP, MAP_SCREEN);
			this.addScreen(LOGIN_SCREEN, LoginScreenItem);
			
			var MapScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(MapScreen);
			MapScreenItem.setScreenIDForPushEvent(MapScreen.GO_FORM, FORM_SCREEN);
			this.addScreen(MAP_SCREEN, MapScreenItem);
			
			var FormScreenItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(FormScreen);
			FormScreenItem.addPopEvent(FormScreen.GO_BACK);
			this.addScreen(FORM_SCREEN, FormScreenItem);
			
			this.rootScreenID = HOME_SCREEN;
			
			myTextLoader = new URLLoader();
			myTextLoader.addEventListener(flash.events.Event.COMPLETE, onLoaded);
			myTextLoader.load(new URLRequest("/assets/pokemons.txt"));
		}
		
		protected function onLoaded(e:Event):void
		{
			trace ("Pokémon list loaded and parsed");
			user.pokemons = new ListCollection(e.target.data.split(/\n/));
		}
	}
}