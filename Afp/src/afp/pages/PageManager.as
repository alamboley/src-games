package afp.pages
{
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author lbineau
	 */
	public class PageManager extends Sprite
	{
		private var _viewStack : Array;
		protected var _pages : Array;
		protected var _currentIdx : uint;
		protected var _currentPageView : APage;
		protected var _currentOptions : Object;

		public function PageManager()
		{
			super();
		}

		public function goBack() : void
		{
			if (_viewStack.length <= 1) return;

			_viewStack.pop();
			gotoPage(_viewStack[_viewStack.length-1], _currentOptions);
		}

		/**
		 * Initialise le pagemanager avec un tableau de classes étendant APage
		 * @param $pages le tableau des classes des pages
		 * @param $startPage l'index de la page à laquelle commencer
		 */
		public function initialize($pages : *, $startPage : uint = 0) : void
		{
			_pages = [];
			for (var i : int = 0; i < $pages.length; i++)
			{
				_pages[i] = $pages[i];
			}
			_currentIdx = $startPage;
			_viewStack = [_currentIdx];
			_currentPageView = APage(new _pages[_currentIdx]);
			addChild(_currentPageView);
			_currentPageView.gotoPage.add(_onGotoPage);
			_currentPageView.show();
		}

		/**
		 * Va à la page demandée
		 * @param $page un entier ou une chaine de caractère
		 */
		private function _onGotoPage($page : Object, $options : Object) : void
		{
			switch(true)
			{
				case $page is String:
					gotoPageById(String($page), $options);
					break;
				case $page is uint:
				case $page is int:
				case $page is Number:
					gotoPage(uint($page), $options);
					break;
				default:
			}
		}

		public function dispose() : void
		{
			_currentPageView.dispose();
			removeChild(_currentPageView);
			_currentPageView = null;
			_pages = [];
			_viewStack = [];
		}

		protected function next() : void
		{
			(_currentIdx < _pages.length) ? _currentIdx++ : 0;
			_update();
		}

		public function prev() : void
		{
			(_currentIdx > 0) ? _currentIdx-- : _pages.length;
			_update();
		}

		public function gotoPage($numPage : uint, $options : Object = null) : void
		{
			if (_currentIdx != $numPage)
			{
				if (_currentIdx > _viewStack[_viewStack.length - 1]) _viewStack.push(_currentIdx);
				_currentIdx = $numPage;
				_currentOptions = $options;
				_update();
			}
		}

		public function gotoPageById($pageName : String, $options : Object = null) : void
		{
			var $numPage : uint = _indexOf(_pages, function(item : *, ...rest) : Boolean
			{
				return item.ID == $pageName;
			});
			gotoPage($numPage, $options);
		}

		private function _indexOf(source : Array, filter : Function, startPos : int = 0) : int
		{
			var len : int = source.length;
			for (var i : int = startPos; i < len; i++)
				if (filter(source[i], i, source)) return i;
			return -1;
		}

		protected function _update() : void
		{
			_currentPageView.gotoPage.add(gotoPage);
			_currentPageView.hiddenSignal.add(_onCurrentPageHidden);
			_currentPageView.hide();
		}

		protected function _onCurrentPageHidden() : void
		{
			_currentPageView.hiddenSignal.remove(_onCurrentPageHidden);
			_flushCurrentPage();
			_currentPageView = APage(new _pages[_currentIdx](_currentOptions));
			_currentPageView.gotoPage.add(_onGotoPage);
			addChild(_currentPageView);
			_currentPageView.show();
			dispatchEvent(new Event(Event.CHANGE));
		}

		protected function _flushCurrentPage() : void
		{
			removeChild(_currentPageView);
			_currentPageView.dispose();
			_currentPageView = null;
		}

		public function get currentPageView() : APage
		{
			return _currentPageView;
		}
	}
}
