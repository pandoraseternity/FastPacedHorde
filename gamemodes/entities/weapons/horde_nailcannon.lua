SWEP.PrintName = "Nailcannon" -- The name of the weapon
    
SWEP.Author = ""
SWEP.Contact = ""--Optional
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Horde" --This is required or else your weapon will be placed under "Other"




SWEP.Spawnable= true --Must be true
SWEP.AdminOnly = false



SWEP.Base = "weapon_base"
--Weapon_Mortar.Impact
local ShootSound = Sound("bootleg_ultrakill/MachineGun.wav")
SWEP.Primary.Damage = 0 --The amount of damage will the weapon do
SWEP.Primary.CVar		= "bootleg_dmg_multiplier"
SWEP.Primary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Spread = 0 -- The spread when shot
SWEP.Primary.Automatic = true -- Is it automatic
SWEP.Primary.Recoil = 0 -- The amount of recoil
SWEP.Primary.Delay = 0.06 -- Delay before the next shot
SWEP.Primary.Force = 1000
SWEP.ReloadSound = "Weapon_AR2.Reload"

SWEP.Secondary.ClipSize		= 100
SWEP.Secondary.DefaultClip	= 100
SWEP.Secondary.MaxAmmo = 100
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay = 0.1 -- 
SWEP.Secondary.Ammo		= ""


SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true --Does it draw the crosshair
SWEP.DrawAmmo = true
SWEP.Weight = 5 --Priority when the weapon your currently holding drops
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 70
SWEP.ViewModel			= "models/weapons/tfa_qc/c_supernailgun.mdl"
SWEP.WorldModel			= "models/weapons/tfa_qc/w_supernailgun.mdl"
SWEP.UseHands           = true

SWEP.HoldType = "Pistol" 

SWEP.FiresUnderwater = true


SWEP.CSMuzzleFlashes = false
SWEP.TracerType                         = "GaussTracer"
SWEP.MuzzleEffect                       = "ChopperMuzzleFlash"
SWEP.MuzzleAttachment                   = "1"



function SWEP:Initialize()
util.PrecacheSound(ShootSound) 
util.PrecacheSound(self.ReloadSound) 
self:SetWeaponHoldType( self.HoldType )
self:SetLastAmmoRegen( CurTime() )

	timer.Create( "railregen" .. self:EntIndex(), 1, 0, function() if IsValid(self) then
		if IsValid(self) && self:Clip2() < 100 && CurTime() > self.shockwaiting then
			self.shockwaiting = CurTime() + 1
			self:SetClip2( self:Clip2() + 10 )
			self.processwaiting = 1
		end
		if IsValid(self) && self:Clip2() >= 100 && self.processwaiting == 1 then
			if self.processwaiting == 0 then return end
			self:EmitSound("bootleg_ultrakill/RailcannonFullClickAndCharge.wav", 500, 100, 1, CHAN_ITEM)
			self.processwaiting = 0
		end
	end end )

end 

function SWEP:Deploy()
self:SetWeaponHoldType( self.HoldType )
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
return true
end

function SWEP:Holster( wep )
return true
end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "LastAmmoRegen" )
	self:NetworkVar( "Float", 1, "NextIdle" )

end

function SWEP:PrimaryAttack()
 
if ( !self:CanPrimaryAttack() ) then return end

tr = self.Owner:GetEyeTrace()
local ply = self:GetOwner()
local ang = self.Owner:GetAimVector():Angle()
 
if SERVER then
local chair = ents.Create("projectile_horde_nail")
chair:SetPos(ply:GetShootPos() + ply:GetRight() * 4 + ply:GetUp() * -2)
chair:SetAngles(ply:GetAngles())
chair:SetOwner(self:GetOwner())
chair:Spawn()
chair:Activate()
local phys = chair:GetPhysicsObject()
phys:SetVelocity( self.Owner:GetAimVector() * 3000 )
--phys:AddAngleVelocity( Vector( 0, 125, 0 ) )
end
 
local PlayerPos = self.Owner:GetShootPos()
local PlayerAim = self.Owner:GetAimVector()
 

self:EmitSound(ShootSound) 

self:SendWeaponAnim( 181 )      // View model animation
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self:TakePrimaryAmmo( self.Primary.TakeAmmo )
 
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay ) 
self:StopSound("thrusters/hover01.wav")
end


SWEP.processwaiting = 0
SWEP.shockwaiting = 0
SWEP.overheat = 0
SWEP.nailamount = 0

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
--PrintMessage( HUD_PRINTTALK, self.overheat )

if self:Clip2() < 100 then return end

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
		dmginfo:SetDamage( 500 )
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetAttacker( self:GetOwner() )
		dmginfo:SetInflictor( self )
		if trace.HitGroup == HITGROUP_HEAD then
			dmginfo:AddDamage(500)
		end
		dmginfo:SetDamagePosition( trace.HitPos )
		dmginfo:SetDamageForce(self:GetOwner():GetForward() * 16000)
		
		if ent ~= self.Owner then 
			ent:TakeDamageInfo( dmginfo )
		end
		
		end
		
		for k,ent in pairs(ents.FindInSphere(trace.HitPos, 200)) do
			if ent:GetClass() == "projectile_horde_nail" then
				self.nailamount = self.nailamount + 1
				self:EmitSound("ambient/energy/zap8.wav", 1000, 100, 1)
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( 25 * self.nailamount )--* ent
				dmginfo:SetDamageType(DMG_SHOCK)
				dmginfo:SetAttacker( self:GetOwner() )
				dmginfo:SetInflictor( self )
				dmginfo:SetDamagePosition( trace.HitPos )
				ent:Remove()
				timer.Create( "shockahhh".. self:EntIndex(), 0.3, math.random(1,2), function() if IsValid(self) && SERVER then 
					local position = trace.HitPos
					for k,ene in pairs(ents.FindInSphere(position, 350)) do
						if HORDE:IsEnemy(ene) then
						self:EmitSound("ambient/energy/weld1.wav", 1000, 100, 1)
						ParticleEffect("phasma_blast_sparks", ene:WorldSpaceCenter(), Angle(0,0,0), nil)
						util.ParticleTracerEx("neutron_beam", trace.HitPos, ene:WorldSpaceCenter(), true, self:EntIndex(), -1)
						ene:TakeDamageInfo( dmginfo )
						end
						self.nailamount = 0
					end 
				end end )
			end
		
		end

		end
end

        local tr = self.Owner:GetEyeTrace()
        local effectdata = EffectData()
        effectdata:SetOrigin( tr.HitPos )
        effectdata:SetNormal( tr.HitNormal )
        effectdata:SetStart( self.Owner:GetShootPos() )
        effectdata:SetAttachment( 1 )
        effectdata:SetEntity( self.Weapon )
        util.Effect( "nailcannon_beam", effectdata )


local attackpos = self:DoTrace()
util.ParticleTracerEx("Weapon_Combine_Ion_Cannon",self:GetPos(),self.Owner:GetEyeTrace().HitPos,false,self:EntIndex(),1)
util.ParticleTracerEx("cguard_fire_beam",self:GetPos(),self.Owner:GetEyeTrace().HitPos,false,self:EntIndex(),1)


local PlayerPos = self.Owner:GetShootPos()
local PlayerAim = self.Owner:GetAimVector()
self.Owner:FireBullets( bullet ) 

	
local fx = EffectData()
fx:SetEntity(self.Weapon)
fx:SetOrigin(PlayerPos)
fx:SetNormal(PlayerAim)
fx:SetAttachment(self.MuzzleAttachment)
util.Effect(self.MuzzleEffect,fx)
	
self:EmitSound("bootleg_ultrakill/RailcannonFire4.wav")
self:SendWeaponAnim( 181 )      // View model animation
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

self.Owner:SetViewPunchVelocity( Angle( -50, 0, 0 ) )

--self:SetClip2( 0 )

end

SWEP.downtime = false
function SWEP:Think()

    if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() and (self.Owner:KeyReleased( IN_ATTACK )) and SERVER then
	self.Owner:EmitSound(Sound("bootleg_ultrakill/MachinePumpLoop.wav"))
	end

end



function SWEP:Reload()
if self:GetMaxClip1() == 0 then return end
if self:Clip1() == self:GetMaxClip1() then return end
self:SetNextPrimaryFire( CurTime() + 2 )
self:SetNextSecondaryFire( CurTime() + 2 )

self:SendWeaponAnim( 173 )
self.Owner:SetAnimation( PLAYER_RELOAD )
self:EmitSound(self.ReloadSound)

	timer.Simple(1, function() if IsValid(self) && IsValid(self.Owner) then
		self:SendWeaponAnim( 172 )
		self:DefaultReload( ACT_VM_RELOAD )
		--self:SetClip1( self:GetMaxClip1() )
		--self:SetClip1( self:GetMaxClip1() )
	end end)
	
end


/*SWEP.AmmoRegenRate = 1 -- Number of seconds before each ammo regen
SWEP.AmmoRegenAmount = 10 -- Amount of ammo refilled every AmmoRegenRate seconds
function SWEP:Regen( keepaligned )
	if self:Clip2() >= 100 then return false end
	local curtime = CurTime()
	local lastregen = self:GetLastAmmoRegen()
	local timepassed = curtime - lastregen
	local regenrate = self.AmmoRegenRate

	-- Not ready to regenerate
	if ( timepassed < regenrate ) then return false end

	local ammo = self:Clip2()
	local maxammo = 100

	-- Already at/over max ammo
	if ( ammo >= maxammo ) then return false end

	if ( regenrate > 0 ) then
		if ( ammo >= maxammo ) then return false end
		if self:Clip2() >= 100 then return end
		self:SetClip2( math.min( ammo + math.floor( timepassed / regenrate ) * self.AmmoRegenAmount, maxammo ) )

		-- If we are setting the last regen time from the Think function,
		-- keep it aligned with the last action time to prevent late Thinks from
		-- creating hiccups in the rate
		self:SetLastAmmoRegen( keepaligned == true and curtime + timepassed % regenrate or curtime )
		if IsValid(self) && self:Clip2() >= 100 && self.processwaiting == 1 then
			self:EmitSound("bootleg_ultrakill/RailcannonFullClickAndCharge.wav", 500, 100, 1, CHAN_ITEM)
			self.processwaiting = 0
		end
	else
		if ( ammo >= maxammo ) then return false end
		self:SetClip2( maxammo )
		self:SetLastAmmoRegen( curtime )
		if self:Clip2() >= 100 then return end
	end

	return true

end*/