PERK.PrintName = "Ferocity"
PERK.Description = [[
Adds {1} Critical Hit chance.
Adds {2} Melee Critical Hit chance.
Removes 25 armor upon melee hit.]]
PERK.Icon = "materials/perks/psycho/ferocity.png"
PERK.Params = {
    [1] = {value = 0.10, percent = true},
    [2] = {value = 0.10, percent = true},
}
PERK.Hooks = {}

PERK.Hooks.Horde_OnPlayerCriticalCheck = function (ply, npc, bonus, hitgroup, dmginfo, crit_bonus)
    if ply:Horde_GetPerk("psycho_ferocity") then
        crit_bonus.add = crit_bonus.add + 0.1
        if HORDE:IsMeleeDamage(dmginfo) then
            crit_bonus.add = crit_bonus.add + 0.1
        end
    end
end

PERK.Hooks.Horde_OnPlayerDamagePost = function (ply, npc, bonus, hitgroup, dmginfo)
    if ply:Horde_GetPerk("psycho_ferocity") and HORDE:IsMeleeDamage(dmginfo) then
		npc:Horde_RemoveArmor(25)
    end
end