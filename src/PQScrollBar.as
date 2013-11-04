package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class PQScrollBar extends Sprite
	{
		/**向上按钮**/
		private var _up:Object;
		/***向下按钮*/
		private var _down:Object;
		/**滚动条背景**/
		private var _bg:Object;
		/**滚动条滑动按钮**/
		private var _bar:Object;
		/**滚动区域遮罩**/
		private var _mask:Sprite;
		/**滚动速度**/
		private var _speed:int;
		/**滚动对象**/
		private var _obj:Object;
		/**滚动条宽或高，由direction决定**/
		private var _size:int;
		/**滚动区域**/
		private var _rollArea:Rectangle;
		/**滚动方向，水平或垂直**/
		private var _direction:String;
		/**滚动范围最小值**/
		private var minValue:int;
		/**滚动范围最大值**/
		private var maxValue:int;
		/**是否缓动类**/
		private var _slow:Class;
		/**是否自动生成遮罩**/
		private var _autoMask:Boolean=false;
		/**是否已添加到舞台**/
		private var inStage:Boolean=false;
		/**滚动类别，文本或其它显示对象,0对象，1文本**/
		private var _type:int=0;
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
			/*_up=new btn_up();
			_down=new btn_down();
			_bar=new btn_bar();
			_bg=new bg();*/
			this.addEventListener(Event.ADDED_TO_STAGE,added);
			this.addEventListener(Event.REMOVED_FROM_STAGE,addOut);
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
			if(btnUp is BitmapData){
				var spup:Sprite=new Sprite();
				spup.addChild(new Bitmap(btnUp as BitmapData));
				_up=spup;
			}
			else _up=btnUp;
			if(btnDown is BitmapData){
				var spd:Sprite=new Sprite();
				spd.addChild(new Bitmap(btnDown as BitmapData));
				_down=spd;
			}
			else _down=btnDown;
			if(btnBar is BitmapData){
				var spb:Sprite=new Sprite();
				spb.addChild(new Bitmap(btnBar as BitmapData));
				_bar=spb;
			}
			else _bar=btnBar;
			if(barBg){
				if(barBg is BitmapData){
					var spbg:Sprite=new Sprite();
					spbg.addChild(new Bitmap(barBg as BitmapData));
					_bg=spbg;
				}
				else _bg=barBg;
			}
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
		 * @param autoMask:是否自动设置遮罩，如果已手动设置了遮罩则应设置为false
		 * @author phhui
		 */
		public function bindObj(target:Object,rollArea:Rectangle,size:int,speed:int=10,direction:String="y",slow:Class=null,autoMask:Boolean=true):void{
			_obj=target;
			_rollArea=rollArea;
			_speed = speed;
			_size = size;
			_direction = direction;
			if(checkTxt())_type=1;
			if (slow)_slow = slow;
			if (_bg) {
				if (_direction == "y")_bg.height = size;
				else _bg.width = size;
			}
			if(autoMask&&_type==0){
				_mask=new Sprite();
				createMask();
			}
			_autoMask=autoMask;
			init();
		}
		/**
		 * 更新滚动对象
		 * @author phhui
		 */
		public function updateBind():void {
			if(_type)return;
			_obj.y=_rollArea.y;
			if (_direction == "y") {
				minValue = _obj.y - _obj["height"] + _rollArea.height;
				maxValue = _obj.y;
				_bar.y=_up.height;
			}else {
				minValue = _obj.y - _obj["width"] + _rollArea.width;
				maxValue = _obj.x;
				_bar.x=_up.width;
			}
			checkEmabled();
		}
		/**
		 *设置滚动条初始位置 
		 * @param i
		 * 
		 */		
		public function setPos(i:int):void{
			setPosition(i);
			updateBarPos();
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
		private function added(e:Event):void{
			inStage=true;
			if(_autoMask&&_type==0){
				this.parent.addChild(_mask);
				_obj.mask=_mask;
			}
		}
		private function addOut(e:Event):void{
			inStage=false;
		}
		private function checkEmabled():void{
			if(_type==0){
				if(_direction=="y"){
					if(_obj.height<_rollArea.height)this.visible=false;
					else this.visible=true;
				}else{
					if(_obj.width<_rollArea.width)this.visible=false;
					else this.visible=true;
				}
			}else{
				if(_obj.textHeight<_obj.height){
					this.visible=false;
				}else{
					this.visible=true;
				}
			}
			if(this.visible)registerListen();
			else remove();
		}
		private function checkTxt():Boolean{
			if(_obj is TextField)return true;
			return false;
		}
		private function init():void {
			if(_bg)this.addChild(_bg as DisplayObject);
			this.addChild(_up as DisplayObject);
			this.addChild(_down as DisplayObject);
			this.addChild(_bar as DisplayObject);
			if(_type!=1){
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
				if(_autoMask&&inStage){
					this.parent.addChild(_mask);
					_obj.mask=_mask;
				}
			}else{
				_down.y = _size-_down.height;
				_bar.y = _up.height;
			}
			checkEmabled();
		}
		private function registerListen():void {
			_up.addEventListener(MouseEvent.CLICK, upScroll);
			_down.addEventListener(MouseEvent.CLICK, downScroll);
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, startScroll);
			_bar.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			_obj.addEventListener(MouseEvent.MOUSE_WHEEL, mouseScroll);
			
		}
		private function createMask():void{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xffffff,0.1);
			_mask.graphics.drawRect(_rollArea.x,_rollArea.y,_rollArea.width,_rollArea.height);
		}
		private function upScroll(e:MouseEvent):void {
			if(_type==0){
				if (_obj[_direction] > maxValue) {
					setPosition(maxValue);
				}else if (_obj[_direction] + _speed < maxValue) {
					setPosition(_obj[_direction]+_speed);
				}else {
					setPosition(maxValue);
				}
			}else{				
				setPosition(_obj.scrollV-_speed);
			}
			updateBarPos();
		}
		private function downScroll(e:MouseEvent):void {
			if(_type==0){
				if (_obj[_direction] < minValue) {
					setPosition(minValue);
				}else if (_obj[_direction] - _speed > minValue) {
					setPosition(_obj[_direction]-_speed);
				}else {
					setPosition(minValue);
				}
			}else{
				setPosition(_obj.scrollV+_speed);
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
			if(_type==0){
				if (_direction == "y") {
					setPosition(maxValue-((_bar.y - _up.height) * (_obj.height-_rollArea.height) / (_size-_up.height - _down.height - _bar.height)));
				}else {
					setPosition(maxValue-((_bar.x - _up.width) * (_obj.width - _rollArea.width) / (_size-_up.width - _down.width - _bar.width)));
				}
			}else{
				setPosition((_bar.y - _up.height) * _obj.maxScrollV / (_size-_up.height - _down.height - _bar.height));
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
			if(_type==0)_bar.y = Math.floor((maxValue-_obj.y) * (_size-_up.height - _down.height - _bar.height) / (_obj.height - _rollArea.height)) + _up.height;
			else{
				_bar.y=Math.floor(_obj.scrollV * (_size-_up.height - _down.height - _bar.height) / _obj.maxScrollV) + _up.height;
				if(_obj.scrollV==1)_bar.y=_up.height;
			}
		}
		private function setPosition(p:int):void {
			if(_type==0){
				var param:Object;
				if (_direction == "y") param = {y:p};
				else param = { x:p };
				
				if (_slow) {
					_slow["killTweensOf"](_obj);
					_slow["to"](_obj,0.8,param);
				}
				else _obj[_direction] = p;
			}else{
				_obj.scrollV=p;
			}
		}
	}
}