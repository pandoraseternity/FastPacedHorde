SWEP.PrintName = "Glorious Will"
SWEP.Purpose = "Special boss weapon drop."
SWEP.Instructions = "Throws the Executioner's axe. Pierces enemies, dealing 125 fire damage. Explodes upon colliding with the terrain."
SWEP.Category = "Horde"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 35
SWEP.ViewModel = "models/weapons/tacint_extras/v_heathawk.mdl"
SWEP.WorldModel = "models/weapons/tacint_extras/w_heathawk.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.BobScale = 1
SWEP.SwayScale = 0
 
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 7
SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.HoldType = "ar2"
SWEP.FiresUnderwater = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.Spin = 0
SWEP.SpinTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.Recoil = 0
SWEP.RecoilTimer = CurTime()

SWEP.Primary.Sound = Sound( "" )
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.MaxAmmo = 9999
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "GaussEnergy"
SWEP.Primary.Delay = 1
SWEP.Primary.Damage = 0

SWEP.Secondary.Sound = Sound( "" )
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Damage = 60
SWEP.Secondary.TakeAmmo = 5
SWEP.ReloadSound            = "ambient/machines/keyboard2_clicks.wav"

function SWEP:DrawHUD()
    if CLIENT then
    local x, y
    if ( self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() ) then
    local tr = util.GetPlayerTrace( self.Owner )
    local trace = util.TraceLine( tr )
    local coords = trace.HitPos:ToScreen()
    x, y = coords.x, coords.y
    else
    x, y = ScrW() / 2, ScrH() / 2
    end
    surface.SetTexture( surface.GetTextureID( "vgui/hud/special_crosshair" ) )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawTexturedRect( x - 16, y - 16, 32, 32 )
    end
end

function SWEP:Initialize()
	timer.Create( "axeregen" .. self:EntIndex(), 1, 0, function() if IsValid(self) then
		if IsValid(self) && self:Clip1() < 12 then
			self:SetClip1(math.min(self.Primary.MaxAmmo, self:Clip1() + 1))
		end
	end end )
end

function SWEP:Deploy()
    self:SetWeaponHoldType( self.HoldType )
    self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
    return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
    if (not self:CanPrimaryAttack()) then return end
	if self:Clip1() < 12 then return end
	local ply = owner
    if CLIENT then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:TakePrimaryAmmo( 12 )
	self:SendWeaponAnim( ACT_VM_DRAW )
    local rocket = ents.Create("projectile_horde_inferno_axe")
    local vel = 2500
    local ang = ply:EyeAngles()

    local src = ply:GetPos() + Vector(0,0,50) + ply:GetEyeTrace().Normal * 5

    if !rocket:IsValid() then print("!!! INVALID ROUND " .. rocket) return end

    local rocketAng = Angle(ang.p, ang.y, ang.r)

    rocket:SetAngles(rocketAng)
    rocket:SetPos(src)

    rocket:SetOwner(owner)
    rocket.Inflictor = rocket

    local RealVelocity = (Vector(0, 0, 0)) + ang:Forward() * vel--ply:GetAbsVelocity()
    rocket.CurVel = RealVelocity -- for non-physical projectiles that move themselves

    rocket:Spawn()
    rocket:Activate()
    if !rocket.NoPhys and rocket:GetPhysicsObject():IsValid() then
        rocket:SetCollisionGroup(rocket.CollisionGroup or COLLISION_GROUP_DEBRIS)
        rocket:GetPhysicsObject():SetVelocityInstantaneous(RealVelocity)
    end

    sound.Play("weapons/physcannon/superphys_launch1.wav", ply:GetPos())
end

function SWEP:SecondaryAttack()
    if (not self:CanPrimaryAttack()) then return end

end

function SWEP:Reload()
    if self:Clip1() >= self:GetMaxClip1() then return end
    self:EmitSound(Sound(self.ReloadSound))
    --self.Weapon:DefaultReload(ACT_VM_RELOAD);
end
