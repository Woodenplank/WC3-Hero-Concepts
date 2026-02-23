-- Uses chopinski missile system
do 
    local bm = Missile:create()
    local function bm_missile(params)
        local x1 = params.x1 or 0
        local y1 = params.y1 or 0
        local x2 = params.x2 or 0
        local y2 = params.y2 or 0
        local owner = params.owner or nil
        local bm = Missiles:create(x1, y1, 0, x2, y2, 0)
        
        function bm:bounce()
        end
        bm:bounces = 0
        bm:max_bounces = params.bounces or 1

        bm:model("....")
        bm:speed(450)
        --bm:arc(math.random()*45)
        bm:arc(35)
        bm.source = owner
        
        bm.onFinish = function()

-----------------
            if UnitAlive(bm.target) then
                UnitDamageTarget(bm.source, bm.target, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, nil)
            end
------------------


            if bm.bounces == bm.max_bounces then
                return true
            else
                bm.bounces = bm.bounces+1
                return false
                --+++ redirect
            end
        end
        
        bm:launch()
    end


    local function do_barrage()

end