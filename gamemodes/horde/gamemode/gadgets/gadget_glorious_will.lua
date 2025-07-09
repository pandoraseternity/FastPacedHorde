GADGET.PrintName = "Glorious Will"
GADGET.Description = [[Throws the Executioner's axe. 
Pierces enemies, dealing 125 fire damage. 
Explodes upon colliding with the terrain.]]
GADGET.Icon = "items/gadgets/glorious_will.png"
GADGET.Droppable = true
GADGET.Active = true
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Params = {}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_glorious_will" then return end

    local rocket = ents.Create("projectile_horde_inferno_axe")
    local vel = 2500
    local ang = ply:EyeAngles()

    local src = ply:GetPos() + Vector(0,0,50) + ply:GetEyeTrace().Normal * 5

    if !rocket:IsValid() then print("!!! INVALID ROUND " .. rocket) return end

    local rocketAng = Angle(ang.p, ang.y, ang.r)

    rocket:SetAngles(rocketAng)
    rocket:SetPos(src)

    rocket:SetOwner(ply)
    rocket.Owner = ply
    rocket.Inflictor = rocket

    local RealVelocity = (ply:GetAbsVelocity() or Vector(0, 0, 0)) + ang:Forward() * vel
    rocket.CurVel = RealVelocity -- for non-physical projectiles that move themselves

    rocket:Spawn()
    rocket:Activate()
    if !rocket.NoPhys and rocket:GetPhysicsObject():IsValid() then
        rocket:SetCollisionGroup(rocket.CollisionGroup or COLLISION_GROUP_DEBRIS)
        rocket:GetPhysicsObject():SetVelocityInstantaneous(RealVelocity)
    end

    sound.Play("weapons/physcannon/superphys_launch1.wav", ply:GetPos())
end