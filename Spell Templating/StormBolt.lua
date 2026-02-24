-- requires Chopinski missiles
-- requires StunUnit.lua
do
    --[[
    Simply the classic Storm Bolt ability from Human Mountain King hero, although this is based off of the Channel dummy.
    
    Damage is set here manually to 100/200/300
    
    The only editor object value left, which wouldn't affect how the spell works, is "art duration."
    But if you want, that value could be used to mod damage.
    This is also where you would add any additional scaling, e.g. bonus damage per Strength.
    ]]--

    local StormBoltSpellObj = Spell:Create("___", "unit") -- input object-editor ability id here (replace "____")
    local function stormboltcast()
        -- early return if wrong spell
        if GetSpellAbilityId() ~= StormBoltSpellObj.id then
            return
        end

        -- ability stats
        local this = DragonsBreathSpellObj:NewInstance()
        local dmg = 100 * (this.alv+1)
        -- local dmg = GetAbilityField(StormBoltSpellObj.id, "artdur",this.alv) -- use "art duration" real as damage stat.
        
        -- ability missile
        local hammer = Missiles:create(this.cast_x, this.cast_y, 50, this.targ_x, this.targ_y, GetUnitFlyHeight(this.target) + 50)
        hammer:model("Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl" )
        hammer:speed(800)
        hammer.target = this.target
        
        hammer.onFinish = function()
            if UnitAlive(hammer.target) then
                if IsUnitType(hammer.target, UNIT_TYPE_HERO) then
                    StunTarget(hammer.target, this.caster, this.herodur)
                else
                    StunTarget(hammer.target, this.caster, this.normaldur)
                end
                UnitDamageTarget(this.caster, hammer.target, dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, nil)
            end
            return true
        end

        hammer:launch()
    end
    DragonsBreathSpellObj:MakeTrigger(dbcast)
end