package engine.utils;

import h3d.mat.Texture;
import h2d.Text;
import hxd.Event;
import hxd.BitmapData;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import hxd.res.DefaultFont;
import h2d.Font;
import h2d.Flow;

interface IWatchable
{
  function invalidate():Void;
  function dispose():Void;
}

@:generic
private class Watchable<T, K> implements IWatchable
{
  
  public var getter:Void->T;
  public var target:K;
  
  public function new(get:Void->T, target:K)
  {
    this.getter = get;
    this.target = target;
  }
  
  public function invalidate():Void { }
  public function dispose() { getter = null; target = null; }
  
}
private class RadioWatcher extends Watchable<Int, Array<Checkbox>>
{
  override public function invalidate()
  {
    var idx = getter();
    for (i in 0...target.length) { target[i].checked = idx == i; }
  }
}
private class CheckboxWatcher extends Watchable<Bool, Checkbox>
{
  override public function invalidate() { target.checked = getter(); }
}
private class SliderWatcher extends Watchable<Float, h2d.Slider>
{
  override public function invalidate() { target.value = getter(); }
}

class DebugDisplay
{
  
  public static var font:Font;
  
  public static var flow:Flow;
  
  private static var groupStack:Array<Flow>;
  private static var group:Flow;
  
  private static var monitor:Array<IWatchable>;
  private static var immediate:Array<IWatchable>;
  
  private static var radioGroup:Array<Checkbox>;
  private static var radioChange:Int->Void;
  private static var radioGet:Void->Int;
  
  private static var active:Bool;
  private static var compactMode:Bool;
  
  public static function init():Void
  {
    active = true;
    groupStack = new Array();
    monitor = new Array();
    immediate = new Array();
    font = DefaultFont.get();
    flow = new h2d.Flow(LD.engine.s2d);
    flow.isVertical = true;
    flow.verticalSpacing = 2;
    haxe.MainLoop.add(update);
  }
  
  private static function update():Void
  {
    for (i in immediate) i.invalidate();
  }
  
  public static function invalidate():Void
  {
    for (w in monitor)
    {
      w.invalidate();
    }
  }
  
  public static function beginGroup(label:String, visible:Bool = true, vertical:Bool = true, foldable:Bool = true):Flow
  {
    if (!active) return null;
    if (group != null)
    {
      groupStack.push(group);
    }
    var g:Flow = new Flow();
    g.isVertical = vertical;
    g.verticalSpacing = 2;
    g.paddingLeft = 10;
    if (foldable)
      addCheckbox(label, visible, (v:Bool) -> { g.visible = v; if (v) invalidate(); });
    if (group != null) group.addChild(g);
    else flow.addChild(g);
    g.visible = visible;
    group = g;
    return g;
  }
  
  public static function endGroup():Void
  {
    if (groupStack.length > 0) group = groupStack.pop();
    else group = null;
  }
  
  private static function pushGroup(g:Flow):Void
  {
    if (!active) return;
    if (group != null)
    {
      groupStack.push(group);
    }
    group = g;
  }
  
  private static inline function popGroup():Void
  {
    endGroup();
  }
  
  private static function makeEntry(label:String, ?comps:Array<Object>):Flow
  {
    if (!active) return null;
    var f:Flow = new Flow(group != null ? group : flow);
    f.horizontalSpacing = 5;
  
    var tf = new h2d.Text(font, f);
    if (label != null) tf.text = label;
    if (!compactMode)
    {
      tf.maxWidth = 70;
      tf.textAlign = Right;
    }
    
    if (comps != null)
    {
      for (comp in comps)
      {
        f.addChild(comp);
      }
    }
    return f;
  }
  
  public static function addButton(label:String, click:Void->Void)
  {
    var b:Button = new Button(100, 20, label);
    b.onClick = (e) -> click();
    
    makeEntry(null, [b]);
    return b;
  }
  
  public static function beginRadioGroup(get:Void->Int, set:Int->Void):Void
  {
    if (radioGroup != null)
    {
      endRadioGroup();
    }
    radioGroup = new Array();
    radioChange = set;
    radioGet = get;
  }
  
  public static function endRadioGroup():Void
  {
    if (radioGroup != null)
    {
      var w = new RadioWatcher(radioGet, radioGroup);
      w.invalidate();
      monitor.push(w);
      radioGroup = null;
      radioChange = null;
      radioGet = null;
    }
  }
  
  public static function addCheckbox(label:String, ?value:Bool, set:Bool->Void, ?get:Void->Bool)
  {
    if (!active) return null;
    var i:Checkbox = new Checkbox();
    i.checked = get != null ? get() : value;//get();//value;
    i.onChange = set;
    
    if (radioGroup != null)
    {
      i.onRadio = radioChange;
      i.group = radioGroup;
      radioGroup.push(i);
    }
    else if (get != null)
    {
      monitor.push(new CheckboxWatcher(get, i));
    }
    makeEntry(label, [i]);
    return i;
  }
  
  public static function addEnum<T>(label:String, e:Enum<T>, get:Void->T, set:T->Void):Void
  {
    var list = haxe.EnumTools.createAll(e);
    var names = [for (e in list) Std.string(e)];
    
    var nullCall = (v:Bool) -> {};
    var f = makeEntry(label);
    pushGroup(f);
    compactMode = true;
    beginRadioGroup(() -> list.indexOf(get()), (v) -> set(list[v]));
    for (val in list)
    {
      addCheckbox(Std.string(val), false, nullCall);
    }
    endRadioGroup();
    compactMode = false;
    popGroup();
  }
  
  public static function addSliderI(label:String, get:Void->Int, set:Int->Void, min:Int = 0, max:Int = 100)
  {
    if (!active) return null;
    var f:Flow = makeEntry(label);
    
    var sli = new h2d.Slider(200, 10, f);
    sli.minValue = min;
    sli.maxValue = max;
    sli.value = get();

    var tf = new h2d.TextInput(font, f);
    tf.text = "" + hxd.Math.fmt(sli.value);
    sli.onChange = function() {
      set(Std.int(sli.value));
      tf.text = "" + hxd.Math.fmt(sli.value);
      f.needReflow = true;
    };
    tf.onChange = function() {
      var v = Std.parseFloat(tf.text);
      if( Math.isNaN(v) ) return;
      sli.value = v;
      set(Std.int(v));
    };
    monitor.push(new SliderWatcher(get, sli));
    
    return sli;
  }
  
  public static function addSliderF( label : String, get : Void -> Float, set : Float -> Void, min : Float = 0., max : Float = 1. ) {
    
    if (!active) return null;
    var f:Flow = makeEntry(label);
    
    var sli = new h2d.Slider(200, 10, f);
    sli.minValue = min;
    sli.maxValue = max;
    sli.value = get();

    var tf = new h2d.TextInput(font, f);
    tf.text = "" + hxd.Math.fmt(sli.value);
    sli.onChange = function() {
      set(sli.value);
      tf.text = "" + hxd.Math.fmt(sli.value);
      f.needReflow = true;
    };
    tf.onChange = function() {
      var v = Std.parseFloat(tf.text);
      if( Math.isNaN(v) ) return;
      sli.value = v;
      set(v);
    };
    monitor.push(new SliderWatcher(get, sli));
    
    return sli;
  }
  
  public static function watch( label : String, get:Void->Dynamic )
  {
    if (!active) return null;
    var f = makeEntry(label);
    var live = new Livewatch(f, get);
    immediate.push(live);
    return live;
  }
  
}

class Livewatch extends Text implements IWatchable
{
  
  private var getter:Void->Dynamic;
  private var last:Dynamic;
  
  public function new(parent:Object, get:Void->Dynamic)
  {
    super(DebugDisplay.font, parent);
    this.getter = get;
    invalidate();
  }
  
  public function invalidate():Void
  {
    var v = getter();
    if (v != last)
    {
      this.text = Std.string(v);
      last = v;
    }
  }
  
  public function dispose():Void
  {
    getter = null;
  }
  
}

class Button extends Interactive
{
  private var bg:Tile;
  private var hover:Tile;
  private var down:Tile;
  
  private var pressed:Bool;
  
  public function new(w:Int, h:Int, label:String, ?parent:Object)
  {
    super(w, h, parent);
    var txt:Text = new Text(DebugDisplay.font, this);
    txt.maxWidth = w;
    txt.textAlign = Align.Center;
    txt.text = label;
    txt.x = 0;
    txt.y = (h - txt.textHeight) / 2;
    txt.color.setColor(0xffffffff);
    
    bg = Tile.fromColor(0x808080, w, h);
    hover = Tile.fromColor(0xA0A0A0, w, h);
    down = Tile.fromColor(0x606060, w, h);
    
  }
  
  override private function draw(ctx:RenderContext)
  {
    if (isOver())
    {
      emitTile(ctx, pressed ? down : hover);
    }
    else 
    {
      emitTile(ctx, pressed ? hover : bg);
    }
    super.draw(ctx);
  }
  
  override public function handleEvent(e:Event)
  {
    if (e.kind == EventKind.EPush)
    {
      pressed = true;
    }
    else if (e.kind == EventKind.ERelease || e.kind == EventKind.EReleaseOutside)
    {
      pressed = false;
    }
    super.handleEvent(e);
  }
  
}

class Checkbox extends Interactive
{
  private static var bg:Tile;
  private static var check:Tile;
  private static var radioBg:Tile;
  private static var radioCheck:Tile;
  
  public var checked:Bool;
  public var group:Array<Checkbox>;
  
  public function new(?parent:Object)
  {
    super(10, 10, parent);
    if (bg == null)
    {
      bg = Tile.fromColor(0x808080, 10, 10);
      var d:BitmapData = new BitmapData(8, 8);
      d.setPixel(7, 1, 0xffCCCCCC);
      d.setPixel(6, 2, 0xffCCCCCC);
      d.setPixel(5, 3, 0xffCCCCCC);
      d.setPixel(4, 4, 0xffCCCCCC);
      d.setPixel(3, 5, 0xffCCCCCC);
      d.setPixel(2, 6, 0xffCCCCCC);
      d.setPixel(1, 5, 0xffCCCCCC);
      d.setPixel(0, 4, 0xffCCCCCC);
      
      check = Tile.fromBitmap(d);
      check.dx = 1;
      check.dy = 1;
      
      d = new hxd.BitmapData(10, 10);
      d.fill(1, 1, 8, 8, 0xffcccccc);
      d.fill(2, 0, 6, 1, 0xffcccccc);
      d.fill(2, 9, 6, 1, 0xffcccccc);
      d.fill(0, 2, 1, 6, 0xffcccccc);
      d.fill(9, 2, 1, 6, 0xffcccccc);
      radioBg = Tile.fromBitmap(d);
      
      d = new hxd.BitmapData(8, 8);
      d.fill(1, 1, 6, 6, 0xff808080);
      d.fill(2, 0, 4, 1, 0xff808080);
      d.fill(2, 7, 4, 1, 0xff808080);
      d.fill(0, 2, 1, 4, 0xff808080);
      d.fill(7, 2, 1, 4, 0xff808080);
      radioCheck = Tile.fromBitmap(d);
      radioCheck.dx = 1;
      radioCheck.dy = 1;
    }
  }
  
  override private function draw(ctx:RenderContext)
  {
    super.draw(ctx);
    if (group != null)
    {
      emitTile(ctx, radioBg);
      if (checked) emitTile(ctx, radioCheck);
    }
    else 
    {
      emitTile(ctx, bg);
      if (checked) emitTile(ctx, check);
    }
  }
  
  override public function handleEvent(e:Event)
  {
    super.handleEvent(e);
    if (e.cancel) return;
    switch(e.kind)
    {
      case ERelease:
        if (group != null)
        {
          if (!checked)
          {
            checked = true;
            for (g in group)
            {
              if (g != this) g.checked = false;
              g.onChange(g.checked);
            }
            onRadio(group.indexOf(this));
          }
        }
        else 
        {
          checked = !checked;
          onChange(checked);
        }
      default:
    }
  }
  
  public dynamic function onChange(value:Bool):Void
  {
    
  }
  
  public dynamic function onRadio(value:Int):Void
  {
    
  }
}