package screens
{
	import com.adobe.protocols.oauth2.OAuth2;
	import com.adobe.protocols.oauth2.event.GetAccessTokenEvent;
	import com.adobe.protocols.oauth2.grant.AuthorizationCodeGrant;
	import com.adobe.protocols.oauth2.grant.IGrantType;
	import com.fabricemontfort.JWT;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.getQualifiedClassName;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.PanelScreen;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	
	import models.pokemapGoUserData;
	
	import org.as3commons.logging.setup.LogSetupLevel;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	public class LoginScreen extends PanelScreen
	{
		
		public static const GO_MAP:String = "goMap";
		
		private var _stageWebView:StageWebView;
				
		private var _nameLabel:Label = new Label();
		
		private var user:pokemapGoUserData;
		
		public function LoginScreen()
		{
			trace ("Login loaded");
			
			user = pokemapGoUserData.instance();
			
			super();
		}
		
		override protected function initialize():void
		{
			trace ("Login initialize");
			
			this.title = "Pokémap Go : Login";
			
			var _layout:VerticalLayout = new VerticalLayout();
			_layout.gap = 20;
			_layout.padding = 20;
			_layout.horizontalAlign = HorizontalAlign.CENTER;
			_layout.verticalAlign = VerticalAlign.MIDDLE;
			this.layout = _layout;
			
			_nameLabel = new Label();
			_nameLabel.text = "Anonymous";
			this.addChild(_nameLabel);
			
			var _googleBtn:Button = new Button();
			_googleBtn.label = "Google";
			_googleBtn.addEventListener(starling.events.Event.TRIGGERED, onGoogleBtnTriggered);
			this.addChild(_googleBtn);
			
			var _facebookBtn:Button = new Button();
			_facebookBtn.label = "Facebook";
			_facebookBtn.addEventListener(starling.events.Event.TRIGGERED, onFacebookBtnTriggered);
			this.addChild(_facebookBtn);
			
			super.initialize();
		}
		
		private function onGoogleBtnTriggered():void
		{
			trace ("Login Google Button Triggered");
			
			user.provider = "google";
			
			this._stageWebView = new StageWebView();
			this._stageWebView.stage = Starling.current.nativeStage;
			this._stageWebView.viewPort = new Rectangle(0,0,Starling.current.nativeStage.fullScreenWidth,Starling.current.nativeStage.fullScreenHeight);
			
			var oauth2:OAuth2 = new OAuth2("https://accounts.google.com/o/oauth2/auth", "https://accounts.google.com/o/oauth2/token", LogSetupLevel.ALL);
			var grant:IGrantType = new AuthorizationCodeGrant(_stageWebView,
				"YOUR_GOOGLE_PROJECT_ID",
				"YOUR_GOOGLE_PROJECT_SECRET",
				"https://YOUR_FIREBASE_PROJECT_ID.firebaseapp.com/__/auth/handler",
				"https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/plus.login",
				null);
			
			oauth2.addEventListener(GetAccessTokenEvent.TYPE, onGetGoogleAccessToken);
			oauth2.getAccessToken(grant);
		}
		
		private function onFacebookBtnTriggered():void
		{
			trace ("Login Facebook Button Triggered");
			
			user.provider = "facebook";
			
			this._stageWebView = new StageWebView();
			this._stageWebView.stage = Starling.current.nativeStage;
			this._stageWebView.viewPort = new Rectangle(0,0,Starling.current.nativeStage.fullScreenWidth,Starling.current.nativeStage.fullScreenHeight);
			
			var oauth2:OAuth2 = new OAuth2("https://www.facebook.com/dialog/oauth", "https://graph.facebook.com/v2.3/oauth/access_token", LogSetupLevel.ALL);
			var grant:IGrantType = new AuthorizationCodeGrant(_stageWebView,
				"YOUR_FACEBOOK_PROJECT_ID",
				"YOUR_FACEBOOK_PROJECT_SECRET",
				"https://YOUR_FIREBASE_PROJECT_ID.firebaseapp.com/__/auth/handler",
				"public_profile,email,user_birthday,user_friends",
				null);
			
			oauth2.addEventListener(GetAccessTokenEvent.TYPE, onGetFacebookAccessToken);
			oauth2.getAccessToken(grant);
		}
		
		private function onGetGoogleAccessToken(getAccessTokenEvent:GetAccessTokenEvent):void
		{
			if (getAccessTokenEvent.errorCode == null && getAccessTokenEvent.errorMessage == null)
			{
				// success!
				trace("Your access token value is: " + getAccessTokenEvent.accessToken);
				user.token = getAccessTokenEvent.accessToken;
				this._stageWebView.stage = null;
				this._stageWebView = null;
				testAPI(user.provider);
			}
			else
			{
				trace ("FAIL : " + getAccessTokenEvent.errorMessage);
			}
		}
		
		private function onGetFacebookAccessToken(getAccessTokenEvent:GetAccessTokenEvent):void
		{
			if (getAccessTokenEvent.errorCode == null && getAccessTokenEvent.errorMessage == null)
			{
				// success!
				trace("Your access token value is: " + getAccessTokenEvent.accessToken);
				user.token = getAccessTokenEvent.accessToken;
				this._stageWebView.stage = null;
				this._stageWebView = null;
				testAPI(user.provider);
			}
			else
			{
				trace ("FAIL : " + getAccessTokenEvent.errorMessage);
			}
		}
		
		private function testAPI(provider:String):void
		{
			var request:URLRequest;
			if (provider == "google")
			{
				request = new URLRequest("https://www.googleapis.com/plus/v1/people/me?access_token="+user.token);
			} else if (provider == "facebook")
			{
				request = new URLRequest("https://graph.facebook.com/me?fields=birthday,email,id,name,picture&redirect=false&access_token="+user.token);
			}
			request.method = URLRequestMethod.GET;
			
			var requestor:URLLoader = new URLLoader();
			requestor.addEventListener( flash.events.Event.COMPLETE, httpRequestComplete );
			requestor.addEventListener( IOErrorEvent.IO_ERROR, httpRequestError );
			requestor.addEventListener( SecurityErrorEvent.SECURITY_ERROR, httpRequestError );
			
			requestor.load( request );
		}
		
		protected function httpRequestError(event:ErrorEvent):void
		{
			trace( "An error occured: " + event.text );
		}
		
		protected function httpRequestComplete(event:flash.events.Event):void
		{
			//trace( event.target.data );
			var obj:Object = JSON.parse(event.target.data);
			
			var profile:Object = new Object();
			profile.uid = obj.id;
			profile.provider = user.provider;
			if (user.provider == "google")
			{
				profile.displayName = obj.displayName;
				profile.picture = obj.image.url;
			} else if (user.provider == "facebook")
			{
				profile.displayName = obj.name;
				profile.picture = obj.picture.data.url;
			}
			
			user.profile = profile;
			
			_nameLabel.text = user.profile.displayName;
			
			var payload:Object = new Object();
			payload.token = user.token;
			payload.provider = user.provider;
			payload.iat = int(new Date().getTime() / 1000);
			payload.v = "0";
			payload.d = user.profile;

			user.auth = JWT.encode(payload, "YOUR_FIREBASE_PROJECT_SECRET");

			var request:URLRequest = new URLRequest( "https://YOUR_FIREBASE_PROJECT_ID.firebaseio.com/users/"+user.profile.uid+".json?auth="+user.auth);
			request.method = URLRequestMethod.PUT;

			request.data = JSON.stringify(user.profile);
			
			var requestor:URLLoader = new URLLoader();
			requestor.addEventListener( flash.events.Event.COMPLETE, createdUser );
			requestor.addEventListener( IOErrorEvent.IO_ERROR, httpRequestError );
			requestor.addEventListener( SecurityErrorEvent.SECURITY_ERROR, httpRequestError );
			
			requestor.load( request );
		}
		
		protected function createdUser(event: flash.events.Event):void
		{
			//trace( event.target.data );
			trace ("User created on Firebase Database");
			this.dispatchEventWith(GO_MAP);
		}
	}
}