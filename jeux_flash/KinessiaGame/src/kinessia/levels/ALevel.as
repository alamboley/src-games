package kinessia.levels {

	import Box2DAS.Dynamics.ContactEvent;

	import kinessia.characters.Bullzor;
	import kinessia.characters.Declik;
	import kinessia.objects.Catapulte;
	import kinessia.objects.MusicalSensor;
	import kinessia.objects.Roseau;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.State;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.Platform;
	import com.citrusengine.objects.platformer.Sensor;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.utils.ObjectMaker;
	import com.citrusengine.view.ExternalArt;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	/**
	 * @author Aymeric
	 */
	public class ALevel extends State {

		public var lvlEnded:Signal;
		public var restartLevel:Signal;

		protected var _ce:CitrusEngine;

		protected var _declik:Declik;
		protected var _bullzors:Vector.<CitrusObject>;

		private var _levelObjectsMC:MovieClip;

		public function ALevel(levelObjectsMC:MovieClip) {

			super();

			_ce = CitrusEngine.getInstance();

			_levelObjectsMC = levelObjectsMC;

			lvlEnded = new Signal();
			restartLevel = new Signal();

			var objects:Array = [Platform, Declik, Bullzor, CitrusSprite, Sensor, MusicalSensor, Roseau, Catapulte];
		}

		override public function initialize():void {

			super.initialize();

			var box2d:Box2D = new Box2D("Box2D", {visible:false});
			add(box2d);

			view.loadManager.onLoadComplete.addOnce(handleLoadComplete);

			ObjectMaker.FromMovieClip(_levelObjectsMC);

			ExternalArt.smoothBitmaps = true;

			_declik = Declik(getObjectByName("Declik"));
			//_declik.onJump.add(_jump);
			//_declik.onAnimationChange.add(_animationChange);
			_declik.onTakeDamage.add(_hurt);
			_declik.onGiveDamage.add(_attack);

			var endLevel:Sensor = Sensor(getObjectByName("EndLevel"));
			endLevel.onBeginContact.add(_endLevel);

			var roseaux:Vector.<CitrusObject> = getObjectsByType(Roseau);
			for each (var roseau:Roseau in roseaux) {
				roseau.onBeginContact.add(_roseauTouche);
				roseau.onEndContact.add(_roseauFin);
			}

			view.setupCamera(_declik, new MathVector(320, 240), new Rectangle(-1000, 0, 4000, 650), new MathVector(.25, .05));
		}
		
		protected function _addContactRestartLevel():void {
			
			var restartLevel:Sensor = Sensor(getObjectByName("RestartLevel"));
			restartLevel.onBeginContact.add(_restartLevel);
		}
		
		protected function _addMusicalSensor():void {
			
			var musicalSensors:Vector.<CitrusObject> = getObjectsByType(MusicalSensor);
			for each (var musicalSensor:MusicalSensor in musicalSensors) {
				musicalSensor.onBeginContact.add(_playSound);
			}
		}

		protected function _endLevel(cEvt:ContactEvent):void {

			if (cEvt.other.GetBody().GetUserData() is Declik) {
				lvlEnded.dispatch();
			}
		}
		
		protected function _restartLevel(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is Declik) {
				restartLevel.dispatch();
			}
		}

		protected function _hurt():void {
			_ce.sound.playSound("Hurt", 1, 0);
		}

		private function _roseauTouche(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is Declik) {
				cEvt.fixture.GetBody().GetUserData().anim = "white";
			}
		}

		private function _roseauFin(cEvt:ContactEvent):void {
			
			if (cEvt.other.GetBody().GetUserData() is Declik) {
				cEvt.fixture.GetBody().GetUserData().anim = "black";
			}
		}
		
		private function _playSound(cEvt:ContactEvent):void {

			if (cEvt.other.GetBody().GetUserData() is Declik) {
				_ce.sound.playSound(cEvt.fixture.GetBody().GetUserData().song, 1, 0);
			}
		}
		
		private function _attack():void {
			_ce.sound.playSound("Kill", 1, 0);
		}

		private function _jump():void {
			_ce.sound.playSound("Jump", 1, 0);
		}

		private function _animationChange():void {
			
			if (_declik.animation == "walk") {
				_ce.sound.stopSound("Skid");
				_ce.sound.playSound("Walk", 1);
				return;
			} else {
				_ce.sound.stopSound("Walk");
			}

			if (_declik.animation == "skid") {
				_ce.sound.playSound("Skid", 1, 0);
				return;
			} else {
				_ce.sound.stopSound("Skid");
			}
		}

		override public function destroy():void {
			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);

			// _percent = Math.round(view.loadManager.bytesLoaded / view.loadManager.bytesTotal * 100).toString();
		}

		private function handleLoadComplete():void {
			
			// remove loader
		}
	}
}
