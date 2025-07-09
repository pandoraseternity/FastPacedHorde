GADGET.PrintName = "Defiance"
GADGET.Description =
[[Defy death. You are marked for revival.
You can mark 3 other people for revival as well.
However, you cannot remark a person once they have been revived.
You have 3 seconds of immunity upon spawning.]]
GADGET.Icon = "items/gadgets/defiance.png"
GADGET.Duration = 0
GADGET.Cooldown = 3
GADGET.Active = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnSetGadget = function (ply, gadget)
    if CLIENT then return end
	if gadget ~= "gadget_defiance" then return end
    ply:Horde_SyncStatus(HORDE.Status_Defiance, 1)
    ply.Horde_Revival_Marked = true
	ply.Horde_Revival_Numb = 0
end

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_defiance" then return end
	
	    local tr = util.TraceHull({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 500000,
        filter = {ply},
        mins = Vector(-16, -16, -8),
        maxs = Vector(16, 16, 8),
        mask = MASK_SHOT_HULL
    })
	
    local ent = tr.Entity

    if ent:IsValid() and ent:IsPlayer() and ply.Horde_Revival_Numb < 3 then
		if ent.AlreadyRevived == true then 
		ent:EmitSound("buttons/button2.wav")
		return end
		ply.Horde_Revival_Numb = ply.Horde_Revival_Numb + 1
        ply:Horde_SyncStatus(HORDE.Status_Defiance, 1)
        ent:EmitSound("horde/gadgets/aegis.ogg")
        local id = ent:SteamID()
        ent.Horde_Revival_Marked = true
        local ed = EffectData()
        ed:SetOrigin(ent:GetPos() + Vector(0,0,50) + ent:GetForward() * 50)
        util.Effect("horde_defiance_apply", ed, true, true)
    end
	
end

GADGET.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if ply.Revival_Marked and dmginfo:GetDamage() > ply:Health() then
       ply:Horde_SyncStatus(HORDE.Status_Defiance, 0)
       ply.Horde_Revival_Marked = nil
       ply.Horde_Invincible = true
       timer.Remove("Horde_RemoveInvin" .. id)
       timer.Create("Horde_RemoveInvin" .. id, 3, 1, function ()
           ent.Horde_Invincible = nil
       end)
	   ply.AlreadyRevived = true
	   ply:SetHealth(ply:GetMaxHealth() * 0.5)
    end
end

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmg, bonus)
    if ply.Horde_Invincible then
        dmg:SetDamage(0)
        return true
    end
end

GADGET.Hooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus)
    if ply.Horde_Invincible then
        bonus.apply = 0
        return true
    end
end
