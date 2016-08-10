package models
{
	import feathers.data.ListCollection;

	public class pokemapGoUserData
	{
		private static var _instance:pokemapGoUserData;
		
		private var _provider:String = "";
		private var _token:String = "";

		private var _profile:Object = [];
		private var _auth:String = "";
		
		private var _lat:Number = 0;
		private var _lng:Number = 0;
		
		private var _pokemons:ListCollection = new ListCollection();
		
		public function pokemapGoUserData(e: Enforcer)
		{
			if (e == null) {
				throw new Error("Please call instance(). This is a singleton.");
			}
		}
		
		public static function instance():pokemapGoUserData {
			if (_instance == null) {
				_instance = new pokemapGoUserData(new Enforcer());
			}
			return _instance;
		}

		public function get provider():String
		{
			return _provider;
		}

		public function set provider(value:String):void
		{
			trace ("SET provider : " + value);
			_provider = value;
		}

		public function get token():String
		{
			return _token;
		}

		public function set token(value:String):void
		{
			trace ("SET token : " + value);
			_token = value;
		}

		public function get profile():Object
		{
			return _profile;
		}

		public function set profile(value:Object):void
		{
			trace ("SET profile : " + JSON.stringify(value));
			_profile = value;
		}

		public function get auth():String
		{
			return _auth;
		}

		public function set auth(value:String):void
		{
			trace ("SET auth : " + value);
			_auth = value;
		}

		public function get lat():Number
		{
			return _lat;
		}

		public function set lat(value:Number):void
		{
			trace ("SET lat : " + value);
			_lat = value;
		}

		public function get lng():Number
		{
			return _lng;
		}

		public function set lng(value:Number):void
		{
			trace ("SET lng : " + value);
			_lng = value;
		}

		public function get pokemons():ListCollection
		{
			return _pokemons;
		}

		public function set pokemons(value:ListCollection):void
		{
			trace ("SET pokemons : " + value.length + " items");
			_pokemons = value;
		}


	}
}

class Enforcer{}