AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/horde/gonome/gonome.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 9000
ENT.HullType = HULL_MEDIUM_TALL
ENT.FindEnemy_CanSeeThroughWalls = true

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {"vjseq_idle2"} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_breen_projectile" -- The entity that is spawned when range attacking
ENT.RangeDistance = 5000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 0 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = false -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "hand_right" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.TimeUntilRangeAttackProjectileRelease = 2 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 10 -- How much time until it can use a range attack?
ENT.NextAnyAttackTime_Range = 0.5 -- How much time until it can use any attack again? | Counted in Seconds
ENT.RangeAttackPos_Up = 50 -- Up/Down spawning position for range attack
ENT.RangeAttackPos_Forward = 0 -- Forward/Backward spawning position for range attack
ENT.RangeAttackPos_Right = 0 -- Right/Left spawning position for range attack

---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackExtraTimers = {1.0} -- Extra melee attack timers | it will run the damage code after the given amount of seconds
ENT.MeleeAttackDistance = 60 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.6 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 40
ENT.FootStepTimeRun = 0.4 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.4 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.SlowPlayerOnMeleeAttack = true -- If true, then the player will slow down
ENT.SlowPlayerOnMeleeAttack_WalkSpeed = 100 -- Walking Speed when Slow Player is on
ENT.SlowPlayerOnMeleeAttack_RunSpeed = 100 -- Running Speed when Slow Player is on
ENT.SlowPlayerOnMeleeAttackTime = 5 -- How much time until player's Speed resets
ENT.MeleeAttackBleedEnemy = false -- Should the player bleed when attacked by melee
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = 100 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 130 -- How far it will push you forward | Second in math.random
ENT.MeleeAttackKnockBack_Up1 = 250 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 260 -- How far it will push you up | Second in math.random
-- ====== Projectile Spawn Position Variables ====== --
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "hand_right" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.RangeAttackPos_Up = 20 -- Up/Down spawning position for range attack
ENT.RangeAttackPos_Forward = 10 -- Forward/ Backward spawning position for range attack
ENT.RangeAttackPos_Right = 10 -- Right/Left spawning position for range attack
-- Miscellaneous ---------------------------------------------------------------------------------------------------------------------------------------------	
ENT.AnimTbl_IdleStand = {"Idle1","Idle2"} -- The idle animation when AI is enabled

	-- ====== Flinching Code ====== --
ENT.CanFlinch = 0 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {"Flinch"} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play


ENT.SoundTbl_BeforeRangeAttack = {"npc/attack_helicopter/aheli_charge_up.wav"}
ENT.SoundTbl_FootStep = {"horde/gonome/gonome_step1.ogg","horde/gonome/gonome_step2.ogg","horde/gonome/gonome_step3.ogg","horde/gonome/gonome_step4.ogg"}
ENT.SoundTbl_Idle = {"horde/gonome/gonome_idle1.ogg","horde/gonome/gonome_idle2.ogg", "vo/citadel/br_youneedme.wav", "vo/citadel/br_youfool.wav"}
ENT.SoundTbl_MeleeAttack = {"horde/gonome/gonome_melee1.ogg","horde/gonome/gonome_melee2.ogg"}
ENT.SoundTbl_MeleeAttackMiss = {"horde/gonome/gonome_melee1.ogg","horde/gonome/gonome_melee2.ogg"}
ENT.SoundTbl_Pain = {"horde/gonome/gonome_pain1.ogg","horde/gonome/gonome_pain2.ogg","horde/gonome/gonome_pain3.ogg","horde/gonome/gonome_pain4.ogg", "vo/citadel/br_no.wav"}
ENT.SoundTbl_Death = {"vo/citadel/br_no.wav"}
ENT.SoundTbl_SoundTrack = nil
ENT.NextBlastTime = CurTime()
ENT.NextBlastCooldown = 13
ENT.NextSummonTime = CurTime()
ENT.HaveSpawned = false

ENT.Breen_Cooldown = 0
ENT.DamageThreshold = 5000
ENT.DamageReceived = 0
ENT.Horde_NoRandAngle = true

ENT.Timer_Hemo = 3
ENT.Timer_Norm = 2.5

ENT.GeneralSoundPitch1 = 50
ENT.GeneralSoundPitch2 = 50
local attackTimers = {
	[VJ.ATTACK_TYPE_MELEE] = function(self, skipStopAttacks)
		if !skipStopAttacks then
			timer.Create("attack_melee_reset" .. self:EntIndex(), self:GetAttackTimer(self.NextAnyAttackTime_Melee, self.TimeUntilMeleeAttackDamage, self.AttackAnimDuration), 1, function()
				self:StopAttacks()
				self:MaintainAlertBehavior()
			end)
		end
		timer.Create("attack_melee_reset_able" .. self:EntIndex(), self:GetAttackTimer(self.NextMeleeAttackTime), 1, function()
			self.IsAbleToMeleeAttack = true
		end)
	end,
	[VJ.ATTACK_TYPE_RANGE] = function(self, skipStopAttacks)
		if !skipStopAttacks then
			timer.Create("attack_range_reset" .. self:EntIndex(), self:GetAttackTimer(self.NextAnyAttackTime_Range, self.TimeUntilRangeAttackProjectileRelease, self.AttackAnimDuration), 1, function()
				self:StopAttacks()
				self:MaintainAlertBehavior()
			end)
		end
		timer.Create("attack_range_reset_able" .. self:EntIndex(), self:GetAttackTimer(self.NextRangeAttackTime), 1, function()
			self.IsAbleToRangeAttack = true
		end)
	end,
	[VJ.ATTACK_TYPE_LEAP] = function(self, skipStopAttacks)
		if !skipStopAttacks then
			timer.Create("attack_leap_reset" .. self:EntIndex(), self:GetAttackTimer(self.NextAnyAttackTime_Leap, self.TimeUntilLeapAttackDamage, self.AttackAnimDuration), 1, function()
				self:StopAttacks()
				self:MaintainAlertBehavior()
			end)
		end
		timer.Create("attack_leap_reset_able" .. self:EntIndex(), self:GetAttackTimer(self.NextLeapAttackTime), 1, function()
			self.IsAbleToLeapAttack = true
		end)
	end
}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if self.IsFiringRocket then return end
    if self.NextBlastTime < CurTime() then
        local enemy = self:GetEnemy()
        local EnemyDistance = self.EnemyData.Distance
        if enemy and EnemyDistance < 350 then
            if self.DamageReceived >= self.DamageThreshold then
                sound.Play("weapons/physcannon/physcannon_claws_close.wav", self:GetPos())
                sound.Play("weapons/physcannon/physcannon_claws_open.wav", self:GetPos())
                self:VJ_ACT_PLAYACTIVITY("big_flinch", true, self.Timer_Hemo, false)
                timer.Simple(self.Timer_Hemo, function()
                    if not self:IsValid() then return end
                    local blast = ents.Create("prop_combine_ball")
                    blast:SetPos(self:GetPos())
                    blast:SetParent(self)
                    blast:Spawn()
                    blast:Fire("explode","",0)
                    local dmg = DamageInfo()
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageType(DMG_CRUSH)
                    dmg:SetDamage(75)
                    util.BlastDamageInfo(dmg, self:GetPos(), 500)

                    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 450)) do
                        if ent:IsPlayer() then
                            ent:Horde_AddHemorrhage(self)
                            ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 30)
                        end
                    end
                end)
                self.NextBlastTime = CurTime() + self.NextBlastCooldown
                self.DamageReceived = 0
                --attackTimers[VJ.ATTACK_TYPE_RANGE](self)
            else
                sound.Play("weapons/physcannon/physcannon_charge.wav", self:GetPos())
                self:VJ_ACT_PLAYACTIVITY("big_flinch", true, self.Timer_Norm, false)
                timer.Simple(self.Timer_Norm, function()
                    if not self:IsValid() then return end
                    local blast = ents.Create("prop_combine_ball")
                    blast:SetPos(self:GetPos())
                    blast:SetParent(self)
                    blast:Spawn()
                    blast:Fire("explode","",0)
                    local dmg = DamageInfo()
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageType(DMG_CRUSH)
                    dmg:SetDamage(75)
                    util.BlastDamageInfo(dmg, self:GetPos(), 500)

                    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 450)) do
                        if ent:IsPlayer() then
                            ent:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 60)
                            ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 30)
                        end
                    end
                end)
                self.NextBlastTime = CurTime() + self.NextBlastCooldown
                --attackTimers[VJ.ATTACK_TYPE_RANGE](self)
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(148,0,211))
	self:SetCollisionBounds(Vector(25, 25, 90), Vector(-25, -25, 0))
	self:SetModelScale(1.25)
    self.NextBlastTime = CurTime() + self.NextBlastCooldown
	timer.Simple(1, function() self.DamageThreshold = self:GetMaxHealth() * 0.05 end)

	local pos = Vector()
	local ang = Angle()

	local bone_id = self:LookupBone("Bone01")

	pos, ang = self:GetBonePosition(bone_id)
    pos.x = pos.x
    pos.z = pos.z - 90
    pos.y = pos.y + 4

    ang.x = ang.x + 30
    ang.z = ang.z - 50
    ang.y = ang.y + 150
	self.breen = ents.Create("prop_dynamic")
	self.breen:SetModel("models/player/breen.mdl")
	self.breen:Activate()
	self.breen:DeleteOnRemove(self);
	self.breen:SetPos(pos)
	self.breen:SetAngles(ang)
    self.breen:Spawn()
	self.breen:SetColor(Color(255,100,100))
    self.breen:FollowBone(self, bone_id)
	self.breen:SetSequence("zombie_cidle_01")

	bone_id = self:LookupBone("Bone01")
	pos, ang = self:GetBonePosition(bone_id)
    pos.x = pos.x - 17
    pos.z = pos.z - 53
    pos.y = pos.y - 30

	ang.x = ang.x + 30
	ang.z = ang.z - 40

	self.model = ents.Create("prop_dynamic")
	self.model:SetModel("models/weapons/w_rocket_launcher.mdl")
	self.model:Activate()
	self.model:DeleteOnRemove(self);
	self.model:SetPos(pos)
	self.model:SetAngles(ang)
    self.model:Spawn()
    self.model:FollowBone(self, bone_id)
	self.model:SetModelScale(2)

	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end

function ENT:OnRangeAttack(status, enemy)
    if not self.IsAbleToRangeAttack then return end
    self.IsFiringRocket = true
end

function ENT:ExecuteRangeAttack()
    local selfData = self:GetTable()
	if selfData.Dead or selfData.PauseAttacks or selfData.Flinching or selfData.AttackType == VJ.ATTACK_TYPE_MELEE then return end
    local ene = self:GetEnemy()
	local eneValid = IsValid(ene)
	if eneValid then
		selfData.AttackType = VJ.ATTACK_TYPE_RANGE
		//self:PointAtEntity(ene)
		-- Create projectile
		if !self:OnRangeAttackExecute("Init", ene) then
			local projectile = ents.Create(self.RangeAttackEntityToSpawn)
			local target_pos = self:GetEnemy():GetPos()
			projectile:SetPos(self:GetAttachment(1).Pos + Vector(0, 0, 10))
			projectile:SetAngles((target_pos - projectile:GetPos()):Angle())
			projectile:SetOwner(self)
			projectile:SetPhysicsAttacker(self)
            if self.Critical then
                projectile.OwnerCritical = true
            end
			projectile:Spawn()
			projectile:Activate()
			//constraint.NoCollide(self, projectile, 0, 0)
			local phys = projectile:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				--local vel = self:RangeAttackProjVel(projectile)
				local vel = (target_pos - self:GetAttachment(1).Pos) * 1.5
				phys:SetVelocity(vel)
				projectile:SetAngles(vel:GetNormalized():Angle())
				self.model:MuzzleFlash()
			else
				local vel = self:RangeAttackProjVel(projectile)
				projectile:SetVelocity(vel)
				projectile:SetAngles(vel:GetNormalized():Angle())
			end
			self:OnRangeAttackExecute("PostSpawn", ene, projectile)
		end
	end
	if selfData.AttackState < VJ.ATTACK_STATE_EXECUTED then
		if eneValid then -- Play range attack only once, otherwise it will spam it for every projectile!
			self:PlaySoundSystem("RangeAttack")
		end
		selfData.AttackState = VJ.ATTACK_STATE_EXECUTED
		if selfData.TimeUntilRangeAttackProjectileRelease then
			attackTimers[VJ.ATTACK_TYPE_RANGE](self)
            self.IsFiringRocket = nil
		end
	end
end

function ENT:MultipleMeleeAttacks()
	local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
	if EnemyDistance < 100 then
		self.MeleeAttackDistance = 45
		self.TimeUntilMeleeAttackDamage = 0.6
		self.MeleeAttackAnimationFaceEnemy = false
		self.AnimTbl_MeleeAttack = {"vjseq_attack1"}
		self.MeleeAttackExtraTimers = {1.0}
		self.MeleeAttackDamage = 30
		self.MeleeAttackDamageDistance = 120
		self.MeleeAttackDamageType = DMG_SLASH
			
		if self.Breen_Cooldown <= CurTime() then
			sound.Play("vo/Citadel/br_laugh01.wav", self:GetPos(), 100, 50)
			self.Breen_Cooldown = CurTime() + math.random(30,60)
		end
	end
end

function ENT:CustomOnMeleeAttack_AfterChecks(TheHitEntity)
	ParticleEffect("vomit_barnacle",TheHitEntity:GetPos() + self:GetUp()* 10,Angle(0,0,0),nil)
	ParticleEffect("blood_impact_green_01",TheHitEntity:GetPos(),Angle(0,0,0),nil)
	--ParticleEffect("antlion_gib_02_gas",TheHitEntity:GetPos(),Angle(0,0,0),nil)
	--ParticleEffect("antlion_gib_02_gas",TheHitEntity:GetPos() + self:GetUp()* 10,Angle(0,0,0),nil)
	--ParticleEffect("antlion_gib_02_juice",TheHitEntity:GetPos() + self:GetUp()* 10,Angle(0,0,0),nil)

	if TheHitEntity and IsValid(TheHitEntity) and TheHitEntity:IsPlayer() then
        TheHitEntity:Horde_AddHemorrhage(self)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
     return (self:GetEnemy():GetPos() - self:LocalToWorld(Vector(math.random(-10,20),math.random(-10,20),math.random(10,20))))*2 + self:GetUp()*200
end

ENT.Critical = false
function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
    if not self.Critical and self:Health() < self:GetMaxHealth() / 2 then
        self.Critical = true
        self:SetPlaybackRate(1.25)
        self.Timer_Hemo = 2.4
        self.Timer_Norm = 2
    end
	self.DamageReceived = self.DamageReceived + dmginfo:GetDamage()
end

function ENT:TranslateActivity(act)
    --[[
    if act == ACT_RUN or act == ACT_WALK then
        if self.Critical then
            return ACT_RUN
        else
            return ACT_WALK
        end
    end
    ]]
    return self.BaseClass.TranslateActivity(self, act)
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPhysicalDamage(dmginfo) then
		dmginfo:ScaleDamage(0.75)
    elseif HORDE:IsPoisonDamage(dmginfo) then
        dmginfo:ScaleDamage(1.25)
    end
end

VJ.AddNPC("Wallace Breen","npc_vj_horde_breen", "Zombies")
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/