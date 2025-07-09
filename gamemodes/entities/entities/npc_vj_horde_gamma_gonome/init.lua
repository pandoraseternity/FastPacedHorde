AddCSLuaFile("shared.lua")
include('shared.lua')
include('autorun/vj_controls.lua')

-- Core
ENT.Model = {"models/horde/gonome/gonome.mdl"}
ENT.StartHealth = 8500
ENT.HullType = HULL_MEDIUM_TALL

ENT.SightDistance = 10000 -- How far it can see
ENT.SightAngle = 100 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 40 -- How fast it can turn
ENT.MaxJumpLegalDistance = VJ_Set(400, 550) -- The max distance the NPC can jump (Usually from one node to another) | ( UP, DOWN )

-- AI
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.ConstantlyFaceEnemy = false -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2000 -- How close does it have to be until it starts to face the enemy?

ENT.PushProps = true -- Should it push props when trying to move?
ENT.PropAP_MaxSize = 2 -- This is a scale number for the max size it can attack/push | x < 1  = Smaller props & x > 1  = Larger props | Default base value: 1
ENT.FindEnemy_CanSeeThroughWalls = true -- Should it be able to see through walls and objects? | Can be useful if you want to make it know where the enemy is at all times

-- Damage/Injured
ENT.BloodColor = "Red"
--ENT.Immune_Dissolve = true
--ENT.Immune_Physics = true

-- Flinch
ENT.CanFlinch = 0 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.NextFlinchTime = 2
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
ENT.RunAwayOnUnknownDamage = false
ENT.CallForBackUpOnDamage = false

-- Melee
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"vjges_attack1"} -- Melee Attack Animations
ENT.MeleeAttackDistance = 35 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 90 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.6 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0 -- How much time until it can use any attack again? | Counted in Seconds
ENT.MeleeAttackDamage = 50
ENT.MeleeAttackDSPSoundType = false
ENT.MeleeAttackWorldShakeOnMiss = true
ENT.MeleeAttackWorldShakeOnMissAmplitude = 2
ENT.MeleeAttackAnimationAllowOtherTasks = true
ENT.RangeAttackAnimationAllowOtherTasks = true -- If set to true, the animation will not stop other tasks from playing, such as chasing | Useful for gesture attacks!

-- Ranged
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {""} -- Range Attack Animations "vjges_attack3"
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_gonome_acid_cold" -- The entity that is spawned when range attacking
ENT.RangeDistance = 8000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 0 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = false -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "Mouth" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.TimeUntilRangeAttackProjectileRelease = 1.5 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 5 -- How much time until it can use a range attack?
ENT.NextAnyAttackTime_Range = 0.5 -- How much time until it can use any attack again? | Counted in Seconds
ENT.DisableDefaultRangeAttackCode = true

ENT.HasSoundTrack = true -- Does the SNPC have a sound track?
ENT.SoundTrackVolume = 1
ENT.SoundTbl_SoundTrack = {"ocpack/music/vesselsofveng.mp3"}

-- Leap
ENT.HasLeapAttack = false
ENT.AnimTbl_LeapAttack = {ACT_RANGE_ATTACK2}
ENT.LeapAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.NextLeapAttackTime = 15
ENT.LeapAttackVelocityForward = 400
ENT.LeapAttackVelocityUp = 0
ENT.LeapAttackDamageDistance = 150

-- Knockback
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy

ENT.LimitChaseDistance = false -- Should it limit chasing when between certain distances? | true = Always limit | "OnlyRange" = Only limit if it's able to range attack
ENT.LimitChaseDistance_Min = 300 -- Min distance from the enemy to limit its chasing | "UseRangeDistance" = Use range attack's min distance
ENT.LimitChaseDistance_Max = 2000 -- Max distance from the enemy to limit its chasing | "UseRangeDistance" = Use range attack's max distance

ENT.FootStepTimeRun = 1 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.PushProps = true -- Should it push props when trying to move?
ENT.FootStepPitch1 = 100
ENT.FootStepPitch2 = 100
ENT.BreathSoundPitch1 = 100
ENT.BreathSoundPitch2 = 100

    -- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"horde/gonome/gonome_step1.ogg","horde/gonome/gonome_step2.ogg","horde/gonome/gonome_step3.ogg","horde/gonome/gonome_step4.ogg"}
ENT.SoundTbl_Idle = {"horde/gonome/gonome_idle1.ogg","horde/gonome/gonome_idle2.ogg"}
ENT.SoundTbl_MeleeAttack = {"horde/gonome/gonome_melee1.ogg","horde/gonome/gonome_melee2.ogg"}
ENT.SoundTbl_MeleeAttackMiss = {"zombie/claw_miss1.wav","zombie/claw_miss2.wav"}
ENT.SoundTbl_BeforeLeapAttack = nil
ENT.SoundTbl_LeapAttackJump = {"horde/gonome/gonome_jumpattack.ogg"}
ENT.SoundTbl_Pain = {"horde/gonome/gonome_pain1.ogg","horde/gonome/gonome_pain2.ogg","horde/gonome/gonome_pain3.ogg","horde/gonome/gonome_pain4.ogg"}
ENT.SoundTbl_Death = {"horde/gonome/gonome_death.ogg"}

ENT.Horde_Gamma_Invis = false
ENT.Critical = false
ENT.NextBlastTime = CurTime()
ENT.NextBlastCooldown = 20
ENT.criticalstats = 1
ENT.NextEvasion = CurTime()
ENT.InvisBreakDmg = 0
ENT.CVar		= "horde_difficulty"
ENT.turnright = -140
ENT.turnleft = 140
ENT.arcattack = 0
ENT.arcattackcool = 0
ENT.charging = 0
ENT.skyattack = false
ENT.skyattackcool = CurTime()
ENT.enraged = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
    self:SetCollisionBounds(Vector(20, 20, 85), Vector(-20, -20, 0))
	--self:SetVar("is_boss", true)
	--self:Horde_SetBossDefaultArmor(0)
	--self:Horde_SetBossMaxArmor(150)
    self:SetSkin(1)
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self.Horde_Gamma_Invis = true
    self:SetColor(Color(0, 150, 255, 200))
	self:SetRenderFX(16)
end

function ENT:TranslateActivity(act)
	if act == ACT_WALK then
		return ACT_RUN
	elseif act == ACT_RUN  then
		return ACT_RUN_AIM
	end
	return self.BaseClass.TranslateActivity(self, act)
end

function ENT:GoInvis()
	if self.Horde_Gamma_Invis == true then return end
	sound.Play("horde/spells/void_maw.ogg", self:GetPos(), 100, 100)
    self:SetColor(Color(0, 150, 255, 20))
    self.Horde_Gamma_Invis = true
	self:SetRenderFX(16)
end

function ENT:UnInvis()
	if self.Horde_Gamma_Invis == false then return end
	sound.Play("ambient/energy/whiteflash.wav", self:GetPos(), 100, 70)
    self:SetColor(Color(0, 150, 255, 255))
    self.Horde_Gamma_Invis = false
	self.HasRangeAttack = true
	self:SetRenderFX(0)
end

function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward()*math.random(150, 300)
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	local p2 = math.random()
    if dmginfo:GetAttacker() == self then dmginfo:SetDamage(0) return true end
	if HORDE:IsColdDamage(dmginfo) then
		dmginfo:ScaleDamage(0.5)
    elseif HORDE:IsFireDamage(dmginfo) then
        dmginfo:ScaleDamage(1.1)
    end
	
	if self:IsOnFire() == true then
		dmginfo:ScaleDamage(1.75)
		if self.enraged == false then
			self.enraged = true
			EnragedVisual(5, self:WorldSpaceCenter(), self)
			self.criticalstats = 0.75
			timer.Simple(5, function() if IsValid(self) then
				if self.Critical == false then
					self.criticalstats = 1
				end
				self:SetColor(Color(0, 150, 255, 255))
				self.enraged = false
			end end)
		end
	end

    if self.InvisBreakDmg >= 1000 then
        self:UnInvis()
        local id = self:GetCreationID()
        timer.Remove("Horde_GammaInvis" .. id)
		timer.Create("Horde_GammaInvis" .. id, 6, 1, function () if self.Horde_Gamma_Invis == false then
			if not self:IsValid() then timer.Remove("Horde_GammaInvis" .. id) return end
			if self.Horde_Gamma_Invis == true then return end
			self:GoInvis()
		end end)
        self.InvisBreakDmg = 0
		
    else
        self.InvisBreakDmg = self.InvisBreakDmg + dmginfo:GetDamage()
    end
	
	if self.Horde_Gamma_Invis == false then
		dmginfo:ScaleDamage(0.75)
	end
	
	if self.Horde_Gamma_Invis == true && CurTime() > self.NextEvasion then
		if p2 >= 0.5 && dmginfo:GetDamage() < 80 then
			self.NextEvasion = CurTime() + 0.5
			sound.Play("horde/player/evade.ogg", self:GetPos(), 1250, 100, 1, CHAN_AUTO)
			sound.Play("horde/player/quickstep.ogg", self:GetPos(), 1250, 100, 1, CHAN_AUTO)
			dmginfo:SetDamage(0)
		end
	end
	
end

function ENT:CustomOnMeleeAttack_BeforeChecks()
	if self.Critical == false then
		self:UnInvis()
	end
    local id = self:GetCreationID()
    timer.Remove("Horde_GammaInvis" .. id)
    timer.Create("Horde_GammaInvis" .. id, 1.5, 1, function () if self.Horde_Gamma_Invis == false then
        if not self:IsValid() then timer.Remove("Horde_GammaInvis" .. id) return end
		if self.Horde_Gamma_Invis == true then return end
        self:GoInvis()
    end end)
end

function ENT:CustomOnMeleeAttack_AfterChecks(hitEnt,isProp)
    if isProp then return end
	if hitEnt and IsValid(hitEnt) and cvars.Number(self.CVar, 1) >= 3 and engine.ActiveGamemode() == "horde" then 
	--hitEnt:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 20, self)
	hitEnt:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 20, self)
	end	
end

function ENT:ColdAttack(delay, dir)
	local ene = self:GetEnemy()
	local pos = ene:GetPos() + dir
    timer.Simple(delay - 1, function() if IsValid(ene) then
		if not self:IsValid() then return end
        local rand = VectorRand()
        rand.z = 0
        pos = ene:GetPos() + dir

        local e = EffectData()
			e:SetOrigin(pos)
			e:SetScale(1)
		util.Effect("horde_ring_effect", e, true, true)
	end end)
	timer.Simple(delay, function()
		if not self:IsValid() then return end
        local rand = VectorRand()
        rand.z = 0
        --local pos = ene:GetPos() + dir

		/*local dmg = DamageInfo()
		dmg:SetAttacker(self)
		dmg:SetInflictor(self)
		dmg:SetDamageType(DMG_BLAST)
		dmg:SetDamage(75)
		util.BlastDamageInfo(dmg, pos, 200)*/
		util.VJ_SphereDamage(self,self,pos,200,75,DMG_BLAST,true,true)

		for _, ent in pairs(ents.FindInSphere(pos, 200)) do
			if ent:IsPlayer() then
				ent:Horde_AddDebuffBuildup(HORDE.Status_Necrosis, 6, self)
				ent:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 8, self)
			end
		end

        local e = EffectData()
			e:SetOrigin(pos)
			e:SetScale(1)
		util.Effect("weeper_blast", e, true, true)
        sound.Play("horde/status/cold_explosion.ogg", pos, 80, math.random(70, 90))
	end)
end

function ENT:OnThinkActive()
	if self.Critical && cvars.Number(self.CVar, 1) >= 4 then
		local ene = self:GetEnemy()
        if not self:GetEnemy() then return end
        local EnemyDistance = self.NearestPointToEnemyDistance
        if EnemyDistance < 800 then
            if CurTime() > self.NextBlastTime then
                sound.Play("horde/gonome/gonome_jumpattack.ogg", self:GetPos(), 100, 30)
                --self:VJ_ACT_PLAYACTIVITY("big_flinch", true, 5, false)
                local p = math.random()
                local p2 = math.random()
                -- Cross shape blast
                for i = 1, 20 do
                    self:ColdAttack(2, ene:GetForward() * i * 100)
                    self:ColdAttack(2, -ene:GetForward() * i * 100)
                    self:ColdAttack(2, ene:GetRight() * i * 100)
                    self:ColdAttack(2, -ene:GetRight() * i * 100)
                    
                    local k1 = ene:GetForward() + ene:GetRight()
                    k1:Normalize()
                    local k2 = ene:GetForward() - ene:GetRight()
                    k2:Normalize()
                    self:ColdAttack(4, k1 * i * 100)
                    self:ColdAttack(4, -k1 * i * 100)
                    self:ColdAttack(4, k2 * i * 100)
                    self:ColdAttack(4, -k2 * i * 100)

                    --if p <= 0.5 then
                        if p2 <= 0.5 then
                            self:ColdAttack(6, ene:GetForward() * i * 100)
                            self:ColdAttack(6, -ene:GetForward() * i * 100)
                            self:ColdAttack(6, ene:GetRight() * i * 100)
                            self:ColdAttack(6, -ene:GetRight() * i * 100)
                        else
                            self:ColdAttack(6, k1 * i * 100)
                            self:ColdAttack(6, -k1 * i * 100)
                            self:ColdAttack(6, k2 * i * 100)
                            self:ColdAttack(6, -k2 * i * 100)
                        end
                    --end
                end
                self.NextBlastTime = CurTime() + self.NextBlastCooldown
            end
        end
	end

    if self:IsOnGround() and (self.Horde_Gamma_Invis == true or self.enraged == true) then
        if self.Critical then
            self:SetLocalVelocity(self:GetMoveVelocity() * 6)
        else
            self:SetLocalVelocity(self:GetMoveVelocity() * 3)
        end
	end
	
	local gonene = self:GetEnemy()
	local p = math.random()
	if self.arcattack == 1 && CurTime() > self.arcattackcool && self:GetEnemy() then
		VJ_EmitSound(self, "horde/spells/neutron_beam.ogg", 2000)
		local arc = ents.Create("obj_vj_horde_gamma_projectiles") --COLD ACID
		arc.type = 1
		arc:SetPos(self:WorldSpaceCenter() + self:GetUp() * 20 +self:GetForward() * 20 )
		arc:SetAngles((self:GetEnemy():WorldSpaceCenter() - self:WorldSpaceCenter()):Angle())
		arc:SetOwner(self)
		arc:Spawn()
		local phys = arc:GetPhysicsObject()
		if IsValid(phys) && IsValid(gonene) then
			phys:SetVelocity(VJ.CalculateTrajectory(self, NULL, "Line", self:WorldSpaceCenter(), gonene:WorldSpaceCenter() + self:GetUp() * -10 +self:GetRight()*(self.turnright), projectile_velocity ))
		end
		arc:Activate()
		self:DeleteOnRemove(arc)
		if p <= 0.075 then
			local arc = ents.Create("obj_miscproj") --homing wraith ball
			arc.type = 6
			arc:SetPos(self:WorldSpaceCenter() + self:GetUp() * 20 +self:GetForward() * 20 )
			arc:SetAngles((self:GetEnemy():WorldSpaceCenter() - self:WorldSpaceCenter()):Angle())
			arc:SetOwner(self)
			arc:Spawn()
			local phys = arc:GetPhysicsObject()
			if IsValid(phys) && IsValid(gonene) then
				phys:SetVelocity(self:CalculateProjectile("Line", self:WorldSpaceCenter(), gonene:WorldSpaceCenter() + self:GetUp() * -10 +self:GetRight()*(self.turnright), (400 + (200 * cvars.Number(self.CVar, 1))) ))
			end
			arc:Activate()
			self:DeleteOnRemove(arc)
		end
		self.turnright = self.turnright + 65
		self.arcattackcool = CurTime() + 0.075
	end
	
	if self.skyattack == true && CurTime() > self.skyattackcool && self:GetEnemy() then
		VJ_EmitSound(self, "horde/spells/neutron_beam.ogg", 2000)
		local arc = ents.Create("obj_vj_horde_gamma_projectiles") --aerial hale
		arc.type = 2
		arc:SetPos(self:WorldSpaceCenter() + self:GetUp() * math.random(80,200) + self:GetRight() * math.random(-80,200) )
		arc:SetAngles((self:GetEnemy():WorldSpaceCenter() - self:GetPos()):Angle())
		arc:SetOwner(self)
		arc:Spawn()
		arc:Activate()
		self:DeleteOnRemove(arc)
		self.skyattackcool = CurTime() + 0.25
	end
	
end
---------------------------------------------------------------------------------------------------------------------------------------------

function ENT:MultipleMeleeAttacks()
    local randattack = math.random(1,2)
	if randattack == 1 then
		self.MeleeAttackDistance = 80
		self.TimeUntilMeleeAttackDamage = 0.6
		self.MeleeAttackAnimationFaceEnemy = false
		self.AnimTbl_MeleeAttack = {"vjges_attack1"}
		self.MeleeAttackExtraTimers = {1.0} 
		self.MeleeAttackDamage = 65
		self.MeleeAttackDamageDistance = 120
		self.MeleeAttackDamageType = DMG_SLASH
		self.NextAnyAttackTime_Melee = 0.6
		
	elseif randattack == 2 then
		self.MeleeAttackDistance = 70
		self.TimeUntilMeleeAttackDamage = 0.5
		self.MeleeAttackAnimationFaceEnemy = false
		self.AnimTbl_MeleeAttack = {"vjges_attack2"}
		self.MeleeAttackExtraTimers = {0.9,1.2,1.4} 
		self.MeleeAttackDamage = 55
		self.MeleeAttackDamageDistance = 100
		self.MeleeAttackDamageType = DMG_SLASH
		self.NextAnyAttackTime_Melee = 0.8
end
end

function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
    if not self.Critical and (self:Health() < self:GetMaxHealth() * 0.6) then
        self.Critical = true
		self.criticalstats = 0.75
		self:EmitSound("weapons/physcannon/physcannon_charge.wav", 15000, 100)
        --self:SetColor(Color(0, 150, 255, 255))
		--util.SpriteTrail( self, 1, Color( 255, 255, 255 ), false, 22, 35, 0.2, 5, "effects/laser_citadel1" )
    end
end

function ENT:DoTrace()
	local tracedata = {}
	tracedata.start = self:GetPos() +self:GetUp()*40
	tracedata.endpos = self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()
	tracedata.filter = {self}
	return util.TraceLine(tracedata).HitPos
end

function ENT:OnRangeAttack(status, enemy)
if status == "Init" then
    local rangeattack = math.random(1, 4)
    local beam = util.TraceLine({
        start = self:GetPos(), --&& self:Visible(self:GetEnemy()) 
        endpos = self:GetPos() + self:GetForward() * 7500,
        filter = self
    })

    if rangeattack == 1 and IsValid(self:GetEnemy()) then
        self.NextRangeAttackTime = 5 * self.criticalstats -- How much time until it can use a range attack?
        self.RangeAttackExtraTimers = nil
        self.RangeAttackReps = 1
		ParticleEffect("black_hole_sparks", self:GetPos() + self:GetUp() * 20, Angle(0, 0, 0), nil)
		local spr2 = ents.Create("env_sprite")
		spr2:SetKeyValue("model", "sprites/animglow02.vmt")
		spr2:SetKeyValue("rendercolor", "255 255 255")
		spr2:SetKeyValue("GlowProxySize", "2.0")
		spr2:SetKeyValue("HDRColorScale", "1.0")
		spr2:SetKeyValue("scale", "2")
		spr2:SetParent(self)
		spr2:SetPos(self:GetPos() + self:GetUp() * 35)
		spr2:Spawn()
		self:DeleteOnRemove(spr2)
		spr2:Fire("Kill", "", 1)
		self:EmitSound("bootleg_ultrakill/Charging.wav", 1500, 100)
		self.charging = true
		timer.Simple(1,function() if IsValid(self) && IsValid(self:GetEnemy()) then
			self.skyattack = true
			self:UnInvis()
			timer.Create( "skyattacktime" .. self:EntIndex(), 2, 1, function() if IsValid(self) then
				self.skyattack = false
				self:GoInvis()
			end end)
		end end)
    elseif rangeattack == 2 and IsValid(self:GetEnemy()) then
        self.NextRangeAttackTime = 3 * self.criticalstats--self.artilleryontimer = 1 -- How much time until it can use a range attack?
        self.RangeAttackExtraTimers = nil
        self.RangeAttackReps = 1
		local spr2 = ents.Create("env_sprite")
		spr2:SetKeyValue("model", "sprites/orangeflare1.vmt")
		spr2:SetKeyValue("rendercolor", "255 255 255")
		spr2:SetKeyValue("GlowProxySize", "2.0")
		spr2:SetKeyValue("HDRColorScale", "1.0")
		spr2:SetKeyValue("scale", "2")
		spr2:SetParent(self)
		spr2:SetPos(self:GetPos() + self:GetUp() * 35)
		spr2:Spawn()
		self:DeleteOnRemove(spr2)
		spr2:Fire("Kill", "", 0.6)
		self:EmitSound("horde/spells/neutron_beam.ogg", 1500, 100)
		self.charging = true
		timer.Simple(0.6,function() if IsValid(self) && IsValid(self:GetEnemy()) then
			self.arcattack = 1
			timer.Create( "arcattacktime" .. self:EntIndex(), 1, 1, function() if IsValid(self) then 
				self.charging = false
				self.turnright = -140
				self.turnleft = 140
				self.arcattack = 0
			end end)
		end end)
    elseif rangeattack == 3 and IsValid(self:GetEnemy()) then
        self.NextRangeAttackTime = 3 * self.criticalstats-- How much time until it can use a range attack?
        self.RangeAttackExtraTimers = nil
        self.RangeAttackReps = 1
        local spr2 = ents.Create("env_sprite")
        spr2:SetKeyValue("model", "effects/tesla_glow_noz.vmt")
        spr2:SetKeyValue("GlowProxySize", "2.0") --spr1:SetKeyValue("rendercolor","0 0 255")
        spr2:SetKeyValue("HDRColorScale", "1.0")
        spr2:SetKeyValue("scale", "2")
        spr2:SetParent(self)
        spr2:SetPos(self:WorldSpaceCenter())
        spr2:Spawn()
        self:DeleteOnRemove(spr2)
        spr2:Fire("Kill", "", 0.8)
		VJ_EmitSound(self, "ocpack/ror2/laserready.mp3", 2000)
		self.charging = 1
        timer.Create( "SuperCold" .. self:EntIndex(), 0.5, 1, function() if IsValid(self) and IsValid(self:GetEnemy()) then
                local posit = self:GetPos() + self:GetUp() * 50
                local gonene = self:GetEnemy()
					timer.Create("bing" .. self:EntIndex(), 1, 1, function()
						if IsValid(self) and IsValid(gonene) then
							attackpos = self:DoTrace()
							util.ParticleTracerEx("Weapon_Combine_Ion_Cannon", self:GetPos(), attackpos, true, self:EntIndex(), 1)
						end
					end)
					timer.Create("boom" .. self:EntIndex(), 1.4, 1, function() if IsValid(self) then
							self.charging = 0
							VJ_EmitSound(self, "ocpack/ror2/laserbig.mp3", 2000)
							VJ_EmitSound(self, "ocpack/blazegeyser.wav", 4000)
							local effectdata = EffectData()
							effectdata:SetOrigin(attackpos)
							effectdata:SetMagnitude(200)
							effectdata:SetRadius(200)
							effectdata:SetScale(200)
							util.Effect("ThumperDust", effectdata)
							util.Effect("explosion", effectdata)
							ParticleEffect("nether_mine_explode", attackpos, Angle(0, 0, 0), self.Owner)
							util.VJ_SphereDamage(self, self, attackpos, 180, 200, DMG_BLAST, true, false, {
								Force = 250
							})
							for k, v in pairs(ents.FindInSphere(attackpos, 180)) do
								if self:Disposition(v) == D_HT then v:SetVelocity(self:GetForward() * 300 + self:GetUp() * 350 + self:GetRight() * 225) end
							end
						end
					end)
					
                end
            end)
    elseif rangeattack == 4 and IsValid(self:GetEnemy()) then
        local oof = self:GetEnemy()
        self.NextRangeAttackTime = 6.5 -- How much time until it can use a range attack?
        self.RangeAttackExtraTimers = nil
        self.RangeAttackReps = 1
		local arc = ents.Create("obj_vj_horde_gammalaser") --gamma beam
		--arc.type = 1
		--arc:SetPos(self:WorldSpaceCenter() + self:GetUp() * 125)
		arc:SetPos(self:GetEnemy():GetPos() + self:GetUp() * -5)
		arc:SetAngles((self:GetEnemy():WorldSpaceCenter() - self:GetPos()):Angle())
		arc:SetOwner(self)
		arc:Spawn()
		arc:Activate()
		self:DeleteOnRemove(arc)
		--self:VJ_ACT_PLAYACTIVITY("big_flinch", true, 8.5, false)
		
	end
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

timer.Create( "resetattacks2" .. self:EntIndex(), 8, 1, function() if IsValid(self) then
attackTimers[VJ.ATTACK_TYPE_MELEE](self)
attackTimers[VJ.ATTACK_TYPE_RANGE](self)
end
end )

end

ENT.WaitBeforeDeathTime = 3 -- Time until the SNPC spawns its corpse and gets removed
function ENT:CustomOnPriorToKilled(dmginfo, hitgroup)
    self.HasSoundTrack = false
    self.VJTag_SD_PlayingMusic = false
    self:StopMoving() --start of the end
	self:VJ_ACT_PLAYACTIVITY("Diesimple", true, 0, false)
    self:SetAbsVelocity(self:GetForward() * 0 + self:GetUp() * 0 + self:GetRight() * 0)
    self:CapabilitiesRemove(CAP_MOVE_GROUND)
    util.ScreenShake(self:GetPos(), 320, 5, 5.5, 2000)
    self.StartLight2 = ents.Create("light_dynamic")
    self.StartLight2:SetKeyValue("brightness", "10")
    self.StartLight2:SetKeyValue("distance", "500")
    self.StartLight2:SetLocalPos(self:GetPos())
    self.StartLight2:SetLocalAngles(self:GetAngles())
    self.StartLight2:Fire("Color", "255 255 255")
    self.StartLight2:SetParent(self)
    self.StartLight2:Spawn()
    self.StartLight2:Activate()
    self.StartLight2:Fire("TurnOn", "", 0.5)
    self:DeleteOnRemove(self.StartLight2)
    local trail = ents.Create("info_particle_system")
    trail:SetKeyValue("effect_name", "black_hole")
    trail:SetOwner(self)
    trail:SetPos(self:GetPos())
    trail:SetAngles(self:GetAngles())
    trail:Spawn()
    trail:Activate()
    trail:Fire("start", "", 0)
    trail:Fire("Kill", "", 5)
    sound.Play("horde/spells/black_hole.ogg", self:GetPos(), 500, 100, 1, CHAN_AUTO)
end

function ENT:CustomOnKilled(dmginfo, hitgroup) -- activates when ragdoll spawns
    util.ScreenShake(self:GetPos(), 320, 5, 5.5, 2000)
    VJ_EmitSound(self, "ambience/the_horror1.wav", 4000, 90, 150)
    VJ_EmitSound(self, "ambience/the_horror1.wav", 4000, 40, 150) --cries of the damned
    self:EmitSound("npcpack/beamstart4.wav", 4000, 100, 1)
    self:EmitSound("npcpack/beamstart4.wav", 4000, 100, 1)
    self:EmitSound("npcpack/beamstart4.wav", 4000, 100, 1)
    for x = 1, 3 do
        local blast = ents.Create("env_explosion")
        blast:SetPos(self:GetPos())
        blast:Spawn()
        blast:Fire("explode", "", 0)
    end
    local spr1 = ents.Create("env_sprite") --his otherworldly being is not long for gmod
    spr1:SetKeyValue("model", "sprites/glow1_noz.vmt")
    spr1:SetKeyValue("rendercolor", "255 100 100")
    spr1:SetKeyValue("GlowProxySize", "2.0")
    spr1:SetKeyValue("HDRColorScale", "1.0")
    spr1:SetKeyValue("renderfx", "14")
    spr1:SetKeyValue("rendermode", "5")
    spr1:SetKeyValue("renderamt", "255")
    spr1:SetKeyValue("framerate", "15.0")
    spr1:SetKeyValue("spawnflags", "1")
    spr1:SetKeyValue("scale", "4")
    spr1:SetPos(self:GetPos() + self:GetUp() * 50)
    spr1:Spawn()
    spr1:Fire("Kill", "", 2.5)
    ParticleEffect("shadowdragon_eruption_3", self:GetPos(), self:GetAngles())
end

VJ.AddNPC("Gamma Gonome","npc_vj_horde_gamma_gonome", "Zombies")