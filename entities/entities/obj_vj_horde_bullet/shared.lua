/*--------------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Bullet"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectiles for my addons"
ENT.Category		= "Projectiles"
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	local Name = "Bullet"
	local LangName = "obj_vj_blasterrod"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = {"models/hunter/blocks/cube025x025x025.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.DoesRadiusDamage = false -- Should it do a blast damage when it hits something?

ENT.DoesDirectDamage = true -- Should it do a direct damage when it hits something?
ENT.DirectDamage = 5 -- How much damage should it do when it hits something
ENT.DirectDamageType = DMG_BULLET -- Damage type
ENT.TracerColor = Color(255,255,128)
ENT.TracerWidth = 5
ENT.Horde_Plague_Soldier = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	--self:SetMaterial("models/effects/vol_light001.mdl")
	self:SetTrigger( true )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(false)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(self.TracerColor)
	util.SpriteTrail(self, 0, self.TracerColor, false, self.TracerWidth, self.TracerWidth, 0.1, 1/(8+8)*0.5, "vj_base/sprites/trail.vmt")
	
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then 
		phys:SetMass( 1 )-- one simple line to solve all my problems...
	end

	timer.Simple(4, function ()
		if !IsValid(self) then return end
		self:Remove()
	end)
end

function ENT:CustomOnDoDamage_Direct(data, phys, hitEnt)
	if not hitEnt then
		return
	end
	/*if hitEnt:IsNPC() then
		local damagecode = DamageInfo()
		damagecode:SetDamage(self.DirectDamage / 2)
		damagecode:SetDamageType(self.DirectDamageType)
		damagecode:SetAttacker(self)
		damagecode:SetInflictor(self)
		damagecode:SetDamagePosition(self:GetPos())
		--hitEnt:TakeDamageInfo(damagecode, self)
	end*/

	if self.Weaken then
		hitEnt:Horde_AddWeaken(self, 3, 1)
	elseif self.Hinder then
		hitEnt:Horde_AddHinder(self, 3, 1)
	end
end

function ENT:StartTouch(npc)
	if npc == self.Owner then return end	
	if npc == self then return end
	if self.Owner:IsNPC() and self.Owner:Disposition(npc) ~= D_HT then return end

	if IsValid(self:GetOwner()) && npc:IsNPC() or npc:IsPlayer() or npc:IsNextBot() then
		self.dmg = DamageInfo()
		self.dmg:SetDamage(self.DirectDamage)
		self.dmg:SetDamageType(DMG_BULLET)
		self.dmg:SetDamagePosition(self:GetPos())
		if !IsValid(self:GetOwner()) then return end
		self.dmg:SetAttacker(self:GetOwner())
		self.dmg:SetInflictor(self:GetOwner())
		npc:TakeDamageInfo(self.dmg)
	if self.Weaken then
		hitEnt:Horde_AddWeaken(self, 3, 1)
	elseif self.Hinder then
		hitEnt:Horde_AddHinder(self, 3, 1)
	end
	if self.parried == 1 then
	self:Explode()
	end
	self:Remove()
    end
	
end


function ENT:CustomOnThink()
local avoid = {
["npc_vj_horde_laser_turret"] = true,
["npc_vj_horde_rocket_turret"] = true,
["npc_vj_horde_sniper_turret"] = true,
["npc_vj_horde_shotgun_turret"] = true,
["npc_vj_horde_combat_bot"] = true,
}

for k, ship in pairs(ents.FindInSphere(self:GetPos(), 80)) do
if avoid[ship:GetClass()] or HORDE:IsPlayerMinion(ship) then
	util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),80,self.DirectDamage,self.DirectDamageType,true,true)
	self:Remove()
end
end

end

ENT.stationary = false --required for knuckleblaster
ENT.parried = 0
function ENT:OnDamaged(dmginfo)
    local phys = self:GetPhysicsObject()
    if dmginfo:GetDamageType() == DMG_CLUB or dmginfo:GetDamageType() == DMG_ALWAYSGIB then
		if self.stationary then return end
		phys:SetVelocity( self.Owner:GetAimVector() * 3000 )
        self.parried = 1
    end
end

function ENT:CustomOnPhysicsCollide(data, phys)
	if self.parried == 1 then
	self:Explode()
	end
end

function ENT:Explode()
    if !self:IsValid() or self.Removing then return end
    --self:EmitSound("horde/spells/meteor_explode.ogg", 125, 100, 1, CHAN_AUTO)

    local attacker = self

    if self.Owner:IsValid() then
        attacker = self.Owner
    end

    local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_BLAST)
	dmg:SetDamage(250)
	util.BlastDamageInfo(dmg, self:GetPos(), 200)
	--ParticleEffect("nether_mine_explode", self:GetPos(), Angle(0,0,0), self.Owner)
	
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect( "Explosion", effectdata )

    self:FireBullets({
        Attacker = attacker,
        Damage = 0,
        Tracer = 0,
        Distance = 20000,
        Dir = self:GetVelocity(),
        Src = self:GetPos(),
        Callback = function(att, tr, dmg)
            util.Decal("Scorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 16), self)
        end
    })
    self.Removing = true
    self:Remove()
end

