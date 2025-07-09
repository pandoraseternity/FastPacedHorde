GADGET.PrintName = "Detoxifier"
GADGET.Description = "50% increased Poison damage and Poison debuff resistance."
GADGET.Icon = "items/gadgets/detoxifier.png"
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Params = {
    [1] = {value = 0.50, percent = true},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if ply:Horde_GetGadget() ~= "gadget_detoxifier"  then return end
    if HORDE:IsPoisonDamage(dmginfo) then
        bonus.resistance = bonus.resistance + 0.35
    end
end

GADGET.Hooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus, inflictor)
    if ply:Horde_GetGadget() ~= "gadget_detoxifier" then return end
    if debuff == HORDE.Status_Break then
        bonus.less = bonus.less * 0.65
    end
end