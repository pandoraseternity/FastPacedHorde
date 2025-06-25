ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "HE Round"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= false


AddCSLuaFile()

ENT.Model = "models/hunter/triangles/025x025.mdl"
ENT.Ticks = 0
ENT.FuseTime = 10
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.CollisionGroupType = COLLISION_GROUP_PROJECTILE
ENT.Removing = nil

if SERVER then

function ENT:Initialize()
    local pb_vert = 1
    local pb_hor = 1
    self:SetModel(self.Model)
    self:PhysicsInitBox( Vector(-pb_vert,-pb_hor,-pb_hor), Vector(pb_vert,pb_hor,pb_hor) )
	self:SetCollisionBounds(Vector(15, 15, 15), Vector(-15, -15, -15))
	
	self:SetTrigger( true )
	self:DrawShadow( false )
	self:SetNoDraw( true )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	ParticleEffectAttach("striderbuster_attach_ring",PATTACH_ABSORIGIN_FOLLOW,self,0)
	--ParticleEffectAttach("ar2_combineball_arc_group",PATTACH_ABSORIGIN_FOLLOW,self,0)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
		phys:SetMass(1)
        phys:SetDragCoefficient(0)
        phys:SetBuoyancyRatio(0)
        phys:EnableGravity(false)
    end
	
	self.extra = ents.Create("prop_dynamic")
	self.extra:SetModel("models/weapons/tacint_extras/w_heathawk.mdl")
	self.extra:SetModelScale( self:GetModelScale() * 3)
	self.extra:PhysicsInit(SOLID_VPHYSICS)
	self.extra:SetMoveType(MOVETYPE_NONE)
	self.extra:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.extra:SetColor( Color( 0, 100, 255, 255 ) ) 
	self.extra:SetPos(self:GetPos())
	self.extra:SetAngles(self:GetAngles())
	self.extra:SetRenderMode( RENDERMODE_WORLDGLOW )
	self.extra:AddEffects( EF_NORECEIVESHADOW )
	self.extra:AddEffects( EF_NOFLASHLIGHT )
	self.extra:AddEffects( EF_BRIGHTLIGHT )
	self.extra:AddEffects( EF_NOSHADOW )
	self.extra:SetMaterial("models/debug/debugwhite")
	self.extra:SetTrigger( true )
	self.extra:Spawn()
	self.extra:Activate()
	self.extra:SetOwner(self)
	self.extra:SetParent(self)

    self.SpawnTime = CurTime()
end

function ENT:Think()

            if IsValid(self:GetOwner()) then
				for k, the in pairs(ents.FindInSphere(self:GetPos(), 3000)) do
                if IsValid(self:GetOwner()) && (the:IsNPC() or the:IsNextBot()) && the:Disposition(self:GetOwner()) != D_LI && self:Visible(the) then
                        self:SetAngles((the:GetPos() + the:GetUp() * 50 + the:GetForward() - self:GetPos()):Angle())
                        local phys = self:GetPhysicsObject()
                        if phys:IsValid() then 
							phys:SetVelocity(self:GetAngles():Forward() * 1000 ) 
						end
                    end
                end
            end
			
				if IsValid(self:GetOwner()) then
					for k, the in pairs(ents.FindInSphere(self:GetPos(), 100)) do
					if IsValid(self:GetOwner()) && (the:IsNPC() or the:IsNextBot()) && the:Disposition(self:GetOwner()) != D_LI && self:Visible(the) then
						local dmg = DamageInfo()
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamageType(DMG_BLAST)
						dmg:SetDamage(100)
						dmg:SetDamagePosition(self:GetPos())
						util.BlastDamageInfo( dmg, self:GetPos(), 250 )
					end
					end
				end

	VJ_EmitSound(self,"ocpack/otheruksound/GabrielSwing2Loop.wav" ,1000, 75)
	VJ_EmitSound(self,"ocpack/otheruksound/GabrielSwing2Loop.wav" ,1000, 125)
    if SERVER and CurTime() - self.SpawnTime >= self.FuseTime then
        self:Detonate()
    end
	
end

end

function ENT:StartTouch(npc)
    if npc == self.Owner then return end
    if npc == self then return end
	
    if npc:IsNPC() or npc:IsPlayer() or npc:IsNextBot() then 
	self.dmg = DamageInfo()
	self.dmg:SetDamage(60)
	self.dmg:SetDamageType( DMG_BURN )
	self.dmg:SetAttacker( self:GetOwner() )
	self.dmg:SetInflictor( self:GetOwner() )
	--npc:TakeDamageInfo( self.dmg )
	end

end

function ENT:PhysicsCollide(colData, collider)
    if !self:IsValid() or self.Removing then return end
    --if colData.HitEntity:IsNPC() then
        local dmg = DamageInfo()
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetDamage(200)
        dmg:SetDamagePosition(self:GetPos())
		util.BlastDamageInfo( dmg, self:GetPos(), 300 )
    --end
    local explosion = EffectData()
    explosion:SetOrigin(self:GetPos())
    explosion:SetMagnitude(200)
    explosion:SetRadius(200)
    explosion:SetScale(200)
    util.Effect("Explosion", explosion)
    util.Effect("AR2Explosion", explosion)
	ParticleEffect("Weapon_Combine_Ion_Cannon_Exlposion_c", self:GetPos(), Angle(0, 0, 0), nil)

    if !self:IsValid() or self.Removing then return end

    local attacker = self

    if self.Owner:IsValid() then
        attacker = self.Owner
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
    self.Removing = true
    self:Remove()

end

function ENT:Detonate()
    if !self:IsValid() or self.Removing then return end
    --if colData.HitEntity:IsNPC() then
        local dmg = DamageInfo()
        dmg:SetAttacker(self.Owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetDamage(200)
        dmg:SetDamagePosition(self:GetPos())
		util.BlastDamageInfo( dmg, self:GetPos(), 250 )
    --end
    local explosion = EffectData()
    explosion:SetOrigin(self:GetPos())
    explosion:SetMagnitude(200)
    explosion:SetRadius(200)
    explosion:SetScale(200)
    util.Effect("Explosion", explosion)
    util.Effect("AR2Explosion", explosion)
	ParticleEffect("Weapon_Combine_Ion_Cannon_Exlposion_c", self:GetPos(), Angle(0, 0, 0), nil)

    self:Remove()

end

function ENT:Draw()
    self:DrawModel()
end