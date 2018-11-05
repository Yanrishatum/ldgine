package engine.basic.rrb;

import haxe.io.Path;
import hxd.res.DefaultFont;
import h2d.Text;
import h2d.Graphics;
import h2d.Object;
import engine.basic.PreloaderDisplay;

class RedRayLoader implements PreloaderDisplay
{
  
  private var _base:Object;
  private var _g:Graphics;
  private var _t:Text;
  private var _total:Float = 0;
  private var _local:Float = 0;
  
  public function new()
  {
  }
  
  public function show():Void 
  {
    _base = new Object();
    _g = new Graphics(_base);
    _t = new Text(DefaultFont.get(), _base);
    _t.textColor = 0xffffffff;
    _t.textAlign = Center;
    _t.y = LD.engine.engine.height / 2;
    LD.engine.s2d.addChild(_base);
  }
  
  private function redraw():Void
  {
    var g:Graphics = _g;
    g.clear();
    g.lineStyle(10, 0xffffff);
    var w = LD.engine.engine.width / 2;
    var h = LD.engine.engine.height / 2;
    drawPie(w, h, 200, -Math.PI*.5, (Math.PI*2 * _total), Std.int(360 * _total) + 2);
    g.lineStyle(10, 0xffffff);
    drawPie(w, h, 190, -Math.PI*.5, (Math.PI*2 * _local), Std.int(360 * _local) + 2);
  }
  
  private function drawPie(cx:Float, cy:Float, radius:Float, angleStart:Float, angleLength:Float, nsegments:Int):Void
  {
    if(Math.abs(angleLength) >= Math.PI * 2) {
      return _g.drawCircle(cx, cy, radius, nsegments);
    }
    @:privateAccess _g.flush();
    if( nsegments == 0 )
      nsegments = Math.ceil(Math.abs(radius * angleLength / 4));
    if( nsegments < 3 ) nsegments = 3;
    var angle = angleLength / (nsegments - 1);
    for( i in 0...nsegments ) {
      var a = i * angle + angleStart;
      _g.lineTo(cx + Math.cos(a) * radius, cy + Math.sin(a) * radius);
    }
    @:privateAccess _g.flush();
  }
  
  public function setTotalProgress(v:Float):Void 
  {
    _total = v;
    redraw();
  }
  
  public function setLocalProgress(v:Float):Void 
  {
    _local = v;
    redraw();
  }
  
  public function setEntryName(v:String):Void
  {
    _t.text = v;
    _t.x = LD.engine.engine.width / 2;
  }
  
  public function hide():Void 
  {
    LD.engine.s2d.removeChild(_base);
  }
  
  public function update():Void 
  {
    
  }
  
  
}