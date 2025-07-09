PERK.PrintName = "Savor"
PERK.Description = [[
{1} increased Critical Hit damage.
Leech {2} of damage dealt when you land a Melee Critical Hit.
Leech caps at 15 health per hit.]]
PERK.Icon = "materials/perks/psycho/savor.png"
PERK.Params = {
    [1] = {value = 0.25, percent = true},
    [2] = {value = 0.1, percent = true},
}
PERK.Hooks = {}

PERK.Hooks.Horde_OnPlayerCritical = function (ply, npc, bonus, hitgroup, dmginfo, crit_bonus)
	if ply:Horde_GetPerk("psycho_savor") then
		bonus.increase = bonus.increase + 0.25
		if HORDE:IsMeleeDamage(dmginfo) then
			HORDE:SelfHeal(ply, math.min(15, dmginfo:GetDamage() * 0.1))
		end
	end
    --if ply:Horde_GetPerk("psycho_savor") and HORDE:IsMeleeDamage(dmginfo) then
       --HORDE:SelfHeal(ply, math.min(15, dmginfo:GetDamage() * 0.1))
    --end
end