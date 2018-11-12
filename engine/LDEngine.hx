package engine;

import hxd.App;

class LDEngine extends App
{
  
  private var _switchScene:LDScene;
  private var _scene:LDScene;
  
  public var scene(get, set):LDScene;
  private inline function get_scene():LDScene { return _scene; }
  private function set_scene(v:LDScene):LDScene
  {
    if (v == _scene) return v;
    _switchScene = v;
    return _scene;
  }
  
  private var _preloader:Preloader;
  
  public function new(?preloader:Preloader)
  {
    _preloader = preloader;
    LD.engine = this;
    super();
  }
  
  override function init()
  {
  }
  
  override function update(dt:Float)
  {
    if (_switchScene != null)
    {
      if (_scene != null)
      {
        _scene.end();
        _scene.sceneRemoved();
        _scene.scene = null;
      }
      _scene = _switchScene;
      _switchScene = null;
      _scene.scene = _scene;
      _scene.sceneAdded();
      _scene.begin();
    }
    LD.startUpdate(dt);
    if (_scene != null) _scene.update();
    LD.tweener.update();
    LD.endUpdate();
  }
  
  override private function loadAssets(onLoaded:Void->Void)
  {
    LD.init();
    scene = new LDScene();
    if (_preloader != null)
    {
      _preloader.onLoaded = onLoaded;
      _preloader.load();
      // ...
    }
    else
    {
      #if js
      // hxd.Res.initEmbed();
      #else
      hxd.Res.initLocal();
      #end
      onLoaded();
    }
  }
  
}