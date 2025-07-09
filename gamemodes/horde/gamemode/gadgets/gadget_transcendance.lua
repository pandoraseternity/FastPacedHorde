GADGET.PrintName = "Transcendance"
GADGET.Description =
[[Surpass damage. Heal 10 health from damage.
After not getting hit for 4 seconds, Regenerate your health.]]
GADGET.Icon = "items/gadgets/transcendance.png"
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Active = false
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnSetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_transcendance" then return end
    local id = ply:SteamID()
	timer.Create("Horde_Transcend_Effect" .. id, 0.1, 0, function ()
		if not ply:IsValid() then timer.Remove("Horde_Transcend_Effect" .. id) return end
		if ply:Health() < ply:GetMaxHealth() then
			ply:SetHealth(ply:Health() + 2)
		end
	end)
	ply.Transcend = true
end

GADGET.Hooks.Horde_OnUnsetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_transcendance" then return end
	local id = ply:SteamID()
	timer.Remove( "Horde_Transcend_Effect" .. id )
	ply.Transcend = nil
end

GADGET.Hooks.Horde_OnPlayerDamageTakenPost = function (ply, dmginfo, bonus)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_transcendance" then return end
	local id = ply:SteamID()
    --ply:Horde_AddDebuffBuildup(HORDE.Status_Necrosis, dmginfo:GetDamage() * 0.5, dmginfo:GetAttacker())
    local healinfo = HealInfo:New({amount=10, healer=ply})
    HORDE:OnPlayerHeal(ply, healinfo)
	timer.Remove( "Horde_Transcend_Effect" .. id )
	timer.Simple( 4, function() if ply:Alive() then
		timer.Create("Horde_Transcend_Effect" .. id, 0.1, 0, function ()
			if not ply:IsValid() then timer.Remove("Horde_Transcend_Effect" .. id) return end
			if ply:Health() < ply:GetMaxHealth() then
				ply:SetHealth(ply:Health() + 2)
			end
		end)
	end end )
end