package engine;

import hxd.res.EmbedOptions;
import msignal.Signal;
import hxd.Res;

class Bootloader
{
  
  public static var onProgress:Signal1<BootState> = new Signal1();
  public static var onFinished:Signal1<BootState> = new Signal1();
  public static var state:BootState = new BootState();
  
  public static function loadAuto():Void
  {
    hxd.res.Loader
  }
  
	public static macro function loadEmbed(?options:haxe.macro.Expr.ExprOf<hxd.res.EmbedOptions>) {
		return macro {
      Res.initEmbed(options);
      Bootloader.state.percent = 1;
      // Res.loader
      
    }
	}
  
  public static function loadLocal():Void
  {
    Res.initLocal();
  }
  
  public static function loadJS():Void
  {
    
  }
  
}

class BootState
{
  
  public var percent:Float;
  public var filesLoaded:Int;
  public var filesTotal:Int;
  public var latestFile:String;
  
  public function new():Void
  {
    this.percent = 0;
    this.filesLoaded = 0;
    this.filesTotal = 0;
  }
  
}