## Grimoire
Grimoire is an add-on for [FFXI Windower](http://windower.net/). The purpose of Grimoire is to simplify spell selection for magic bursting. When a cast spell/helix command is sent to Grimoire, it determines the best elemental spell to cast based on the last skillchain it detected.

### Usage
When Grimoire detects a skillchain, it will send a message in chat indicating which skillchain was performed. If timers plug-in is installed, it'll create a countdown timer for the magic burst window. During the magic burst window, the caster can send a `cast spell` or `cast helix` command to let Grimoire decide which element is best. 

The logic behind Grimoire goes through the following checks:
* Is there any weather/storm? If so, is the weather/storm element in the skillchain? Cast that element.
* If no weather, is the current day's element in the skillchain? Cast that element.
* If no weather, or matching day element, go by elemental priority list for elements in the skillchain.

### Commands
`cast spell|helix [1-6]` - Casts a spell|helix at the provided tier.

Example - `cast spell 5` or `cast helix 2`

*Note: using a tier higher than what is available will not cast anything, e.g. `cast helix 3` will try to cast a tier III helix spell regardless if spell doesn't exist.*