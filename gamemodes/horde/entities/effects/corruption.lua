function EFFECT:Init(effect_data)
	self.effect_data = effect_data
    local pos = effect_data:GetOrigin()
    self.emitter = ParticleEmitter(pos)
    local smoke = self.emitter:Add("particles/smokey", pos)
    smoke:SetGravity( Vector(0, 0, 1500) )
    smoke:SetDieTime( math.Rand(0.5, 1) )
    smoke:SetStartAlpha(200)
    smoke:SetEndAlpha(0)
    smoke:SetStartSize(10)
    smoke:SetEndSize(300)
    smoke:SetRoll( math.Rand(-180, 180) )
    smoke:SetRollDelta( math.Rand(-0.2,0.2) )
    smoke:SetColor(200, 50, 200, 255)
    smoke:SetAirResistance(1000)
    smoke:SetPos(self:GetPos())
    smoke:SetLighting(false)
    smoke:SetCollide(true)
    smoke:SetBounce(0)
    self.emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end