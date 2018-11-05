package engine.components;

import hxd.Timer;
import yatl.Tween;

class TweenComponent extends Component
{
  
  private var tweens:Array<Tween>;
  
  public function new()
  {
    tweens = new Array();
  }
  
  override public function update()
  {
    var i = 0;
    while (i < tweens.length)
    {
      var t:Tween = tweens[i];
      t.update(Timer.elapsedTime);
      if (t.state == Idle || t.state == Finished) tweens.remove(tweens[i]);
      else i++;
    }
  }
  
  public function add(t:Tween, reset:Bool = true):Void
  {
    tweens.push(t);
    t.start(reset);
  }
  
}