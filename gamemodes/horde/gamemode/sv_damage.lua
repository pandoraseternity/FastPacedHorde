local plymeta = FindMetaTable("Player")
local entmeta = FindMetaTable("Entity")

HORDE.DMG_CALCULATED = 1
HORDE.DMG_OVER_TIME = 3
HORDE.DMG_SPLASH = 2
HORDE.DMG_PLAYER_FRIENDLY = -3
HORDE.DMG_PARASITE = 4

-- Player damage.
function HORDE:ApplyDamage(npc, hitgroup, dmginfo)
    if dmginfo:GetDamageCustom() > 0 then return end
    if dmginfo:GetDamage() <= 0 then return end
    if not npc:IsValid() then return end
    --if GetConVar("horde_corpse_cleanup"):GetInt() == 1 and npc:Health() <= 0 then npc:Remove() return end

    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) then return end

    if attacker:GetNWEntity("HordeOwner"):IsPlayer() then
        dmginfo:SetInflictor(attacker)
        dmginfo:SetAttacker(attacker:GetNWEntity("HordeOwner"))
    end

    if IsValid(attacker:GetOwner()) and attacker:GetOwner():IsPlayer() then
        dmginfo:SetAttacker(attacker:GetOwner())
    end

    local ply = dmginfo:GetAttacker()
    if not ply:IsPlayer() then return end

    local increase = 0
    local more = 1
    local base_add = 0
    local post_add = 0
    --dmginfo:SetDamage(1000)
    --npc:Horde_AddDebuffBuildup(HORDE.Status_Stun, dmginfo:GetDamage() * 10, ply, dmginfo:GetDamagePosition())

    -- Apply bonus
    local bonus = {increase=increase, more=more, base_add=base_add, post_add=post_add}
    if ply:Horde_GetCurrentSubclass() == "Gunslinger" then
        local wpn = HORDE:GetCurrentWeapon(dmginfo:GetInflictor())
        if IsValid(wpn) then
            -- Currently only applies to Gunslinger
            local level = ply:Horde_GetUpgrade(wpn:GetClass())
            if level and level > 0 then
                if HORDE.items[wpn:GetClass()].starter_classes then
                    -- Bonus damage to starter weapons
                    bonus.more = bonus.more * (1 + 0.1 * level)
                else
                    bonus.more = bonus.more * (1 + 0.03 * level)
                end
            end
        end
    end
    local res = hook.Run("Horde_OnPlayerDamagePre", ply, npc, bonus, hitgroup, dmginfo)
    if res then
        dmginfo:AddDamage(bonus.base_add)
        dmginfo:ScaleDamage(bonus.more * (1 + bonus.increase))
        dmginfo:AddDamage(bonus.post_add)
        dmginfo:SetDamageCustom(HORDE.DMG_CALCULATED)
        if hitgroup == HITGROUP_HEAD then
            sound.Play("horde/player/headshot.ogg", npc:GetPos())
        end
        return
    end
    hook.Run("Horde_OnPlayerDamage", ply, npc, bonus, hitgroup, dmginfo)
    if dmginfo:GetInflictor():GetNWEntity("HordeOwner"):IsPlayer() or dmginfo:GetAttacker():GetNWEntity("HordeOwner"):IsPlayer() then
        hook.Run("Horde_OnPlayerMinionDamage", ply, npc, bonus, dmginfo)
    end

    -- DMG_BURN for some reason does not apply, convert this to something else
    if dmginfo:GetInflictor():GetClass() == "entityflame" then
        dmginfo:SetDamagePosition(npc:GetPos())
        dmginfo:SetDamage(npc:Horde_GetIgniteDamageTaken())
    else
        if dmginfo:GetDamageType() == DMG_BURN then
            dmginfo:SetDamageType(DMG_SLOWBURN)
            if ply:Horde_GetGadget() ~= "gadget_hydrogen_burner" then
                npc:Horde_SetMostRecentFireAttacker(ply, dmginfo)
                npc:Ignite(ply:Horde_GetApplyIgniteDuration())
            end
        elseif ply:Horde_GetApplyIgniteChance() > 0 then
            local ignite = math.random()
            if ignite <= ply:Horde_GetApplyIgniteChance() then
                if ply:Horde_GetGadget() ~= "gadget_hydrogen_burner" then
                    npc:Horde_SetMostRecentFireAttacker(ply, dmginfo)
                    npc:Ignite(ply:Horde_GetApplyIgniteDuration())
                end
            end
        end
    end

    dmginfo:AddDamage(bonus.base_add)
    dmginfo:ScaleDamage(bonus.more * (1 + bonus.increase))
    dmginfo:AddDamage(bonus.post_add)
    dmginfo:SetDamageCustom(HORDE.DMG_CALCULATED)

    -- Vortigaunt damage
    if HORDE:IsLightningDamage(dmginfo) and dmginfo:GetInflictor():GetClass() == "npc_vortigaunt" then
        -- Splash damaage
        local dmg = DamageInfo()
        dmg:SetAttacker(dmginfo:GetAttacker())
        dmg:SetInflictor(dmginfo:GetInflictor())
        dmg:SetDamageType(DMG_PLASMA)
        dmg:SetDamage(dmginfo:GetDamage())
        dmg:SetDamageCustom(HORDE.DMG_SPLASH)
        util.BlastDamageInfo(dmg, dmginfo:GetDamagePosition(), 250)
    end

    -- Play sound
    if hitgroup == HITGROUP_HEAD then
        sound.Play("horde/player/headshot.ogg", npc:GetPos(), 150)
    end

    hook.Run("Horde_OnPlayerDamagePost", ply, npc, bonus, hitgroup, dmginfo)
    
    if not npc.Horde_Assist then
        npc.Horde_Assist = ply
    elseif ply ~= npc.Horde_Hit then
        npc.Horde_Assist = npc.Horde_Hit
    end

    npc.Horde_Hit = ply
end

function entmeta:TakeDamageOverTime(attacker, dmg, dmgtype, interval, duration)
    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(attacker)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamageType(dmgtype)
    dmginfo:SetDamage(dmg)
    dmginfo:SetDamageCustom(HORDE.DMG_OVER_TIME)
    dmginfo:SetDamagePosition(self:GetPos())

    self:TakeDamageInfo(dmginfo)
    for i = 1, duration / interval do
        timer.Simple(interval * i, function()
            if self:IsValid() then
                local dmginfo2 = DamageInfo()
                dmginfo2:SetAttacker(attacker)
                dmginfo2:SetInflictor(Entity(0))
                dmginfo2:SetDamageType(dmgtype)
                dmginfo2:SetDamage(dmg)
                dmginfo2:SetDamageCustom(HORDE.DMG_OVER_TIME)
                dmginfo2:SetDamagePosition(self:GetPos())
                self:TakeDamageInfo(dmginfo2)
            end
        end)
    end
end

function HORDE:ApplyDamageInRadius(pos, radius, dmginfo, callback)
    for _, ent in pairs(ents.FindInSphere(pos, radius)) do
        if ent:IsNPC() and HORDE:IsPlayerOrMinion(ent) ~= true then
            dmginfo:SetDamagePosition(ent:GetPos())
            ent:TakeDamageInfo(dmginfo)
            if callback then
                callback(ent)
            end
        end
    end
end

function HORDE:DamageInfo(damage, dmgtype, attacker, inflictor, damage_custom)
    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(attacker)

    if inflictor then
        dmginfo:SetInflictor(inflictor)
    else
        dmginfo:SetInflictor(attacker)
    end

    if dmgtype then
        dmginfo:SetDamageType(dmgtype)
    else
        dmginfo:SetDamageType(DMG_GENERIC)
    end
    dmginfo:SetDamage(damage)
    if damage_custom then
        dmginfo:SetDamageCustom(damage_custom)
    end
    return dmginfo
end

function HORDE:TakeDamage(victim, damage, dmgtype, attacker, inflictor, damage_custom)
    local dmginfo = DamageInfo()
    if attacker then
        dmginfo:SetInflictor(attacker)
    else
        dmginfo:SetInflictor(Entity(0))
    end

    if inflictor then
        dmginfo:SetInflictor(inflictor)
    else
        dmginfo:SetInflictor(Entity(0))
    end
    
    dmginfo:SetDamagePosition(victim:GetPos())
    
    if dmgtype then
        dmginfo:SetDamageType(dmgtype)
    else
        dmginfo:SetDamageType(DMG_GENERIC)
    end
    dmginfo:SetDamage(damage)
    if damage_custom then
        dmginfo:SetDamageCustom(damage_custom)
    end
    victim:TakeDamageInfo(dmginfo)
end

hook.Add("EntityTakeDamage", "Horde_DamageRedirection", function (target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) then return end
    if not HORDE:IsEnemy(target) then return end

    if attacker:GetClass() == "entityflame" then
        if target:Horde_GetMostRecentFireAttacker() then
            dmginfo:SetAttacker(target:Horde_GetMostRecentFireAttacker())
        end
    elseif HORDE:IsPlayerMinion(attacker) then
        dmginfo:SetInflictor(attacker)
        dmginfo:SetAttacker(attacker:GetNWEntity("HordeOwner"))
    elseif IsValid(attacker:GetOwner()) and attacker:GetOwner():IsPlayer() then
        dmginfo:SetAttacker(attacker:GetOwner())
    end

    if dmginfo:GetAttacker():IsPlayer() then
        HORDE:ApplyDamage(target, HITGROUP_GENERIC, dmginfo)
    end
end)

-- Seems like ScaleNPCDamage is called before EntityTakeDamage.
hook.Add("ScaleNPCDamage", "Horde_ApplyDamage", function (npc, hitgroup, dmginfo)
    if (not HORDE:IsPlayerMinion(npc)) then
        HORDE:ApplyDamage(npc, hitgroup, dmginfo)
    end
end)

-- Player damage taken
hook.Add("EntityTakeDamage", "Horde_ApplyDamageTaken", function (target, dmg)
    if not target:IsValid() or not target:IsPlayer() then return end
    if dmg:GetDamageCustom() ~= 0 then return true end
    local ply = target

    if dmg:GetAttacker():IsPlayer() and (dmg:GetInflictor() == dmg:GetAttacker()) then return true end

    -- Prevent damage from skill explosions (e.g. Rip and Tear, Chain Reaction, Kamikaze)
    if dmg:GetInflictor():IsNPC() and dmg:GetAttacker():IsPlayer() then return true end
    
    -- Prevent minion from damaging players
    if (IsValid( dmg:GetInflictor() ) and HORDE:IsPlayerMinion(dmg:GetInflictor()) )or (IsValid( dmg:GetAttacker() ) and HORDE:IsPlayerMinion(dmg:GetAttacker())) then return true end
    
    if dmg:GetDamage() <= 0.5 then return true end
	
    if HORDE:IsBlastDamage(dmg) and dmg:GetAttacker():IsPlayer() then
		--print("poop")
        dmg:ScaleDamage(0.5)
    end
    
    -- Apply bonus
    local bonus = {resistance=0, less=1, evasion=0, block=0}
    local ret = hook.Run("Horde_OnPlayerDamageTaken", ply, dmg, bonus)
    if ret then return end
    if bonus.evasion > 0 then
        local evade = math.random()
        if evade <= bonus.evasion then
            ply:EmitSound("horde/player/evade.ogg", 125, 100, 1, CHAN_AUTO)
            hook.Run("Horde_OnPlayerEvade", ply, dmg)
            return true
        end
    end
    if bonus.resistance >= 1.0 then return true end

    if ply.Horde_Special_Armor then
        local armor = ply.Horde_Special_Armor
        local dmgtype = dmg:GetDamageType()
        if armor == "armor_assault" then
            if HORDE:IsBallisticDamage(dmg) then
                bonus.resistance = bonus.resistance + 0.08
            end
        elseif armor == "armor_heavy" then
        elseif armor == "armor_medic" then
            if HORDE:IsPoisonDamage(dmg) then
                bonus.resistance = bonus.resistance + 0.08
            end
        elseif armor == "armor_demolition" then
            if HORDE:IsBlastDamage(dmg) then
                bonus.resistance = bonus.resistance + 0.08
            end
        elseif armor == "armor_ghost" then
            bonus.evasion = bonus.evasion + 0.05
        elseif armor == "armor_engineer" then
            bonus.resistance = bonus.resistance + 0.05
        elseif armor == "armor_warden" then
            if HORDE:IsLightningDamage(dmg) then
                bonus.resistance = bonus.resistance + 0.08
            end
        elseif armor == "armor_cremator" then
            if HORDE:IsFireDamage(dmg) then
                bonus.resistance = bonus.resistance + 0.08
            end
        elseif armor == "armor_berserker" then
            if dmgtype == DMG_SLASH or dmgtype == DMG_CLUB then
                bonus.resistance = bonus.resistance + 0.08
            end
        elseif armor == "armor_survivor" then
            bonus.resistance = bonus.resistance + 0.05
        end
    end

    dmg:ScaleDamage(bonus.less * (1 - bonus.resistance))
    dmg:SubtractDamage(bonus.block)

    if dmg:GetDamage() <= 0.5 then return true end

    hook.Run("Horde_OnPlayerDamageTakenPost", ply, dmg, bonus)

    local more = 1
    local debuff = nil
    if dmg:GetDamage() > 0 then
        if HORDE:IsPoisonDamage(dmg) then
            debuff = HORDE.Status_Break
            more = 2
        elseif HORDE:IsFireDamage(dmg) then
            debuff = HORDE.Status_Ignite
            more = 2
        elseif HORDE:IsLightningDamage(dmg) then
            debuff = HORDE.Status_Shock
            more = 2
        elseif HORDE:IsColdDamage(dmg) then
            debuff = HORDE.Status_Frostbite
            more = 2
            local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos() + ply:GetUp() * 50)
                effectdata:SetScale(10)
                effectdata:SetMagnitude(10)
		    util.Effect("GlassImpact", effectdata, true, true)
		    util.Effect("GlassImpact", effectdata, true, true)
        elseif dmg:IsDamageType(DMG_DISSOLVE) then
            debuff = HORDE.Status_Necrosis
            more = 2
        end

        if not debuff then return end

        local buildup = dmg:GetDamage() * more
        local class = dmg:GetAttacker():GetClass()
        if class == "npc_headcrab_poison" or class == "npc_headcrab_black" then
            dmg:SetDamage(1)
            if debuff == HORDE.Status_Break then
                buildup = ply:Health() * 2
            end
        else
            buildup = math.min(85, buildup)
        end
        ply:Horde_AddDebuffBuildup(debuff, buildup, dmg:GetAttacker())
    end
end)

hook.Add("EntityTakeDamage", "Horde_ApplyMinionDamageTaken", function (target, dmg)
    if not target:IsValid() or not HORDE:IsPlayerMinion(target) then return end
    if dmg:GetAttacker():IsPlayer() then return true end
    hook.Run("Horde_OnMinionDamageTaken", target, dmg)
    if dmg:GetDamage() <= 0.5 then return true end

    --if dmg:GetAttacker():GetClass() == "npc_vj_horde_grigori" or dmg:GetAttacker().Horde_Plague_Soldier then
        --dmg:ScaleDamage(2.5) --WHY THE FUCK IS THIS HERE??
    --end

    local debuff = nil
    local bonus = {more = 1}
    if dmg:GetDamage() > 0 then
        if HORDE:IsPoisonDamage(dmg) then
            debuff = HORDE.Status_Break
            bonus.more = 2
        elseif HORDE:IsFireDamage(dmg) then
            debuff = HORDE.Status_Ignite
            bonus.more = 2
        elseif HORDE:IsLightningDamage(dmg) then
            debuff = HORDE.Status_Shock
            bonus.more = 2
        elseif HORDE:IsColdDamage(dmg) then
            debuff = HORDE.Status_Frostbite
            bonus.more = 2
            local effectdata = EffectData()
                effectdata:SetOrigin(target:GetPos() + target:GetUp() * 50)
                effectdata:SetScale(10)
                effectdata:SetMagnitude(10)
		    util.Effect("GlassImpact", effectdata, true, true)
		    util.Effect("GlassImpact", effectdata, true, true)
        end

        if not debuff then return end

        local buildup = dmg:GetDamage() * bonus.more
        local class = dmg:GetAttacker():GetClass()
        if class == "npc_headcrab_poison" or class == "npc_headcrab_black" then
            dmg:SetDamage(1)
            if debuff == HORDE.Status_Break then
                buildup = target:Health() * 2
            end
        else
            buildup = math.min(85, buildup)
        end
        target:Horde_AddDebuffBuildup(debuff, buildup)
    end
end)

-- Enemy damage.
hook.Add("EntityTakeDamage", "Horde_MutationDamage", function (target, dmg)
    if target:IsValid() and target:IsNPC() and dmg:GetInflictor():IsWorld() and dmg:GetAttacker():IsNPC() then
        return true
    end
end)

hook.Add("Horde_OnPlayerDamageTaken",  "Horde_MeteorDefense", function (ply, dmginfo, bonus)
    if ply:Horde_GetMaxMind() > 0 and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "projectile_horde_meteor" then
        if dmginfo:IsDamageType(DMG_BLAST) then
            dmginfo:SetDamage(math.min(10, dmginfo:GetDamage()))
            dmginfo:SetDamageType(DMG_DIRECT)
        else
            dmginfo:SetDamage(math.min(70, dmginfo:GetDamage()))
            dmginfo:SetDamageType(DMG_DIRECT)
        end
	elseif IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "weapon_hl1_gauss" then
		--if dmginfo:IsDamageType(DMG_BLAST) then
            dmginfo:SetDamage(math.min(10, dmginfo:GetDamage()))
            dmginfo:SetDamageType(DMG_DIRECT)
		--end
		
    end
end)

-- Main target does not take splash damage
hook.Add("EntityTakeDamage", "Horde_SplashDamage", function (target, dmg)
    if target:IsValid() and target:IsNPC() and dmg:GetInflictor() == target and dmg:GetAttacker():IsPlayer() and dmg:GetDamageCustom() == HORDE.DMG_SPLASH then
        return true
    end
end)

-- Boss headshot multiplier reduction
hook.Add("ScaleNPCDamage", "Horde_BossHeadshotDamage", function (npc, hitgroup, dmg)
    if npc:IsValid() and npc:Horde_GetBossProperties() and hitgroup == HITGROUP_HEAD then
        dmg:ScaleDamage(1)
    end
end)

--Controls limb damage multipliers relative to default limb damage multipliers for weapon types and NPC/Minion damage
local HitGroups = { -- https://wiki.facepunch.com/gmod/Enums/HITGROUP
    [0] = 1, -- Generic, aka other
    [1] = 1, -- Head
    [2] = 1, -- Chest
    [3] = 1, -- Stomach
    [4] = 1, -- Left Arm
    [5] = 1, -- Right Arm
    [6] = 1, -- Left Leg
    [7] = 1, -- Right Leg
    [10] = 1, -- Gear(?), Somewhere near belt
}
local MeleeHitGroups = { -- Also used for Minion damage to ignore limb multipliers
    [0] = 1, -- Generic, aka other
    [1] = 1, -- Head
    [2] = 1, -- Chest
    [3] = 1, -- Stomach
    [4] = 4, -- Left Arm    -- 25% * 4 = 100% damage vs limb
    [5] = 4, -- Right Arm
    [6] = 4, -- Left Leg
    [7] = 4, -- Right Leg
    [10] = 1, -- Gear(?), Somewhere near belt
}
hook.Add("ScaleNPCDamage", "Horde_Locational_Damage", function(npc, hitgroup, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if (!IsValid(attacker)) then return end
    if (attacker:IsPlayer() and not attacker:GetActiveWeapon().Horde_Use_Locational_DMG) --[[or not (attacker.Horde_Use_Locational_DMG)]] then return end
    local scale = HitGroups[hitgroup] || 1
    if attacker:IsPlayer() and not HORDE:IsPlayerMinion(attacker) then --Player damage and not minion damage
        --[[
        if HORDE:IsCurrentWeapon(dmginfo, "Melee") == true then --Melee damage
            scale = MeleeHitGroups[hitgroup] || 1
        end
        ]]
    elseif HORDE:IsPlayerMinion(attacker) then --Minion damage
        scale = MeleeHitGroups[hitgroup] || 1
    else
        scale = 1 --Scale nothing
    end
    dmginfo:ScaleDamage(scale)
end)


-- New dank explosion code
--[[
    <entity> attacker = attacker
    <vector> origin = position for damage
    <int> radius = radius
    <int> falloffradius = minimum distance for damage to start decreasing
    <int> damage = damage
    <int> damagetype = Damage type, https://wiki.facepunch.com/gmod/Enums/DMG
    <float> basedamagemul = base damage multiplier

    <string> fallofftype = Damage falloff mode
        instant : Only uses base damage when target's distance > min distance
        linear : It explains itself
        linear_inverted : It explains itself

    <float> falloff_speed = Damage falloff speed
    <int> falloff_cap = Damage falloff cap
    <bool> ignoreattacker = Ignore the attacker
]]
local defaults = { -- Default variables
    radius = 100,
    falloffradius = 0,
    falloff_cap = 0,
    damage = 100,
    basedamagemul = 0,
    fallofftype = "linear",
    falloff_speed = 1,
    ignoreattacker = false,
    origin = Vector(0, 0, 0),
    damagetype = 64, -- DMG_BLAST
    damagecustomtype = nil
}
function HORDE.RadiusDamageExtra(data)
    if(!data || !IsValid(data.attacker)) then return end -- check is data table and attacker is valid or not
    for k,v in pairs(defaults) do -- apply default variables so it won't error out when you didn't enter it

        --[[
            k = key
            v = value

            e.x
                defaults = { -- This is a table
                    radius = 100, -- radius is key, 100 is value
                }

            if you pay attention at both data table and defaults table, they have same keys, we can use it to validate the values in the key we wanted
        ]]

        if(data[k]) then continue end -- If value is valid then skip it
        data[k] = v -- Apply the default value to data table if it's invalid, so you don't have to enter every single key
    end

    -- local variables will be faster than table-lookup in the for loop
    local attacker = data.attacker
    local inflictor = data.inflictor -- || attacker
    --if(attacker:IsPlayer() && IsValid(attacker:GetActiveWeapon())) then inflictor = attacker:GetActiveWeapon() end
    local radius = data.radius
    local fradius = data.falloffradius
    local fradius_min = math.max(radius - fradius, 0)
    if(fradius_min == 0) then -- Prevent math.huge(infinite) when dividing
        fradius_min = 1
    end
    local dmg = data.damage
    local dmgtype = data.damagetype
    local basedmg_scale = data.basedamagemul
    local ftype = data.fallofftype
    local fscale = data.falloff_speed
    local fcap = data.falloff_cap
    local skip_attacker = data.ignoreattacker

    local pos = data.origin
    local dmgcustom = data.damagecustomtype

    local base_dmg = dmg * basedmg_scale
    local scalable_dmg = dmg * math.max(1 - basedmg_scale, 0) -- Just in case if you got basedmg_scale > 1

    for _, ent in pairs(ents.FindInSphere(pos, radius)) do
        if(skip_attacker && ent == attacker) then continue end
        local dst = ent:GetPos():Distance(pos)
        if(dst > radius) then continue end -- Sometimes it returns entities with incorrect distance, filte it out
        local sData = {
            checkmode = 2,
            originVector = pos,
            targetEntity = ent,
            advancedCheck = true,
        }
        if(!HORDE.IsInSight(sData)) then continue end
        local dmginfo = DamageInfo()
            dmginfo:SetAttacker(attacker)
            dmginfo:SetInflictor(inflictor)
            dmginfo:SetDamagePosition(ent:GetPos())
            dmginfo:SetDamageType(dmgtype)
            if dmgcustom then
                dmginfo:SetDamageCustom(dmgcustom)
            end

        if(dst <= fradius) then
            dmginfo:SetDamage(dmg)

            ent:TakeDamageInfo(dmginfo)
        else
            local newdst = dst - fradius
            local scale = (newdst / fradius_min) / fscale
            local sdmg = scalable_dmg
            if(ftype == "instant") then
                sdmg = 0
            elseif(ftype == "linear") then
                sdmg = sdmg * (1 - scale)
            elseif(ftype == "linear_inverted") then
                sdmg = sdmg * scale
            end
            dmginfo:SetDamage(math.max(base_dmg + sdmg, fcap))

            ent:TakeDamageInfo(dmginfo)
        end
    end
end
