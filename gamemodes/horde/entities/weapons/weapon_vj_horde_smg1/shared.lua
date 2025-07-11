if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base 						= "weapon_vj_base"
SWEP.PrintName					= "SMG1"
SWEP.Author 					= "DrVrej"
SWEP.Contact					= "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose					= "This weapon is made for Players and NPCs"
SWEP.Instructions				= "Controls are like a regular weapon."
SWEP.Category					= "VJ Base"
	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
SWEP.Slot						= 2 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
SWEP.SlotPos					= 4 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.UseHands					= true
end
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel					= "models/weapons/c_smg1.mdl"
SWEP.WorldModel					= "models/weapons/w_smg1.mdl"
SWEP.HoldType 					= "smg"
SWEP.Spawnable					= true
SWEP.AdminSpawnable				= false
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_HasSecondaryFire = false -- Can the weapon have a secondary fire?
SWEP.NPC_SecondaryFireSound = {"weapons/ar2/ar2_altfire.wav"} -- The sound it plays when the secondary fire is used
SWEP.NPC_ReloadSound = "vj_base/weapons/smg1/reload.wav"
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage				= 0 -- Damage
SWEP.Primary.ClipSize			= 30 -- Max amount of bullets per clip
SWEP.Primary.Delay				= 0.09 -- Time until it can shoot again
SWEP.Primary.Automatic			= true -- Is it automatic?
SWEP.Primary.Ammo				= "SMG1" -- Ammo type
SWEP.Primary.Sound				= "VJ.Weapon_SMG1.Single"
SWEP.Primary.DistantSound		= {"Weapon_SMG1.NPC_Single"}
SWEP.NPC_TimeUntilFireExtraTimers = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6} -- Extra timers, which will make the gun fire again! | The seconds are counted after the self.NPC_TimeUntilFire!
SWEP.PrimaryEffects_MuzzleAttachment = 1
SWEP.PrimaryEffects_ShellAttachment = 2
SWEP.PrimaryEffects_ShellType = "VJ_Weapon_PistolShell1"
SWEP.NPC_NextPrimaryFire = 5 -- Next time it can use primary fire
	-- ====== Secondary Fire Variables ====== --
SWEP.Secondary.Automatic = false -- Is it automatic?
SWEP.Secondary.Ammo = nil -- Ammo type
	-- Reload Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasReloadSound = true -- Does it have a reload sound? Remember even if this is set to false, the animation sound will still play!
SWEP.ReloadSound = {"weapons/smg1/smg1_reload.wav"}
SWEP.Primary.Tracer = 0
SWEP.Primary.DisableBulletCode = true
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- function SWEP:CustomOnSecondaryAttack()
-- 	local owner = self:GetOwner()
-- 	owner:ViewPunch(Angle(-self.Primary.Recoil *3, 0, 0))
-- 	VJ_EmitSound(self, "weapons/ar2/ar2_altfire.wav", 85)

-- 	local proj = ents.Create(self.NPC_SecondaryFireEnt)
-- 	proj:SetPos(owner:GetShootPos())
-- 	proj:SetAngles(owner:GetAimVector():Angle())
-- 	proj:SetOwner(owner)
-- 	proj:Spawn()
-- 	proj:Activate()
-- 	local phys = proj:GetPhysicsObject()
-- 	if IsValid(phys) then
-- 		phys:Wake()
-- 		phys:SetVelocity(owner:GetAimVector() * 2000)
-- 	end
-- 	return true
-- end

function SWEP:OnPrimaryAttack(status, statusData)
	if CLIENT then return end
	if status == "Init" then
		if SERVER then
			local fireSd = VJ.PICK(self.Primary.Sound)
			if fireSd != false then
				self:EmitSound(fireSd, self.Primary.SoundLevel, math.random(self.Primary.SoundPitch.a, self.Primary.SoundPitch.b), self.Primary.SoundVolume, CHAN_WEAPON, 0, 0, VJ_RecipientFilter)
				//EmitSound(fireSd, owner:GetPos(), owner:EntIndex(), CHAN_WEAPON, 1, 140, 0, 100, 0, filter)
				//sound.Play(fireSd, owner:GetPos(), self.Primary.SoundLevel, math.random(self.Primary.SoundPitch.a, self.Primary.SoundPitch.b), self.Primary.SoundVolume)
			end
			if self.Primary.HasDistantSound then
				local fireFarSd = VJ.PICK(self.Primary.DistantSound)
				if fireFarSd != false then
					-- Use "CHAN_AUTO" instead of "CHAN_WEAPON" otherwise it will override primary firing sound because it's also "CHAN_WEAPON"
					self:EmitSound(fireFarSd, self.Primary.DistantSoundLevel, math.random(self.Primary.DistantSoundPitch.a, self.Primary.DistantSoundPitch.b), self.Primary.DistantSoundVolume, CHAN_AUTO, 0, 0, VJ_RecipientFilter)
				end
			end
		end
		local bullet = ents.Create("obj_vj_horde_bullet")
		bullet:SetPos(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
		bullet:SetAngles(self:GetOwner():GetAngles())
		bullet:SetOwner(self:GetOwner())
		bullet:Activate()
		bullet:Spawn()
		bullet.DirectDamage = 5
		
		local phy = bullet:GetPhysicsObject()
		if phy:IsValid() then
			local dir = (self:GetOwner():GetEnemy():GetPos() - self:GetOwner():GetPos())
			dir:Normalize()
			dir = dir + VectorRand() * 0.03
			dir:Normalize()
			phy:ApplyForceCenter(dir * 1000)
		end
		return true
	end
end