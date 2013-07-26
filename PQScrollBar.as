package 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	
	public class PQScrollBar extends Sprite
	{
		private var _up:Object;
		private var _down:Object;
		private var _bg:Object;
		private var _bar:Object;
		private var _speed:int;
		private var _obj:Object;
		private var _size:int;
		private var _rollArea:Rectangle;
		private var _direction:String;
		private var minValue:int;
		private var maxValue:int;
		private var _slow:Class;
		/**
	 	 * 滚动条
		 *功能概述：
		 * 1、支持自定义皮肤
		 * 2、支持缓动滚动
		 *方法：
		 * 1、bindObj：绑定滚动对象
		 * 2、setSkin：设置自定义皮肤
		 * 3、updateBind：更新绑定，当滚动对象宽高发生变化时调用
	 	 * @author phhui
	 	 */
		public function PQScrollBar()
		{
			_up=this.s_up;
			_down=this.s_down;
			_bar=this.s_bar;
			_bg=this.s_bg;
		}
		/**
	 	 * 设置皮肤
		 * @param btnUp:向上按钮
		 * @param btnDown:向下按钮
		 * @param btnBar:滑块
		 * @param btnBg:滚动条背景
	 	 * @author phhui
	 	 */
		public function setSkin(btnUp:Object,btnDown:Object,btnBar:Object,barBg:Object=null):void {
			while(this.numChildren>0){
				this.removeChildAt(0);
			}
			_up=btnUp;
			_down=btnDown;
			_bar=btnBar;
			if(barBg)_bg=barBg;
			else _bg=null;
		}
		/**
	 	 * 绑定滚动对象
		 * @param target：滚动对象
		 * @param rollArea：滚动区域
		 * @param size：滚动条大小--垂直滚动时此值为高度，水平滚动时为宽度
		 * @param speed：滚动速度
		 * @param direction：滚动方向
		 * @param slow：缓动类--需要缓动则要设置该缓动类，否则不用。注：该类只能是TweenLite或是与TweenLite的to方法有相同参数的缓动类
	 	 * @author phhui
	 	 */
		public function bindObj(target:Object,rollArea:Rectangle,size:int,speed:int=10,direction:String="y",slow:Class=null):void{
			_obj=target;
			_rollArea=rollArea;
			_speed = speed;
			_size = size;
			_direction = direction;
			if (slow)_slow = slow;
			if (_bg) {
				if (_direction == "y")_bg.height = size;
				else _bg.width = size;
			}
			init();
		}
		/**
	 	 * 更新滚动对象
	 	 * @author phhui
	 	 */
		public function updateBind():void {
			if (_direction == "y") {
				minValue = _obj.y - _obj["height"] + _rollArea.height;
				maxValue = _obj.y;
			}else {
				minValue = _obj.y - _obj["width"] + _rollArea.width;
				maxValue = _obj.x;
			}
			checkEmabled();
		}
		/**
	 	 * 删除相关事件监听
	 	 * @author phhui
	 	 */
		public function remove():void{
			_up.removeEventListener(MouseEvent.CLICK, upScroll);
			_down.removeEventListener(MouseEvent.CLICK, downScroll);
			_bar.removeEventListener(MouseEvent.MOUSE_DOWN, startScroll);
			_bar.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			_obj.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseScroll);
		}
		private function checkEmabled():void{
			if(_direction=="y"){
				if(_obj.height<_rollArea.height)this.visible=false;
				else this.visible=true;
			}else{
				if(_obj.width<_rollArea.width)this.visible=false;
				else this.visible=true;
			}
		}
		private function init():void {
			if(_bg)this.addChild(_bg as DisplayObject);
			this.addChild(_up as DisplayObject);
			this.addChild(_down as DisplayObject);
			this.addChild(_bar as DisplayObject);
			if (_direction == "y") {
				minValue = _obj.y - _obj["height"] + _rollArea.height;
				maxValue = _obj.y;
				_down.y = _size-_down.height;
				_bar.y = _up.height;
			}else {
				minValue = _obj.y - _obj["width"] + _rollArea.width;
				maxValue = _obj.x;
				_down.y = _size-_down.width;
				_bar.y = _up.width;
			}
			registerListen();
		}
		private function registerListen():void {
			_up.addEventListener(MouseEvent.CLICK, upScroll);
			_down.addEventListener(MouseEvent.CLICK, downScroll);
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, startScroll);
			_bar.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			_obj.addEventListener(MouseEvent.MOUSE_WHEEL, mouseScroll);
			checkEmabled();
		}
		private function upScroll(e:MouseEvent):void {
			if (_obj[_direction] > maxValue) {
				setPosition(maxValue);
			}else if (_obj[_direction] + _speed < maxValue) {
				setPosition(_obj[_direction]+_speed);
			}else {
				setPosition(maxValue);
			}
			updateBarPos();
		}
		private function downScroll(e:MouseEvent):void {
			if (_obj[_direction] < minValue) {
				setPosition(minValue);
			}else if (_obj[_direction] - _speed > minValue) {
				setPosition(_obj[_direction]-_speed);
			}else {
				setPosition(minValue);
			}
			updateBarPos();
		}
		private function startScroll(e:MouseEvent):void {
			if (_direction == "y") {
				_bar.startDrag(false, new Rectangle(0,_up.height,0,_size-_down.height-_bar.height-_up.height));
			}else {
				_bar.startDrag(false, new Rectangle(_up.width,0,_size-_down.width-_bar.width-_up.width,0));
			}
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, update);
		}
		private function stopScroll(e:MouseEvent):void {
			_bar.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, update);
		}
		private function update(e:MouseEvent):void {
			if (_direction == "y") {
				setPosition(maxValue-((_bar.y - _up.height) * (_obj.height-_rollArea.height) / (_size-_up.height - _down.height - _bar.height)));
			}else {
				setPosition(maxValue-((_bar.x - _up.width) * (_obj.width - _rollArea.width) / (_size-_up.width - _down.width - _bar.width)));
			}
		}
		private function mouseScroll(e:MouseEvent):void{
			if (e.delta < 0) {
				downScroll(e);
			}else {
				upScroll(e);
			}
			updateBarPos();
		}
		private function updateBarPos():void {
			_bar.y = Math.floor((maxValue-_obj.y) * (_size-_up.height - _down.height - _bar.height) / (_obj.height - _rollArea.height)) + _up.height;
		}
		private function setPosition(p:int):void {
			var param:Object;
			if (_direction == "y") param = {y:p};
			else param = { x:p };
			
			if (_slow) {
				_slow["killTweensOf"](_obj);
				_slow["to"](_obj,0.8,param);
			}
			else _obj[_direction] = p;
		}
	}
}