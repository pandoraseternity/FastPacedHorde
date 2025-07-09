PERK.PrintName = "Seismic Wave"
PERK.Description = [[Blast damage generates a delayed explosion.
Delayed explosion deals {1} explosion damage as Physical damage.
Only activates when damage is greater than {2}.]]
PERK.Icon = "materials/perks/seismic_wave.png"
PERK.Params = {
    [1] = {value = 0.25, percent = true},
    [2] = {value = 100},
}

PERK.Hooks = {}

PERK.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("demolition_seismic_wave") then return end
    if HORDE:IsBlastDamage(dmginfo) and dmginfo:GetDamage() >= 100 then
        local dmg = dmginfo:GetDamage() / 4
        local pos = npc:GetPos()
        timer.Simple(0.5, function()
            if !IsValid(ply) then return end
            local bpos = pos + VectorRand()
            local d = DamageInfo()
            d:SetAttacker(ply)
            d:SetInflictor(ply)
            d:SetDamageType(DMG_SONIC)
            d:SetDamage(dmg)
            util.BlastDamageInfo(d, bpos, math.min(400, dmg * 2))
			--for k, npc in pairs(ents.FindInSphere(bpos, 400)) do
				--npc:TakeDamageInfo(d)
			--end
            local e = EffectData()
                e:SetNormal(Vector(0,0,1))
                e:SetOrigin(bpos)
                e:SetRadius(math.min(400, dmg * 2))
            util.Effect("seismic_wave", e, true, true)
        end)
    end
end