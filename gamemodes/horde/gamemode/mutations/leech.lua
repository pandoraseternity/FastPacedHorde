MUTATION.PrintName = "Leech"
MUTATION.Description = "Leeches health upon hitting enemies. Occurs wave 6 and beyond."
MUTATION.Wave = 6

MUTATION.Hooks = {}

MUTATION.Hooks.Horde_OnSetMutation = function(ent, mutation)
    if mutation == "leech" then
        ent.Horde_Mutation_Leech = true
        if SERVER then
            local col_min, col_max = ent:GetCollisionBounds()
            local radius = col_max:Distance(col_min) / 2
            local e = EffectData()
                e:SetOrigin(ent:GetPos())
                e:SetEntity(ent)
                e:SetRadius(radius)
            util.Effect("leech", e, true, true)
			ent.NextTimeLeech = CurTime() + 0.1
        end
    end
end

MUTATION.Hooks.EntityTakeDamage = function(target, dmg)
	local attack = dmg:GetAttacker()
    if (attack:IsNPC() or attack:IsNextBot()) and attack:Horde_HasMutation("leech") and CurTime() > attack.NextTimeLeech then
		attack.NextTimeLeech = CurTime() + 0.1 --and CurTime() > attack.NextTimeLeech and HORDE:IsPlayerMinion(target)
        attack:SetHealth(math.min(attack:GetMaxHealth(), (dmg:GetDamage()) + attack:Health()))
		sound.Play("vj_lnrspecials/heal.wav", attack:GetPos(), 500)
		local HealParticle = ents.Create("info_particle_system")
		HealParticle:SetKeyValue("effect_name","vortigaunt_hand_glow")
		HealParticle:SetPos(attack:GetPos() +attack:OBBCenter())
		HealParticle:Spawn()
		HealParticle:Activate()
		HealParticle:SetParent(attack)
		HealParticle:Fire("Start","",0)
		HealParticle:Fire("Kill","",0.6)			
	    --effects.BeamRingPoint(attack:GetPos() + attack:GetUp()*20, 0.3, 5, 400, 50, 0, Color(63, 127, 0, 255))
    end
end

MUTATION.Hooks.Horde_OnUnsetMutation = function (ent, mutation)
    if not ent:IsValid() or mutation ~= "leech" then return end
    ent.Horde_Mutation_Leech = nil
end