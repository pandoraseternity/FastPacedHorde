AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hunter/blocks/cube025x025x025.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.laserready = false
ENT.CollisionBehavior = PROJ_COLLISION_PERSIST
---------------------------------------------------------------------------------------------------------------------------------------------
  
function ENT:CustomOnInitialize()
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetColor( Color( 0, 255, 0, 0 ) ) 
	self:SetRenderMode( RENDERMODE_TRANSCOLOR ) -- You need to set the render mode on some entities in order for the color to change
	--ParticleEffectAttach("horde_gammabeam_starting",PATTACH_ABSORIGIN_FOLLOW,block,0)
end

function ENT:OnCollision(data, phys) 
return true
end

function ENT:Think()
	local own = self:GetOwner()
	local e = EffectData()
	local p = math.random()
	e:SetOrigin(self:GetPos())
	e:SetScale(0.5)
	util.Effect("frostcloud", e, true, true)
	self:SetPos(own:GetPos() + Vector(0,0,35))
	self:SetAngles(Angle(270, 0, 0))
end