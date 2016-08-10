package screens
{
	import com.fabricemontfort.GUID;
	import com.fabricemontfort.JWT;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import feathers.controls.List;
	import feathers.controls.PanelScreen;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import models.pokemapGoUserData;
	
	import starling.events.Event;
	
	public class FormScreen extends PanelScreen
	{	
		
		public static const GO_BACK:String = "goBack";
		
		private var user:pokemapGoUserData;
		
		public function FormScreen()
		{
			trace ("Form loaded");
			
			user = pokemapGoUserData.instance();
			
			super();
		}
		
		override protected function initialize():void
		{
			trace ("Form initialize");
			
			super.initialize();
			
			this.title = "Pokémap Go : Form";
			
			var _layout:AnchorLayout = new AnchorLayout();
			this.layout = _layout;
			
			var list:List = new List();
			list.dataProvider = this.getPokemons();
			list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			list.addEventListener( starling.events.Event.CHANGE, list_changeHandler );
			this.addChild( list );
		}
		
		private function list_changeHandler(event: starling.events.Event):void
		{
			var list:List = List( event.currentTarget );
			trace( "selectedItem:", String(list.selectedItem) );
			this.addPokemonToMap(String(list.selectedItem));
		}
		
		private function getPokemons():ListCollection
		{
			if (user.pokemons != null)
			{
				return user.pokemons;
			}
			return null;
		}
		
		private function addPokemonToMap(pokemonName:String):void
		{
			var obj:Object = new Object();
			obj.userId = user.profile.uid;
			obj.lat = user.lat;
			obj.lng = user.lng;
			obj.timestamp = int(new Date().getTime() / 1000);
			obj.uuid = GUID.create();
			obj.pokemonName = pokemonName;
			
			var payload:Object = new Object();
			payload.token = user.token;
			payload.provider = user.provider;
			payload.iat = int(new Date().getTime() / 1000);
			payload.v = "0";
			payload.d = user.profile;
			
			user.auth = JWT.encode(payload, "YOUR_FIREBASE_PROJECT_SECRET");
			
			var request:URLRequest = new URLRequest( "https://YOUR_FIREBASE_PROJECT_ID.firebaseio.com/markers.json?auth="+user.auth);
			request.method = URLRequestMethod.POST;
			
			request.data = JSON.stringify(obj);
			
			var requestor:URLLoader = new URLLoader();
			requestor.addEventListener( flash.events.Event.COMPLETE, pokemonAdded );
			requestor.addEventListener( IOErrorEvent.IO_ERROR, httpRequestError );
			requestor.addEventListener( SecurityErrorEvent.SECURITY_ERROR, httpRequestError );
			
			requestor.load( request );
		}
		
		protected function httpRequestError(event:IOErrorEvent):void
		{
			trace( "An error occured: " + event.text );
		}
		
		protected function pokemonAdded(event:flash.events.Event):void
		{
			//trace( event.target.data );
			trace ("Pokemon Added on Firebase Database");
			this.dispatchEventWith(GO_BACK, false, null);
		}
	}
}