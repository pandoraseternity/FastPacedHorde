GADGET.PrintName = "Iridescent Pearl"
GADGET.Description = [[Permantly increases your movement speed by 35%.]]
GADGET.Icon = "items/gadgets/iridescent_pearl.png"
GADGET.Droppable = true
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Params = {
    [1] = {value = 0.25, percent = true},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_PlayerMoveBonus = function(ply, bonus_walk, bonus_run)
    if ply:Horde_GetGadget() ~= "gadget_iridescent_pearl" then return end
    bonus_walk.increase = bonus_walk.increase + 0.35
    bonus_run.increase = bonus_run.increase + 0.35
end
