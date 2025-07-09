MUTATION.PrintName = "Transcendent"
MUTATION.Description = "Powerful mutation that occurs randopmly on wave 8 and above."
MUTATION.Wave = 8

MUTATION.Hooks = {}

MUTATION.Hooks.Horde_OnSetMutation = function(ent, mutation)
    if mutation == "transcendent" then
		sound.Play("horde/status/transspawn.mp3", ent:GetPos(), 9999)
		--VJ_EmitSound(ent,"horde/status/transspawn.mp3" ,1000, 120)
        ent.Horde_Mutation_Transc = true
        if SERVER then
            if ent.AnimationPlaybackRate then
                ent.AnimationPlaybackRate = ent.AnimationPlaybackRate * 1.75
            else
                ent:SetPlaybackRate(ent:GetPlaybackRate() * 1.75)
            end
            local col_min, col_max = ent:GetCollisionBounds()
            local radius = col_max:Distance(col_min) / 2
            local e = EffectData()
                e:SetOrigin(ent:GetPos())
                e:SetEntity(ent)
                e:SetRadius(radius)
            util.Effect("transcendent", e, true, true)
			
			local cooldownreduction = 0.5
			if ent:GetVar("is_boss") == true then
				cooldownreduction = 0.75
            end
			if ent:IsNPC() && ent.IsVJBaseSNPC then
			ent.NextMeleeAttackTime = ent.NextMeleeAttackTime * cooldownreduction
			ent.NextRangeAttackTime = ent.NextRangeAttackTime * cooldownreduction
			elseif ent:IsNextBot() && ent.IsDrGNextbot then
			ent.statmult = ent.statmult * cooldownreduction
			end
			
        end
    end
end

MUTATION.Hooks.EntityTakeDamage = function(target, dmg)
    if (target:IsNPC() or target:IsNextBot()) and target:Horde_HasMutation("transcendent") then
		dmg:SubtractDamage(10)
    end
end

local entmeta = FindMetaTable("Entity")
MUTATION.Hooks.Think = function()
if entmeta.Horde_Mutation_Transc == true then
     if ent.AnimationPlaybackRate then
         ent.AnimationPlaybackRate = ent.AnimationPlaybackRate * 1.75
     else
         ent:SetPlaybackRate(ent:GetPlaybackRate() * 1.75)
    end
	local cooldownreduction = 0.5
	if ent:GetVar("is_boss") == true then
		cooldownreduction = 0.75
	end
			
	if ent:IsNPC() then
	ent.NextMeleeAttackTime = ent.NextMeleeAttackTime * cooldownreduction
	ent.NextRangeAttackTime = ent.NextRangeAttackTime * cooldownreduction
	elseif ent:IsNextBot() then
	ent.statmult = ent.statmult * cooldownreduction
	end
	
	if entmeta:IsOnGround() && entmeta:IsNPC() then
		entmeta:SetVelocity(entmeta:GetMoveVelocity() * 5)
	end
end
end

/*MUTATION.Hooks.EntityTakeDamage = function(ply, dmg)
    if (dmg:GetAttacker():IsNPC() or dmg:GetAttacker():IsNextBot()) and dmg:GetAttacker():Horde_HasMutation("transcendent") then
        dmg:ScaleDamage(1.25)
    end
end*/

MUTATION.Hooks.Horde_OnUnsetMutation = function (ent, mutation)
    if not ent:IsValid() or mutation ~= "transcendent" then return end
    ent.Horde_Mutation_Transc = nil
end