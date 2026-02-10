# Hero Ensemble Outstanding issues

 * [Bribe's Damage Detection Engine](https://www.hiveworkshop.com/threads/damage-engine-5-a-0-0.201016/)
 Due to current issues, see [here](https://www.hiveworkshop.com/threads/trying-to-implement-bribes-damage-engine-in-lua.369283/#post-3704305), I'm using my own "light-weight" damage system.

Until the above issue is resolved, the Lua version can't compete in functionality with older GUI/JASS versions (which didn't incur the same error(s)).
Short of rewriting a whole damage detection system in lua myself that is --- But if I felt that was a good idea, I wouldn't have tried using Bribe's in the first place...


 Otherwise...
 * (Hellion) Emberstorm will spawn fiery tornadoes even without activating the associated Hellforge upgrade.
 * (Hellion x DamageSystem) preventing lethal damage with Dark Pact doesn't work.
 * (Sword-Saint) Passion/Dispassion of a Saint doesn't always properly swap upon activation.
 * (Astromancer) Arcane Almanac (dummy) buff ability icon is not properly hidden.
 * Type-checking in the Spell-Template causes WC3 to ctd on load. Lack of error message makes this a tad harder to fix. Investigate.

## Future plans:
* Centralize all object editor data in a single document, and define the IDs there.
Whenever reference must be made, use the variable rather than a literal reference.
Should make it easier to root out copy'ing mistakes and (potentially) export to other maps
* As long as its included in the map code prior to any of the triggers or "helper" functions that rely on it, should be fine.
Be careful with global functions like SHhammermod for Hellion. It's not a trigger, therefore not created "at map initialization" but it still relies on defined object variables.
