PERK.PrintName = "Chain Reaction"
PERK.Description = [[Explosions deals up to {1} of an enemy's current health as extra Blast damage.
Damage increase is capped at {2}.]]
PERK.Icon = "materials/perks/chain_reaction.png"
PERK.Params = {
    [1] = {value = 0.03, percent = true},
    [2] = {value = 4000}
}

PERK.Hooks = {}

PERK.Hooks.Horde_OnSetPerk = function (ply, perk)
    if SERVER and perk == "demolition_chain_reaction" then
        ply.ChainNumb = 0
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function (ply, perk)
    if SERVER and perk == "demolition_chain_reaction" then
        ply.ChainNumb = nil
    end
end

PERK.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("demolition_chain_reaction") then return end
	if HORDE:IsBlastDamage(dmginfo) then
		local decreasingdmg = dmginfo:GetDamage()
		timer.Simple( 0.75, function() if ply.ChainNumb <= 3 && IsValid(npc) then
		if decreasingdmg < 50 then return end
		if ply.ChainNumb >= 3 then return end
		--print(decreasingdmg)
		--print(ply.ChainNumb)
		decreasingdmg = decreasingdmg + 45
		ply.ChainNumb = ply.ChainNumb + 1
        local pos = npc:WorldSpaceCenter()
        local targets = ents.FindInSphere(pos, 530)
        local closest = nil 
        local nearestDist = 4000 --do not proc on yourself
		
        for _, ent in pairs(targets) do
            local dist = ent:GetPos():DistToSqr(pos)
            if HORDE:IsEnemy(ent) and ent:Health() > 0 and dist > nearestDist then
                closest = ent
                nearestDist = dist
            end
        end
		
        if closest then
            local target = closest
			local targetpos = target:GetPos() + target:OBBCenter()
			util.BlastDamage( ply, ply, targetpos, 250, decreasingdmg )
            util.ParticleTracerEx("vortigaunt_beam", npc:GetPos(), targetpos, true, npc:EntIndex(), -1)
            util.ParticleTracerEx("vortigaunt_beam_b", npc:GetPos(), targetpos, true, npc:EntIndex(), -1)
            local effectdata = EffectData()
            effectdata:SetOrigin(targetpos)
            effectdata:SetScale(1)
            effectdata:SetEntity(ply)
            util.Effect("horde_minirocket_explosion", effectdata )
        end
		
		end end)
		
	end
	
		timer.Simple( 4, function() if ply.ChainNumb >= 3 then
			ply.ChainNumb = 0
		end end)
	
end

