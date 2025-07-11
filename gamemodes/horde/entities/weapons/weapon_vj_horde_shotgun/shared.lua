if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "SPAS-12"
SWEP.Author = "DrVrej"
SWEP.Contact = "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose = "This weapon is made for Players and NPCs"
SWEP.Instructions = "Controls are like a regular weapon."
SWEP.Category = "VJ Base"
	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	SWEP.Slot = 3 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
	SWEP.SlotPos = 4 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
	SWEP.UseHands = true
end
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire = 4 -- Next time it can use primary fire
SWEP.NPC_CustomSpread = 2.5 -- This is added on top of the custom spread that's set inside the SNPC! | Starting from 1: Closer to 0 = better accuracy, Farther than 1 = worse accuracy
SWEP.NPC_ExtraFireSound = {"vj_weapons/perform_shotgunpump.wav"} -- Plays an extra sound after it fires (Example: Bolt action sound)
SWEP.NPC_FiringDistanceScale = 0.5 -- Changes how far the NPC can fire | 1 = No change, x < 1 = closer, x > 1 = farther
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.HoldType = "shotgun"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage = 0 -- Damage
SWEP.Primary.PlayerDamage = "Double" -- Only applies for players | "Same" = Same as self.Primary.Damage, "Double" = Double the self.Primary.Damage OR put a number to be different from self.Primary.Damage
SWEP.Primary.Force = 1 -- Force applied on the object the bullet hits
SWEP.Primary.NumberOfShots = 5 -- How many shots per attack?
SWEP.Primary.ClipSize = 6 -- Max amount of bullets per clip
SWEP.Primary.Cone = 12 -- How accurate is the bullet? (Players)
SWEP.Primary.Delay = 0.8 -- Time until it can shoot again
SWEP.Primary.Automatic = true -- Is it automatic?
SWEP.Primary.Ammo = "Buckshot" -- Ammo type
SWEP.Primary.Sound = "VJ.Weapon_SPAS12.Single"
SWEP.Primary.DistantSound = "VJ.Weapon_SPAS12.Single"
SWEP.NPC_ExtraFireSound = "vj_base/weapons/cycle_shotgun_pump.wav"
SWEP.PrimaryEffects_MuzzleAttachment = 1
SWEP.PrimaryEffects_ShellAttachment = 2
SWEP.PrimaryEffects_ShellType = "VJ_Weapon_ShotgunShell1"
	-- ====== Secondary Fire Variables ====== --
SWEP.Secondary.Automatic = true -- Is it automatic?
SWEP.Secondary.Ammo = "Buckshot" -- Ammo type
	-- Reload Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasReloadSound = true -- Does it have a reload sound? Remember even if this is set to false, the animation sound will still play!
SWEP.ReloadSound = {"weapons/shotgun/shotgun_reload1.wav","weapons/shotgun/shotgun_reload2.wav","weapons/shotgun/shotgun_reload3.wav"}
SWEP.Reload_TimeUntilAmmoIsSet = 0.3 -- Time until ammo is set to the weapon
SWEP.Primary.Tracer = 0
SWEP.Primary.DisableBulletCode = true
---------------------------------------------------------------------------------------------------------------------------------------------
-- function SWEP:CustomOnPrimaryAttack_AfterShoot()
-- 	local owner = self:GetOwner()
-- 	if IsValid(owner) && owner:IsPlayer() then
-- 		timer.Simple(0.2, function()
-- 			if IsValid(self) && IsValid(owner) && owner:IsPlayer() then
-- 				self:EmitSound(Sound("weapons/shotgun/shotgun_cock.wav"), 80, 100)
-- 				local animTime = VJ_GetSequenceDuration(owner:GetViewModel(), ACT_SHOTGUN_PUMP)
-- 				self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
-- 				self.NextIdleT = CurTime() + animTime
-- 				self.NextReloadT = CurTime() + animTime
-- 			end
-- 		end)
-- 	end
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
		for i = 1, 6 do
			local bullet = ents.Create("obj_vj_horde_bullet")
			bullet:SetPos(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
			bullet:SetAngles(self:GetOwner():GetAngles())
			bullet:SetOwner(self:GetOwner())
			bullet:Activate()
			bullet:Spawn()
			bullet.DirectDamage = 4
			
			local phy = bullet:GetPhysicsObject()
			if phy:IsValid() then
				local dir = (self:GetOwner():GetEnemy():GetPos() - self:GetOwner():GetPos())
				dir:Normalize()
				dir = dir + VectorRand() * 0.06
				dir:Normalize()
				phy:ApplyForceCenter(dir * 1000)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnSecondaryAttack()
	if self:Clip1() > 1 then
		self.Primary.Delay = 1
		self.Primary.Cone = 20
		self.Primary.NumberOfShots = 14
		self.Primary.TakeAmmo = 2
		self.NextIdle_PrimaryAttack = 1
		self.AnimTbl_PrimaryFire = {ACT_VM_SECONDARYATTACK}
	end
	self:PrimaryAttack()
	self.Primary.Delay = 0.8
	self.Primary.Cone = 12
	self.Primary.NumberOfShots = 7
	self.Primary.TakeAmmo = 1
	self.NextIdle_PrimaryAttack = 0.8
	self.AnimTbl_PrimaryFire = {ACT_VM_PRIMARYATTACK}
	
	self:SetNextSecondaryFire(CurTime() + 1)
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnReload_Finish()
	local owner = self:GetOwner()
	if !owner:IsPlayer() then return true end
	self:GetOwner():RemoveAmmo(1, self.Primary.Ammo)
	self:SetClip1(self:Clip1() + 1)
	if self.Primary.ClipSize > self:Clip1() then
		timer.Simple(0.1, function()
			if IsValid(self) && IsValid(self:GetOwner()) then
				self.Reloading = false
				self:Reload()
			end
		end)
	end
	return false
end
