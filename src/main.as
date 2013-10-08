package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class main extends Sprite
	{
		public function main()
		{
			var txt:TextField=new TextField();
			txt.width=100;
			txt.height=100;
			txt.border=true;
			txt.x=100;
			txt.y=100;
			txt.multiline=true;
			txt.wordWrap=true;
			txt.text="在短暂拜访了亚洲的 Android 合作伙伴之后，Google 资深副总裁 Sundar Pichai 正式通过 Google+ 和 Twitter 公布了下一版移动系统 Android 4.4 的代号名称「KitKat」（看到上面这个由 Kit Kat，也就是奇巧巧克力组成的机器人了吗？）。之前盛传的 Key Lime Pie 最终并未入选，而在消息公布后 Google 也火速更新了自己的 Android 开发者网站并在上面列出了迄今为止的 Android 编年史。关于最新的系统暂时还没有太多细节可与大家分享，但按照 Google 的说法，他们的目标是「用 KitKat 为每个人打造出色的 Android 体验」。";
			addChild(txt);
			var pq:PQScrollBar=new PQScrollBar();
			pq.bindObj(txt,null,200,2);
			addChild(pq);
			pq.x=450;
			pq.y=100;
			pq.setPos(txt.maxScrollV);
		}
	}
}