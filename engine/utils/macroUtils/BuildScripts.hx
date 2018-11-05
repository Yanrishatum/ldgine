package engine.utils.macroUtils;

import haxe.macro.Context;
import haxe.macro.Type;
// import haxe.macro.Context;
// import haxe.macro.Compiler;
import haxe.macro.Expr;

class BuildScripts
{
  
  public static macro function dispatchSignal(callExpr:Expr):Expr
  {
    return macro {
      var slot = this.head, tmp;
      while (slot != null)
      {
        $callExpr
        if (slot.once)
        {
          tmp = slot.next;
          slot.remove();
          slot = tmp;
        }
        else slot = slot.next;
      }
    }
  }
  
}