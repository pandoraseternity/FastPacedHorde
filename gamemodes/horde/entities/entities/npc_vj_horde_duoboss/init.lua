AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/headcrabclassic.mdl"
ENT.StartHealth = 8500
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.HasMeleeAttack = false

	-- ====== Sound Pitch ====== --
-- Higher number = Higher pitch | Lower number = Lower pitch
-- Highest number is 254
	-- !!! Important variables !!! --
ENT.UseTheSameGeneralSoundPitch = true
	-- If set to true, it will make the game decide a number when the SNPC is created and use it for all sound pitches set to "UseGeneralPitch"
	-- It picks the number between the two variables below:
ENT.GeneralSoundPitch1 = 75
ENT.GeneralSoundPitch2 = 75
ENT.LastHp = 0
ENT.EntitiesToNoCollide = {"npc_vj_horde_executioner", "npc_vj_horde_virulent"}

ENT.HasSoundTrack = true -- Does the SNPC have a sound track?
ENT.SoundTrackVolume = 1
ENT.SoundTbl_SoundTrack = {"ocpack/paradiselostultrakill.mp3", "ocpack/stolenheavenultrakill.mp3"}

/*function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(0,0,0),Vector(0,0,0))
	self:EmitSound("horde/plague_elite/summon.ogg")
	self.Init = nil
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(0,0,0,0))
	timer.Simple(1, function ()
		ParticleEffect("aurora_shockwave_debris", self:GetPos(), Angle(0,0,0), nil)
		ParticleEffect("aurora_shockwave", self:GetPos(), Angle(0,0,0), nil)
		self.MiniBoss1 = ents.Create("npc_vj_horde_executioner")
		self.MiniBoss1:SetPos(self:GetPos())
		self.MiniBoss1:SetAngles(self:GetAngles())
		self.MiniBoss1:Spawn()
		self.MiniBoss1:SetOwner(self)
		timer.Simple(0.1, function ()
			self.MiniBoss1:SetMaxHealth(self:GetMaxHealth() * HORDE.difficulty_health_multiplier[HORDE.difficulty])
			self.MiniBoss1:SetHealth(self.MiniBoss1:GetMaxHealth())
		end)

		self.MiniBoss2 = ents.Create("npc_vj_horde_virulent")
		self.MiniBoss2:SetPos(self:GetPos() + self:GetRight()*-10)
		self.MiniBoss2:SetAngles(self:GetAngles())
		self.MiniBoss2:Spawn()
		self.MiniBoss2:SetOwner(self)
		timer.Simple(0.1, function ()
			self.MiniBoss2:SetMaxHealth(self:GetMaxHealth() * HORDE.difficulty_health_multiplier[HORDE.difficulty])
			self.MiniBoss2:SetHealth(self.MiniBoss2:GetMaxHealth())
		end)
		self.Init = true

		timer.Simple(0.1, function ()
			self:SetMaxHealth(self.MiniBoss1:GetMaxHealth() + self.MiniBoss2:GetMaxHealth())
			net.Start("Horde_SyncBossHealth")
			net.WriteInt(self:Health(), 32)
			net.Broadcast()
		end)
	end)
end*/

function ENT:CustomOnInitialize()
	self:SetModel("models/headcrabclassic.mdl")
	self:SetCollisionBounds(Vector(0,0,0),Vector(0,0,0))
	self:EmitSound("horde/plague_elite/summon.ogg")
	self.Init = nil
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(0,0,0,0))
	timer.Simple(1, function ()
		ParticleEffect("aurora_shockwave_debris", self:GetPos(), Angle(0,0,0), nil)
		ParticleEffect("aurora_shockwave", self:GetPos(), Angle(0,0,0), nil)
		self.MiniBoss1 = ents.Create("npc_vj_horde_executioner")
		self.MiniBoss1:SetPos(self:GetPos())
		self.MiniBoss1:SetAngles(self:GetAngles())
		self.MiniBoss1:Spawn()
		self.MiniBoss1:SetOwner(self)
		timer.Simple(0.1, function ()
			self.MiniBoss1:SetMaxHealth(self:GetMaxHealth() * 0.5)
			self.MiniBoss1:SetHealth(self.MiniBoss1:GetMaxHealth())
		end)
		self.MiniBoss1.HasSoundTrack = false -- Does the SNPC have a sound track?
		
		--self.MiniBoss1.DisableCritical = true

		self.MiniBoss2 = ents.Create("npc_vj_horde_virulent")
		self.MiniBoss2:SetPos(self:GetPos() + self:GetRight()*-14)
		self.MiniBoss2:SetAngles(self:GetAngles())
		self.MiniBoss2.wave10 = true
		self.MiniBoss2:Spawn()
		self.MiniBoss2:SetOwner(self)
		timer.Simple(0.1, function ()
			self.MiniBoss2:SetMaxHealth(self:GetMaxHealth() * 0.5)
			self.MiniBoss2:SetHealth(self.MiniBoss2:GetMaxHealth())
		end)
		self.MiniBoss2.HasSoundTrack = false -- Does the SNPC have a sound track?
		--self.MiniBoss2.DisableCritical = true
		
		self.Init = true

		timer.Simple(0.1, function ()
			self:SetMaxHealth(self.MiniBoss1:GetMaxHealth() + self.MiniBoss2:GetMaxHealth())
			net.Start("Horde_SyncBossHealth")
			net.WriteInt(self:Health(), 32)
			net.Broadcast()
		end)
	end)
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	dmginfo:SetDamage(0)
	return true
end

function ENT:CustomOnThink_AIEnabled()
	if not self.Init then return end
	local hp = 0
	local dead = 0
	if self.MiniBoss1 and IsValid(self.MiniBoss1) then
		hp = hp + self.MiniBoss1:Health()
	else
		dead = 1
	end
	if self.MiniBoss2 and IsValid(self.MiniBoss2) then
		hp = hp + self.MiniBoss2:Health()
	else
		dead = 1
	end

	if hp <= 0 then
		self:TakeDamage(self:Health() + 1, self, self)
		net.Start("Horde_SyncBossHealth")
		net.WriteInt(0, 32)
		net.Broadcast()
		HORDE:OnEnemyKilled(self, self)
		return
	end
	self:SetHealth(hp)
	if self.LastHp ~= hp then
		net.Start("Horde_SyncBossHealth")
		net.WriteInt(self:Health(), 32)
		net.Broadcast()
	end
	self.LastHp = hp

	if dead > 0 and not self.Critical then
		self.Critical = true
		if self.MiniBoss1 and IsValid(self.MiniBoss1) then
			--self.MiniBoss1.Critical = true
		end
		if self.MiniBoss2 and IsValid(self.MiniBoss2) then
			--self.MiniBoss2.Critical = true
			--self.AnimationPlaybackRate = 1.25
		end
	end
end

/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

VJ.AddNPC("DuoBoss","npc_vj_horde_duoboss", "Zombies")