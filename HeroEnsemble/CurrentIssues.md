# Outstanding issues

 * [Bribe's Damage Detection Engine](https://www.hiveworkshop.com/threads/damage-engine-5-a-0-0.201016/)
 Due to current issues, see [here](https://www.hiveworkshop.com/threads/trying-to-implement-bribes-damage-engine-in-lua.369283/#post-3704305), some damage detection functionality is omitted from the map.
 In particular;
  * (Oni) Exploit Weakness applies a critical hit chance to ALL damage dealt by the Sword-Saint, when it should only function for normal attacks
  * (Oni) Guard currently treats melee and ranged attacks the same, when they should be differentiated.
 * (Astromancer) Silver Veil (dummy) buff ability icon is not properly hidden.

Until the above issue is resolved, the Lua version can't compete in functionality with older GUI/JASS versions (which didn't incur the same error(s)).
Short of rewriting a whole damage detection system in lua myself that is --- But if I felt that was a good idea, I wouldn't have tried using Bribe's in the first place...
