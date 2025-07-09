AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/dav0r/hoverball.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.DoesRadiusDamage = false -- Should it do a blast damage when it hits something?
ENT.RadiusDamageRadius = 140 -- How far the damage go? The farther away it's from its enemy, the less damage it will do | Counted in world units
ENT.RadiusDamage = 60 -- How much damage should it deal? Remember this is a radius damage, therefore it will do less damage the farther away the entity is from its enemy
ENT.RadiusDamageUseRealisticRadius = true -- Should the damage decrease the farther away the enemy is from the position that the projectile hit?
ENT.RadiusDamageType = DMG_BLAST -- Damage type
ENT.RadiusDamageForce = 90 -- Put the force amount it should apply | false = Don't apply any force
ENT.ShakeWorldOnDeath = true -- Should the world shake when the projectile hits something?
ENT.ShakeWorldOnDeathAmplitude = 16 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.ShakeWorldOnDeathRadius = 3000 -- How far the screen shake goes, in world units
ENT.ShakeWorldOnDeathtDuration = 1 -- How long the screen shake will last, in seconds
ENT.ShakeWorldOnDeathFrequency = 200 -- The frequency
ENT.SoundTbl_Idle = {"weapons/physcannon/energy_sing_flyby1.wav","weapons/physcannon/energy_sing_flyby2.wav","ocpack/throatdronestereo.wav"}
ENT.SoundTbl_OnCollide = {"weapons/physcannon/energy_sing_explosion2.wav"}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetMaterial("models/props_combine/portalball001_sheet")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	--self:SetSolid(SOLID_CUSTOM)
	self:SetOwner(self:GetOwner())
	self.RemoveOnHit = false

	-- Physics Functions
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end

	-- Misc Functions
	ParticleEffectAttach("fire_jet_01_flame", PATTACH_ABSORIGIN_FOLLOW, self, 0)

	self.StartGlow1 = ents.Create( "env_sprite" )
	self.StartGlow1:SetKeyValue( "rendercolor","255 255 255" )
	self.StartGlow1:SetKeyValue( "renderfx","14" )
	self.StartGlow1:SetKeyValue( "rendermode","3" )
	self.StartGlow1:SetKeyValue( "renderamt","255" )
	self.StartGlow1:SetKeyValue( "framerate","10.0" )
	self.StartGlow1:SetKeyValue( "model","sprites/blueflare1.spr" )
	self.StartGlow1:SetKeyValue( "spawnflags","0" )
	self.StartGlow1:SetKeyValue( "scale","0.75" )
	self.StartGlow1:SetPos( self.Entity:GetPos() )
	self.StartGlow1:Spawn()
	self.StartGlow1:SetParent( self.Entity )
	self:DeleteOnRemove(self.StartGlow1)

	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "4")
	self.StartLight1:SetKeyValue("distance", "200")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 150 0")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(self.StartLight1)

	/*timer.Simple(5, function ()
		if !IsValid(self) then return end
		self:Remove()
	end)*/
end
ENT.immobile = false
ENT.CVar		= "horde_difficulty"
ENT.TurnYaw = 0
ENT.Accelerate = 0
ENT.NextTick = 0
function ENT:CustomOnThink()
--print(self:GetOwner())
local own = self:GetOwner()
if CurTime() >= self.NextTick then
	local dmg = DamageInfo()
	dmg:SetAttacker(self:GetOwner())
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_SHOCK)
	dmg:SetDamage(25)
	--util.BlastDamageInfo(dmg, self:GetPos(), 140)
	util.VJ_SphereDamage(own,self,self:GetPos(),120,25,DMG_SHOCK,true,false,{Force = 150})
	self.NextTick = CurTime() + 0.2
end

		if self.OwnerCritical then
            if IsValid(self:GetOwner()) && self:GetOwner():IsNPC() && IsValid(self) && IsValid(self:GetOwner():GetEnemy())  then
					local ownene = self:GetOwner():GetEnemy()
                    --PrintMessage( HUD_PRINTTALK, "yomomma" )
					local phys = self:GetPhysicsObject()
                    if phys:IsValid() then 
						phys:SetVelocity(self:GetAngles():Forward() * (500 + (100 * cvars.Number(self.CVar, 1) )) + self:GetAngles():Right() * self.TurnYaw) 
					end--+ self:GetForward() * self.TurnYaw 
					self:SetAngles((ownene:GetPos() + ownene:GetUp() * 50 - self:GetPos()):Angle())
                    if self:GetPos():Distance(ownene:GetPos()) <= 1000 then -- self:GetAngles():Right()*self.TurnYaw
						self.TurnYaw = self.TurnYaw - 10
						--self.Accelerate = self.Accelerate + 1
					end
			end
		end
			
end


function ENT:CustomOnPhysicsCollide(data, phys)
	local dmg = DamageInfo()
	dmg:SetAttacker(self:GetOwner())
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_BLAST)
	dmg:SetDamage(80)
	util.BlastDamageInfo(dmg, self:GetPos(), 150)
	dmg = DamageInfo()
	dmg:SetAttacker(self:GetOwner())
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_NERVEGAS)
	dmg:SetDamage(80)
	util.BlastDamageInfo(dmg, self:GetPos(), 150)

	local self_pos = self:GetPos()
	if self.OwnerCritical then
		for i =0,10 do
            timer.Simple(0.5 + i * 0.2, function ()
                local rand = VectorRand()
                if rand.z < 0 then rand.z = -rand.z end
                local pos = self_pos
                for _, ent in pairs(ents.FindInSphere(pos, 150)) do
                    --if (HORDE:IsPlayerOrMinion(e1) == true) then + rand * math.Rand(10, 50)
					--if IsValid(self:GetOwner()) && ent == self:GetOwner() then return end
					if IsValid(self) && IsValid(self:GetOwner()) and ent ~= self:GetOwner() and (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) then
                        local dmginfo = DamageInfo()
                        dmginfo:SetDamage(75)--math.max(10, 0.05 * ent:GetMaxHealth())
                        dmginfo:SetAttacker(self:GetOwner())
                        dmginfo:SetInflictor(self:GetOwner())
                        dmginfo:SetDamagePosition(pos)
                        dmginfo:SetDamageType(DMG_BLAST)
                        ent:TakeDamageInfo(dmginfo)
                    end
                end
                local e = EffectData()
                    e:SetOrigin(pos)
                util.Effect("explosion", e, true, true)
                --sound.Play("ambient/levels/canals/toxic_slime_sizzle2.wav", pos)
            end)
        end
    end
	self:OnCollideSoundCode()
	if self.ShakeWorldOnDeath == true then util.ScreenShake(data.HitPos, self.ShakeWorldOnDeathAmplitude, self.ShakeWorldOnDeathFrequency, 1, self.ShakeWorldOnDeathRadius) end

	
	--self:SetNoDraw(true)
	self:SetMoveType(MOVETYPE_NONE)
	self:AddSolidFlags(FSOLID_NOT_SOLID)
	self:SetLocalVelocity(Vector())
	SafeRemoveEntityDelayed(self, 10)
	self.immobile = true
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	util.Effect( "Explosion", effectdata )
	util.Effect( "energy_explosion", effectdata )
	ParticleEffect("vj_explosion_shockwave1", data.HitPos, Angle(0,0,0))
	--self.Dead = true
	return false
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/