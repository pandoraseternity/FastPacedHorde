GADGET.PrintName = "Glass Body"
GADGET.Description =[[Deal 30% more damage,
Move 15% more faster.
Take 25% more damage.]]
GADGET.Icon = "items/gadgets/glass_body.png"
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Params = {
    [1] = {value = 0.2, percent = true},
	[2] = {value = 0.15, percent = true},
	[3] = {value = 0.25, percent = true},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if ply:Horde_GetGadget() ~= "gadget_glass_body" then return end
    bonus.resistance = bonus.resistance - 0.25
end

GADGET.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if ply:Horde_GetGadget() ~= "gadget_glass_body" then return end
    bonus.increase = bonus.increase + 0.30
end

GADGET.Hooks.Horde_PlayerMoveBonus = function(ply, bonus_walk, bonus_run)
    if ply:Horde_GetGadget() ~= "gadget_glass_body" then return end
    bonus_walk.increase = bonus_walk.increase + 0.15
    bonus_run.increase = bonus_run.increase + 0.15
end
