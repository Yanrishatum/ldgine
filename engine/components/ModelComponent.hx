package engine.components;

import h3d.scene.Interactive;
import h3d.scene.Object;

class ModelComponent extends Component
{
  
  public var model:Object;
  public var interactive:Interactive;
  
  public function new(model:Object)
  {
    this.model = model;
    this.interactive = Std.instance(model, Interactive);
    type = ComponentType.Graphics3D;
  }
  
  override public function sceneAdded()
  {
    if (model != null)
    {
      var scene:LDScene = owner.scene;
      if (scene == owner.parent)
      {
        scene.s3d.addChild(model);
      }
      else 
      {
        var u:Unit = owner.parent;
        while (u != scene)
        {
          var comp:ModelComponent = u.get(ModelComponent);
          if (comp != null && comp.model != null)
          {
            comp.model.addChild(model);
            return;
          }
          u = u.parent;
        }
        scene.s3d.addChild(model);
      }
    }
  }
  
  override public function sceneRemoved()
  {
    if (this.model != null) this.model.remove();
  }
  
  override public function dispose()
  {
    this.model = null;
  }
  
}