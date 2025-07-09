SWEP.PrintName = "Hellfire Tincture"
SWEP.Purpose = "Special boss weapon drop."
SWEP.Instructions = "Every second: Deals 5% of your max health as damage to you. Deals 100% of your max health as Fire damage to enemies near you. 			Upon kill: Deals 125% of your max health as Fire damage to enemies."
SWEP.Category = "Horde"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
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
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
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

function SWEP:Deploy()
    self:SetWeaponHoldType( self.HoldType )
    self:SendWeaponAnim( ACT_VM_DRAW )
    return true
end

function SWEP:Initialize()
	timer.Create( "tinctureregen" .. self:EntIndex(), 1, 0, function() if IsValid(self) then
		if IsValid(self) && self:Clip1() < 20 then
			self:SetClip1(math.min(self.Primary.MaxAmmo, self:Clip1() + 1))
		end
	end end )
end

hook.Add( "Horde_OnEnemyKilled", "HellfireTincture", function(victim, killer, wpn)
    if not killer.Hellfire_Tincture then return end
	local pos = victim:GetPos()
	ParticleEffect("zeala_burst_core", victim:GetPos(), Angle(0, 0, 0), nil)
	timer.Simple(0.5, function()
    HORDE:ApplyDamageInRadius(pos, 250, HORDE:DamageInfo(killer:GetMaxHealth() * 1.25, DMG_BURN, killer))
	end)
end )

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
    if (not self:CanPrimaryAttack()) then return end
	if self:Clip1() < 20 then return end
    if CLIENT then return end
    self:EmitSound("horde/player/drink.ogg")
	self:TakePrimaryAmmo( 20 )
    local id = owner:SteamID()
	owner.Hellfire_Tincture = true
    owner:ScreenFade(SCREENFADE.IN, Color(200, 50, 50, 50), 0.1, 12)
    timer.Remove("Horde_Hellfire_Tincture" .. id)
    timer.Create("Horde_Hellfire_Tincture" .. id, 1, 0, function ()
        if !owner:IsValid() then timer.Remove("Horde_Hellfire_Tincture" .. id) return end
        HORDE:TakeDamage(owner, 0.025 * owner:GetMaxHealth(), DMG_GENERIC, owner)
		--owner:TakeDamage(0.025 * owner:GetMaxHealth(), owner, owner )
        HORDE:ApplyDamageInRadius(owner:GetPos(), 300, HORDE:DamageInfo(owner:GetMaxHealth() * 1, DMG_BURN, owner))
		self:EmitSound("horde/weapons/blaster/fire_explosion.ogg")
    end)
    timer.Simple(12, function()
		timer.Remove("Horde_Hellfire_Tincture" .. id)
		owner:EmitSound("horde/gadgets/optical_camouflage_on.ogg")
        if owner:IsValid() then owner.Hellfire_Tincture = nil end
    end)
end

function SWEP:SecondaryAttack()
    if (not self:CanPrimaryAttack()) then return end

end

function SWEP:Reload()
    if self:Clip1() >= self:GetMaxClip1() then return end
    self:EmitSound(Sound(self.ReloadSound))
    --self.Weapon:DefaultReload(ACT_VM_RELOAD);
end

function SWEP:Remove()
    if CLIENT then return end
	local owner = self:GetOwner()
    local id = owner:SteamID()
	timer.Remove("Horde_Hellfire_Tincture" .. id)
	owner.Hellfire_Tincture = nil
end