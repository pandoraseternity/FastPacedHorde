AddCSLuaFile()

SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Plague Sniper Weapon"
SWEP.Author = "DrVrej"
SWEP.Contact = "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose = "This weapon is made for Players and NPCs"
SWEP.Instructions = "Controls are like a regular weapon."
SWEP.Category = "VJ Base"
SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/tnb/weapons/c_cisr.mdl"
SWEP.WorldModel = "models/tnb/weapons/w_cisr.mdl"
SWEP.UseHands = true
SWEP.ViewModelFOV = 70
SWEP.Spawnable = true
	-- World Model ---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire = 4 -- Next time it can use primary fire
SWEP.NPC_TimeUntilFire = 0 -- How much time until the bullet/projectile is fired?
SWEP.NPC_CustomSpread = 0 -- This is added on top of the custom spread that's set inside the SNPC! | Starting from 1: Closer to 0 = better accuracy, Farther than 1 = worse accuracy
SWEP.NPC_StandingOnly = true -- If true, the weapon can only be fired if the NPC is standing still
SWEP.NPC_FiringDistanceScale = 2.5 -- Changes how far the NPC can fire | 1 = No change, x < 1 = closer, x > 1 = farther
	-- ====== Reload Variables ====== --
SWEP.NPC_ReloadSound = {"npc/sniper/reload1.wav"} -- Sounds it plays when the base detects the SNPC playing a reload animation
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SWEP.Primary.Damage = 0 -- Damage
SWEP.Primary.Force = 3 -- Force applied on the object the bullet hits
SWEP.Primary.ClipSize = 10 -- Max amount of bullets per clip
SWEP.Primary.Ammo = "SniperRound" -- Ammo type
SWEP.Primary.TracerType = "AR2Tracer"
SWEP.Primary.Sound = {""}
SWEP.Primary.DistantSound = {""}
SWEP.PrimaryEffects_MuzzleParticles = {"vj_rifle_full_blue"}
SWEP.PrimaryEffects_SpawnShells = false
SWEP.PrimaryEffects_DynamicLightColor = Color(0, 31, 225)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Dry Fire Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Examples: Under water, out of ammo
SWEP.Primary.Tracer = 0
SWEP.Primary.DisableBulletCode = true
SWEP.CVar		= "horde_difficulty"---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.AnimTbl_PrimaryFire = {ACT_VM_SECONDARYATTACK}
SWEP.AnimTbl_Reload = {ACT_VM_DRAW}
SWEP.Change = 1

local vec_def = Vector(0, 0, 0)
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetupDataTables()
	--self:NetworkVar("Bool", 0, "Zoomed")
	--self:NetworkVar("Float", 0, "ZoomLevel")
	baseclass.Get("weapon_vj_base").SetupDataTables(self)
end

function SWEP:CustomOnInitialize()
if cvars.Number(self.CVar, 1) == 5 then
	self.Change = 0.6
end
end

function SWEP:DoTrace()
	local tracedata = {}
	tracedata.start = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
	tracedata.endpos = self:GetOwner():GetEnemy():WorldSpaceCenter()--self:GetOwner():GetEnemy():WorldSpaceCenter()--+self:GetOwner():GetEnemy():OBBCenter()
	tracedata.filter = {self}
	return util.TraceLine(tracedata).HitPos
end

SWEP.soundbeep = 0
function SWEP:OnPrimaryAttack(status, statusData)
if status == "Init" then
    local own = self:GetOwner()
    if CLIENT then return end
    timer.Create("Beeptimer" .. self:EntIndex(), 0.5 * self.Change, 4, function()
        if IsValid(self) then
            if own.ouchie == true then return end
            self.soundbeep = self.soundbeep + 20
            self:EmitSound("bootleg_ultrakill/BeepBeep_high.wav", 30000, 60 + self.soundbeep, 2, CHAN_STATIC)
            local spr1 = ents.Create("env_sprite")
            spr1:SetKeyValue("model", "sprites/plasmaember.vmt")
            spr1:SetKeyValue("rendercolor", "0 100 255")
            spr1:SetKeyValue("GlowProxySize", "2.0")
            spr1:SetKeyValue("HDRColorScale", "3.0")
            spr1:SetKeyValue("scale", "1") --self:GetAttachment(self:LookupAttachment("eyes")).Pos
            spr1:SetPos(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
            spr1:Spawn()
            self:DeleteOnRemove(spr1)
            spr1:Fire("Kill", "", 0.2)
        end
    end)
	
	local speed = own:GetEnemy():GetVelocity():Length()
	local oof = own:GetEnemy()
	local dist = own:WorldSpaceCenter():Distance(oof:WorldSpaceCenter())
	local Pos = self:GetAttachment(self:LookupAttachment("muzzle")).Pos

    self.soundbeep = 0
    timer.Simple(2.5 * self.Change, function() if own.ouchie == false then
		if own.ouchie == true then return end
		if own:IsOnGround() && own.ouchie == false then 
			self:EmitSound("bootleg_ultrakill/Bell_10_b.wav", 30000, 99, 2, CHAN_STATIC)
		end
	end end)
    timer.Simple(2.7 * self.Change, function() if own.ouchie == false && IsValid(oof) then
            BulletTbl = {}
            BulletTbl.Num = 1
            BulletTbl.TracerName = "AirboatGunHeavyTracer"--AirboatGunHeavyTracer
            BulletTbl.Src = Pos
            BulletTbl.Dir = oof:WorldSpaceCenter() - Pos
            BulletTbl.Attacker = own
            BulletTbl.Spread = Vector(0, 0, 0)
            BulletTbl.Tracer = 1
            BulletTbl.Force = 100
            BulletTbl.Damage = 150
			attackpos = self:DoTrace() --position to hit
	end end)
    timer.Create("shootytime" .. self:EntIndex(), 2.75 * self.Change, 1, function() if own.ouchie == false then -- complicated stuff about hitting the player...
		if own.ouchie == true then timer.Remove("shootytime" .. self:EntIndex()) return end
        if IsValid(self) and IsValid(own:GetEnemy()) and own:Visible(own:GetEnemy()) and own.ouchie != true then
            if own.ouchie == true then return end
			if own.ouchie == true then timer.Remove("shootytime" .. self:EntIndex()) return end
            VJ_CreateSound(self, "npc/sniper/sniper1.wav", 100)
			VJ_CreateSound(self, "bootleg_ultrakill/AltRevolverShoot1D.wav", 100)
			/*if cvars.Number(self.CVar, 1) >= 4 then
				BulletTbl = {}
				BulletTbl.Num = 1
				BulletTbl.TracerName = "AirboatGunHeavyTracer"--AirboatGunHeavyTracer
				BulletTbl.Src = Pos
				BulletTbl.Dir = oof:WorldSpaceCenter() - Pos
				BulletTbl.Attacker = own
				BulletTbl.Spread = Vector(0, 0, 0)
				BulletTbl.Tracer = 1
				BulletTbl.Force = 100
				BulletTbl.Damage = 150
				attackpos = self:DoTrace()
			end*/
            local muzzleLight = ents.Create("light_dynamic")
            muzzleLight:SetKeyValue("brightness", "10")
            muzzleLight:SetKeyValue("distance", "120")
            muzzleLight:SetPos(self:GetPos())
            muzzleLight:SetLocalAngles(self:GetAngles())
            muzzleLight:Fire("Color", "255 150 60")
            muzzleLight:SetParent(self)
            muzzleLight:Spawn()
            muzzleLight:Activate()
            muzzleLight:Fire("TurnOn", "", 0)
            muzzleLight:Fire("Kill", "", 0.3)
            self:DeleteOnRemove(muzzleLight)
            self:FireBullets(BulletTbl)
			--local attackpos = self:DoTrace()
			util.ParticleTracerEx("neutron_beam", Pos, attackpos, true, self:EntIndex(), 1)
            ParticleEffect("Weapon_Combine_Ion_Cannon_Exlposion_c", attackpos, Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)), nil) --oof:GetPos() - own:GetPos()
	end
	end end)
end
end
---------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnThink()
	local owner = self:GetOwner()
	if IsValid(owner) then
		/*if owner:IsNPC() then
			if IsValid(owner:GetEnemy()) && self:Visible(owner:GetEnemy()) then -- Return the enemy center position
				self:SetNW2Vector("OwnerEnemyPos", self.Owner:GetEnemy():GetPos() + self.Owner:GetEnemy():OBBCenter())
			else -- Make the vector default position, used to determine whether or not to lock onto the enemy (the laser)
				self:SetNW2Vector("OwnerEnemyPos", vec_def)
			end
		end*/
		if !owner:IsOnGround() && (timer.Exists("shootytime" .. self:EntIndex()) or timer.Exists("Beeptimer" .. self:EntIndex())) then 
			timer.Remove("shootytime" .. self:EntIndex())
			timer.Remove("Beeptimer" .. self:EntIndex())
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------

