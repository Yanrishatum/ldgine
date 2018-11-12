package engine;

import engine.components.Component;
import engine.components.ComponentType;

@:allow(engine.LDEngine)
class Unit
{
  private var _compDirty:Bool;
  private var comps:Array<Component>;
  private var _parent:Unit;
  public var parent(get, set):Unit;
  private var children:Unit;
  private var prev:Unit;
  private var next:Unit;
  
  public var name:String;
  
  public var scene:LDScene;
  
  public var componentCount(get, null):Int;
  
  public function new()
  {
    comps = new Array();
  }
  
  private inline function get_parent():Unit { return _parent; }
  private function set_parent(v:Unit):Unit
  {
    v.addChild(this);
    return v;
  }
  
  inline function get_componentCount():Int
  {
    return comps.length;
  }
  
  public function update():Void
  {
    if (_compDirty)
    {
      comps.sort(prioritySort);
      _compDirty = false;
    }
    for (c in comps) c.update();
    
    var child:Unit = children;
    while (child != null)
    {
      child.update();
      child = child.next;
    }
  }
  
  // Component workings
  
  public function add<T:Component>(c:T):T
  {
    if (c.owner != this)
    {
      if (c.owner != null) c.owner.remove(c);
      comps.push(c);
      c.owner = this;
      #if js
      if (c.type == null) c.type = ComponentType.Generic;
      #end
      c.added();
      _compDirty = true;
      if (parent != null) c.unitAdded();
      if (scene != null) c.sceneAdded();
    }
    return c;
  }
  
  private static function prioritySort(a:Component, b:Component):Int
  {
    if (a.priority > b.priority) return -1;
    else return a.priority < b.priority ? 1 : 0;
  }
  
  public function remove<T:Component>(c:T):T
  {
    if (c.owner == this)
    {
      if (scene != null) c.sceneRemoved();
      if (parent != null) c.unitRemoved();
      c.removed();
      comps.remove(c);
      c.owner = null;
    }
    return c;
  }
  
  public function get<T:Component>(cl:Class<T>):T
  {
    var inst:T;
    for (comp in comps)
    {
      inst = Std.instance(comp, cl);
      if (inst != null) return inst;
    }
    return null;
  }
  
  // Children
  
  public function removeChild<T:Unit>(u:T):T
  {
    if (u.parent == this)
    {
      if (scene != null) u.sceneRemoved();
      u.removed();
      var prev:Unit = u.prev;
      var next:Unit = u.next;
      if (children == u) children = next;
      if (prev != null) prev.next = next;
      if (next != null) next.prev = prev;
      u.next = null;
      u.prev = null;
      u._parent = null;
      u.scene = null;
    }
    
    return u;
  }
  
  public function addChild<T:Unit>(u:T):T
  {
    if (u.parent != this)
    {
      if (u.parent != null) u.parent.removeChild(u);
      if (children != null)
        children.prev = u;
      u.next = children;
      u._parent = this;
      children = u;
      u.scene = scene;
      u.added();
      if (scene != null) u.sceneAdded();
    }
    return u;
  }
  
  private function sceneAdded():Void
  {
    for (c in comps) c.sceneAdded();
    var child:Unit = children;
    while (child != null)
    {
      child.scene = scene;
      child.sceneAdded();
      child = child.next;
    }
  }
  
  private function sceneRemoved():Void
  {
    for (c in comps) c.sceneRemoved();
    var child:Unit = children;
    while (child != null)
    {
      child.sceneRemoved();
      child.scene = null;
      child = child.next;
    }
  }
  
  private function removed():Void
  {
    for (c in comps) c.unitRemoved();
  }
  
  private function added():Void
  {
    for (c in comps) c.unitAdded();
  }
  
  public function dispose():Void
  {
    if (_parent != null) _parent.removeChild(this);
    for (c in comps)
    {
      c.removed();
      c.owner = null;
      c.dispose();
    }
    while (children != null)
    {
      children.dispose();
    }
    comps = new Array();
  }
  
}