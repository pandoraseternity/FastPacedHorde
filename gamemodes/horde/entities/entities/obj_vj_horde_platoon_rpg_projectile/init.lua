/*--------------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Tank Shell"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectiles for my addons"
ENT.Category		= "Projectiles"

ENT.VJ_IsDetectableDanger = true

---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	local Name = "Tank Shell"
	local LangName = "obj_vj_tank_shell"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))

	function ENT:Think()
		/*if self:IsValid() then
			self.Emitter = ParticleEmitter(self:GetPos())
			self.SmokeEffect1 = self.Emitter:Add("particles/flamelet2",self:GetPos() +self:GetForward()*-7)
			self.SmokeEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
			self.SmokeEffect1:SetDieTime(0.2)
			self.SmokeEffect1:SetStartAlpha(100)
			self.SmokeEffect1:SetEndAlpha(0)
			self.SmokeEffect1:SetStartSize(10)
			self.SmokeEffect1:SetEndSize(1)
			self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
			self.SmokeEffect1:SetAirResistance(200)
			self.Emitter:Finish()
		end*/
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = {"models/weapons/w_missile_launch.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.DoesRadiusDamage = false -- Should it do a blast damage when it hits something?
ENT.RadiusDamageRadius = 250 -- How far the damage go? The farther away it's from its enemy, the less damage it will do | Counted in world units
ENT.RadiusDamage = 40 -- How much damage should it deal? Remember this is a radius damage, therefore it will do less damage the farther away the entity is from its enemy
ENT.RadiusDamageUseRealisticRadius = true -- Should the damage decrease the farther away the enemy is from the position that the projectile hit?
ENT.RadiusDamageType = DMG_BLAST -- Damage type
ENT.RadiusDamageForce = 90 -- Put the force amount it should apply | false = Don't apply any force
ENT.DecalTbl_DeathDecals = {"Scorch"}
ENT.SoundTbl_Idle = {"weapons/rpg/rocket1.wav"}
ENT.SoundTbl_OnCollide = {"ambient/explosions/explode_8.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	//util.SpriteTrail(self, 0, Color(90,90,90,255), false, 10, 1, 3, 1/(15+1)*0.5, "trails/smoke.vmt")
	ParticleEffectAttach("vj_rocket_idle1", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	ParticleEffectAttach("vj_rocket_idle2", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	//ParticleEffectAttach("vj_rpg2_smoke2", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	//ParticleEffectAttach("rocket_smoke", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	//ParticleEffectAttach("smoke_burning_engine_01", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	
	/*self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "1")
	self.StartLight1:SetKeyValue("distance", "200")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 150 0")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(self.StartLight1)*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAngle = Angle(0, 0, 0)
--
function ENT:DeathEffects(data, phys)
	util.ScreenShake(data.HitPos, 16, 200, 1, 3000)
	ParticleEffect("vj_explosion3", self:GetPos(), defAngle, nil)
	
	local effectData = EffectData()
	effectData:SetOrigin(data.HitPos)
	//effectData:SetScale(500)
	//util.Effect("HelicopterMegaBomb", effectData)
	//util.Effect("ThumperDust", effectData)
	util.Effect("Explosion", effectData)
	//util.Effect("VJ_Small_Explosion1", effectData)

	local expLight = ents.Create("light_dynamic")
	expLight:SetKeyValue("brightness", "4")
	expLight:SetKeyValue("distance", "300")
	expLight:SetLocalPos(data.HitPos)
	expLight:SetLocalAngles(self:GetAngles())
	expLight:Fire("Color", "255 150 0")
	expLight:SetParent(self)
	expLight:Spawn()
	expLight:Activate()
	expLight:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(expLight)
end

function ENT:CustomOnPhysicsCollide(data, phys)
    if self.Dead then return end
    if not self.Owner:IsValid() then self:Remove() return end
    self.Dead = true
    local dmg = DamageInfo()
    PrintTable(data)
	local gunPos = self.Owner:GetShootPos()
	local hitPos = data.HitPos
	
	local x = (gunPos.x - hitPos.x)^2;
	local y = (gunPos.y - hitPos.y)^2;
	local z = (gunPos.z - hitPos.z)^2;
	local distance = math.sqrt(x + y + z);
	
	local max_distance = 1500
    local scaled_dmg = self.RadiusDamage * 0.5 * (1 + math.min(distance, max_distance) / max_distance)
    
    dmg:SetAttacker(self.Owner)
    dmg:SetInflictor(self)
    dmg:SetDamageType(self.RadiusDamageType)
    dmg:SetDamage(scaled_dmg)
    util.BlastDamageInfo(dmg, self:GetPos(), self.RadiusDamageRadius)
    
    self:Remove()
end
