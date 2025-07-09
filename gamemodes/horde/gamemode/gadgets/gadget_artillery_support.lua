GADGET.PrintName = "Artillery Support"
GADGET.Description = "Sends down a flurry of Artillery Strikes. Deals 400 damage with each explosive."
GADGET.Icon = "items/gadgets/artillery_support.png"
GADGET.Duration = 5
GADGET.Cooldown = 30
GADGET.Active = true
GADGET.Params = {
    [1] = {value = 25},
}
GADGET.Hooks = {}

local function explosion(ply, pos)
		sound.Play( "horde/gadgets/artillery/doi_generic_03.wav", pos, 3000 )
		ParticleEffect("100lb_ground", pos, Angle(0, 0, 0), nil)
        --util.Effect("explosion_shock", effectdata)
        local dmg = DamageInfo()
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetDamage(400)
        util.BlastDamageInfo(dmg, pos, 800)
        for _, q in pairs(ents.FindInSphere(pos, 800)) do
			if q:IsNPC() or q:IsNextBot() then
				q:Horde_AddDebuffBuildup(HORDE.Status_Stun, 750, ply, q:GetPos())
			end
		end
end

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_artillery_support" then return end
	local id = ply:SteamID()
	local pos = ply:GetEyeTrace().HitPos
	timer.Create("Horde_Air_Support_Illusion" .. id, 0.5, 8, function ()
		if not ply:IsValid() then timer.Remove("Horde_Air_Support_Illusion" .. id) return end
		sound.Play( "horde/gadgets/artillery/far/distant_artillery_fire_01.wav", pos, 3000 )
	end)
	
    timer.Create("Horde_Air_Support_Effect" .. id, 0.85, 8, function ()
        if not ply:IsValid() then timer.Remove("Horde_Air_Support_Effect" .. id) return end
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
		pos = pos + Vector(math.random(-100,100),math.random(-100,100),0)
		sound.Play( "horde/gadgets/artillery/flyby/artillery_strike_incoming_04.wav", pos, 3000 )
		timer.Simple(2, function() if ply:IsValid() then
		explosion(ply, pos)
		end end)
    end)
	
end

GADGET.Hooks.Horde_OnUnsetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_artillery_support" then return end
    local id = ply:SteamID()
	timer.Remove("Horde_Air_Support_Illusion" .. id)
    timer.Remove("Horde_Air_Support_Effect" .. id)
end