AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {"models/vj_base/projectiles/spit_acid_medium.mdl"} -- The models it should spawn with | Picks a random one from the table
-- ====== Shake World On Death Variables ====== --
ENT.ShakeWorldOnDeath = true -- Should the world shake when the projectile hits something?
ENT.ShakeWorldOnDeathAmplitude = 4 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.ShakeWorldOnDeathRadius = 500 -- How far the screen shake goes, in world units
ENT.ShakeWorldOnDeathDuration = 1 -- How long the screen shake will last, in seconds
ENT.ShakeWorldOnDeathFrequency = 200 -- The frequency
-- ====== Radius Damage Variables ====== --
ENT.DoesRadiusDamage = false -- Should it do a blast damage when it hits something?
ENT.RadiusDamageRadius = 250 -- How far the damage go? The farther away it's from its enemy, the less damage it will do | Counted in world units
ENT.RadiusDamageUseRealisticRadius = false -- Should the damage decrease the farther away the enemy is from the position that the projectile hit?
ENT.RadiusDamage = 25  -- How much damage should it deal? Remember this is a radius damage, therefore it will do less damage the farther away the entity is from its enemy
ENT.RadiusDamageType = DMG_REMOVENORAGDOLL -- Damage type
ENT.RadiusDamageForce = 200 -- Put the force amount it should apply | false = Don't apply any force
ENT.RadiusDamageForce_Up = false -- How much up force should it have? | false = Let the base automatically decide the force using RadiusDamageForce value
ENT.RadiusDamageDisableVisibilityCheck = false -- Should it disable the visibility check? | true = Disables the visibility check
    -----------------------------------------------------
ENT.DecalTbl_DeathDecals = {"VJ_AcidSlime1"}
ENT.SoundTbl_Idle = {}--"vj_acid/acid_idle1.wav"
ENT.SoundTbl_OnCollide = {"horde/status/frostbite_buildup.ogg"}

ENT.type = 1
ENT.CVar		= "horde_difficulty"
---------------------------------------------------------------------------------------------------------------------------------------------
/*function ENT:CustomPhysicsObjectOnInitialize(phys)
	phys:Wake()
	phys:SetBuoyancyRatio(0)
	phys:EnableDrag(false)
	self:SetColor(Color(0,150,255,255))
end*/
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
if self.type == 1 then --COLD ACID
	self:SetModel("models/spitball_medium.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetColor( Color( 0, 150, 250, 255 ) ) 
	self:SetRenderMode( RENDERMODE_TRANSCOLOR ) -- You need to set the render mode on some entities in order for the color to change
	self:SetTrigger( true )
	
	--ParticleEffectAttach("vj_impact1_red", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	--ParticleEffectAttach("vj_impact1_red", PATTACH_ABSORIGIN_FOLLOW, self, 1)
	util.SpriteTrail( self, 0, Color( 255, 255, 255 ), false, 20, 5, 1, 5, "trails/smoke.vmt" )

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then 
		phys:Wake()
		phys:SetMass( 1 )
		phys:SetDragCoefficient( 0 )
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
	end
	
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "10")
	self.StartLight1:SetKeyValue("distance", "100")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:SetColor( Color( 255, 255, 255, 255 ) )
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self.StartLight1:Fire("Kill", "", 2.5)
	self:DeleteOnRemove(self.StartLight1)

elseif self.type == 2 then --aerial hale
	self:EmitSound("ocpack/otheruksound/future_shotsingle2.wav", 125, 100, 1, CHAN_AUTO)
	self:SetModel("models/props_phx/cannonball.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetColor( Color( 0, 255, 237, 180 ) ) 
	self:SetRenderMode( RENDERMODE_TRANSCOLOR ) -- You need to set the render mode on some entities in order for the color to change
	--self:SetTrigger( true )
	self:SetMaterial("lights/white")
	self:AddEffects( EF_NORECEIVESHADOW )
	self:AddEffects( EF_NOFLASHLIGHT )
	self:AddEffects( EF_BRIGHTLIGHT )
	self:AddEffects( EF_NOSHADOW )
	
	util.SpriteTrail( self, 0, Color( 0, 255, 237 ), false, 20, 5, 1, 5, "trails/smoke.vmt" )

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then 
		phys:Wake()
		phys:EnableDrag( false )
		phys:SetMass( 0 )
		phys:SetDragCoefficient( 0 )
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity( false )
	end
	
		local ownene = self:GetOwner():GetEnemy()
		timer.Simple(0.6,function() if IsValid(self) && IsValid(ownene) then	
			self:EmitSound("ocpack/marisaspells/laser3.wav", 125, 100, 1, CHAN_AUTO)
			local phys = self:GetPhysicsObject()
			if IsValid(phys) && IsValid(ownene) then--(400 + (400 * cvars.Number(self.CVar, 1))) + ownene:GetAbsVelocity()*0.35
				self:SetAngles((ownene:WorldSpaceCenter() - self:GetPos()):Angle())
				if cvars.Number(self.CVar, 1) >= 5 then
					self:SetAngles((ownene:WorldSpaceCenter() + ownene:GetAbsVelocity()*0.1 - self:GetPos()):Angle())
				end
				phys:SetVelocity(self:GetAngles():Forward() * (200 + (300 * cvars.Number(self.CVar, 1) )) )
			end
		end end)

end
end


---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	local own = self:GetOwner()
	local e = EffectData()
		e:SetOrigin(self:GetPos())
		e:SetScale(0.5)
	util.Effect("frostcloud", e, true, true)
	
	if self.type == 1 then-- COLD ACID
	
		for k, ship in pairs(ents.FindInSphere(self:GetPos(), 80)) do
		if engine.ActiveGamemode() == "horde" && HORDE:IsPlayerMinion(ship) then
			util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),250,80,DMG_ACID,true,true)
			ParticleEffect("zeala_burst", self:GetPos() + self:GetUp() * 20, Angle(0, 0, 0), nil)
			self:Remove()
		end
		end

	elseif self.type == 2 then --AERIAL HALE
		
		for k, ship in pairs(ents.FindInSphere(self:GetPos(), 80)) do
		if engine.ActiveGamemode() == "horde" && HORDE:IsPlayerMinion(ship) then
			util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),250,80,DMG_BLAST,true,true)
			ParticleEffect("zeala_burst", self:GetPos() + self:GetUp() * 20, Angle(0, 0, 0), nil)
			self:Remove()
		end
		end
		
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data,phys)
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	effectdata:SetScale( 2 )
	util.Effect("frostcloud", effectdata, true, true)
end

ENT.stationary = false
ENT.parried = 0
function ENT:OnDamaged(dmginfo)
    local phys = self:GetPhysicsObject()
    if dmginfo:GetDamageType() == DMG_CLUB or dmginfo:GetDamageType() == DMG_ALWAYSGIB then
		if self.stationary then return end
        local Eff = EffectData()
        Eff:SetOrigin(self:GetPos())
        Eff:SetScale(5)
        Eff:SetMagnitude(5)
        Eff:SetFlags(0)
		local phys = self:GetPhysicsObject()
		if(phys:IsValid()) then
			phys:EnableGravity(false)
			phys:SetVelocity( self.Owner:GetAimVector() * 3000 )
		end
        self.parried = true
    end
end

function ENT:StartTouch( npc ) 
local ow = self:GetOwner()
if self.parried == true then 
    util.VJ_SphereDamage(self:GetOwner(), self:GetOwner(), self:GetPos(), 200, 400, DMG_BLAST, true, true)
    local explosion = EffectData()
    explosion:SetOrigin(self:GetPos())
    explosion:SetMagnitude(200)
    explosion:SetRadius(200)
    explosion:SetScale(200)
    util.Effect("Explosion", explosion)
    util.Effect("AR2Explosion", explosion)
    self:Remove()
end

if self.type == 1 then
	if npc == self.Owner then return end	
	if npc == self then return end
	if self.Owner:IsNPC() && self.Owner:Disposition(npc) != D_HT then return end

	if npc:IsNPC() or npc:IsPlayer() or npc:IsNextBot() then
	if engine.ActiveGamemode() == "horde" then
	npc:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 10, self:GetOwner())
	end
	util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),50,25,DMG_ACID,true,true)
	self:Remove()
end 
elseif self.type == 2 then
	if npc == self.Owner then return end	
	if npc == self then return end
	if self.Owner:IsNPC() && self.Owner:Disposition(npc) != D_HT then return end

	if npc:IsNPC() or npc:IsPlayer() or npc:IsNextBot() then
	if engine.ActiveGamemode() == "horde" then
	npc:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 40, self:GetOwner())
	end
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetScale( 2 )
	util.Effect("frostcloud", effectdata, true, true)
	util.Effect("cold_explosion", effectdata, true, true)
	util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),250,80,DMG_BLAST,true,true)
	ParticleEffect("zeala_burst", self:GetPos() + self:GetUp() * 20, Angle(0, 0, 0), nil)
	self:EmitSound("ocpack/abyssblastog.wav", 125, 100, 1, CHAN_AUTO)
	
	/*for _, ent in pairs(ents.FindInSphere(self:GetPos(), 300)) do
        if engine.ActiveGamemode() == "horde" && (ent:IsNPC() or ent:IsPlayer()) then
			if ow:IsNPC() && ow:Disposition(ent) == D_HT then
				if ent:IsNextBot() then ent:LeaveGround() end
				ent:SetGroundEntity(NULL)
				ent:SetVelocity(self:GetForward()*200 +self:GetUp()*300)
			end
        end
    end*/
	
	self:Remove()
end
end
end


function ENT:CustomOnPhysicsCollide(data, phys) 
local ow = self:GetOwner()
if self.parried == true then
    util.VJ_SphereDamage(self:GetOwner(), self:GetOwner(), self:GetPos(), 200, 400, DMG_BLAST, true, true)
    local explosion = EffectData()
    explosion:SetOrigin(self:GetPos())
    explosion:SetMagnitude(200)
    explosion:SetRadius(200)
    explosion:SetScale(200)
    util.Effect("Explosion", explosion)
    util.Effect("AR2Explosion", explosion)
    self:Remove()
elseif (self.type == 2) && IsValid(self:GetOwner()) then
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	effectdata:SetScale( 1 )
	util.Effect("frostcloud", effectdata, true, true)
	util.Effect("cold_explosion", effectdata, true, true)
	util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),250,80,DMG_BLAST,true,true)
	ParticleEffect("zeala_burst", self:GetPos() + self:GetUp() * 20, Angle(0, 0, 0), nil)
	self:EmitSound("ocpack/abyssblastog.wav", 125, 100, 1, CHAN_AUTO)
	
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 300)) do
        if engine.ActiveGamemode() == "horde" && (ent:IsNPC() or ent:IsPlayer()) then
			if ow:IsNPC() && ow:Disposition(ent) == D_HT then
				ent:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 25, self:GetOwner())
			end
        end
    end
	
	self:Remove()
end
end
