if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "hlof/sprites/shockrifle_selecticon" )
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
killicon.Add( "weapon_hlof_shockrifle", "hlof/sprites/shockrifle_killicon", Color( 255, 255, 255, 255 ) )
killicon.Add( "ent_hlof_shock", "hlof/sprites/shockrifle_killicon", Color( 255, 255, 255, 255 ) )
end

SWEP.PrintName = "Shock Roach"
SWEP.Category = "Horde"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 85
SWEP.ViewModel = "models/hlof/v_shock.mdl"
SWEP.WorldModel = "models/hlof/w_shock_rifle.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Slot = 5
SWEP.SlotPos = 4

SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.FiresUnderwater = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.RegenerationTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()

SWEP.Primary.Sound = Sound( "Weapon_HLOF_Shock_Roach.Single" )
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 15
SWEP.Primary.MaxAmmo = 15
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Hornet"
SWEP.Primary.Damage = 8
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Delay = 0.07
SWEP.Primary.Force = 200

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Delay = 0.1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	timer.Create( "shockregen" .. self:EntIndex(), 1, 0, function() if IsValid(self) && self:GetOwner():Alive() then
		if IsValid(self) && self:Ammo1() < self.Primary.MaxAmmo && CurTime() > self.RegenerationTimer then
			self.RegenerationTimer = CurTime() + 0.2
			--self:SetClip1( self:Clip1() + 1 )
			self.Owner:SetAmmo( self:Ammo1() + 1, self.Primary.Ammo )
			self:EmitSound("Weapon_HLOF_Shock_Roach.Recharge", 500, 100, 1, CHAN_ITEM)
		end
	end end )
self:SetWeaponHoldType( self.HoldType )
self.Idle = 0
self.IdleTimer = CurTime() + 1
end

function SWEP:DrawHUD()
end

function SWEP:Deploy()
self:SetWeaponHoldType( self.HoldType )
self:SendWeaponAnim( ACT_VM_DRAW )
self.RegenerationTimer = CurTime() + 1
self.Idle = 0
self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
self.Recoil = 0
self.RecoilTimer = CurTime()
return true
end

function SWEP:Holster()
self.RegenerationTimer = CurTime()
self.Idle = 0
self.IdleTimer = CurTime()
self.Recoil = 0
self.RecoilTimer = CurTime()
return true
end

function SWEP:PrimaryAttack()
    if self:Ammo1() <= 0 then return end
    if self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 then return end
    if SERVER then
        local entity = ents.Create("obj_horde_shockproj")
        entity:SetOwner(self.Owner)
        if IsValid(entity) then
            local Forward = self.Owner:EyeAngles():Forward()
            local Right = self.Owner:EyeAngles():Right()
            local Up = self.Owner:EyeAngles():Up()
            entity:SetPos(self.Owner:GetShootPos() + Forward * 12 + Right * 4 + Up * -4)
            entity:SetAngles(self.Owner:EyeAngles())
            entity:Spawn()
            local phys = entity:GetPhysicsObject()
            phys:SetMass(0)
            phys:EnableGravity(false)
			phys:EnableDrag( false )
			if IsValid(entity) and IsValid(phys) then phys:ApplyForceCenter(entity:GetForward() * 2000) end
        end
    end

    self:EmitSound(self.Primary.Sound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.Owner:MuzzleFlash()
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.RegenerationTimer = CurTime() + 1
    self.Idle = 0
    self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:DoTrace()
    tr = { }
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 8096
    tr.mins = Vector( ) * -20
    tr.maxs = Vector( ) * 20
    tr = util.TraceHull( tr )
end

function SWEP:SecondaryAttack()

if self:Ammo1() < 5 then return end

local bullet = {} 
bullet.Num = 1
bullet.Src = self.Owner:GetShootPos() 
bullet.Dir = self.Owner:GetAimVector() 
bullet.Spread = Vector( 0, 0, 0 )
bullet.HullSize = 10
bullet.Tracer = 0
bullet.Force = 500 
bullet.Damage = 0.0001
bullet.AmmoType = "StriderMinigun" 
bullet.Callback = function(attacker, tr, dmginfo)	
local trace = util.TraceLine({
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos()+self.Owner:GetAimVector()*32768,
	filter = {self.Owner},
})
	if SERVER then
		for k,ent in pairs(ents.FindAlongRay(self.Owner:GetShootPos()+self.Owner:GetAimVector()*30, self.Owner:GetShootPos()+self.Owner:GetAimVector()*32768 ,Vector(-10,-10,-10),Vector(10,10,10))) do
		dmginfo = DamageInfo()
		dmginfo:SetDamage( 45 )
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetAttacker( self:GetOwner() )
		dmginfo:SetInflictor( self )
		if trace.HitGroup == HITGROUP_HEAD then
			dmginfo:AddDamage(45)
		end
		if ent ~= self.Owner && (HORDE:IsPlayerOrMinion(ent) == false) && (ent:IsNPC() or ent:IsNextBot()) && engine.ActiveGamemode() == "horde" then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 50, self.Owner)
		end
		dmginfo:SetDamagePosition( trace.HitPos )
		dmginfo:SetDamageForce(self:GetOwner():GetForward() * 4000)
		if ent ~= self.Owner then 
			ent:TakeDamageInfo( dmginfo )
		end
		end
	end

end

        local tr = self.Owner:GetEyeTrace()
        local effectdata = EffectData()
        effectdata:SetOrigin( tr.HitPos )
        effectdata:SetNormal( tr.HitNormal )
        effectdata:SetStart( self.Owner:WorldSpaceCenter() )
        effectdata:SetAttachment( 1 )
        effectdata:SetEntity( self )
        util.Effect( "nailcannon_beam", effectdata )


local attackpos = self:DoTrace()
self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self.Owner:SetAnimation( PLAYER_ATTACK1 )

local PlayerPos = self.Owner:GetShootPos()
local PlayerAim = self.Owner:GetAimVector()
self.Owner:FireBullets( bullet ) 
	
self:EmitSound("weapons/shock_discharge2.wav", 100, 100, 1, CHAN_AUTO)
self:SetNextPrimaryFire( CurTime() + 1 )
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )


self:TakePrimaryAmmo( 3 )
end

function SWEP:Reload()
end

function SWEP:Think()
if self.RegenerationTimer <= CurTime() and self:Ammo1() < self.Primary.MaxAmmo then
if SERVER then
self.Owner:EmitSound( "Weapon_HLOF_Shock_Roach.Recharge" )
end
self.Owner:SetAmmo( self:Ammo1() + 1, self.Primary.Ammo )
self.RegenerationTimer = CurTime() + 0.2
end
if self.Idle == 0 and self.IdleTimer <= CurTime() then
if SERVER then
self:SendWeaponAnim( ACT_VM_IDLE )
end
self.Idle = 1
end
if self:Ammo1() > self.Primary.MaxAmmo then
self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
end
end