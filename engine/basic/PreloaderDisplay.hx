package engine.basic;

interface PreloaderDisplay
{
  
  function show():Void;
  function setTotalProgress(v:Float):Void;
  function setLocalProgress(v:Float):Void;
  function setEntryName(v:String):Void;
  function hide():Void;
  function update():Void;
  
}