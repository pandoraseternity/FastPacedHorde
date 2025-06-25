SWEP.PrintName = "Unstable Injection"
SWEP.Purpose = "Special boss weapon drop."
SWEP.Instructions = "Gives you a random effect out of the following: Recover 40% health. Gain 3 Adrenaline or 35 Barrier. Gain Fortify/Berserk for 25 seconds"
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
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
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
	timer.Create( "injectregen" .. self:EntIndex(), 1, 0, function() if IsValid(self) then
		if IsValid(self) && self:Clip1() < 10 then
			self:SetClip1(math.min(self.Primary.MaxAmmo, self:Clip1() + 1))
		end
	end end )
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
    if (not self:CanPrimaryAttack()) then return end
	local ply = owner
    if CLIENT then return end
	self:TakePrimaryAmmo( 10 )
    sound.Play("horde/gadgets/injection.ogg", ply:GetPos())

    local p = math.random(1,3)
    if p == 1 then
        sound.Play("items/medshot4.wav", ply:GetPos())
        local healinfo = HealInfo:New({amount=ply:GetMaxHealth() * 0.4, healer=ply})
        HORDE:OnPlayerHeal(ply, healinfo)
    elseif p == 2 then
        local q = math.random(1,2)
        if q == 1 then
            ply:Horde_AddAdrenalineStack(3)
			ply:Horde_SetAdrenalineStackDuration(10)
        else
            ply:Horde_AddBarrierStack(50)
        end
    elseif p == 3 then
        local q = math.random(1,2)
        if q == 1 then
            ply:Horde_AddBerserk(25)
        else
            ply:Horde_AddFortify(25)
        end
    end
end

function SWEP:Remove()
    if CLIENT then return end
	local owner = self:GetOwner()
    local id = owner:SteamID()
	timer.Remove("Horde_Hellfire_Tincture" .. id)
	owner.Hellfire_Tincture = nil
end

function SWEP:Reload()

end
