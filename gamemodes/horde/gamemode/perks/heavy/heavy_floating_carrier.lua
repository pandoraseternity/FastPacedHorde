PERK.PrintName = "Floating Carrier"
PERK.Description = "+{1} to maximum weight."
PERK.Icon = "materials/perks/floating_carrier.png"
PERK.Params = {
    [1] = {value = 5},
}

PERK.Hooks = {}
PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "heavy_floating_carrier" then
        ply:Horde_SetMaxWeight(HORDE.max_weight + 5)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "heavy_floating_carrier" then
        ply:Horde_SetMaxWeight(HORDE.max_weight)
    end
end

PERK.Hooks.Horde_PlayerMoveBonus = function(ply, bonus_walk, bonus_run)
    if not ply:Horde_GetPerk("heavy_floating_carrier") then return end
	local weight = ply:Horde_GetMaxWeight() - ply:Horde_GetWeight()
    bonus_walk.more = bonus_walk.more + (weight * 0.02)
    bonus_run.more = bonus_run.more + (weight * 0.02)
end