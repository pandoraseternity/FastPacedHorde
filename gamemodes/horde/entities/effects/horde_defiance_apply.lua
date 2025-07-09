function EFFECT:Init(data)	
    local radius = data:GetRadius()

    local emitter = ParticleEmitter(data:GetOrigin())
    local emitter2 = ParticleEmitter(data:GetOrigin(), true)
    emitter2:SetNearClip(24, 32)
    for i = 1,10 do
        local smoke = emitter:Add("particles/smokey", data:GetOrigin())
        smoke:SetGravity(Vector(0,0,-800))
        smoke:SetDieTime(radius/190/1.5)
        smoke:SetStartAlpha(0)
        smoke:SetEndAlpha(100)
        smoke:SetStartSize(10)
        smoke:SetEndSize(radius * 1.25)
        smoke:SetRoll( math.Rand(-180, 180) )
        smoke:SetRollDelta( math.Rand(-0.2,0.2) )
        smoke:SetColor(194, 255, 125)
        smoke:SetAirResistance(0)
        local p = VectorRand() * 50
        p.z = 0
        smoke:SetPos( data:GetOrigin() + p)
        smoke:SetLighting( false )
        smoke:SetCollide(true)
        smoke:SetBounce(0)
    end
    emitter:Finish()

    local normal = Vector(0,0,1)
    local ringstart = data:GetOrigin() + normal * 10
    local particle
    for i=1, 2 do
        particle = emitter2:Add("effects/select_ring", ringstart)
        particle:SetDieTime(0.25 + i * 0.2)
        particle:SetColor(194, 255, 125)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(0)
        particle:SetEndSize(radius)
        particle:SetAngles(normal:Angle())
    end
    emitter2:Finish()


	local Hitpos = data:GetOrigin()

	local mat = Material("status/gadget/aegis.png", "mips smooth")
	print(Hitpos)

	self.Emitter = ParticleEmitter(Hitpos)
	local p = self.Emitter:Add(mat, Hitpos)
	p:SetColor(255,0,0)
	p:SetDieTime(0.5)
	p:SetStartAlpha(255)
	p:SetEndAlpha(0)
	p:SetStartSize(50)
	p:SetEndSize(50)
	p:SetCollide(false)
	self.Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end