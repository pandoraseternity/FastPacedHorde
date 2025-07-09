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
ENT.Behavior = VJ_BEHAVIOR_PASSIVE_NATURE
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

ENT.HasSoundTrack = false -- Does the SNPC have a sound track?
ENT.SoundTrackVolume = 1
ENT.SoundTbl_SoundTrack = {"ocpack/paradiselostultrakill.mp3", "ocpack/stolenheavenultrakill.mp3"}


function ENT:CustomOnInitialize()
	self:SetModel("models/headcrabclassic.mdl")
	self:SetCollisionBounds(Vector(0,0,0),Vector(0,0,0))
	self:EmitSound("horde/plague_elite/summon.ogg")
	--self.Init = nil
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(0,0,0,0))

	HORDE:SpawnEnemy("npc_vj_horde_exploder", self:GetPos())
	/*timer.Simple(1, function ()
		ParticleEffect("aurora_shockwave_debris", self:GetPos(), Angle(0,0,0), nil)
		ParticleEffect("aurora_shockwave", self:GetPos(), Angle(0,0,0), nil)
		self.ally1 = ents.Create("npc_vj_horde_exploder")
		self.ally1:SetPos(self:GetPos())
		self.ally1:SetAngles(self:GetAngles())
		self.ally1:Spawn()
		self.ally1:SetOwner(self)
		timer.Simple(0.1, function ()
			self.ally1:SetMaxHealth(self.ally1:GetMaxHealth() * HORDE.Difficulty[HORDE.CurrentDifficulty].healthMultiplier)
			self.ally1:SetHealth(self.ally1:GetMaxHealth())
		end)
		
		--self.Init = true

	end)*/
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	dmginfo:SetDamage(0)
	return true
end

function ENT:CustomOnThink_AIEnabled()

end

function ENT:CustomOnPriorToKilled(dmginfo, hitgroup) 
HORDE:OnEnemyKilled(self, self)
end

/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
