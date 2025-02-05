package defenseofaegir.levels {

	import org.osflash.signals.Signal;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	/**
	 * @author Aymeric
	 */
	public class LevelManager {

		static private var _instance:LevelManager;

		public var onLevelChanged:Signal;

		private var _levels:Array;
		private var _currentIndex:uint;
		private var _currentLevel:ALevel;

		public function LevelManager() {

			_instance = this;

			onLevelChanged = new Signal(ALevel);
			_currentIndex = 0;

			_levels = [[LevelA1, "levels/LevelA.swf"], [LevelA2]];

			gotoLevel();
		}

		static public function getInstance():LevelManager {
			return _instance;
		}


		public function destroy():void {
			onLevelChanged.removeAll();
			_currentLevel = null;
		}

		public function nextLevel():void {

			if (_currentIndex < _levels.length - 1)
				++_currentIndex;

			gotoLevel();
		}

		public function prevLevel():void {

			if (_currentIndex > 0)
				--_currentIndex;

			gotoLevel();
		}

		public function gotoLevel(index:int = -1):void {

			if (_currentLevel != null)
				_currentLevel.lvlEnded.remove(_onLevelEnded);

			var loader:Loader = new Loader();

			if (index != -1)
				_currentIndex = index;
				
			// Level SWF is undefined 
			if (_levels[_currentIndex][1] == undefined) {
				
				_currentLevel = ALevel(new _levels[_currentIndex][0]());
				_currentLevel.lvlEnded.add(_onLevelEnded);

				onLevelChanged.dispatch(_currentLevel);
				
			} else {
				
				loader.load(new URLRequest(_levels[_currentIndex][1]));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _levelSWFLoaded);
			}
		}

		private function _levelSWFLoaded(evt:Event):void {

			_currentLevel = ALevel(new _levels[_currentIndex][0](evt.target.loader.content));
			_currentLevel.lvlEnded.add(_onLevelEnded);

			onLevelChanged.dispatch(_currentLevel);

			evt.target.removeEventListener(Event.COMPLETE, _levelSWFLoaded);
			evt.target.loader.unloadAndStop();
		}

		private function _onLevelEnded():void {

		}


		public function get currentLevel():ALevel {
			return _currentLevel;
		}

		public function set currentLevel(currentLevel:ALevel):void {
			_currentLevel = currentLevel;
		}

		public function get nameCurrentLevel():String {
			return _currentLevel.nameLevel;
		}

	}
}
