package engine.components;

import h2d.Interactive;
import h2d.Object;

class SpriteComponent extends Component
{
  
  public var sprite:Object;
  public var interactive:Interactive;
  
  public function new(?sprite:Object)
  {
    type = ComponentType.Graphics;
    if (sprite != null) sprite = new Object();
    this.sprite = sprite;
    this.interactive = Std.instance(sprite, Interactive);
  }
  
  override public function dispose()
  {
    if (this.sprite.parent != null) this.sprite.remove();
    this.sprite = null;
  }
  
  override public function sceneAdded()
  {
    if (sprite != null)
    {
      var scene:LDScene = owner.scene;
      if (scene == owner.parent)
      {
        scene.s2d.addChild(sprite);
      }
      else 
      {
        var u:Unit = owner.parent;
        while (u != scene)
        {
          var comp:SpriteComponent = u.get(SpriteComponent);
          if (comp != null && comp.sprite != null)
          {
            comp.sprite.addChild(sprite);
            return;
          }
          u = u.parent;
        }
        scene.s2d.addChild(sprite);
      }
    }
  }
  
  override public function sceneRemoved()
  {
    if (this.sprite != null) this.sprite.remove();
  }
  
}