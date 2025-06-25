ENT.Type 				= "anim"
ENT.Base 				= "projectile_horde_spell_base"
ENT.PrintName 			= "HE Round"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= false


AddCSLuaFile()

ENT.Model = "models/props_lab/bigrock.mdl"
ENT.Models = {"models/props_wasteland/rockgranite03b.mdl"}
ENT.Ticks = 0
ENT.FuseTime = 5
ENT.CollisionGroup = COLLISION_GROUP_PLAYER_MOVEMENT
ENT.CollisionGroupType = COLLISION_GROUP_PLAYER_MOVEMENT
ENT.Removing = nil
ENT.parried = 0
ENT.enemyhit = 0

if SERVER then

function ENT:CustomOnInitialize()
    self:SetModel(self.Models[math.random(#self.Models)])
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_PLAYER_MOVEMENT )
    self:DrawShadow( false )
    local a = Angle(0,0,0)
    a:Random()
    self:SetAngles(a)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetBuoyancyRatio(0)
        phys:EnableDrag(false)
        phys:SetMass(1)
        phys:EnableGravity(false)
    end

    timer.Simple(0, function ()
        if self:GetCharged() >= 2 then
            self:Ignite(999)
            if self:GetCharged() == 2 then
                HORDE:SimpleParticleSystem("vj_rocket_idle1", self:GetPos(), Angle(0,0,0), self)
            else
                HORDE:SimpleParticleSystem("vj_rocket_idle2", self:GetPos(), Angle(0,0,0), self)
            end
        end
    end)

    self.SpawnTime = CurTime()
end

function ENT:Think()
    if SERVER and CurTime() - self.SpawnTime >= self.FuseTime or self.enemyhit >= 2 then
        self:EmitSound("physics/concrete/boulder_impact_hard4.wav", 125, 100, 1, CHAN_AUTO)
        for i = 1, math.random(5, 10) do
            local debris = ents.Create("base_gmodentity")
            local mat = "debris/debris" .. tostring(math.random(1, 4))
            debris:SetPos(self:GetPos())
            debris:SetAngles(VectorRand():Angle())
            debris:SetModel("models/props_junk/rock001a.mdl")
            debris:PhysicsInit(SOLID_VPHYSICS)
            debris:SetCollisionGroup(COLLISION_GROUP_WORLD)
            if self:GetCharged() == 3 then debris:Ignite(999) end
            local physobj = debris:GetPhysicsObject()
            local force = 1000
            physobj:AddVelocity(Vector(math.random(-force, force), math.random(-force, force), math.random(-force, force)))
            physobj:AddAngleVelocity(Vector(math.random(-force, force), math.random(-force, force), math.random(-force, force)))
            timer.Simple(3, function()
                if IsValid(debris) then
                    local effect = EffectData()
                    local debrisPos = debris:GetPos()
                    effect:SetStart(debrisPos)
                    effect:SetOrigin(debrisPos)
                    effect:SetEntity(debris)
                    util.Effect("entity_remove", effect)
                    debris:Remove()
                end
            end)
        end

        self:Remove()
    end
end

else

function ENT:Think()
    if self.Ticks % 5 == 0 then
        local emitter = ParticleEmitter(self:GetPos())

        if !self:IsValid() or self:WaterLevel() > 2 then return end
        if !IsValid(emitter) then return end

        local smoke = emitter:Add("particle/particle_smokegrenade", self:GetPos())
        smoke:SetVelocity( VectorRand() * 25 )
        smoke:SetGravity( Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-20, -25)) )
        smoke:SetDieTime( math.Rand(1.5, 2.0) )
        smoke:SetStartAlpha( 255 )
        smoke:SetEndAlpha( 0 )
        smoke:SetStartSize( 0 )
        smoke:SetEndSize( 100 )
        smoke:SetRoll( math.Rand(-180, 180) )
        smoke:SetRollDelta( math.Rand(-0.2,0.2) )
        smoke:SetColor( 20, 20, 20 )
        smoke:SetAirResistance( 5 )
        smoke:SetPos( self:GetPos() )
        smoke:SetLighting( false )
        emitter:Finish()
    end

    self.Ticks = self.Ticks + 1
end

end

function ENT:Detonate()
    if !self:IsValid() or self.Removing then return end
    self:EmitSound("horde/spells/meteor_explode.ogg", 125, 100, 1, CHAN_AUTO)
    local attacker = self

    if self.Owner:IsValid() then
        attacker = self.Owner
    end

    local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_GENERIC)
	dmg:SetDamage(self:GetSpellBaseDamage(1) * (1 + 0.5 * (self:GetCharged() - 1)))
	util.BlastDamageInfo(dmg, self:GetPos(), 200)

    if self:GetCharged() == 3 then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(2)
        util.Effect("horde_blaster_flame_explosion", effectdata, true ,true)

        local d2 = DamageInfo()
        d2:SetAttacker(self.Owner)
        d2:SetInflictor(self)
        d2:SetDamageType(DMG_BLAST)
        d2:SetDamage(self:GetSpellBaseDamage(1) / 1.5)
        util.BlastDamageInfo(d2, self:GetPos(), 200)
    end

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
    --self.Removing = true
    self:Remove()
end

function ENT:Test()
if SERVER then
--PrintMessage( HUD_PRINTTALK, "hi" )
end
end

function ENT:OnTakeDamage( dmginfo )
    if dmginfo:GetDamageType() == DMG_CLUB then
		self.parried = 1
        --self:Test()
    end
end

/*function ENT:StartTouch( npc ) 
	if npc == self.Owner then return end	
	if npc == self then return end

	if npc:IsNPC() or npc:IsNextBot() then
		self.enemyhit = self.enemyhit + 1
	end
end*/

function ENT:PhysicsCollide(colData, collider)
	if self.parried == 1 then
	--self:Test()
	self:Detonate2()
	elseif self.parried == 0 then
		local wowe = self:GetOwner()
		if colData.HitEntity:IsNPC() or colData.HitEntity:IsNextBot() && self.enemyhit <= 2 then
			self:Detonate()
		elseif colData.HitEntity:IsSolid() && self.enemyhit <= 2 then
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
			phys:SetMaterial( "metal_bouncy" )
			phys:SetMass(1)
			phys:EnableDrag(false)
			self:SetAngles(self:GetAngles() + Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
			phys:SetDragCoefficient( 0 )
			phys:Wake()
			phys:SetVelocity(self:GetAngles():Forward() * 2000 )
			--self:SetTrigger( true )
			--PrintMessage( HUD_PRINTTALK, "yomomma" )
			
				--PrintMessage( HUD_PRINTTALK, "yomomma" )
				--ParticleEffect("aurora_shockwave_ring",self:GetPos() + self:GetUp()*5,Angle(0,0,0),nil)
				local pos = self:GetPos()
				local targets = ents.FindInSphere(pos, 5000)
				local nearest = nil 
				local nearestDist = math.huge
				for _, ent in pairs(targets) do
					local dist = ent:GetPos():DistToSqr(pos)
						if HORDE:IsEnemy(ent) and ent:Health() > 0 and not HORDE:IsPlayerMinion(ent) and dist < nearestDist then
						nearest = ent
						nearestDist = dist
						--self:SetAngles((ent:WorldSpaceCenter() - self:GetPos()):Angle())
					end
				end
			if nearest then
				local target = nearest
					self:SetAngles((nearest:WorldSpaceCenter() - self:GetPos()):Angle())
					local phys = self:GetPhysicsObject()
					if(phys:IsValid()) then 
						phys:SetVelocity(self:GetAngles():Forward() * 3500 )
				end
			end
			
			
		end
		
		end
	end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Detonate2()
    if !self:IsValid() or self.Removing then return end
    self:EmitSound("horde/spells/meteor_explode.ogg", 125, 100, 1, CHAN_AUTO)
    for i = 1, math.random(5,10) do
		local debris = ents.Create("base_gmodentity")
		local mat = "debris/debris" .. tostring(math.random(1, 4))
		
		debris:SetPos(self:GetPos())
		debris:SetAngles(VectorRand():Angle())
		debris:SetModel("models/props_junk/rock001a.mdl")
		debris:PhysicsInit(SOLID_VPHYSICS)
        debris:SetCollisionGroup(COLLISION_GROUP_WORLD)

        debris:Ignite(999)
        
		
		local physobj = debris:GetPhysicsObject()
		local force = 1000
		
		physobj:AddVelocity(Vector(math.random(-force, force), math.random(-force, force), math.random(-force, force)))
		physobj:AddAngleVelocity(Vector(math.random(-force, force), math.random(-force, force), math.random(-force, force)))
		
		timer.Simple(3, function()
			if IsValid(debris) then
				local effect = EffectData()
				local debrisPos = debris:GetPos()
				effect:SetStart(debrisPos)
				effect:SetOrigin(debrisPos)
				effect:SetEntity(debris)
				util.Effect("entity_remove", effect)
				debris:Remove()
			end
		end)
    end
    local attacker = self

    if self.Owner:IsValid() then
        attacker = self.Owner
    end

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(2)
        util.Effect("horde_blaster_flame_explosion", effectdata, true ,true)
		
		local dmg = DamageInfo()
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamageType(DMG_GENERIC)
		dmg:SetDamage(self:GetSpellBaseDamage(1) * (3 + 0.5 * (self:GetCharged() - 1)))
		util.BlastDamageInfo(dmg, self:GetPos(), 300)

        local d2 = DamageInfo()
        d2:SetAttacker(self.Owner)
        d2:SetInflictor(self)
        d2:SetDamageType(DMG_BLAST)
        d2:SetDamage(self:GetSpellBaseDamage(1) / 1.25)
        util.BlastDamageInfo(d2, self:GetPos(), 300)

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