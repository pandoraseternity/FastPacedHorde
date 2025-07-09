PERK.PrintName = "Medic Base"
PERK.Description = [[
The Medic class is a durable support class that focuses on healing and buffing teammates.
Complexity: MEDIUM

Amplifies healing by {1}. ({2} per level, up to {3}).

Regenerate {4} health per second.

SHIFT+E to shoot out healing darts.]]
PERK.Params = {
    [1] = {percent = true, level = 0.008, max = 0.20, classname = HORDE.Class_Medic},
    [2] = {value = 0.008, percent = true},
    [3] = {value = 0.20, percent = true},
    [4] = {value = 0.01, percent = true},
}

PERK.Hooks = {}
PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "medic_base" then
        ply:Horde_SetHealthRegenPercentage(0.01)
        ply:Horde_SetPerkCooldown(1)
        net.Start("Horde_SyncActivePerk")
        net.WriteUInt(HORDE.Status_Needles, 8)
        net.WriteUInt(1, 3)
        net.Send(ply)
        HORDE:CheckDarts(ply)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "medic_base" then
        ply:Horde_SetHealthRegenPercentage(0)
        net.Start("Horde_SyncActivePerk")
        net.WriteUInt(HORDE.Status_Needles, 8)
        net.WriteUInt(0, 3)
        net.Send(ply)
        ply:Horde_SetPerkCharges(1)
    end
end

PERK.Hooks.Horde_UseActivePerk = function (ply)
    if not ply:Horde_GetPerk("medic_base") then return end
    if ply:Horde_GetPerkCharges() <= 0 then
        return true
    end

    if ply:Horde_GetSpamPerkCooldown() > CurTime() then return true end
    ply:Horde_SetSpamPerkCooldown(CurTime() + 0.25)
    local id = ply:SteamID()
	
    local max_charges = 1
    if ply:Horde_GetPerk("medic_antibiotics") then
         max_charges = max_charges + 2
   end
    if ply:Horde_GetPerk("medic_cellular_implosion") then
        max_charges = max_charges + 2
    end
    ply:Horde_SetPerkCharges(ply:Horde_GetPerkCharges() - 1)
    
    timer.Remove("Horde_Needle_recovery" .. id)
    timer.Create("Horde_Needle_recovery" .. id, 2, 0, function ()
        if !ply:IsValid() or (not ply:Horde_GetPerk("medic_base")) then timer.Remove("Horde_Needle_recovery" .. id) return end
        if ply:Horde_GetPerkCharges() >= max_charges then timer.Remove("Horde_Needle_recovery" .. id) return end
        ply:Horde_SetPerkCharges(math.min(max_charges, ply:Horde_GetPerkCharges() + 1))
    end)
	
	ply:EmitSound("horde/weapons/mp7m/heal.ogg", 125, 100, 1, CHAN_AUTO)
    local tr = util.TraceLine(util.GetPlayerTrace(ply))
    if tr.Hit then
        local effectdata = EffectData()
        effectdata:SetOrigin(tr.HitPos)
        effectdata:SetRadius(90)
        util.Effect("horde_heal_mist", effectdata)

        local attacker = self

        if ply:IsValid() then
            attacker = ply
        end
	if SERVER then
        for _, ent in pairs(ents.FindInSphere(tr.HitPos, 90)) do
            if ent:IsPlayer() then
				--if ent == ply then return end
                local healinfo = HealInfo:New({amount=20, healer=ply})
                HORDE:OnPlayerHeal(ent, healinfo)
            elseif ent:GetClass() == "npc_vj_horde_antlion" then
                local healinfo = HealInfo:New({amount=20, healer=ply})
                HORDE:OnAntlionHeal(ent, healinfo)
            elseif ent:IsNPC() or ent:IsNextBot() then
                local dmg = DamageInfo()
                dmg:SetDamage(25)
                dmg:SetDamageType(DMG_NERVEGAS)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(ply)
                dmg:SetDamagePosition(tr.HitPos)
                ent:TakeDamageInfo(dmg)
            end
        end
    end
	end

    if ply:Horde_GetPerkCharges() > 0 then
        return true
    end
end

PERK.Hooks.Horde_OnPlayerHeal = function(ply, healinfo)
    local healer = healinfo:GetHealer()
    if healer:IsPlayer() and healer:Horde_GetPerk("medic_base") then
        healinfo:SetHealAmount(healinfo:GetHealAmount() * healer:Horde_GetPerkLevelBonus("medic_base"))
    end
end

PERK.Hooks.Horde_PrecomputePerkLevelBonus = function (ply)
    if SERVER then
        ply:Horde_SetPerkLevelBonus("medic_base", 1 + math.min(0.20, 0.008 * ply:Horde_GetLevel(HORDE.Class_Medic)))
    end
end