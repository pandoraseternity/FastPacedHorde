GADGET.PrintName = "Arctic Plating"
GADGET.Description = "35% increased Cold damage and debuff resistance."
GADGET.Icon = "items/gadgets/arctic_plating.png"
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Params = {
    [1] = {value = 0.20, percent = true},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if ply:Horde_GetGadget() ~= "gadget_arctic_plating"  then return end
    if HORDE:IsColdDamage(dmginfo) then
        bonus.resistance = bonus.resistance + 0.35
    end
end

GADGET.Hooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus, inflictor)
    if ply:Horde_GetGadget() ~= "gadget_detoxifier" then return end
    if debuff == HORDE.Status_Frostbite then
        bonus.less = bonus.less * 0.65
    end
end