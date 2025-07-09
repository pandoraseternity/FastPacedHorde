function EFFECT:Init(effect_data)
	self.effect_data = effect_data
    self.entity = effect_data:GetEntity()
    self.radius = effect_data:GetRadius()
    self.ticks = 0
end

-- Bubbles
function EFFECT:Think()
	if not self.entity or not self.entity:IsValid() then return true end
	if not self.entity.Horde_Mutation_Transc and IsValid(self.emitter) then self.emitter:Finish() return false end
    local pos = self.entity:GetPos()
    if not self.emitter then
        self.emitter = ParticleEmitter(pos)
        self.emitter:SetNearClip(24, 32)
    end
	
    local dlight = DynamicLight( math.random( 0, 9999999 ) )
	if dlight then
		dlight.Pos = pos
		dlight.r = math.random(0,255)
		dlight.g = math.random(0,255)
		dlight.b = math.random(0,255)
		dlight.Brightness = 6
		dlight.Size = 160
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 0.1
	end

    if self.emitter then
		local particle = self.emitter:Add("particle/particle_glow_02", pos + VectorRand() * self.radius)
		particle:SetDieTime(0.6)
		particle:SetColor(math.random(0,255),math.random(0,255),math.random(0,255))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(8)
		particle:SetVelocity(Vector(0,0,100))
		particle:SetGravity(VectorRand(0,0,5))
		particle:SetCollide(true)
		particle:SetBounce(5)
        particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetAirResistance(0)
	end

    return true
end

function EFFECT:Render()
end