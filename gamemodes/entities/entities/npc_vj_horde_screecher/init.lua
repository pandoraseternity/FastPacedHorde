AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_zombies/stalker.mdl"
ENT.StartHealth = 200
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {} -- Melee Attack Animations
ENT.MeleeAttackDistance = 32 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 60 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.6 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 20

ENT.HasRangeAttack = true -- Should the SNPC have a range attack
ENT.RangeAttackEntityToSpawn = "obj_vj_superzombieattack" -- The entity that is spawned when range attacking
ENT.RangeDistance = 4000 -- This is how far away it can shoot
ENT.TimeUntilRangeAttackProjectileRelease = 0 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 12 -- How much time until it can use a range attack?
ENT.RangeToMeleeDistance = 400 -- How close does it have to be until it uses melee?
ENT.DisableDefaultRangeAttackCode = true -- When true, it won't spawn the range attack entity, allowing you to make your own

ENT.SlowPlayerOnMeleeAttack = true -- If true, then the player will slow down
ENT.SlowPlayerOnMeleeAttack_WalkSpeed = 100 -- Walking Speed when Slow Player is on
ENT.SlowPlayerOnMeleeAttack_RunSpeed = 100 -- Running Speed when Slow Player is on
ENT.SlowPlayerOnMeleeAttackTime = 5 -- How much time until player's Speed resets
ENT.MeleeAttackBleedEnemy = false -- Should the player bleed when attacked by melee
ENT.FootStepTimeRun = 0.2 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.3 -- Next foot step sound when it is walking
ENT.AnimTbl_Run = {ACT_WALK}
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"npc/stalker/stalker_footstep_left1.wav", "npc/stalker/stalker_footstep_left2.wav", "npc/stalker/stalker_footstep_right1.wav", "npc/stalker/stalker_footstep_right2.wav"}
ENT.SoundTbl_Breath = "npc/stalker/breathing3.wav"
ENT.SoundTbl_Idle = {"vj_zombies/special/zmisc_idle1.wav", "vj_zombies/special/zmisc_idle2.wav", "vj_zombies/special/zmisc_idle3.wav", "vj_zombies/special/zmisc_idle4.wav", "vj_zombies/special/zmisc_idle5.wav", "vj_zombies/special/zmisc_idle6.wav"}
ENT.SoundTbl_Alert = "npc/stalker/go_alert2a.wav"
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav", "vj_zombies/slow/miss3.wav", "vj_zombies/slow/miss4.wav"}
ENT.SoundTbl_Pain = {"vj_zombies/special/zmisc_pain1.wav", "vj_zombies/special/zmisc_pain2.wav", "vj_zombies/special/zmisc_pain3.wav", "vj_zombies/special/zmisc_pain4.wav", "vj_zombies/special/zmisc_pain5.wav", "vj_zombies/special/zmisc_pain6.wav"}
ENT.SoundTbl_Death = {"vj_zombies/special/zmisc_die1.wav", "vj_zombies/special/zmisc_die2.wav", "vj_zombies/special/zmisc_die3.wav"}

ENT.FootStepSoundLevel = 55
ENT.NextBlastTime = CurTime()
ENT.NextBlastCooldown = 8
ENT.AnimTbl_MeleeAttack = {}
ENT.Critical = nil
ENT.CVar		= "horde_difficulty"
ENT.shocktime = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	if cvars.Number(self.CVar, 1) >= 3 then
		self.shocktime = 0.5
	end
	self:SetCollisionBounds(Vector(12, 12, 65), Vector(-12, -12, 0))
	--self:SetModelScale(1.25, 0)
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsLightningDamage(dmginfo) then
		dmginfo:ScaleDamage(0.5)
    elseif HORDE:IsBlastDamage(dmginfo) then
        dmginfo:ScaleDamage(1.25)
    end
end

--ENT.ScreecherRange = 0
function ENT:CustomRangeAttackCode() 
--if self.ScreecherRange < CurTime() then 
sound.Play("npc/stalker/go_alert2.wav", self:GetPos())
self:VJ_ACT_PLAYACTIVITY("rangeattack", true, 1.25, false)
		local enemy_pos = self:GetEnemy():GetPos()
		local dist = enemy_pos:Distance(self:GetPos())
		local dir = enemy_pos - self:GetPos()
		dir:Normalize()
		local start = 0
		local i = 0
		timer.Simple(1.5, function() if IsValid(self) && (self:GetEnemy()) then
			if !IsValid(self) and !IsValid(self:GetEnemy()) then return end
			local tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetEnemy():GetPos(),
				filter = {self}
			})

			dir = tr.HitPos - self:GetPos()
			dir:Normalize()

			while (start < dist + 300) do
				local pos = self:GetPos() + dir * start
				timer.Simple(0.25 + i * 0.1, function()
					if !IsValid(self) then return end
					ParticleEffect("hunter_projectile_explosion_1", pos, Angle(0,0,0), nil)
					sound.Play("ambient/energy/newspark01.wav", pos)
					local dmg = DamageInfo()
					dmg:SetAttacker(self)
					dmg:SetInflictor(self)
					dmg:SetDamage(38)
					dmg:SetDamageType(DMG_SHOCK)
					util.BlastDamageInfo(dmg, pos, 100)
				end)
				i = i + 1
				start = start + 150
			end
		end
	--self.ScreecherRange = CurTime() + 5
end)
end

function ENT:ShockAttack(delay)
	if self.Horde_Stunned then return end
	timer.Simple(delay, function()
		if not self:IsValid() then return end
		local dmg = DamageInfo()
		dmg:SetAttacker(self)
		dmg:SetInflictor(self)
		dmg:SetDamageType(DMG_SHOCK)
		dmg:SetDamage(12)
		util.BlastDamageInfo(dmg, self:GetPos(), 300)

		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 300)) do
			if ent:IsPlayer() then
				ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 4, self)
			end
		end
		
		local e = EffectData()
			e:SetOrigin(self:GetPos())
			e:SetNormal(Vector(0,0,1))
		util.Effect("screecher_blast", e, true, true)
	end)
end

function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
	if not self.Critical and self:Health() < self:GetMaxHealth() / 2 then
        self.Critical = true
		self.AnimTbl_Run = {ACT_RUN}
    end
end

function ENT:CustomOnThink()
	if not self:GetEnemy() then return end
	local EnemyDistance = self.NearestPointToEnemyDistance
	if EnemyDistance < 250 then
		if CurTime() > self.NextBlastTime then
			sound.Play("npc/stalker/go_alert2.wav", self:GetPos())
			self:VJ_ACT_PLAYACTIVITY("podconvulse", true, 1.5, false)
			self:ShockAttack(1.5 * self.shocktime)
			self:ShockAttack(1.7 * self.shocktime)
			self:ShockAttack(1.9 * self.shocktime)
			--self:ShockAttack(2.1 * self.shocktime)
			--self:ShockAttack(2.3 * self.shocktime)
			self.NextBlastTime = CurTime() + self.NextBlastCooldown
			timer.Simple(2.5, function ()
				if not self:IsValid() then return end
				self:VJ_ACT_PLAYACTIVITY("walk")
			end)
		end
	end
end

VJ.AddNPC("Screecher","npc_vj_horde_screecher", "Zombies")