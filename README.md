# GMacros

*GMacros* is a collection of slash commands, some of which use CleverMacro's recreation of WoW 2.0 syntax. CleverMacro is a required dependency. These commands and conditionals are not valid in retail WoW. Many of the slash commands have nothing to do with CleverMacro, so this is not strictly a CleverMacro extension, but also a collection of macros that I like to use, turned into slash commands.

### Current features

* Additional slash commands
* More conditionals

### Implemented conditionals

* *distance*, *dist*

All conditionals can be prefixed with "no" to negate the result.

These conditionals are not valid in retail WoW.

### Implemented or adapted commands

* /autoshot

* /safetarget
* /togglesafetarget

* /feedpet
* /petfood

* /petattack
* /petfollow
* /togglepetattack

* /setassist
* /clearassist
* /assistpreset

* /unbuff

### Documentation

#### slash commands

##### /autoshot
a mashable autoshotcommand
```
/autoshot
```

##### /petfood
sets the specified food to feed to your pet
```
/petfood Roasted Quail
```

##### /feedpet
feeds your pet the food set with /petfood
```
/feedpet
```
or specify it manually in the command:
```
/feedpet Roasted Quail
```

##### /setassist
sets an assist target to use with /assistpreset (does not persist through sessions):
```
/setassist Rexxar
```
or while targeting your assist:
```
/setassist
```

##### /assistpreset
assists the target specified with /setassist
```
/assistpreset
```

##### /safetarget
cancels everything after /safetarget if no target is selected
good for avoiding accidental pulls with abilities that automatically target the nearest target if no target is selected:
```
/safetarget
/petattack
/autoshot
```

##### /unbuff
removes the first buff found with the specified buff texture
useful for WoW vanilla builds that do not auto dismount, also useful for tanks who need to unbuff Blessing of Salvation
```
/unbuff inv_pet_speedy
```

#### conditionals

##### [distance]
conditional that evaluates according to distance from target
* 1 = 9.9 yards
* 2 = 11.11 yards
* 3 = 9.9 yards
* 4 = 28 yards
 (due to a bug in the WoW Vanilla API, both 1 and 3 are 9.9 yards)
```
#showtooltip
/cast [distance:one] Wing Clip; Concussive Shot
```
or
```
#showtooltip
/cast [dist:1] Wing Clip; Concussive Shot
```