AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/combine_soldier.mdl" -- Leave empty if using more than one model
ENT.StartHealth = 300
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.MeleeAttackDamage = 30
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.SightDistance = 10000 -- How far it can see
ENT.SightAngle = 80 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 20 -- How fast it can turn

ENT.Flinches = 1 -- 0 = No Flinch | 1 = Flinches at any damage | 2 = Flinches only from certain damages
ENT.FlinchingChance = 3 -- chance of it flinching from 1 to x | 1 will make it always flinch
ENT.FlinchingSchedules = {SCHED_FLINCH_PHYSICS} -- If self.FlinchUseACT is false the it uses this | Common: SCHED_BIG_FLINCH, SCHED_SMALL_FLINCH, SCHED_FLINCH_PHYSICS

ENT.MoveWhenDamagedByEnemy = false -- Should the SNPC move when being damaged by an enemy?

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.HasGrenadeAttack = true -- Should the SNPC have a grenade attack?
ENT.NextThrowGrenadeTime1 = 10 -- Time until it runs the throw grenade code again | The first # in math.random
ENT.NextThrowGrenadeTime2 = 15 -- Time until it runs the throw grenade code again | The second # in math.random
ENT.ThrowGrenadeChance = 1 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.GrenadeAttackThrowDistance = 1000 -- How far it can throw grenades
ENT.GrenadeAttackThrowDistanceClose = 500 -- How close until it stops throwing grenades
ENT.AnimTbl_GrenadeAttack = {"grenThrow"} -- Grenade Attack Animations
ENT.GrenadeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.GrenadeAttackAnimationStopAttacks = true -- Should it stop attacks for a certain amount of time?
ENT.GrenadeAttackEntity = "npc_grenade_frag" -- The entity that the SNPC throws | Half Life 2 Grenade: "npc_grenade_frag"
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.CallForBackUpOnDamage = false -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a enemy)
ENT.CanDetectDangers = true
ENT.MoveOrHideOnDamageByEnemy = false

ENT.Weapon_FiringDistanceFar = 15000

ENT.WeaponReload_FindCover = false
ENT.Horde_Plague_Soldier = false

ENT.CallForHelp = false
ENT.CanInvestigate = false

ENT.SoundTbl_Pain = {
"npc/combine_soldier/pain1.wav",
"npc/combine_soldier/pain2.wav",
"npc/combine_soldier/pain3.wav"}

ENT.SoundTbl_Death = {
"npc/combine_soldier/die1.wav",
"npc/combine_soldier/die2.wav",
"npc/combine_soldier/die3.wav"}

ENT.SoundTbl_FootStep = {
"npc/combine_soldier/gear1.wav",
"npc/combine_soldier/gear2.wav",
"npc/combine_soldier/gear3.wav",
"npc/combine_soldier/gear4.wav",
"npc/combine_soldier/gear5.wav",
"npc/combine_soldier/gear6.wav"}

ENT.SoundTbl_Alert = {"zsszombine/alert1.wav","zsszombine/alert2.wav","zsszombine/alert3.wav","zsszombine/alert4.wav","zsszombine/alert5.wav","zsszombine/alert6.wav"}


	-- ====== Sound Pitch ====== --
-- Higher number = Higher pitch | Lower number = Lower pitch
-- Highest number is 254
	-- !!! Important variables !!! --
ENT.UseTheSameGeneralSoundPitch = true
	-- If set to true, it will make the game decide a number when the SNPC is created and use it for all sound pitches set to "UseGeneralPitch"
	-- It picks the number between the two variables below:
ENT.GeneralSoundPitch1 = 75
ENT.GeneralSoundPitch2 = 75
ENT.CVar		= "horde_difficulty"
function ENT:CustomOnInitialize()
	if cvars.Number(self.CVar, 1) > 2 then
		self.FalldamageImmune = true
	end
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self:Horde_AddArmor(150)
	self:Give("weapon_vj_horde_csniper")
	local pos = Vector()
	local ang = Angle()
	local attach_id = self:LookupAttachment("eyes")
	local attach = self:GetAttachment(attach_id)
	pos = attach.Pos
	ang = attach.Ang
	pos.x = pos.x - 3
	pos.z = pos.z - 7
	pos.y = pos.y
	self.model = ents.Create("prop_dynamic")
	self.model:SetModel("models/headcrabblack.mdl")
	self.model:SetColor(Color(255, 0, 0))
	--self.model = ClientsideModel("models/headcrabblack.mdl", RENDERGROUP_OPAQUE)
	self.model:SetSequence("ragdoll")
	self.model:SetPos(pos)
	self.model:SetAngles(ang)
	self.model:Spawn()
	self.model:SetParent(self, attach_id)
	self.model:SetModelScale(1.25)
end

ENT.DamageReceived = 0
ENT.ouchie = false
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    local dmgsource = dmginfo:GetAttacker()
    local effectdata = EffectData()
    util.Effect("MetalSpark", effectdata)
	
    VJ_EmitSound(self, "vj_impact_metal/bullet_metal/metalsolid" .. math.random(1, 10) .. ".wav", 75)
    self.DamageReceived = self.DamageReceived + dmginfo:GetDamage()
    if dmginfo:GetDamage() >= 60 then
        self.ouchie = true
        self:VJ_ACT_PLAYACTIVITY("Cower", true, 0.5, false)
		timer.Simple(0.5, function()
			if IsValid(self) and IsValid(self:GetEnemy()) then
				self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH")
			end
		end)
    end
    --if dmginfo:IsDamageType( DMG_FALL ) == true then
		--dmginfo:SubtractDamage( dmginfo:GetDamage() )
    --end
    timer.Simple(5, function()
        if IsValid(self) and IsValid(self:GetEnemy()) then
            self.ouchie = false
        end
    end)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

VJ.AddNPC("Plague Solder","npc_vj_horde_plague_soldier", "Zombies")