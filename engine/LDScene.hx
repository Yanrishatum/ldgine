package engine;

import engine.components.Component;

@:allow(engine.LDEngine)
class LDScene extends Unit
{
  
  public var s3d(get, never):h3d.scene.Scene;
  private inline function get_s3d():h3d.scene.Scene { return LD.engine.s3d; }
  
  public var s2d(get, never):h2d.Scene;
  private inline function get_s2d():h2d.Scene { return LD.engine.s2d; }
  
  public function new()
  {
    super();
  }
  
  public function begin():Void
  {
    
  }
  
  public function end():Void
  {
    
  }
  
  override public function add<T:Component>(c:T):T
  {
    throw "Scene cannot have components!";
  }
  
  override public function remove<T:Component>(c:T):T
  {
    throw "Scene cannot have components!";
  }
  
  override public function get<T:Component>(cl:Class<T>):T
  {
    throw "Scene cannot have components!";
  }
  
  
  
}