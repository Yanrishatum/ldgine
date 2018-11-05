
import hxp.HXML;
import hxp.System;

class Build extends hxp.Script
{
  
  
  public function new()
  {
    super();
    
    System.mkdir("tools");
    
    var hxml = new HXML();
    
    hxml.lib("msignal");
    hxml.lib("yatl");
    hxml.lib("heaps");
    
    inline function fillOther()
    {
      hxml.lib("ldgine");
    }
    
    inline function fillSelf()
    {
      hxml.cp(".");
      hxml.cp("test");
    }
    
    switch (command)
    {
      case "tools":
        fillSelf();
        hxml.lib("hldx");
        hxml.main = "PartsDesigner";
        hxml.hl = "tools/partsdesigner.hl";
      case "setup":
        trace(this.workingDirectory);
    }
    
  }
  
}