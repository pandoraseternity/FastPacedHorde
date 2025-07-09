GADGET.PrintName = "Shock Plating"
GADGET.Description = "35% increased Lightning damage resistance."
GADGET.Icon = "items/gadgets/shock_plating.png"
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Params = {
    [1] = {value = 0.35, percent = true},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if ply:Horde_GetGadget() ~= "gadget_shock_plating"  then return end
    if HORDE:IsLightningDamage(dmginfo) then
        bonus.resistance = bonus.resistance + 0.35
    end
end

GADGET.Hooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus, inflictor)
    if ply:Horde_GetGadget() ~= "gadget_detoxifier" then return end
    if debuff == HORDE.Status_Shock then
        bonus.less = bonus.less * 0.65
    end
end