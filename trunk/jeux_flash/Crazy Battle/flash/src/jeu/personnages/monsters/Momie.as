package jeu.personnages.monsters {		import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	/**	 * @author Aymeric	 */	public class Momie extends Sprite {				private const force : int=10;		private const vitesse:int=10;				private var monPersoMomie : MovieClip = new PersoMomie();				private var vie : int=50;				public function Momie():void {						addChild(monPersoMomie);			monPersoMomie.scaleX=0.05;			monPersoMomie.scaleY=0.05;			monPersoMomie.x=50;			monPersoMomie.y=400;						monPersoMomie.addEventListener(Event.ENTER_FRAME, deplacementMomie, false, 0, true);		}				public function combat():void {			monPersoMomie.removeEventListener(Event.ENTER_FRAME, deplacementMomie);			monPersoMomie.stop();		}				private function deplacementMomie(e:Event):void {						monPersoMomie.x+=vitesse;		}	}}