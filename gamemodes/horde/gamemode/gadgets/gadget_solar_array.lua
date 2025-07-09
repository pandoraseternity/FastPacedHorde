GADGET.PrintName = "Solar Array"
GADGET.Description = "Give players within your aura 30 armor."
GADGET.Icon = "items/gadgets/solar_array.png"
GADGET.Duration = 0
GADGET.Cooldown = 20
GADGET.Active = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_solar_array" then return end
    --local ent = ents.Create("item_battery")
    local pos = ply:EyePos()
    local dir = ply:GetAimVector()
    local drop_pos = pos + dir * 50
    drop_pos.z = pos.z + 15
    --ent:SetPos(drop_pos)
    --ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
    --ent:Spawn()
	
	local effectdata = EffectData()
	local pos = ply:GetPos()
    effectdata:SetOrigin(pos)
    util.Effect("explosion_shock", effectdata)
    sound.Play("HL1/ambience/particle_suck1.wav", ply:GetPos())
    local players = ents.FindInSphere(ply:GetPos(), ply:Horde_GetWardenAuraRadius())
    if not players then return end
    for _, ent in pairs(players) do
        if ent:IsPlayer() then
			ent:SetArmor(math.min(ent:GetMaxArmor(), ent:Armor() + 30))
        end
    end
	
end
