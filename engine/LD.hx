package engine;

import hxd.Timer;
import hxd.snd.ChannelGroup;
import h3d.col.Collider;
import h3d.prim.ModelCache;
import engine.utils.MacroUtil;
import hxd.res.Model;
import engine.components.TweenComponent;

class LD
{
  
  public static function main()
  {
    MacroUtil.constructEngine();
  }
  
  public static function init():Void
  {
    modelCache = new ModelCache();
    musicChannel = new ChannelGroup("music");
    sfxChannel = new ChannelGroup("sfx");
    tweener = new TweenComponent();
    
    // Disable scrolling with wheel scrolling page.
    #if js
    js.Syntax.code("window.addEventListener(\"wheel\", (e) => { e.preventDefault(); return false; })");
    #end
  }
  
  public static var engine:LDEngine;
  
  public static var modelCache:ModelCache;
  private static var colliderCache:Map<String, Collider> = new Map();
  public static function clearCache():Void
  {
    modelCache.dispose();
    colliderCache = new Map();
  }
  
  public static function loadCollider(m:Model):Collider
  {
    var cache:Collider = colliderCache.get(m.name);
    if (cache != null) return cache;
    cache = modelCache.loadModel(m).getCollider();
    colliderCache.set(m.name, cache);
    return cache;
  }
  
  public static function startUpdate(dt:Float):Void
  {
    frame++;
    deltaTime = dt;
    elapsed = dt * timescale;
    realtime += dt;
    runtime += elapsed;
  }
  
  public static function endUpdate():Void
  {
    Music.update(Timer.elapsedTime);
  }
  
  public static inline function randomI(min:Int, max:Int):Int
  {
    return Std.int(Math.random() * (max - min)) + min;
  }
  
  public static inline function randomIZ(len:Int):Int
  {
    return Std.int(Math.random() * len);
  }
  
  public static inline function max<T:Float>(a:T, b:T):T
  {
    return a > b ? a : b;
  }
  
  public static inline function min<T:Float>(a:T, b:T):T
  {
    return a > b ? b : a;
  }
  
  public static inline function moveTowards<T:Float>(val:T, add:T, target:T):T
  {
    if (target > val)
    {
      if (val + add > target) return target;
      else return val + add;
    }
    else 
    {
      if (val - add < target) return target;
      else return val - add;
    }
  }
  
  public static var tweener:TweenComponent;
  
  public static var sfxChannel:ChannelGroup;
  public static var musicChannel:ChannelGroup;
  
  public static var frame:Int = 0;
  public static var timescale:Float = 1.0;
  /* Raw delta time not modified by timescale */
  public static var deltaTime:Float = 0;
  public static var realtime:Float = 0;
  /* Delta-time with timescale applied */
  public static var elapsed:Float = 0;
  public static var runtime:Float = 0;
}