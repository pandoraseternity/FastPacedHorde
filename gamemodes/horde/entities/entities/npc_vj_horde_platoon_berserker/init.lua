AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/police.mdl" -- Leave empty if using more than one model
ENT.StartHealth = 5000
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.MeleeAttackDamage = 30
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.SightDistance = 10000 -- How far it can see
ENT.SightAngle = 80 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 20 -- How fast it can turn
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasBloodParticle = true -- Does it spawn a particle when damaged?
ENT.HasBloodDecal = true -- Does it spawn a decal when damaged?
ENT.HasBloodPool = false -- Does it have a blood pool?
ENT.Flinches = 1 -- 0 = No Flinch | 1 = Flinches at any damage | 2 = Flinches only from certain damages
ENT.FlinchingChance = 12 -- chance of it flinching from 1 to x | 1 will make it always flinch
ENT.FlinchingSchedules = {SCHED_FLINCH_PHYSICS} -- If self.FlinchUseACT is false the it uses this | Common: SCHED_BIG_FLINCH, SCHED_SMALL_FLINCH, SCHED_FLINCH_PHYSICS
ENT.HasAllies = true -- Put to false if you want it not to have any allies
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.Weapon_MaxDistance  = 80
ENT.ThrowGrenadeChance = 1 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.GrenadeAttackThrowDistance = 1000 -- How far it can throw grenades
ENT.GrenadeAttackThrowDistanceClose = 500 -- How close until it stops throwing grenades
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.CallForBackUpOnDamage = false -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a enemy)
ENT.CanDetectDangers = false
ENT.MoveOrHideOnDamageByEnemy = false
ENT.WeaponSpread = 1.5
ENT.Weapon_FiringDistanceFar = 2500
ENT.WeaponReload_FindCover = false
ENT.Horde_Plague_Soldier = true

    -- ====== Item Drops On Death Variables ====== --
ENT.HasItemDropsOnDeath = false -- Should it drop items on death?
ENT.DropWeaponOnDeath = false -- Should it drop its weapon on death?

ENT.SoundTbl_Pain = {
"npc/combine_soldier/pain1.wav",
"npc/combine_soldier/pain2.wav",
"npc/combine_soldier/pain3.wav"}

ENT.SoundTbl_FootStep = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav"}
ENT.SoundTbl_Idle = {"vj_zombies/zombine/idle1.wav", "vj_zombies/zombine/idle2.wav", "vj_zombies/zombine/idle3.wav", "vj_zombies/zombine/idle4.wav", "vj_zombies/zombine/idle5.wav"}
ENT.SoundTbl_Alert = {"vj_zombies/zombine/alert1.wav", "vj_zombies/zombine/alert2.wav", "vj_zombies/zombine/alert3.wav", "vj_zombies/zombine/alert4.wav", "vj_zombies/zombine/alert5.wav", "vj_zombies/zombine/alert6.wav"}

	-- ====== Sound Pitch ====== --
-- Higher number = Higher pitch | Lower number = Lower pitch
-- Highest number is 254
	-- !!! Important variables !!! --
ENT.UseTheSameGeneralSoundPitch = true
	-- If set to true, it will make the game decide a number when the SNPC is created and use it for all sound pitches set to "UseGeneralPitch"
	-- It picks the number between the two variables below:
ENT.GeneralSoundPitch1 = 75
ENT.GeneralSoundPitch2 = 75
ENT.DisableCritical = nil
ENT.EntitiesToNoCollide = {"npc_vj_horde_platoon_heavy", "npc_vj_horde_platoon_berserker", "npc_vj_horde_platoon_demolitionist"}


function ENT:Init()
	self:SetModelScale(1.25)
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self:SetColor(Color(150,100,100))

	local p = math.random()
	self:Give("weapon_vj_horde_katana")
	local pos = Vector()
	local ang = Angle()
	local attach_id = self:LookupAttachment("eyes")
	local attach = self:GetAttachment(attach_id)
	pos = attach.Pos
	ang = attach.Ang
	pos.x = pos.x
	pos.z = pos.z - 25
	pos.y = pos.y
	self.model = ents.Create("prop_dynamic")
	self.model:SetModel("models/headcrab.mdl")
	self.model:SetColor(Color(150, 100, 100))
	self.model:SetSequence("idle01")
	self.model:SetPos(pos)
	self.model:SetAngles(ang)
	self.model:Spawn()
	self.model:SetParent(self, attach_id)
	self.model:SetModelScale(1.5)
	timer.Create("Equip", 0.5, 0, function() self.Weapon_MaxDistance = 80 end)

	self:EmitSound("npc/combine_gunship/see_enemy.wav", 3000, 100, 2, CHAN_STATIC)
end

function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "Init" then
		dmginfo:ScaleDamage(0.9)
		local p = math.random()
		if HORDE:IsPhysicalDamage(dmginfo) and p <= 0.25 then
			local e = EffectData()
			if dmginfo:GetDamagePosition() ~= Vector(0,0,0) then
				e:SetOrigin(dmginfo:GetDamagePosition())
			else
				e:SetOrigin(self:GetPos() + self:OBBCenter() + self:GetForward() * 25)
			end
			dmginfo:ScaleDamage(0.75)
			util.Effect("horde_platoon_parry", e, true, true)
			sound.Play("horde/gadgets/guard" .. tostring(math.random(1,2)) ..".ogg", self:GetPos(), 125, 100, 1, CHAN_AUTO)
		end

		if (not self.DisableCritical) and self:Health() <= self:GetMaxHealth() * 0.5 then
			self.Critical = true
		end
	end
end

function ENT:CustomOnThink()
	if self:IsOnGround() then
		if self.Critical then
			self:SetLocalVelocity(self:GetMoveVelocity() * 0.5)
		else
			self:SetLocalVelocity(self:GetMoveVelocity() * 0.25)
		end
	else
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

VJ.AddNPC("Platoon Berserker","npc_vj_horde_platoon_berserker", "Zombies")