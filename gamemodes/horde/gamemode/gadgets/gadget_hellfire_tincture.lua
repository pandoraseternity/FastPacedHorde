GADGET.PrintName = "Hellfire Tincture"
GADGET.Description = [[
Every second:
- Deals 2.5% of your max health as damage to you.
- Deals 100% of your max health as Fire damage to enemies near you.
Upon kill:
- Deals 125% of your max health as Fire damage to enemies.]]
GADGET.Icon = "items/gadgets/hellfire_tincture.png"
GADGET.Active = true
GADGET.Duration = 20
GADGET.Cooldown = 20
GADGET.Droppable = true
GADGET.Params = {
    [1] = {value = 0.05, percent = true},
    [2] = {value = 0.5, percent = true},
}
GADGET.Hooks = {}
GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_hellfire_tincture" then return end
    ply:EmitSound("horde/player/drink.ogg")
	
    local id = ply:SteamID()
	ply.Hellfire_Tincture = true
    ply:ScreenFade(SCREENFADE.IN, Color(200, 50, 50, 50), 0.1, 12)
    local count = 8
    timer.Remove("Horde_Hellfire_Tincture" .. id)
    timer.Create("Horde_Hellfire_Tincture" .. id, 1, 0, function ()
        if !ply:IsValid() or count <= 1 then timer.Remove("Horde_Hellfire_Tincture" .. id) return end
        HORDE:TakeDamage(ply, 0.025 * ply:GetMaxHealth(), DMG_GENERIC, ply)
        HORDE:ApplyDamageInRadius(ply:GetPos(), 300, HORDE:DamageInfo(ply:GetMaxHealth() * 1, DMG_BURN, ply))
        count = count - 1
    end)
    timer.Simple(12, function()
		ply:EmitSound("horde/gadgets/optical_camouflage_on.ogg")
        if ply:IsValid() then ply.Hellfire_Tincture = nil end
    end)
end

GADGET.Hooks.Horde_OnEnemyKilled = function(victim, killer, wpn)
    if killer:Horde_GetGadget() ~= "gadget_hellfire_tincture" or not killer.Hellfire_Tincture then return end
	local pos = victim:GetPos()
	ParticleEffect("zeala_burst_core", victim:GetPos(), Angle(0, 0, 0), nil)
	timer.Simple(0.5, function()
    HORDE:ApplyDamageInRadius(pos, 250, HORDE:DamageInfo(killer:GetMaxHealth() * 1.25, DMG_BURN, killer))
	end)
end

GADGET.Hooks.Horde_OnUnsetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_hellfire_tincture" then return end
    local id = ply:SteamID()
	timer.Remove("Horde_Hellfire_Tincture" .. id)
	ply.Hellfire_Tincture = nil
end
