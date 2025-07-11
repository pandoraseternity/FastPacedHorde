AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_zombies/stalker.mdl"
ENT.StartHealth = 350
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 32 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 60 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.4 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 36
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
ENT.GeneralSoundPitch1 = 30
ENT.GeneralSoundPitch2 = 30

ENT.FootStepSoundLevel = 55
ENT.NextBlastTime = CurTime()
ENT.NextBlastCooldown = 5
ENT.AnimTbl_MeleeAttack = {}
ENT.Critical = nil
ENT.CVar		= "horde_difficulty"
ENT.shocktime = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	if cvars.Number(self.CVar, 1) >= 4 then
		self.shocktime = 0.5
		self.Critical = true
		self.AnimTbl_Run = {ACT_RUN}
	end
	self:SetCollisionBounds(Vector(12, 12, 65), Vector(-12, -12, 0))
	self:SetModelScale(self:GetModelScale() * 1.25, 0)
	self:SetColor(Color(0, 150, 250))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end


function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsColdDamage(dmginfo) then
		dmginfo:ScaleDamage(0.5)
	elseif HORDE:IsLightningDamage(dmginfo) then
		dmginfo:ScaleDamage(0.75)
	elseif HORDE:IsBlastDamage(dmginfo) or HORDE:IsFireDamage(dmginfo) then
		dmginfo:ScaleDamage(1.25)
	end
end

function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
	if not self.Critical and self:Health() < self:GetMaxHealth() / 1.5 then
        self.Critical = true
		self.AnimTbl_Run = {ACT_RUN}
    end
end

function ENT:CustomOnMeleeAttack_AfterChecks(hitEnt,isProp)
    if isProp then return end
	if IsValid(hitEnt) and cvars.Number(self.CVar, 1) >= 3 then 
	hitEnt:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 45, self) 
	end	
	--return false
end

function ENT:ShockAttack(delay)
	if self.Horde_Stunned then return end
	timer.Simple(delay, function()
		if not self:IsValid() then return end
		local dmg = DamageInfo()
		dmg:SetAttacker(self)
		dmg:SetInflictor(self)
		dmg:SetDamageType(DMG_REMOVENORAGDOLL)
		dmg:SetDamage(12)
		util.BlastDamageInfo(dmg, self:GetPos(), 350)

        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 350)) do
			if ent:IsPlayer() then
				local Trace = util.TraceLine({
		                    start = self:WorldSpaceCenter(),
		                    endpos = ent:WorldSpaceCenter(),
				    mask = MASK_SOLID_BRUSHONLY
		                })
				if not Trace.HitWorld then
					ent:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 4, self)
				end
			end
		end

		local e = EffectData()
			e:SetOrigin(self:GetPos())
			e:SetNormal(Vector(0,0,1))
			e:SetScale(1.4)
		util.Effect("weeper_blast", e, true, true)
	end)
end

function ENT:CustomOnThink()
	if cvars.Number(self.CVar, 1) >= 3 && self:IsOnGround() then
		self.MeleeAttackAnimationAllowOtherTasks = true
		self:SetLocalVelocity(self:GetMoveVelocity() * 1.5)
	end

	if not self:GetEnemy() then return end
	local EnemyDistance = self.NearestPointToEnemyDistance
	if EnemyDistance < 250 then
		if CurTime() > self.NextBlastTime then
			sound.Play("npc/stalker/go_alert2.wav", self:GetPos(), 100, 50)
			self:VJ_ACT_PLAYACTIVITY("podconvulse", true, 1.5, false)
			self:ShockAttack(1.5 * self.shocktime)
			self:ShockAttack(1.7  * self.shocktime)
			self:ShockAttack(1.9  * self.shocktime)
			--self:ShockAttack(2.1  * self.shocktime)
			--self:ShockAttack(2.3  * self.shocktime)
			--self:ShockAttack(2.5 * self.shocktime)
			self.NextBlastTime = CurTime() + self.NextBlastCooldown
			timer.Simple(2.5, function ()
				if not self:IsValid() then return end
				self:VJ_ACT_PLAYACTIVITY("walk")
			end)
		end
	end
end

VJ.AddNPC("Weeper","npc_vj_horde_weeper", "Zombies")