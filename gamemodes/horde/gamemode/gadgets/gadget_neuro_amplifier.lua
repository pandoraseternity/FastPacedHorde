GADGET.PrintName = "Neuro Amplifier"
GADGET.Description = [[Decrease 8% damage taken per Adrenaline stack.]]
--[[Adrenaline also increases 8% evasion.]]
GADGET.Icon = "items/gadgets/neuro_amplifier.png"
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Active = false
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmg, bonus)
    if SERVER and ply:Horde_GetAdrenalineStack() > 0 and ply:Horde_GetGadget() == "gadget_neuro_amplifier" then
        --bonus.evasion = bonus.evasion + ply:Horde_GetAdrenalineStack() * 0.08
		bonus.less = bonus.less + ply:Horde_GetAdrenalineStack() * 0.08
    end
end