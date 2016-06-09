## Grimoire
Grimoire is an add-on for [FFXI Windower](http://windower.net/). The purpose of Grimoire is to simplify spell selection for magic bursting. When a cast spell/helix command is sent to Grimoire, it determines the best elemental spell to cast based on the last skillchain it detected.

### Usage
When Grimoire detects a skillchain, it will send a message in chat indicating which skillchain was performed. If timers plug-in is installed, it'll create a countdown timer for the magic burst window. During the magic burst window, the caster can send a `cast` command to let Grimoire decide which element is best. 

The logic behind Grimoire goes through the following checks:
* Is there any weather/storm? If so, is the weather/storm element in the skillchain? Cast that element.
* If no weather, is the current day's element in the skillchain? Cast that element.
* If no weather, or matching day element, go by elemental priority list for elements in the skillchain.

### Commands
* `cast {TYPE} {TIER}`
  * `{TYPE}` argument:
    * `spell` - Casts a single target spell, e.g. Stone.
    * `helix` - Casts a helix spell, e.g. Geohelix.
    * `ga` - Casts a -ga AoE spell, e.g. Stonega.
    * `ja` - Casts a -ja AoE spell, e.g. Stoneja.
    * `ra` - Casts a -ra AoE spell, e.g. Stonera.
  * `{TIER}` argument:
    * `1-6` - The spell tier to cast, e.g. `3` would be III.

Examples 
* `grimoire cast spell 5`
* `grimoire cast helix 2`
* `grimoire cast ga 3`

*Note: using a tier higher than what is available, e.g. `cast helix 3`, will try to cast a tier III helix spell regardless if spell exists or not.*
