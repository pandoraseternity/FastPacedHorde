AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_zombies/fast_main.mdl"
ENT.StartHealth = 1000
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 32 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 85 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.4 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 55
ENT.MeleeAttackBleedEnemy = false -- Should the player bleed when attacked by melee
ENT.HasLeapAttack = true -- Should the SNPC have a leap attack?
ENT.NextAnyAttackTime_Melee = 0.6

ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfVisible = true -- Should it only face the enemy if it's visible?
ENT.ConstantlyFaceEnemy_IfAttacking = false -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Both" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2500 -- How close does it have to be until it starts to face the enemy?

ENT.AnimTbl_LeapAttack = {"leapstrike"} -- Melee Attack Animations
ENT.LeapDistance = 300 -- The distance of the leap, for example if it is set to 500, when the SNPC is 500 Unit away, it will jump
ENT.LeapToMeleeDistance = 150 -- How close does it have to be until it uses melee?
ENT.TimeUntilLeapAttackDamage = 0.2 -- How much time until it runs the leap damage code?
ENT.NextLeapAttackTime = 10 -- How much time until it can use a leap attack?
ENT.NextAnyAttackTime_Leap = 1 -- How much time until it can use any attack again? | Counted in Seconds
ENT.LeapAttackExtraTimers = {0.4,0.6,0.8,1} -- Extra leap attack timers | it will run the damage code after the given amount of seconds
ENT.TimeUntilLeapAttackVelocity = 0.2 -- How much time until it runs the velocity code?
ENT.LeapAttackVelocityForward = 300 -- How much forward force should it apply?
ENT.LeapAttackVelocityUp = 250 -- How much upward force should it apply?
ENT.LeapAttackDamage = 40
ENT.LeapAttackDamageDistance = 100 -- How far does the damage go?
ENT.FootStepTimeRun = 0.25 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.4 -- Next foot step sound when it is walking

ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = 100 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 130 -- How far it will push you forward | Second in math.random

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"npc/fast_zombie/foot1.wav","npc/fast_zombie/foot2.wav","npc/fast_zombie/foot3.wav","npc/fast_zombie/foot4.wav"}
ENT.SoundTbl_Breath = {"npc/fast_zombie/breathe_loop1.wav"}
ENT.SoundTbl_Alert = {"npc/fast_zombie/fz_alert_close1.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/fast_zombie/claw_strike1.wav","npc/fast_zombie/claw_strike2.wav","npc/fast_zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"zsszombie/miss1.wav","zsszombie/miss2.wav","zsszombie/miss3.wav","zsszombie/miss4.wav"}
ENT.SoundTbl_LeapAttackDamage = {"npc/fast_zombie/claw_strike1.wav","npc/fast_zombie/claw_strike2.wav","npc/fast_zombie/claw_strike3.wav"}
ENT.SoundTbl_Pain = {"npc/fast_zombie/idle1.wav","npc/fast_zombie/idle2.wav","npc/fast_zombie/idle3.wav"}
ENT.SoundTbl_Death = {"npc/fast_zombie/wake1.wav"}

ENT.GeneralSoundPitch1 = 50
ENT.GeneralSoundPitch2 = 50

ENT.HasSoundTrack = false

ENT.Raging = nil
ENT.Raged = nil
ENT.DamageReceived = 0
ENT.NextShoveT = 0
ENT.Attacks = 0
ENT.CVar		= "horde_difficulty"
ENT.hugeleapcooldown = CurTime()
ENT.hugeland = false
ENT.FalldamageImmune = true

ENT.HasWorldShakeOnMove = true -- Should the world shake when it's moving?
ENT.WorldShakeOnMoveAmplitude = 6 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.WorldShakeOnMoveRadius = 200 -- How far the screen shake goes, in world units
ENT.WorldShakeOnMoveDuration = 0.4 -- How long the screen shake will last, in seconds
ENT.WorldShakeOnMoveFrequency = 100 -- Just leave it to 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Rage()
    if self.Raging or self.Raged then return end
    self.Raging = true
    sound.Play("horde/lesion/lesion_enrage.ogg", self:GetPos(), 100, 75)
    self:VJ_ACT_PLAYACTIVITY("BR2_Roar", true, 1.5, false)
	self:EnragedVisual(5, self:WorldSpaceCenter(), self, true)
    timer.Simple(1.5, function ()
        if not IsValid(self) then return end
        self.AnimTbl_Run = ACT_RUN
        self.HasLeapAttack = true
        self.Raged = true
        self.Raging = false
        self:SetColor(Color(255, 50, 50))
    end)
end

function ENT:SetupDataTables() --there is a :Set and a :Get for each variable
	self:NetworkVar( "Entity", 0, "EnrageSprite" )
end

function ENT:TranslateActivity(act)
    -- throw1 idle, throw2 walk, throw3 run
    if (act == ACT_WALK or act == ACT_RUN) then
		if self.Raged then
			return ACT_RUN
        end
        return ACT_WALK
    end
    return self.BaseClass.TranslateActivity(self, act)
end

function ENT:EnragedVisual(time, pos, ent, infinite)
		VJ_EmitSound(ent,"ocpack/enrage.wav" ,500)
		ent:SetColor( Color( 255, 0, 0) )
		enrage = ents.Create("env_sprite")
		enrage:SetKeyValue("model","sprites/orangecore1.vmt")
		enrage:SetKeyValue("rendercolor","255 0 90")
		enrage:SetKeyValue("GlowProxySize", "2.0")
		enrage:SetKeyValue("scale", "2.5")
		enrage:SetKeyValue("HDRColorScale","1.0")
		enrage:SetParent(ent)
		enrage:SetPos(pos)
		enrage:Spawn()
		ent:DeleteOnRemove(enrage)
		self:SetEnrageSprite(enrage)
end

function ENT:CustomOnThink_AIEnabled()

    if self.hugeland == true and self:OnGround() then
        local explosion = EffectData()
        explosion:SetOrigin(self:GetPos())
        explosion:SetMagnitude(200)
        explosion:SetRadius(200)
        explosion:SetScale(200)
        util.Effect("seismic_wave", explosion)
        VJ_EmitSound(self, "ocpack/otheruksound/bigrockbreak.wav", 800)
        util.VJ_SphereDamage(self, self, self:GetPos(), 200, self:VJ_GetDifficultyValue(90), DMG_CLUB, true, true)
        self.hugeland = false
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 200)) do
		if v:IsNextBot() then
			v:LeaveGround()
		end
		if self:Disposition(v) == D_HT then
			DoKnockback(v,self,200,300,0)
		end
	end
    end

	if CurTime() > self.hugeleapcooldown && IsValid(self:GetEnemy()) then
	self:EmitSound("npc/fast_zombie/fz_alert_close1.wav", 1500, 100, 1, CHAN_STATIC)
	self:VJ_ACT_PLAYACTIVITY("jumpnavmove",true,1,true)
	self:SetAngles((self:GetEnemy():GetPos() -self:GetPos()):Angle() )
	self.hugeleapcooldown = CurTime() + 16
	self:SetVelocity(self:GetAngles():Up() * 500 )
    timer.Simple(0.85, function () if IsValid(self) && IsValid(self:GetEnemy()) then
		--self:SetVelocity(self:GetAngles():Up() * 0 )
		--self:SetAngles((self:GetEnemy():GetPos() -self:GetPos()):Angle() )
		self:SetGroundEntity(NULL)
		self:SetLocalVelocity((self:GetEnemy():GetPos() - self:GetPos()):GetNormal()*500 + self:GetUp()*-200 + self:GetForward()*(self:GetPos():Distance(self:GetEnemy():GetPos())+50) )
		self.hugeland = true
		self:EmitSound("horde/lesion/lesion_leap.ogg", 1500, 100, 1, CHAN_STATIC)
		self.AnimTbl_Run = ACT_WALK
    end end)
	end
	
end

function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(13, 13, 50), Vector(-13, -13, 0))
    self:SetModelScale(1.75)
    self.HasLeapAttack = false
    self.AnimTbl_Run = ACT_WALK

    local id = self:GetCreationID()
    timer.Remove("Horde_FlayerRage" .. id)
    timer.Create("Horde_FlayerRage" .. id, 10, 1, function ()
        if not IsValid(self) then return end
        self:Rage()
    end)
	
    timer.Create("Horde_difficultyRage" .. id, 1, 1, function ()
        if not IsValid(self) then return end
		if cvars.Number(self.CVar, 1) >= 4 then
			self:Rage()
		end
    end)

    --self:AddRelationship("npc_headcrab_poison D_LI 99")
	--self:AddRelationship("npc_headcrab_fast D_LI 99")

    local mat = Material("models/horde/lesion/lesion_sheet", "mips smooth")
    self:SetSubMaterial(0, "models/horde/lesion/lesion_sheet")
    self:EmitSound("horde/lesion/lesion_roar.ogg", 1500, 80, 1, CHAN_STATIC)
end

function ENT:CustomOnMeleeAttack_AfterChecks(hitEnt, isProp)
    if isProp then return end
    if hitEnt and IsValid(hitEnt) and hitEnt:IsPlayer() then
        self:UnRage()
        hitEnt:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 30, self)
    elseif not self.Raging then
        -- Reset rage timer if not raging and hitting
        local id = self:GetCreationID()
        timer.Remove("Horde_FlayerRage" .. id)
        timer.Create("Horde_FlayerRage" .. id, 10, 1, function ()
            if not IsValid(self) then return end
            self:Rage()
        end)
    end
end

function ENT:CustomOnMeleeAttack_Miss()
    if not self.Raging then
        -- Reset rage timer if not raging and hitting
        local id = self:GetCreationID()
        timer.Remove("Horde_FlayerRage" .. id)
        timer.Create("Horde_FlayerRage" .. id, 10, 1, function ()
            if not IsValid(self) then return end
            self:Rage()
        end)
    end
end

function ENT:UnRage()
	if IsValid(self:GetEnrageSprite()) then
		self:GetEnrageSprite():Fire("Kill", "", 0.1)
	end
    self.Raged = nil
    self.Raging = nil
    self.DamageReceived = 0
    self.HasLeapAttack = false
    self.AnimTbl_Run = ACT_WALK
    self:SetColor(Color(255,255,255))
    local id = self:GetCreationID()
    timer.Remove("Horde_FlayerRage" .. id)
    timer.Create("Horde_FlayerRage" .. id, 10, 1, function ()
        if not IsValid(self) then return end
        self:Rage()
    end)
end

function ENT:CustomOnLeapAttack_BeforeChecks(hitEnt, isProp)
    self:EmitSound("horde/lesion/lesion_leap.ogg")
end

function ENT:CustomOnLeapAttack_AfterChecks(hitEnt, isProp)
    if isProp then return end
    if hitEnt and IsValid(hitEnt) and (HORDE:IsPlayerOrMinion(hitEnt) == true) then
        self:UnRage()
        hitEnt:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 60, self)
    end
end

function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
    self.DamageReceived = self.DamageReceived + dmginfo:GetDamage()
    if self.DamageReceived >= self:GetMaxHealth() * 0.25 then
        if self.Horde_Stunned then return end
        self:Rage()
        self.DamageReceived = 0
    end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)

	if dmginfo:GetDamage() >= 110 && CurTime() > self.NextShoveT then
		self.hugeland = false
		self:UnRage()
		self.NextShoveT = CurTime() + 6
		self:VJ_ACT_PLAYACTIVITY("vjseq_landleft",true,5,false)
	end

end

VJ.AddNPC("Lesion","npc_vj_horde_lesion", "Zombies")