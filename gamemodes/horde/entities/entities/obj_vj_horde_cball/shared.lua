/*--------------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Combine Ball"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectiles for my addons"
ENT.Category		= "Projectiles"

ENT.VJ_IsDetectableDanger = true

if CLIENT then
	local Name = "Combine Ball"
	local LangName = "obj_vj_combineball"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))

	function ENT:Draw()
		self:DrawModel()
		self:SetAngles((LocalPlayer():EyePos() - self:GetPos()):Angle())
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = "models/effects/combineball.mdl" -- The models it should spawn with | Picks a random one from the table
ENT.CollisionBehavior = VJ.PROJ_COLLISION_PERSIST
ENT.CollisionDecal = "FadingScorch"
ENT.RemoveOnHit = false -- Should it remove itself when it touches something? | It will run the hit sound, place a decal, etc.
ENT.DoesDirectDamage = false -- Should it do a direct damage when it hits something?
ENT.DirectDamage = 50 -- How much damage should it do when it hits something
ENT.DirectDamageType = DMG_BLAST -- Damage type
--ENT.CollideCodeWithoutRemoving = true -- If RemoveOnHit is set to false, you can still make the projectile deal damage, place a decal, etc.
ENT.DecalTbl_DeathDecals = {"Scorch"}
ENT.SoundTbl_Idle = {"weapons/physcannon/energy_sing_loop4.wav"}
ENT.SoundTbl_OnCollide = {"weapons/physcannon/energy_bounce1.wav","weapons/physcannon/energy_bounce2.wav"}

ENT.IdleSoundPitch = VJ_Set(100, 100)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:InitPhys()
	self:PhysicsInitSphere(1, "metal_bouncy")
	construct.SetPhysProp(self:GetOwner(), self, 0, self:GetPhysicsObject(), {GravityToggle = false, Material = "metal_bouncy"})
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetCoreType(capture)
	if capture then
		self:SetSubMaterial(0, "models/effects/comball_glow1")
	else
		self:SetSubMaterial(0, "vj_base/effects/comball_glow2")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorWhite = Color(255, 255, 255, 255)
--
function ENT:CustomOnInitialize()
	timer.Simple(5, function() if IsValid(self) then self:DeathEffects() end end)

	self:DrawShadow(false)
	self:ResetSequence("idle")
	self:SetCoreType(false)

	util.SpriteTrail(self, 0, colorWhite, true, 15, 0, 0.1, 1 / 6 * 0.5, "sprites/combineball_trail_black_1.vmt")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBounce(data, phys)
	local myPos = self:GetPos()
	local owner = self:GetOwner()
	local newVel = phys:GetVelocity():GetNormal()
	local lastVel = math.max(newVel:Length(), math.max(data.OurOldVelocity:Length(), data.Speed)) -- Get the last velocity and speed
	-- phys:SetVelocity(newVel * lastVel * 0.985) -- Sometimes this could get the combine ball stuck in certain brushes, disabling it just because it looks better without it tbh

	if !IsValid(owner) then return end
	local closestDist = 1024
	local target = NULL
	for _, v in ipairs(ents.FindInSphere(myPos, 1024)) do
		if v == owner then continue end
		if (!v:IsNPC() && !v:IsPlayer()) then continue end
		if owner:IsNPC() && owner:CheckRelationship(v) == D_LI then continue end
		local dist = v:GetPos():Distance(myPos)
		if dist < closestDist && dist > 20 then
			closestDist = dist
			target = v
		end
	end
	
	if IsValid(target) then
		local targetPos = target:GetPos() + target:OBBCenter()
		local norm = (targetPos - myPos):GetNormalized()
		if self:GetForward():DotProduct(norm) < 0.75 then -- Lowered the visual range from 0.95, too accurate
			phys:SetVelocity(norm * lastVel)
		end
	end
end

local sdHit = {"weapons/physcannon/energy_disintegrate4.wav", "weapons/physcannon/energy_disintegrate5.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCollision(data, phys)
	local owner = self:GetOwner()
	local hitEnt = data.HitEntity
	if IsValid(owner) then
		if (VJ_IsProp(hitEnt)) or (owner:IsNPC() && owner:CheckRelationship(hitEnt) == D_HT && (hitEnt != owner) or true) then
			VJ.CreateSound(self, VJ_PICK(sdHit), 80)
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(self.DirectDamage)
			dmgInfo:SetDamageType(self.DirectDamageType)
			dmgInfo:SetAttacker(owner)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamagePosition(data.HitPos)
			hitEnt:TakeDamageInfo(dmgInfo, self)
		end
	else
		VJ.CreateSound(self, VJ_PICK(sdHit), 80)
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage(self.DirectDamage)
		dmgInfo:SetDamageType(self.DirectDamageType)
		dmgInfo:SetAttacker(self)
		dmgInfo:SetInflictor(self)
		dmgInfo:SetDamagePosition(data.HitPos)
		hitEnt:TakeDamageInfo(dmgInfo, self)
	end

	local dataF = EffectData()
	dataF:SetOrigin(self:GetPos())
	util.Effect("cball_bounce", dataF)

	dataF = EffectData()
	dataF:SetOrigin(self:GetPos())
	dataF:SetScale(50)
	util.Effect("AR2Impact", dataF)

    local myPos = self:GetPos()
	effects.BeamRingPoint(myPos, 0.2, 12, 512, 64, 0, color1, {material="sprites/lgtning.vmt", framerate=2, flags=0, speed=0, delay=0, spread=0})
	effects.BeamRingPoint(myPos, 0.5, 12, 512, 64, 0, color2, {material="sprites/lgtning.vmt", framerate=2, flags=0, speed=0, delay=0, spread=0})

	local effectData = EffectData()
	effectData:SetOrigin(myPos)
	util.Effect("cball_explode", effectData)

	VJ_EmitSound(self, "weapons/physcannon/energy_sing_explosion2.wav", 150)
	util.ScreenShake(myPos, 20, 150, 1, 500)

    local dmg = DamageInfo()
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_GENERIC)
    dmg:SetDamage(60)
    util.BlastDamageInfo(dmg, self:GetPos(), 150)
	--util.VJ_SphereDamage(self, self, myPos, 250, 100, DMG_BLAST, true, true, {DisableVisibilityCheck=true, Force=80})

	self:Remove()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GravGunPunt(ply)
	self:SetCoreType(false)
	self:GetPhysicsObject():EnableMotion(true)
	return true
end

function ENT:DeathEffects()
	local dataF = EffectData()
	dataF:SetOrigin(self:GetPos())
	util.Effect("cball_bounce", dataF)

	dataF = EffectData()
	dataF:SetOrigin(self:GetPos())
	dataF:SetScale(50)
	util.Effect("AR2Impact", dataF)

    local myPos = self:GetPos()
	effects.BeamRingPoint(myPos, 0.2, 12, 512, 64, 0, color1, {material="sprites/lgtning.vmt", framerate=2, flags=0, speed=0, delay=0, spread=0})
	effects.BeamRingPoint(myPos, 0.5, 12, 512, 64, 0, color2, {material="sprites/lgtning.vmt", framerate=2, flags=0, speed=0, delay=0, spread=0})

	local effectData = EffectData()
	effectData:SetOrigin(myPos)
	util.Effect("cball_explode", effectData)

	VJ_EmitSound(self, "weapons/physcannon/energy_sing_explosion2.wav", 150)
	util.ScreenShake(myPos, 20, 150, 1, 500)

    local dmg = DamageInfo()
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_GENERIC)
    dmg:SetDamage(60)
    util.BlastDamageInfo(dmg, self:GetPos(), 150)
end
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
local color1 = Color(255, 255, 225, 32)
local color2 = Color(255, 255, 225, 64)