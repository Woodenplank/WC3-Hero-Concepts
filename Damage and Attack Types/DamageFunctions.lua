GetEventDamage()
GetEventDamageSource()      -- the unit dealing damage for EVENT_UNIT_DAMAGED
BlzGetEventDamageTarget()   -- returns the same as GetTriggerUnit() for EVENT_UNIT_DAMAGED
BlzSetEventDamage()
    --[[    https://lep.nrw/jassbot/doc/BlzSetEventDamage
    In 1.31 PTR there’s currently 3 new damage events:

        1. EVENT_UNIT_DAMAGED          - old classic event for a specific unit;

        2. EVENT_PLAYER_UNIT_DAMAGED   - Same as 1, but for all units of a specific player on the map;

        // This seems to work fine anyway:
            TriggerRegisterAnyUnitEventBJ(gg_trg_a, EVENT_PLAYER_UNIT_DAMAGING)

        3. EVENT_UNIT_DAMAGING         - triggers before any armor, armor type and other resistances. Event for a specific unit like 1.
        4. EVENT_PLAYER_UNIT_DAMAGING  - triggers before any armor, armor type and other resistances. 
                                         Useful to modify either damage amount, attack type or damage type before any reductions done by game.

    1 and 2 - modify the damage after any reduction. 
    3 and 4 - changes damage before reduction. Amount you set will be reduced later according to target’s resistance, armor etc.

    • If set to <=0 during 3 or 4, then 1 or 2 will never fire. 
    • Misses don’t trigger any damage events. 
    • Set to 0.00 to completely block the damage. 
    • Set to negative value to heal the target instead of damaging.
    ]]

ConvertDamageType(i)    -- Returns the damagetype that corresponds to the given integer.
BlzGetEventDamageType() -- Returns damagetype of the damage being taken. Regular attack is DAMAGE_TYPE_NORMAL.
BlzSetEventDamageType() -- Set the damagetype of a damage being taken. Can be only used to change damagetype before armor reduction.
