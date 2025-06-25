AddCSLuaFile("shared.lua")
include('shared.lua')


-- Core
ENT.Model = {"models/horde/kingpin/kingpin.mdl"}
ENT.StartHealth = 7000
ENT.HullType = HULL_MEDIUM_TALL

ENT.SightDistance = 10000 -- How far it can see
ENT.SightAngle = 100 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 40 -- How fast it can turn
ENT.MaxJumpLegalDistance = VJ_Set(400, 550) -- The max distance the NPC can jump (Usually from one node to another) | ( UP, DOWN )

-- AI
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2000 -- How close does it have to be until it starts to face the enemy?

ENT.LimitChaseDistance = false -- Should it limit chasing when between certain distances? | true = Always limit | "OnlyRange" = Only limit if it's able to range attack
ENT.LimitChaseDistance_Min = 300 -- Min distance from the enemy to limit its chasing | "UseRangeDistance" = Use range attack's min distance
ENT.LimitChaseDistance_Max = 2000 -- Max distance from the enemy to limit its chasing | "UseRangeDistance" = Use range attack's max distance

ENT.AttackProps = true -- Should it attack props when trying to move?
ENT.PushProps = true -- Should it push props when trying to move?
ENT.PropAP_MaxSize = 2 -- This is a scale number for the max size it can attack/push | x < 1  = Smaller props & x > 1  = Larger props | Default base value: 1
ENT.FindEnemy_CanSeeThroughWalls = true -- Should it be able to see through walls and objects? | Can be useful if you want to make it know where the enemy is at all times

-- Damage/Injured
ENT.BloodColor = "Red"
ENT.Immune_Dissolve = false
ENT.Immune_Physics = false

-- Flinch
ENT.CanFlinch = 0 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.NextFlinchTime = 2
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
ENT.RunAwayOnUnknownDamage = false
ENT.CallForBackUpOnDamage = false

-- Melee
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"attack1", "attack2"} -- Melee Attack Animations
ENT.MeleeAttackDistance = 100 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 165 -- How close does it have to be until it attacks?
ENT.NextMeleeAttackTime = 1 -- How much time until it can use a melee attack?
ENT.TimeUntilMeleeAttackDamage = 0.5 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 60

-- Ranged
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeAttackEntityToSpawn = "obj_gonome_acid_cold" -- The entity that is spawned when range attacking
ENT.RangeDistance = 7000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 1 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = 0.1 -- How much time until the projectile code is ran?
ENT.RangeAttackPos_Up = 65
ENT.RangeAttackPos_Forward = 65
ENT.NextRangeAttackTime = 4 -- How much time until it can use a range attack?
ENT.RangeAttackPos_Right = -20 -- Right/Left spawning position for range attack
ENT.DisableDefaultRangeAttackCode = true

-- Knockback
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = 100 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 100 -- How far it will push you forward | Second in math.random
ENT.MeleeAttackKnockBack_Up1 = 50 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 50 -- How far it will push you up | Second in math.random
ENT.MeleeAttackKnockBack_Right1 = 0 -- How far it will push you right | First in math.random
ENT.MeleeAttackKnockBack_Right2 = 0 -- How far it will push you right | Second in math.random

ENT.FootStepTimeRun = 1 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.PushProps = true -- Should it push props when trying to move?

    -- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"horde/kingpin/kingpin_step01.ogg","horde/kingpin/kingpin_step02.ogg","horde/kingpin/kingpin_step03.ogg"}
ENT.SoundTbl_Breath = {"horde/kingpin/kingpin_breath01.mp3","horde/kingpin/kingpin_breath02.mp3"}
ENT.SoundTbl_Idle = {"horde/kingpin/kingpin_idle01.mp3","horde/kingpin/kingpin_idle02.mp3"}
ENT.SoundTbl_Alert = {"horde/kingpin/kingpin_alert.mp3"}
ENT.SoundTbl_BeforeMeleeAttack = {"horde/kingpin/kingpin_melee.ogg"}
ENT.SoundTbl_MeleeAttackMiss = {"horde/kingpin/kingpin_meleemiss01.ogg","horde/kingpin/kingpin_meleemiss02.ogg"}
ENT.SoundTbl_Pain = {"horde/kingpin/kingpin_injured01.mp3","horde/kingpin/kingpin_injured02.mp3","horde/kingpin/kingpin_injured03.mp3"}
ENT.SoundTbl_Death = {"horde/kingpin/kingpin_death01.ogg"}

ENT.HasSoundTrack = true
ENT.SoundTbl_SoundTrack = {"music/altars_of_apostasy.mp3"} --npcpack/nh2bosssong.mp3npcpack/lgorbifoldremixrevamped.wav
ENT.SoundTrackPlaybackRate = 1

ENT.NextChangeTime = CurTime() + 15
ENT.NextChangeCooldown = 15

-- Ranged Mode: Homing lightning plasma, lightning cannon
-- Melee Mode: Shield, increased movement speed
ENT.Combat_Mode = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
    self:SetCollisionBounds(Vector(35, 35, 110),Vector(-35, -35, 0))
    self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	local shield = ents.Create("prop_dynamic_override")
	shield:SetModel("models/horde/kingpin/kingpin_sphereshield.mdl")
	shield:SetModelScale(0.5)
	shield:SetPos(self:GetPos() + self:OBBCenter())
	shield:SetParent(self)
	shield:DrawShadow(false)
	shield:Spawn()
	shield:Activate()
	self.bShieldActive = true
	self.entShield = shield
	self:DisableShield()
	--self:SetShieldPower(100)
	--self:ActivateShield()
	self.NextChangeTime = CurTime() + 15
end

function ENT:DisableShield()
	if IsValid(self.entShield) then self.entShield:SetNoDraw(true); self.bShieldActive = false end
end

function ENT:EnableShield()
	if IsValid(self.entShield) then self.entShield:SetNoDraw(false); self.bShieldActive = true end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Critical = nil
ENT.damageabsorbed = 0
ENT.damagereleasecooldown = 0
ENT.CVar		= "horde_difficulty"
function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)

	if self.damageabsorbed <= 300 then--&& self.Critical == true
	--local dmg = dmginfo:GetDamage() 
	self.damageabsorbed = self.damageabsorbed + dmginfo:GetDamage() --math.Clamp(dmginfo:GetDamage(), 0, 305)
	--PrintMessage(HUD_PRINTTALK, self.damageabsorbed)
	end
	
	if self.damageabsorbed > 300 && CurTime() > self.damagereleasecooldown && IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) < 900 then
		self.damageabsorbed = 300
		self:VJ_ACT_PLAYACTIVITY("attack_beam_start1", true, 1, false)
		local e = EffectData()
		e:SetOrigin(self:GetPos() + self:OBBCenter() + self:GetForward() * 25)
		sound.Play("ocpack/otheruksound/hit2.wav", self:WorldSpaceCenter(), 1000, math.random(90, 110))
		sound.Play("horde/gadgets/guard" .. tostring(math.random(1,2)) ..".ogg", self:GetPos(), 125, 100, 1, CHAN_AUTO)
		ParticleEffect("static_guard", self:GetPos(), Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)), nil)
		util.Effect("horde_platoon_parry", e, true, true)
			local tracing = util.TraceLine({
                    start = self:GetPos() + self:GetUp() * 90,
                    endpos = self:GetEnemy():WorldSpaceCenter(),
                    filter = {self},
            })
		timer.Simple(0.75, function() if IsValid(self) and IsValid(self:GetEnemy()) then
		sound.Play("bootleg_ultrakill/Shotgun_2_03.wav", self:GetPos(), 1000, math.random(90, 110))
            local BulletTbl = {}
            BulletTbl.Num = 50
			BulletTbl.HullSize = 25
            BulletTbl.TracerName = "AirboatGunHeavyTracer"
            BulletTbl.Src = self:GetPos()--gonene:WorldSpaceCenter()
            BulletTbl.Dir = tracing.HitPos - (self:GetPos())
            BulletTbl.Attacker = self
            BulletTbl.Spread = Vector(35, 35, 35)
            BulletTbl.Tracer = 1
            BulletTbl.Force = 500
            BulletTbl.Damage = self.damageabsorbed / 20
            BulletTbl.Callback = function(attacker, trace, dmginfo) 
			end
			self:FireBullets(BulletTbl)
			self.damageabsorbed = 0
		end end)
	self.damagereleasecooldown = CurTime() + 4
	end

    if not self.Critical and (self:Health() < self:GetMaxHealth() * 0.6) then
        self.Critical = true

		self.NextRangeAttackTime = 2.5 -- How much time until it can use a range attack?
    end
end

function ENT:trace()
local tracedata = {}
	tracedata.start = self:GetPos() + self:GetUp() * 30
	tracedata.endpos = self:GetEnemy():GetPos()
	tracedata.filter = {self}--+ self:GetAimVector()*1000 +self:GetUp()*-40 +self:GetEnemy():OBBCenter()
	tracedata.mask = MASK_SHOT
	return util.TraceLine(tracedata).HitPos
end

    local function beam(owner, pos)
		util.VJ_SphereDamage(owner, owner, pos, 200, 70, DMG_SHOCK, true, true)
		--util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", owner:GetPos() + owner:GetUp() * 60, pos, true, owner:EntIndex(), -1)
        --HORDE:ApplyDebuffInRadius(HORDE.Status_Shock, pos, 200, 10, owner)
        ParticleEffect("striderbuster_break", pos, Angle(0, 0, 0), nil)
    end
	
    local function homing(owner, pos, velo)
            local breen3 = ents.Create("obj_vj_horde_homing_lightning") --Ultraviolet cross
            breen3:SetPos(pos)
            breen3:SetAngles((owner:GetEnemy():WorldSpaceCenter() - owner:GetPos()):Angle())
            breen3:SetOwner(owner)
            breen3:Spawn()
            breen3:Activate()
            breen3:SetOwner(owner)
            local phys3 = breen3:GetPhysicsObject()
            if IsValid(phys3) then phys3:SetVelocity(owner:CalculateProjectile("Line", owner:WorldSpaceCenter(), owner:GetEnemy():WorldSpaceCenter(), velo)) end
            owner:DeleteOnRemove(breen3)
    end

function ENT:CustomRangeAttackCode()

	local specialpos = self:WorldSpaceCenter() + self:GetRight() * 175 + self:GetForward() * 450
	local specialpos2 = self:WorldSpaceCenter() + self:GetRight() * -175 + self:GetForward() * 450
    local rangeattack = math.random(1, 2)
    --local p = math.random()
        if rangeattack == 1 && IsValid(self:GetEnemy()) then
            self.NextRangeAttackTime = 4
			sound.Play("horde/plague_elite/summon.ogg", self:GetPos(), 1000, math.random(90, 110))
			ParticleEffect("cryo_explo_frags", specialpos, Angle(0, 0, 0), nil)
			ParticleEffect("cryo_explo_frags", specialpos2, Angle(0, 0, 0), nil)
			timer.Simple(0.6,function() if IsValid(self) then
			homing(self, self:WorldSpaceCenter(), 500)
			homing(self, specialpos, 200)--self:GetEnemy():WorldSpaceCenter() + self:GetRight() * 705
			homing(self, specialpos2, 200)
			end end)
        elseif rangeattack == 2 && IsValid(self:GetEnemy()) then --Lightning blast
            self.NextRangeAttackTime = 4
            self:VJ_ACT_PLAYACTIVITY("attack_beam_start1", true, 0.1, false) --self.ChargeSound = VJ_CreateSound(self, "npc/strider/charging.wav")
            local pos = self:GetEnemy():GetPos()

                --local pos = self:trace()
                util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetPos() + self:GetUp() * 60, pos + self:GetRight() * -270, true, self:EntIndex(), -1)
                util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetPos() + self:GetUp() * 60, pos + self:GetRight() * 270, true, self:EntIndex(), -1)
                sound.Play("beams/beamstart5.wav", pos, 1000, math.random(90, 110))
                timer.Simple(0.5, function() if IsValid(self) and IsValid(self:GetEnemy()) then
                        beam(self, pos + self:GetRight() * 270)
                        beam(self, pos + self:GetRight() * -270)
                        sound.Play("ambient/explosions/explode_7.wav", pos, 1000, math.random(90, 110))
						if cvars.Number(self.CVar, 1) >= 5 then
							pos = self:GetEnemy():GetPos()
						end
						util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetPos() + self:GetUp() * 60, pos, true, self:EntIndex(), -1)
						util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetPos() + self:GetUp() * 60, pos + self:GetRight() * 60, true, self:EntIndex(), -1)
						util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetPos() + self:GetUp() * 60, pos + self:GetRight() * -60, true, self:EntIndex(), -1)
                    end end) 
                timer.Simple(1, function() if IsValid(self) and IsValid(self:GetEnemy()) then
						if self.Critical then
							local fire = ents.Create("horde_lightning_homing_fire")
							fire:SetOwner(self)
							fire:SetPos(pos)
							fire:Spawn()
							self:DeleteOnRemove(fire)
						end
                        beam(self, pos)
                        beam(self, pos + self:GetRight() * 60)
                        beam(self, pos + self:GetRight() * -60)
                        sound.Play("ambient/explosions/explode_7.wav", pos, 1000, math.random(90, 110))
                    end end) 
				--end end)
    end
end


function ENT:CustomOnThink()
	-- Ability to see through walls
	if CurTime() > self.NextChangeTime and self.Critical then
		self.Combat_Mode = self.Combat_Mode + 1
		if self.Combat_Mode > 1 then
			self.Combat_Mode = 0
		end
		
		if self.Combat_Mode == 0 then
			self:DisableShield()
			--self.HasRangeAttack = true
		else
			self:EnableShield()
			--self.HasRangeAttack = false
		end
		self.NextChangeTime = CurTime() + self.NextChangeCooldown
	end

	if self.Combat_Mode == 1 and self:IsOnGround() then
		self:SetLocalVelocity(self:GetMoveVelocity() * 6)
		self.AnimationPlaybackRate = 1.25
	end

	if self:IsOnFire() then
		self:Extinguish()
	end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if self.bShieldActive then
		dmginfo:SubtractDamage(5)
        dmginfo:ScaleDamage(0.5)
    end
	if HORDE:IsFireDamage(dmginfo) or HORDE:IsLightningDamage(dmginfo) then
		dmginfo:ScaleDamage(0.75)
	elseif HORDE:IsColdDamage(dmginfo) then
		dmginfo:ScaleDamage(1.25)
	end
end

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



function ENT:CustomOnMeleeAttack_AfterStartTimer(seed)
timer.Create( "resetattacks550", 4, 1, function() if IsValid(self) then
attackTimers[VJ.ATTACK_TYPE_MELEE](self)
attackTimers[VJ.ATTACK_TYPE_RANGE](self)
end
end )
end

VJ.AddNPC("Xen Psychic Unit","npc_vj_horde_xen_psychic_unit", "Zombies")