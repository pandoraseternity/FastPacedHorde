AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/props_phx/cannonball.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.GodMode = true
ENT.laserready = false
ENT.CollisionBehavior = PROJ_COLLISION_PERSIST
ENT.StartHealth = 30
--ENT.TurningSpeed = 5 -- How fast it can turn
--ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.RightYaw = 40
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.CVar		= "horde_difficulty"
 
function ENT:CustomOnInitialize()
	if cvars.Number(self.CVar, 1) <= 3 then
		self.RightYaw = 80
	end
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:EmitSound("ocpack/ror2/voidlaser1.mp3", 125, 100, 1, CHAN_AUTO)
	self.stationary = true
	self:SetMaterial("lights/white")
	self:AddEffects( EF_NORECEIVESHADOW )
	self:AddEffects( EF_NOFLASHLIGHT )
	self:AddEffects( EF_BRIGHTLIGHT )
	self:AddEffects( EF_NOSHADOW )
	
	block = ents.Create("obj_vj_horde_gammalaser_top")
	block:SetOwner(self)
	block:SetPos(self:GetPos())
	ParticleEffectAttach("horde_gammabeam_starting",PATTACH_ABSORIGIN_FOLLOW,block,0)
	block:Spawn()
	block:Activate()
	self:DeleteOnRemove(block)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then 
		phys:Wake()
		phys:SetMass( 0 )
		phys:SetDragCoefficient( 0 )
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity( false )
	end
	
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "10")
	self.StartLight1:SetKeyValue("distance", "300")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:SetColor( Color( 255, 255, 255, 255 ) )
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self.StartLight1:Fire("Kill", "", 7)
	self:DeleteOnRemove(self.StartLight1)
	
		timer.Simple(1.8,function() if IsValid(self) then	
			self:EmitSound("ocpack/AIAS_WPN_laser.wav", 125, 100, 1, CHAN_AUTO)
			self.laserready = true
			self:EmitSound("ocpack/ror2/voidlaser2.mp3", 125, 100, 1, CHAN_AUTO)
		end end)
	
		timer.Simple(7,function() if IsValid(self) then	
			self:Remove()
		end end)
end

function ENT:CustomOnRemove()
	self:StopSound("ocpack/ror2/voidlaser1.mp3")
	self:StopSound("ocpack/AIAS_WPN_laser.wav")
	self:EmitSound("ocpack/ror2/voidlaser4.mp3", 125, 100, 1, CHAN_AUTO)
end

function ENT:OnCollision(data, phys) 
return true
end

function ENT:Think()
	if !self:GetOwner():GetEnemy() then return end
	local own = self:GetOwner()
	local e = EffectData()
	local p = math.random()
	e:SetOrigin(self:GetPos())
	e:SetScale(0.5)
	util.Effect("frostcloud", e, true, true)
	
	if self.laserready == true && IsValid(self:GetOwner():GetEnemy()) then-- GAMMA BEAM + own:GetForward()*15
	local ik = util.TraceLine({
	start = self:WorldSpaceCenter(),
	endpos = self:WorldSpaceCenter() + self:GetForward()*15000,
	filter = self
	})
	local w = own:GetEnemy()
	--self:SetMoveType(MOVETYPE_NONE)
	self:AddSolidFlags(FSOLID_NOT_SOLID)
	self:SetLocalVelocity(Vector())--+ (w:GetUp()*20)
	self:SetAngles((w:GetPos() - self:GetPos()):Angle())
    if IsValid(own) && (own:IsNPC() or own:IsNextBot()) && IsValid(w) then
		local ownene = self:GetOwner():GetEnemy()
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then 
			phys:SetVelocity(self:GetAngles():Forward() * 500) 
		end
	end
	
	util.ScreenShake(self:GetPos(),1,1,0.5,500)
	for k,ent in pairs(ents.FindAlongRay(block:WorldSpaceCenter() + (block:GetUp()*-20), block:WorldSpaceCenter() + (block:GetUp()*-20) + block:GetForward()*150000,Vector(-60,-60,-60),Vector(60,60,60))) do
		if SERVER then
		if self:Visible( ent ) == false then return end
		dmginfo = DamageInfo()
		dmginfo:SetDamage( 75 )
		dmginfo:SetDamageType(DMG_DIRECT)
		dmginfo:SetDamagePosition(ent:GetPos())
		dmginfo:SetAttacker( self:GetOwner() )
		dmginfo:SetInflictor( self )
		if (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() ) then --&& ent ~= self.Owner && ent ~= self
			--if ent == self.Owner then return end
			ent:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, dmginfo:GetDamage()/10, self.Owner)
			ent:TakeDamageInfo( dmginfo )
			ent:SetGroundEntity(NULL)
			--ent:SetLocalVelocity(Vector(25,0,25) )
			--ent:SetLocalVelocity(own:GetAngles():Forward()*450 )
		end
		end
	end
	
	end
end