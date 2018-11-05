package engine.components;

enum abstract ComponentType(Int) from Int to Int
{
  var Generic = 0;
  var Graphics = 1;
  var Graphics3D = 2;
  var Sound = 3;
  var Custom = 4;
  
  inline static function makeCustom(id:Int):ComponentType
  {
    return id + Custom;
  }
  
}