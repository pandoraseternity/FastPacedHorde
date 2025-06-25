SWEP.PrintName = "Iridescent Pearl"
SWEP.Purpose = "Special boss weapon drop."
SWEP.Instructions = "Gives a passive 35% speed boost."
SWEP.Category = "Horde"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 65
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

hook.Add("Horde_PlayerMoveBonus", "Iridescentpearl", function(ply, bonus_walk, bonus_run)
    if ply.Pearl == true then
		--if ply.Pearl == nil then return false end
        bonus_walk.increase = bonus_walk.increase + (0.5 )
        bonus_run.increase = bonus_run.increase + (0.5 )
	end
end)

hook.Add( "EntityRemoved", "IridescentpearlRemove", function( ent, fullUpdate )
	if ent:GetClass() == "horde_drop_iridescent" then
		ent:GetOwner().Pearl = nil
		ent:EmitSound("horde/spells/enlighten.ogg", 90, 120, 1)
	end
end )

hook.Add("PlayerDroppedWeapon", "IridescentpearlDrop", function(owner, wep)
	if wep:GetClass() == "horde_drop_iridescent" then
		owner.Pearl = nil
		wep:EmitSound("horde/spells/enlighten.ogg", 90, 120, 1)
	end
end)

/*function SWEP:OnRemove()
	if SERVER then
	local owner = self:GetOwner()
        if owner:IsValid() then
            owner.Pearl = nil
			self:EmitSound("horde/spells/enlighten.ogg", 90, 120, 1)
        end
	end
end

function SWEP:OnDrop()
	if SERVER then
	local owner = self:GetOwner()
        if owner:IsValid() then
            owner.Pearl = nil
			self:EmitSound("horde/spells/enlighten.ogg", 90, 120, 1)
        end
	end
end*/

function SWEP:Deploy()
	local owner = self:GetOwner()
	timer.Simple(0.5, function() if IsValid(owner) then
		self:EmitSound("horde/spells/enlighten.ogg", 90, 120, 1)
		owner.Pearl = true
	end end)
	--owner:PrintMessage(HUD_PRINTTALK, "poop")
end