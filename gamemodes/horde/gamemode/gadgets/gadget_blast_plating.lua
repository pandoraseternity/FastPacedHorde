GADGET.PrintName = "Blast Plating"
GADGET.Description = "{4} increased Blast damage resistance."
GADGET.Icon = "items/gadgets/blast_plating.png"
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Params = {
    [1] = {value = 35, percent = true},
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if ply:Horde_GetGadget() ~= "gadget_blast_plating" then return end
    if HORDE:IsBlastDamage(dmginfo) then
        bonus.resistance = bonus.resistance + 0.35
    end
end