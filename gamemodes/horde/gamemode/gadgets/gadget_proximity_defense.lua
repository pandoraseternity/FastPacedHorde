GADGET.PrintName = "Proximity Defense"
GADGET.Description = "Triggers an explosion that Stuns nearby enemies."
GADGET.Icon = "items/gadgets/proximity_defense.png"
GADGET.Duration = 0
GADGET.Cooldown = 20
GADGET.Active = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_proximity_defense" then return end
    local effectdata = EffectData()
    effectdata:SetOrigin(ply:GetPos())
    util.Effect("Explosion", effectdata)
    ply:EmitSound("phx/kaboom.wav", 125, 100, 1, CHAN_AUTO)
	
	if ply:Horde_GetPerk("warlock_base") then
		local s = ply:Horde_GetSecondarySpell()
		if s.Sigil then
			s.Fire(ply, wpn, stage)
		end
	end

    for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 400)) do
        if ent:IsNPC() or ent:IsNextBot() then
            ent:Horde_AddDebuffBuildup(HORDE.Status_Stun, 500, ply, ent:GetPos())
        end
    end
end