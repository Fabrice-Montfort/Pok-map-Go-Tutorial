package screens
{
	import com.fabricemontfort.JWT;
	
	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.sensors.Geolocation;
	
	import cz.j4w.map.MapLayerOptions;
	import cz.j4w.map.MapOptions;
	import cz.j4w.map.geo.GeoMap;
	import cz.j4w.map.geo.Maps;
	
	import feathers.controls.Button;
	import feathers.controls.PanelScreen;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import models.pokemapGoUserData;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class MapScreen extends PanelScreen
	{
		
		public static const GO_FORM:String = "goForm";
		
		private var geo:Geolocation;
		
		private var user:pokemapGoUserData;
		
		private var mapOptions:MapOptions;
		private var geoMap:GeoMap;
		private var googleMaps:MapLayerOptions;
		
		[Embed(source = "/assets/marker.png")]
		private var MarkerClass:Class;
		
		public function MapScreen()
		{
			trace ("Map loaded");
			
			user = pokemapGoUserData.instance();
			
			super();
		}
		
		override protected function initialize():void
		{
			trace ("Map initialize");
			
			super.initialize();
			
			this.title = "Pokémap Go : Map";
			
			if (Geolocation.isSupported) 
			{ 
				geo = new Geolocation(); 
				geo.setRequestedUpdateInterval(1000);
				if (!geo.muted)
				{
					geo.addEventListener(GeolocationEvent.UPDATE, updateGeolocationHandler); 
				} else {
					trace ("Geolocation feature is muted");
				}
				geo.addEventListener(StatusEvent.STATUS, statusGeolocationHandler);
			} 
			else 
			{ 
				trace ("Geolocation feature not supported"); 
			} 
			
			var _layout:AnchorLayout = new AnchorLayout();
			this.layout = _layout;
			
			mapOptions = new MapOptions();
			mapOptions.initialCenter = new Point(55.47535833333333, -21.342465);
			mapOptions.initialScale = 1 / 32;
			mapOptions.disableRotation = true;
			
			geoMap = new GeoMap(mapOptions);
			geoMap.setSize(stage.stageWidth, stage.stageHeight);
			geoMap.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			geoMap.x = geoMap.y = 0;
			
			addChild(geoMap);
			
			googleMaps = Maps.GOOGLE_MAPS;
			googleMaps.notUsedZoomThreshold = 1;
			geoMap.addLayer("googleMaps", googleMaps);
			
			var _formBtn:Button = new Button();
			_formBtn.label = "Add a Pokémon";
			_formBtn.width = stage.width - 40;
			var aLD:AnchorLayoutData = new AnchorLayoutData();
			aLD.bottom = 20;
			aLD.right = 20;
			aLD.left = 20;
			_formBtn.layoutData = aLD;
			_formBtn.addEventListener(starling.events.Event.TRIGGERED, onFormBtnTriggered);
			this.addChild(_formBtn);
			
			getPokemonsOnMap();
		}
		
		private function onFormBtnTriggered():void
		{
			trace ("Form Button Triggered");
			this.dispatchEventWith(GO_FORM, false, null);
		}
		
		protected function statusGeolocationHandler(event:StatusEvent):void
		{
			if (geo.muted) 
			{
				geo.removeEventListener(GeolocationEvent.UPDATE, updateGeolocationHandler); 
			}
			else 
			{
				geo.addEventListener(GeolocationEvent.UPDATE, updateGeolocationHandler);
			}
		}
		
		protected function updateGeolocationHandler(event:GeolocationEvent):void
		{
			user.lat = event.latitude;
			user.lng = event.longitude;
			geoMap.setCenterLongLat(user.lng, user.lat);
			geoMap.invalidate();
		}
		
		private function getPokemonsOnMap():void
		{
			var payload:Object = new Object();
			payload.token = user.token;
			payload.provider = user.provider;
			payload.iat = int(new Date().getTime() / 1000);
			payload.v = "0";
			payload.d = [];
			
			user.auth = JWT.encode(payload, "YOUR_FIREBASE_PROJECT_SECRET");
			
			var request:URLRequest = new URLRequest( "https://YOUR_FIREBASE_PROJECT_ID.firebaseio.com/markers.json?auth="+user.auth);
			request.method = URLRequestMethod.GET;
			
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
			trace ("Pokemon Retrieved from Firebase Database");
			trace( event.target.data );
			
			var markers:Object = JSON.parse(event.target.data);
			
			var markerTexture:Texture = Texture.fromEmbeddedAsset(MarkerClass);
			
			for (var item:String in markers) {
				var image:Image = new Image(markerTexture);
				image.alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
				trace (item);
				
				geoMap.addMarkerLongLat("marker" + markers[item].uuid, markers[item].lng, markers[item].lat, image);
			}
		}
	}
}