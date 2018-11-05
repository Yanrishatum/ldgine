package engine;

class Preloader
{
  
  public var onLoaded:Void->Void;
  
  public function load():Void
  {
    onLoaded();
  }
  
}