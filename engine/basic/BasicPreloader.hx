package engine.basic;

import hxd.res.Loader;
import h2d.Graphics;
import hxd.fs.FileEntry;
import haxe.io.Bytes;
import hxd.net.BinaryLoader;
import hxd.fs.FileSystem;
import h2d.Object;
import engine.Preloader;
import hxd.fs.MultiFileSystem;
import engine.utils.fs.ManifestFileSystem;

#if sys
import sys.io.FileInput;
#else
import hxd.fmt.pak.FileSystem.FileInput;
#end

class BasicPreloader extends Preloader
{
  private var commands:Array<BasicPreloaderItem>;
  private var current:Int;
  
  private var renderer:PreloaderDisplay;
  private var resourceCount:Int;
  private var pakFs:hxd.fmt.pak.FileSystem;
  private var systems:Array<FileSystem>;
  
  private var loader:BinaryLoader;
  
  public function new(display:PreloaderDisplay):Void
  {
    renderer = display;
    systems = new Array();
    commands = new Array();
    current = 0;
  }
  
  public function addPak(pak:String):Void
  {
    commands.push( Pak(pak) );
  }
  
  public function addManifest(path:String, base:String):Void
  {
    commands.push( Manifest(path, base) );
  }
  
  private function fetch(path:String):Void
  {
    
    #if sys
    try 
    {
      process(sys.io.File.getBytes(path));
      resourceCount++;
    }
    catch(e:Dynamic)
    {
      
    }
    next();
    #else
    
    loader = new BinaryLoader(path);
    loader.onLoaded = function(b:Bytes):Void
    {
      try
      {
        process(b);
        resourceCount++;
      }
      catch(e:Dynamic)
      {
        loader.onError(e);
        return;
      }
      next();
    }
    loader.onProgress = updateBinaryProgress;
    loader.onError = function(e)
    {
      next();
    }
    loader.load();
    #end
  }
  
  private function updateBinaryProgress(curr:Int, max:Int):Void
  {
    renderer.setLocalProgress(curr / max);
  }
  
  private function next():Void
  {
    updateBinaryProgress(1, 1);
    if (++current == commands.length)
    {
      renderer.hide();
      hxd.Res.loader = new Loader(new MultiFileSystem(systems));
      onLoaded();
      return;
    }
    renderer.setTotalProgress(current / commands.length);
    switch(commands[current])
    {
      case ManifestFile(f):
        renderer.setEntryName(f.path);
        f.fancyLoad(next, updateBinaryProgress);
      default:
        var path:String = commands[current].getParameters()[0];
        renderer.setEntryName(path);
        fetch(path);
    }
    
  }
  
  private function process(data:Bytes):Void
  {
    switch(commands[current])
    {
      case Pak(path):
        if (pakFs == null)
        {
          pakFs = new hxd.fmt.pak.FileSystem();
          systems.push(pakFs);
        }
        #if sys
        // Because stupid pak
        var fo = sys.io.File.read(path);
        pakFs.addPak(fo);
        fo.close();
        #else
        pakFs.addPak(new FileInput(data));
        #end
      case File(path):
        
      case Manifest(path, base):
        var fs:ManifestFileSystem = new ManifestFileSystem(base, data);
        systems.push(fs);
        for (f in fs.manifest)
        {
          commands.push(ManifestFile(f));
          resourceCount++;
        }
      case ManifestFile(f):
        
    }
  }
  
  override public function load()
  {
    renderer.show();
    renderer.setTotalProgress(0);
    renderer.setLocalProgress(0);
    current = -1;
    next();
    hxd.System.setLoop(render);
    var g:Graphics = new Graphics();
    // if (_pak != null)
    // {
      // new hxd.fmt.pak.Loader(LD.engine.s2d, onLoaded);
    // }
  }
  
  private function render():Void
  {
    LD.engine.engine.render(LD.engine.s2d);
    renderer.update();
  }
  
}

enum BasicPreloaderItem
{
  Pak(path:String);
  File(path:String);
  Manifest(path:String, base:String);
  ManifestFile(f:ManifestEntry);
}