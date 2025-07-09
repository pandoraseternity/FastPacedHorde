AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/Humans/Group03/Female_07.mdl", "models/Humans/Group03/male_09.mdl","models/Humans/Group03/Female_06.mdl", "models/Humans/Group03/male_07.mdl", "models/Humans/Group03/male_06.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 250
ENT.HasHealthRegeneration = true -- Can the SNPC regenerate its health?
ENT.HealthRegenerationAmount = 20 -- How much should the health increase after every delay?
ENT.HealthRegenerationDelay = VJ_Set(5,4) -- How much time until the health increases
ENT.HealthRegenerationResetOnDmg = false -- Should the delay reset when it receives damage? 
ENT.SightAngle = 90 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.TurningSpeed = 50 -- How fast it can turn
ENT.TurningUseAllAxis = false -- If set to true, angles will not be restricted to y-axis, it will change all axes (plural axis)
ENT.Weapon_FiringDistanceFar = 4500 -- How far away it can shoot
ENT.Weapon_FiringDistanceClose = 0 -- How close until it stops shooting

ENT.HasWeaponBackAway = false -- Should the SNPC back away if the enemy is close?
ENT.WeaponBackAway_Distance = 0 -- When the enemy is this close, the SNPC will back away | 0 = Never back away
ENT.WeaponReload_FindCover = false
ENT.WeaponSpread = 1.5 -- What's the spread of the weapon? | Closer to 0 = better accuracy, Farther than 1 = worse accuracy


ENT.MoveRandomlyWhenShooting = false -- Should it move randomly when shooting?
ENT.NextMoveRandomlyWhenShootingTime1 = 6 -- How much time until it can move randomly when shooting? | First number in math.random
ENT.NextMoveRandomlyWhenShootingTime2 = 6.5 -- How much time until it can move randomly when shooting? | Second number in math.random

ENT.NoWeapon_UseScaredBehavior = false
ENT.CanOpenDoors = true -- Can it open doors?
ENT.FriendsWithAllPlayerAllies = true
ENT.VJ_NPC_Class = {"CLASS_COMBINE", "CLASS_PLAYER_ALLY"} -- NPCs with the same class with be allied to each other
ENT.PlayerFriendly = true

ENT.HasGrenadeAttack = true -- Should the SNPC have a grenade attack?--obj_vj_snpc_molotov
ENT.GrenadeAttackEntity = "obj_vj_grenade" -- The entity that the SNPC throws | Half Life 2 Grenade: "npc_grenade_frag"
ENT.AnimTbl_GrenadeAttack = {"grenThrow"} -- Grenade Attack Animations
ENT.GrenadeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.TimeUntilGrenadeIsReleased = 0 -- Time until the grenade is released
ENT.NextThrowGrenadeTime1 = 2 -- Time until it runs the throw grenade code again | The first # in math.random
ENT.ThrowGrenadeChance = 0.45 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.GrenadeAttackThrowDistance = 1100 -- How far it can throw grenades
ENT.GrenadeAttackThrowDistanceClose = 200 -- How close until it stops throwing grenades
	-- ====== Projectile Spawn & Velocity Variables ====== --
ENT.GrenadeAttackSpawnPosition = Vector(0,0,0) -- The position to use if the attachment variable is set to false for spawning
--ENT.GrenadeAttackVelRight1 = -20 -- Grenade attack velocity right | The first # in math.random
--ENT.GrenadeAttackVelRight2 = 20 -- Grenade attack velocity right | The second # in math.random
	-- ====== Grenade Detection & Throwing Back Variables ====== --
ENT.CanDetectGrenades = true -- Set to false to disable the SNPC from running away from grenades
ENT.RunFromGrenadeDistance = 400 -- If the entity is this close to the it, then run!
	-- NOTE: The ability to throw grenades back only work if the SNPC can detect grenades AND has a grenade attack!


ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfVisible = true -- Should it only face the enemy if it's visible?
ENT.ConstantlyFaceEnemy_IfAttacking = false -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Both" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2500 -- How close does it have to be until it starts to face the enemy?

	-- ====== Standing-Firing Variables ====== --
--ENT.AnimTbl_WeaponAttack = {ACT_RANGE_ATTACK_AR2} -- Animation played when the SNPC does weapon attack
ENT.CanCrouchOnWeaponAttack = true -- Can it crouch while shooting?
--ENT.AnimTbl_WeaponAttackCrouch = {ACT_RANGE_ATTACK_AR2_LOW} -- Animation played when the SNPC does weapon attack while crouching | For VJ Weapons
ENT.CanCrouchOnWeaponAttackChance = 0 -- How much chance of crouching? | 1 = Crouch every time
--ENT.AnimTbl_WeaponAttackFiringGesture = {ACT_GESTURE_RANGE_ATTACK_HMG1} -- Firing Gesture animations used when the SNPC is firing the weapon
ENT.DisableWeaponFiringGesture = false -- If set to true, it will disable the weapon firing gestures

	-- ====== Secondary Fire Variables ====== --
ENT.CanUseSecondaryOnWeaponAttack = true -- Can the NPC use a secondary fire if it's available?
ENT.AnimTbl_WeaponAttackSecondary = {"shoot_AR2_alt"} -- Animations played when the SNPC fires a secondary weapon attack
ENT.WeaponAttackSecondaryTimeUntilFire = 0.2 -- The weapon uses this integer to set the time until the firing code is ran
	-- ====== Moving-Firing Variables ====== --
ENT.HasShootWhileMoving = true -- Can it shoot while moving?
ENT.AnimTbl_ShootWhileMovingRun = {ACT_RUN_AIM} -- Animations it will play when shooting while running | NOTE: Weapon may translate the animation that they see fit!
ENT.AnimTbl_ShootWhileMovingWalk = {ACT_RUN_AIM} -- Animations it will play when shooting while walking | NOTE: Weapon may translate the animation that they see fit!

ENT.AllowWeaponReloading = true -- If false, the NPC will not reload
ENT.DisableWeaponReloadAnimation = false -- if true, it will disable the animation code when reloading
ENT.AnimTbl_WeaponReload = {"Reload_Smg1"} -- Animations that play when the NPC reloads
ENT.AnimTbl_WeaponReloadBehindCover = {"Crouch_Reload_Smg1"} -- Animations that play when the NPC reloads, but behind cover

ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 80
ENT.DropWeaponOnDeath = false -- Should it drop its weapon on death?
ENT.DisableWeaponFiringGesture = false -- If set to true, it will disable the weapon firing gestures


	-- ====== Sound File Paths ====== --
ENT.SoundTbl_Alert = {""}
ENT.SoundTbl_MeleeAttack = {""}
ENT.SoundTbl_Death = {""}
ENT.SoundTbl_Idle = {""}
ENT.SoundTbl_Pain = {""}
ENT.SoundTbl_IdleDialogue = {"common/warning.wav"}
ENT.SoundTbl_IdleDialogueAnswer = {"Friends/message.wav"}
ENT.SoundTbl_FootStep = {"NPC_Citizen.FootstepLeft","NPC_Citizen.FootstepRight"}
ENT.HasSoundTrack = false -- Does the SNPC have a sound track?
ENT.SoundTrackVolume = 1
--{"npcpack/OF2atlast.mp3"}--"adrshep/weapons/vandoorearesistance.mp3","adrshep/weapons/obmoldtheme.mp3" "adrshep/weapons/modernstorm.mp3","adrshep/weapons/obmfoxtrot.mp3","weapons/old opposingforce 2 theme.mp3",

	-- ====== Sound Pitch ====== --
-- Higher number = Higher pitch | Lower number = Lower pitch
-- Highest number is 254
	-- !!! Important variables !!! --
ENT.UseTheSameGeneralSoundPitch = true 
	-- If set to true, it will make the game decide a number when the SNPC is created and use it for all sound pitches set to "UseGeneralPitch"
	-- It picks the number between the two variables below:
ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
-- To add rest of the SNPC and get full list of the function, you need to decompile VJ Base.



--util.VJ_SphereDamage(attacker, inflictor, startPos, dmgRadius, dmgMax, dmgType, ignoreInnocents, realisticRadius, extraOptions, customFunc)

--https://github.com/DrVrej/VJ-Base/blob/6092341069f763d2066a88b4eab822aeeb9c19a4/lua/autorun/vj_globals.lua
--https://github.com/DrVrej/VJ-Base/blob/6092341069f763d2066a88b4eab822aeeb9c19a4/lua/vj_base/npc_general.lua

--function VJ_EmitSound(ent, sd, sdLevel, sdPitch, sdVolume, sdChannel)

--CUSTOM VARIABLES FROM THIS POINT DOWN
--ENT.m_iClass = CLASS_PLAYER_ALLY_VITAL

ENT.flipdodge = false
ENT.extradodging = false

ENT.emergencyfactor = false

ENT.dodgeclose = false
ENT.graze = false

ENT.movefarawaymoderate = false
ENT.movefaraway = false
ENT.dodging = false

ENT.Weaponcooldown = 0
ENT.WeaponchangeAI = 0
ENT.Canchangeweapons = true


ENT.WeaponInventory_GameWeaponry = {"weapon_vj_adrian_spas","weapon_vj_adrian_mp5","weapon_vj_adrian_saw","weapon_vj_pack_mp7"}


--ENT.WeaponInventory_AntiMetalWeapon = {"weapon_vj_adrian_rpg"}"weapon_vj_adrian_spas","weapon_vj_adrian_mp5","weapon_vj_adrian_saw",

-------------------------------------------------------------------------------------------------------------------

function ENT:CustomOnPreInitialize()
if math.random(1, 2) == 2 then
	self:ApplyFemaleSounds()
else
	self:ApplyMaleSounds()
end
end

function ENT:CustomOnInitialize()
self:Horde_AddArmor(150)
self:CapabilitiesAdd(bit.bor(CAP_SQUAD))
self:CapabilitiesAdd(bit.bor(CAP_MOVE_CRAWL))
self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
self:AddFlags(FL_SWIM)
self:AddEFlags(EFL_NO_WATER_VELOCITY_CHANGE)
self:AddRelationship("npc_turret_floor D_LI 99")
self:AddRelationship("npc_vj_horde_combat_bot D_LI 99")
self:AddRelationship("npc_manhack D_LI 99")
self:AddRelationship("npc_vj_horde_vortigaunt D_LI 99")
self:AddRelationship("npc_vj_horde_rocket_turret D_LI 99")
end

function ENT:CustomOnThink()

if IsValid(self) and self:GetActiveWeapon() == NULL then
if GetConVarNumber("vj_npc_noweapon") == 1 then return end
local nullswitcher = math.random(1,2) 
if nullswitcher == 1 then
self:VJ_ACT_PLAYACTIVITY("smgdraw",false,0,false)
self:Give("weapon_vj_adrian_deagle", true)
end
elseif nullswitcher == 2 then
self:VJ_ACT_PLAYACTIVITY("smgdraw",false,0,false)
self:Give("weapon_vj_adrian_mp5", true)
end	

if IsValid(self:GetEnemy()) && CurTime() > self.WeaponchangeAI && self:Visible(self:GetEnemy()) && self.Canchangeweapons == true then
	self:Give(VJ_PICK(self.WeaponInventory_GameWeaponry), true) --custom weapon switch for large retreating
	self:EmitSound("common/wpn_moveselect.wav", 9999, 100, 1)
	self.WeaponchangeAI = CurTime() + 4
	self:GetActiveWeapon():SetClip1(self:GetActiveWeapon():GetMaxClip1())
	if IsValid(self:GetEnemy()) then
	self:VJ_TASK_CHASE_ENEMY(false) -- please do not chase like an idiot
	end
end	


end

function ENT:CustomOnGrenadeAttack_OnThrow(grEnt)
self:VJ_TASK_IDLE_STAND()
end

-------------------------------------------------------------------------------------------------------------------

function ENT:CustomOnMoveRandomlyWhenShooting()
self:Give(VJ_PICK(self.WeaponInventory_GameWeaponry))
VJ_EmitSound(self,"common/wpn_moveselect.wav" ,8000)
self.CurrentWeaponEntity:SetClip1(self.CurrentWeaponEntity:GetMaxClip1())
if IsValid(self:GetEnemy()) then
self:VJ_TASK_CHASE_ENEMY(false) -- please do not chase like an idiot
end
self:VJ_TASK_IDLE_STAND()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnWaitForEnemyToComeOut()
self:Give(VJ_PICK(self.WeaponInventory_GameWeaponry))
VJ_EmitSound(self,"common/wpn_moveselect.wav" ,8000)
self.CurrentWeaponEntity:SetClip1(self.CurrentWeaponEntity:GetMaxClip1())
end

function ENT:CustomOnWeaponReload() 
self:EmitSound("suit/ammo_depleted.wav", 9999, 100, 1)
end

function ENT:CustomOnTakeDamage_AfterDamage(dmginfo,hitgroup)
if !IsValid(self:GetEnemy()) then
self.IsMedicSNPC = true
elseif IsValid(self:GetEnemy()) then
self.IsMedicSNPC = false
end
end

function ENT:CustomOnKilled()
	local pos = self:GetPos()
	local pitch = math.random(95, 105)
	local function deathSound(time, snd)
		timer.Simple(time, function()
			sound.Play(snd, pos, 65, pitch)
		end)
	end
	deathSound(0, "hl1/fvox/beep.wav")
	deathSound(0.25, "hl1/fvox/beep.wav")
	deathSound(0.75, "hl1/fvox/beep.wav")
	deathSound(1.25, "hl1/fvox/beep.wav")
	deathSound(1.7, "hl1/fvox/flatline.wav")
end
-------------------------------------------------------------------------------------------------------------------------

function ENT:CustomOnThink_AIEnabled() --maze

self:Closerangenocover()

if IsValid(self:GetEnemy()) then
	self:CustomDodge()
end

local hetfemboy = {
["npc_vj_bld_movemine"] = true, --now privated addon
 ["npc_vj_bld_turret"] = true, --now privated addon
 ["npc_headcrab_poison"] = true,
 ["npc_headcrab_black"] = true,
 ["npc_headcrab_fast"] = true,
 ["npc_headcrab"] = true,
 }
 
local models = {
["models/headcrabblack.mdl"] = true,
 ["models/headcrab.mdl"] = true,
 ["models/headcrabclassic.mdl"] = true,
 }

local metal = self:GetEnemy()	
if IsValid(metal) then 
		if hetfemboy[metal:GetClass()] or models[metal:GetModel()] or metal:GetModel() == "models/headcrabblack.mdl" then
		self.WeaponUseEnemyEyePos = true-- why do poison headcrabs have 2 different classnames?
		end
		end
		
--self.WeaponUseEnemyEyePos = true

if IsValid(self) && IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) <= 80 then
self:MultipleMeleeAttacks()
end
				
self:Grazing()

self.WeaponReload_FindCover = false

local dangerousenemies = {
["npc_vj_horde_lesion"] = true,
["npc_vj_horde_hulk"] = true,
["npc_vj_horde_yeti"] = true,
["npc_vj_traducer"] = true,
 }
 
local metal = self:GetEnemy()
if IsValid(metal) then
	if IsValid(self:GetEnemy()) && metal:GetMaxHealth() >= 1200 or dangerousenemies[self:GetEnemy():GetClass()] then --MODERATE
	self.movefarawaymoderate = true 
	self.HasMeleeAttack = false
	self.WeaponReload_FindCover = false --prevents him from taking cover
	--PrintMessage( HUD_PRINTTALK, "Moderate Move activated" )
	elseif IsValid(self:GetEnemy()) == false or IsValid(self:GetEnemy()) && metal:GetMaxHealth() < 1200 or IsValid(self:GetEnemy()) && !dangerousenemies[self:GetEnemy():GetClass()] then
	self.movefarawaymoderate = false
	self.HasMeleeAttack = false
	self.WeaponReload_FindCover = true --he can now take cover
	--PrintMessage( HUD_PRINTTALK, "Moderate Move deactivated" )
	end
	end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
--dmginfo:ScaleDamage(0.5)
if self.dodging then
dmginfo:ScaleDamage(0)
end
end

function ENT:MultipleMeleeAttacks()

	local attack_close = math.random(1,4)
	if attack_close == 1 then
		self.AnimTbl_MeleeAttack = {"Range_Fistse_R_1","Range_Fistse_L_1"} -- Light Melee Attack
		self.MeleeAttackAngleRadius = 40 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 40 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 40
		self.NextMeleeAttackTime = 2.3 -- How much time until it can use a melee attack?
		self.TimeUntilMeleeAttackDamage = 0 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = 24
		self.MeleeAttackReps = 3 -- How many times does it run the melee attack code?
		self.MeleeAttackExtraTimers = {} -- Extra melee attack timers, EX: {0.1,0.2,0.3,0.4,0.5,0.6} | it will run the damage code after the given amount of seconds
			
	elseif attack_close == 2 then
		self.AnimTbl_MeleeAttack = {"Range_Fistse_Head_1"} -- Medium Melee Attack
		self.MeleeAttackAngleRadius = 20 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 20 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 40
		self.NextMeleeAttackTime = 0.5 -- How much time until it can use a melee attack?
		self.TimeUntilMeleeAttackDamage = 0 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = 18
		self.MeleeAttackReps = 1 -- How many times does it run the melee attack code?
		self.MeleeAttackExtraTimers = {} -- Extra melee attack timers, EX: {1, 1.4} | it will run the damage code after the given amount of seconds
		
	elseif attack_close == 3 then
		self.AnimTbl_MeleeAttack = {"Range_Fistse_Hook_1"} -- Heavy Melee Attack
		self.MeleeAttackAngleRadius = 75 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 75 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 75
		self.NextMeleeAttackTime = 1 -- How much time until it can use a melee attack?
		self.TimeUntilMeleeAttackDamage = 0 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = 20
		self.MeleeAttackReps = 1 -- How many times does it run the melee attack code?
		self.MeleeAttackExtraTimers = {} -- Extra melee attack timers, EX: {1, 1.4} | it will run the damage code after the given amount of seconds
		
	elseif attack_close == 4 then
		self.AnimTbl_MeleeAttack = {"Range_Fistse_Noga_1"} -- Light Melee Attack Special
		self.MeleeAttackAngleRadius = 80 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 80 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 80
		self.NextMeleeAttackTime = 1.5 -- How much time until it can use a melee attack?
		self.TimeUntilMeleeAttackDamage = 0 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = 22
		self.MeleeAttackReps = 1 -- How many times does it run the melee attack code?
		self.MeleeAttackExtraTimers = {} -- Extra melee attack timers, EX: {1, 1.4} | it will run the damage code after the given amount of seconds

	end
end

function ENT:CustomOnMeleeAttack_BeforeStartTimer(seed) 
util.VJ_SphereDamage(self,self,self:GetPos(),110,25,DMG_DIRECT,true,true)
VJ_EmitSound(self,"hlof/weapons/pwrench_big_hit1.wav",1000)
for k, v in pairs(ents.FindInSphere(self:GetPos(), 135)) do
	if self:Disposition(v) == D_HT then
		v:SetVelocity(self:GetForward()*-400 +self:GetUp()*180 +self:GetRight()*125)
	end
end

end


function ENT:Closerangenocover()
local metal = self:GetEnemy()
if IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) < 550 && self:Visible(self:GetEnemy()) then --NO COVER CLOSE RANGE
if self:GetEnemy():GetMaxHealth() >= 1200 or !IsValid(self:GetEnemy()) then return end
	self.WeaponReload_FindCover = false--prevents him from taking cover
elseif !IsValid(self:GetEnemy()) or IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) > 550 then
if !IsValid(self:GetEnemy()) or self:GetEnemy():GetMaxHealth() >= 1200 then return end
	self.WeaponReload_FindCover = true --he can now take cover
end
end

-------------------------------------------------------------------------------------------------------------------------

function ENT:MoveFarawaymoderatetrue()
		if self:GetPos():Distance(self:GetEnemy():GetPos()) < 320 && self:Visible(self:GetEnemy()) then
			local randomdodge_close = math.random(1,2)
		if randomdodge_close == 1 && self.dodgeclose == false then
			self.dodgeclose = true
			self:SetGroundEntity(NULL)
			self:SetVelocity(self:GetForward()*-170 + self:GetUp()*40)
			timer.Simple(math.random(0.1,0.4),function() if IsValid(self) then self.dodgeclose = false end end)
		elseif randomdodge_close == 2 && self.dodgeclose == false then
			self.dodgeclose = true
			self:SetGroundEntity(NULL)
			self:SetVelocity(self:GetForward()*-75 + self:GetUp()*45 + self:GetRight()*300)
			timer.Simple(math.random(0.1,0.4),function() if IsValid(self) then self.dodgeclose = false end end)
			end
			end
			end
------------------------------------------------------------------------------------------------

function ENT:CustomDodge()
	if self.FollowingPlayer == true then return end
	if self.VJ_IsBeingControlled == true then return end

	if IsValid(self:GetEnemy()) then
	--PrintMessage( HUD_PRINTTALK, "woa" )
	if self.movefarawaymoderate == true then
	self:MoveFarawaymoderatetrue()
	elseif self.movefarawaymoderate == false then
	if self:GetPos():Distance(self:GetEnemy():GetPos()) < 220 && self:Visible(self:GetEnemy()) then
		local randomdodge_close = math.random(1,2)
		if randomdodge_close == 1 && self.dodgeclose == false && self:IsOnGround() then
			self.dodgeclose = true
			self:SetGroundEntity(NULL)
			self:SetVelocity(self:GetForward()*-70 + self:GetUp()*40)
			timer.Simple(0.27,function() if IsValid(self) then self.dodgeclose = false end end)
		elseif randomdodge_close == 2 && self.dodgeclose == false && self:IsOnGround() then
			self.dodgeclose = true
			self:SetGroundEntity(NULL)
			self:SetVelocity(self:GetForward()*-20 + self:GetUp()*90 + self:GetRight()*200)
			timer.Simple(0.27,function() if IsValid(self) then self.dodgeclose = false end end)
		end
	end
	end
	end
	end

function ENT:Grazing()


	for k, danmaku in pairs(ents.FindByClass( "obj_*" )) do 
		if danmaku:GetOwner() != self then
		if IsValid(danmaku:GetOwner()) && IsValid(danmaku) && self:Disposition(danmaku:GetOwner()) == D_LI then return end
		if danmaku:GetClass() == "obj_vj_combineball" then return end
			if IsValid(danmaku.Owner) then
				if danmaku.Owner:GetOwner() != self then
					if danmaku:GetParent() != self then
						if danmaku != self then
							local phys = danmaku:GetPhysicsObject()
							if phys:IsValid() then
								if self:GetPos():Distance(phys:GetPos()) < (phys:GetVelocity():Length()/4) then
									if self.graze == false && IsValid(self) then
										self.graze = true
										self.dodging = true
										--self:SetAngles((danmaku:GetPos()-self:GetPos()):Angle())
										local grazedir = math.random(1,3)
										if grazedir == 1 then
											self:SetGroundEntity(NULL)
											self:SetVelocity(self:GetForward()*100 + self:GetUp()*100 + self:GetRight()*500)
										elseif grazedir == 2 then
											self:SetGroundEntity(NULL)
											self:SetVelocity(self:GetForward()*100 + self:GetUp()*100 + self:GetRight()*-500)
										end
										timer.Simple(0.2,function() if IsValid(self) then
											self.dodging = false
										end end)
										timer.Simple(1,function() if IsValid(self) then
											self.graze = false
										end end)
									end
								end
							end
						end
					end
				end
			elseif !IsValid(danmaku.Owner) then
				if danmaku:GetParent() != self then
					if danmaku != self then
						local phys = danmaku:GetPhysicsObject()
						if phys:IsValid() then
							if self:GetPos():Distance(phys:GetPos()) < (phys:GetVelocity():Length()/4) then
								if self.graze == false && IsValid(self) then
									self.graze = true
									--self:SetAngles((danmaku:GetPos()-self:GetPos()):Angle())
									local grazedir = math.random(1,2)
									if grazedir == 1 then
										self:SetGroundEntity(NULL)
										self:SetVelocity(self:GetForward()*-100 + self:GetUp()*100 + self:GetRight()*500)
									elseif grazedir == 2 then
										self:SetGroundEntity(NULL)
										self:SetVelocity(self:GetForward()*-100 + self:GetUp()*100 + self:GetRight()*-500)
									end
									timer.Simple(1,function() if IsValid(self) then
										self.graze = false
									end end)
								end
							end
						end
					end
				end
			end
		end
	end
	
	for k, danmaku in pairs(ents.FindByClass( "proj_*" )) do 
		if danmaku:GetOwner() != self then
			if IsValid(danmaku.Owner) then
				if danmaku.Owner:GetOwner() != self then
					if danmaku:GetParent() != self then
						if danmaku != self then
							local phys = danmaku:GetPhysicsObject()
							if phys:IsValid() then
								if self:GetPos():Distance(phys:GetPos()) < (phys:GetVelocity():Length()/4) then
									if self.graze == false && IsValid(self) then
										self.graze = true
										self:SetAngles((danmaku:GetPos()-self:GetPos()):Angle())
										local grazedir = math.random(1,2)
										if grazedir == 1 then
											self:SetGroundEntity(NULL)
											self:SetVelocity(self:GetForward()*-200 + self:GetUp()*250 + self:GetRight()*600)
										elseif grazedir == 2 then
											self:SetGroundEntity(NULL)
											self:SetVelocity(self:GetForward()*-200 + self:GetUp()*250 + self:GetRight()*-600)
										end
										timer.Simple(0.3,function() if IsValid(self) then
											self.graze = false
										end end)
									end
								end
							end
						end
					end
				end
			elseif !IsValid(danmaku.Owner) then
				if danmaku:GetParent() != self then
					if danmaku != self then
						local phys = danmaku:GetPhysicsObject()
						if phys:IsValid() then
							if self:GetPos():Distance(phys:GetPos()) < (phys:GetVelocity():Length()/2) then
								if self.graze == false && IsValid(self) then
									self.graze = true
									self:SetAngles((danmaku:GetPos()-self:GetPos()):Angle())
									local grazedir = math.random(1,2)
									if grazedir == 1 then
										self:SetGroundEntity(NULL)
										self:SetVelocity(self:GetForward()*-200 + self:GetUp()*100 + self:GetRight()*700)
									elseif grazedir == 2 then
										self:SetGroundEntity(NULL)
										self:SetVelocity(self:GetForward()*-200 + self:GetUp()*100 + self:GetRight()*-700)
									end
									timer.Simple(0.4,function() if IsValid(self) then
										self.graze = false
									end end)
								end
							end
						end
					end
				end
			end
		end
	end

	
end

function ENT:ApplyMaleSounds()
	self.SoundTbl_Idle = {
		"vo/npc/male01/vanswer14.wav"
	}
	self.SoundTbl_IdleDialogue = {
		"vo/npc/male01/doingsomething.wav",
		"vo/npc/male01/getgoingsoon.wav",
		"vo/npc/male01/question01.wav",
		"vo/npc/male01/question02.wav",
		"vo/npc/male01/question03.wav",
		"vo/npc/male01/question04.wav",
		"vo/npc/male01/question05.wav",
		"vo/npc/male01/question06.wav",
		"vo/npc/male01/question07.wav",
		"vo/npc/male01/question08.wav",
		"vo/npc/male01/question09.wav",
		"vo/npc/male01/question10.wav",
		"vo/npc/male01/question11.wav",
		"vo/npc/male01/question12.wav",
		"vo/npc/male01/question13.wav",
		"vo/npc/male01/question14.wav",
		"vo/npc/male01/question15.wav",
		"vo/npc/male01/question16.wav",
		"vo/npc/male01/question17.wav",
		"vo/npc/male01/question18.wav",
		"vo/npc/male01/question19.wav",
		"vo/npc/male01/question20.wav",
		"vo/npc/male01/question21.wav",
		"vo/npc/male01/question22.wav",
		"vo/npc/male01/question23.wav",
		"vo/npc/male01/question25.wav",
		"vo/npc/male01/question26.wav",
		"vo/npc/male01/question27.wav",
		"vo/npc/male01/question28.wav",
		"vo/npc/male01/question29.wav",
		"vo/npc/male01/question30.wav",
		"vo/npc/male01/question31.wav",
		"vo/npc/male01/vquestion01.wav",
		"vo/npc/male01/vquestion02.wav",
		"vo/npc/male01/vquestion04.wav",
		"vo/coast/cardock/le_onfoot.wav",
		"vo/trainyard/cit_water.wav"
	}
	self.SoundTbl_IdleDialogueAnswer = {
		"vo/npc/male01/answer01.wav",
		"vo/npc/male01/answer02.wav",
		"vo/npc/male01/answer03.wav",
		"vo/npc/male01/answer04.wav",
		"vo/npc/male01/answer05.wav",
		"vo/npc/male01/answer07.wav",
		"vo/npc/male01/answer08.wav",
		"vo/npc/male01/answer09.wav",
		"vo/npc/male01/answer10.wav",
		"vo/npc/male01/answer11.wav",
		"vo/npc/male01/answer12.wav",
		"vo/npc/male01/answer13.wav",
		"vo/npc/male01/answer14.wav",
		"vo/npc/male01/answer15.wav",
		"vo/npc/male01/answer16.wav",
		"vo/npc/male01/answer17.wav",
		"vo/npc/male01/answer18.wav",
		"vo/npc/male01/answer19.wav",
		"vo/npc/male01/answer20.wav",
		"vo/npc/male01/answer21.wav",
		"vo/npc/male01/answer22.wav",
		"vo/npc/male01/answer23.wav",
		"vo/npc/male01/answer25.wav",
		"vo/npc/male01/answer26.wav",
		"vo/npc/male01/answer27.wav",
		"vo/npc/male01/answer28.wav",
		"vo/npc/male01/answer29.wav",
		"vo/npc/male01/answer30.wav",
		"vo/npc/male01/answer31.wav",
		"vo/npc/male01/answer32.wav",
		"vo/npc/male01/answer33.wav",
		"vo/npc/male01/answer34.wav",
		"vo/npc/male01/answer35.wav",
		"vo/npc/male01/answer36.wav",
		"vo/npc/male01/answer37.wav",
		"vo/npc/male01/answer38.wav",
		"vo/npc/male01/answer39.wav",
		"vo/npc/male01/answer40.wav",
		"vo/npc/male01/vanswer01.wav",
		"vo/npc/male01/vanswer04.wav",
		"vo/npc/male01/vanswer08.wav",
		"vo/npc/male01/vanswer13.wav",
		"vo/trainyard/cit_window_hope.wav"
	}
	self.SoundTbl_CombatIdle = {
		"vo/npc/male01/letsgo01.wav",
		"vo/npc/male01/letsgo02.wav",
		"vo/npc/male01/squad_affirm05.wav",
		"vo/npc/male01/squad_affirm06.wav",
		"vo/canals/male01/stn6_go_nag02.wav"
	}
	self.SoundTbl_OnReceiveOrder = {
		"vo/npc/male01/ok01.wav",
		"vo/npc/male01/ok02.wav",
		"vo/npc/male01/squad_approach02.wav",
		"vo/npc/male01/squad_approach03.wav",
		"vo/npc/male01/squad_approach04.wav"
	}
	self.SoundTbl_FollowPlayer = {
		"vo/npc/male01/leadon01.wav",
		"vo/npc/male01/leadon02.wav",
		"vo/npc/male01/leadtheway01.wav",
		"vo/npc/male01/leadtheway02.wav",
		"vo/npc/male01/okimready01.wav",
		"vo/npc/male01/okimready02.wav",
		"vo/npc/male01/okimready03.wav",
		"vo/npc/male01/readywhenyouare01.wav",
		"vo/npc/male01/readywhenyouare02.wav",
		"vo/npc/male01/squad_affirm01.wav",
		"vo/npc/male01/squad_affirm02.wav",
		"vo/npc/male01/squad_affirm03.wav",
		"vo/npc/male01/squad_affirm04.wav",
		"vo/npc/male01/squad_affirm07.wav",
		"vo/npc/male01/squad_affirm08.wav",
		"vo/npc/male01/squad_affirm09.wav",
		"vo/npc/male01/squad_follow03.wav",
		"vo/npc/male01/squad_train01.wav",
		"vo/npc/male01/squad_train02.wav",
		"vo/npc/male01/squad_train03.wav",
		"vo/npc/male01/squad_train04.wav",
		"vo/npc/male01/yougotit02.wav"
	}
	self.SoundTbl_UnFollowPlayer = {
		"vo/npc/male01/holddownspot01.wav",
		"vo/npc/male01/holddownspot02.wav",
		"vo/npc/male01/illstayhere01.wav",
		"vo/npc/male01/imstickinghere01.wav",
		"vo/npc/male01/littlecorner01.wav",
		"vo/canals/male01/gunboat_farewell.wav",
		"vo/canals/male01/gunboat_giveemhell.wav",
		"vo/canals/matt_go_nag04.wav",
		"vo/canals/matt_go_nag05.wav",
		"vo/coast/odessa/male01/stairman_follow03.wav"
	}
	self.SoundTbl_MoveOutOfPlayersWay = {
		"vo/npc/male01/excuseme01.wav",
		"vo/npc/male01/excuseme02.wav",
		"vo/npc/male01/outofyourway02.wav",
		"vo/npc/male01/pardonme01.wav",
		"vo/npc/male01/pardonme02.wav",
		"vo/npc/male01/sorry01.wav",
		"vo/npc/male01/sorry02.wav",
		"vo/npc/male01/sorry03.wav",
		"vo/npc/male01/sorrydoc01.wav",
		"vo/npc/male01/sorrydoc02.wav",
		"vo/npc/male01/sorrydoc04.wav",
		"vo/npc/male01/sorryfm01.wav",
		"vo/npc/male01/sorryfm02.wav",
		"vo/npc/male01/whoops01.wav"
	}
	self.SoundTbl_MedicBeforeHeal = {
		"vo/npc/male01/health01.wav",
		"vo/npc/male01/health02.wav",
		"vo/npc/male01/health03.wav",
		"vo/npc/male01/health04.wav",
		"vo/npc/male01/health05.wav"
	}
	self.SoundTbl_MedicAfterHeal = {}
	self.SoundTbl_MedicReceiveHeal = {}
	self.SoundTbl_OnPlayerSight = {
		"vo/npc/male01/abouttime01.wav",
		"vo/npc/male01/abouttime02.wav",
		"vo/npc/male01/ahgordon01.wav",
		"vo/npc/male01/ahgordon02.wav",
		"vo/npc/male01/docfreeman01.wav",
		"vo/npc/male01/docfreeman02.wav",
		"vo/npc/male01/freeman.wav",
		"vo/npc/male01/hellodrfm01.wav",
		"vo/npc/male01/hellodrfm02.wav",
		"vo/npc/male01/heydoc01.wav",
		"vo/npc/male01/heydoc02.wav",
		"vo/npc/male01/hi01.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/squad_greet01.wav",
		"vo/npc/male01/squad_greet04.wav",
		"vo/canals/male01/gunboat_owneyes.wav",
		"vo/canals/shanty_yourefm.wav",
		"vo/coast/odessa/nlo_greet_freeman.wav"
	}
	self.SoundTbl_Investigate = {
		"vo/npc/male01/startle01.wav",
		"vo/npc/male01/startle02.wav",
		"vo/canals/boxcar_becareful.wav",
		"vo/streetwar/sniper/male01/c17_09_help03.wav"
	}
	self.SoundTbl_LostEnemy = {}
	self.SoundTbl_Alert = {
		"vo/npc/male01/headsup01.wav",
		"vo/npc/male01/headsup02.wav",
		"vo/npc/male01/heretheycome01.wav",
		"vo/npc/male01/incoming02.wav",
		"vo/npc/male01/overhere01.wav",
		"vo/npc/male01/overthere01.wav",
		"vo/npc/male01/overthere02.wav",
		"vo/npc/male01/squad_away02.wav",
		"vo/npc/male01/upthere01.wav",
		"vo/npc/male01/upthere02.wav",
		"vo/canals/male01/stn6_incoming.wav"
	}
	self.SoundTbl_CallForHelp = {
		"vo/npc/male01/help01.wav",
		"vo/coast/bugbait/sandy_help.wav",
		"vo/streetwar/sniper/male01/c17_09_help01.wav",
		"vo/streetwar/sniper/male01/c17_09_help02.wav"
	}
	self.SoundTbl_BecomeEnemyToPlayer = {
		"vo/npc/male01/heretohelp01.wav",
		"vo/npc/male01/heretohelp02.wav",
		"vo/npc/male01/notthemanithought01.wav",
		"vo/npc/male01/notthemanithought02.wav",
		"vo/npc/male01/wetrustedyou01.wav",
		"vo/npc/male01/wetrustedyou02.wav"
	}
	self.SoundTbl_WeaponReload = {
		"vo/npc/male01/coverwhilereload01.wav",
		"vo/npc/male01/coverwhilereload02.wav",
		"vo/npc/male01/gottareload01.wav"
	}
	self.SoundTbl_BeforeMeleeAttack = {}
	self.SoundTbl_MeleeAttack = {}
	self.SoundTbl_MeleeAttackExtra = {}
	self.SoundTbl_MeleeAttackMiss = {}
	self.SoundTbl_GrenadeAttack = {}
	self.SoundTbl_OnGrenadeSight = {
		"vo/npc/male01/getdown02.wav",
		"vo/npc/male01/gethellout.wav",
		"vo/npc/male01/runforyourlife01.wav",
		"vo/npc/male01/runforyourlife02.wav",
		"vo/npc/male01/runforyourlife03.wav",
		"vo/npc/male01/strider_run.wav",
		"vo/npc/male01/takecover02.wav",
		"vo/npc/male01/uhoh.wav",
		"vo/npc/male01/watchout.wav"
	}
	self.SoundTbl_OnDangerSight = {
		"vo/npc/male01/getdown02.wav",
		"vo/npc/male01/takecover02.wav",
		"vo/npc/male01/uhoh.wav",
		"vo/npc/male01/watchout.wav"
	}
	self.SoundTbl_OnKilledEnemy = {
		"vo/npc/male01/gotone01.wav",
		"vo/npc/male01/gotone02.wav",
		"vo/npc/male01/nice.wav",
		"vo/npc/male01/ohno.wav",
		"vo/npc/male01/yeah02.wav",
		"vo/coast/odessa/male01/nlo_cheer01.wav",
		"vo/coast/odessa/male01/nlo_cheer02.wav",
		"vo/coast/odessa/male01/nlo_cheer03.wav",
		"vo/coast/odessa/male01/nlo_cheer04.wav"
	}
	self.SoundTbl_AllyDeath = {
		"vo/npc/male01/goodgod.wav",
		"vo/npc/male01/likethat.wav",
		"vo/npc/male01/no01.wav",
		"vo/npc/male01/no02.wav",
		"vo/canals/matt_beglad_b.wav",
		"vo/coast/odessa/male01/nlo_cubdeath01.wav",
		"vo/coast/odessa/male01/nlo_cubdeath02.wav"
	}
	self.SoundTbl_Pain = {
		"vo/npc/male01/imhurt01.wav",
		"vo/npc/male01/imhurt02.wav",
		"vo/npc/male01/ow01.wav",
		"vo/npc/male01/ow02.wav",
		"vo/npc/male01/pain01.wav",
		"vo/npc/male01/pain02.wav",
		"vo/npc/male01/pain03.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain05.wav",
		"vo/npc/male01/pain06.wav"
	}
	self.SoundTbl_DamageByPlayer = {
		"vo/npc/male01/onyourside.wav",
		"vo/npc/male01/stopitfm.wav",
		"vo/npc/male01/watchwhat.wav",
		"vo/trainyard/male01/cit_hit01.wav",
		"vo/trainyard/male01/cit_hit02.wav",
		"vo/trainyard/male01/cit_hit03.wav",
		"vo/trainyard/male01/cit_hit04.wav",
		"vo/trainyard/male01/cit_hit05.wav"
	}
	self.SoundTbl_Death = {
		"vo/npc/male01/pain07.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/pain09.wav"
	}
end

function ENT:ApplyFemaleSounds()
	self.SoundTbl_Idle = {
		//"vo/npc/female01/vanswer14.wav"
	}
	self.SoundTbl_IdleDialogue = {
		"vo/npc/female01/doingsomething.wav",
		"vo/npc/female01/getgoingsoon.wav",
		"vo/npc/female01/question01.wav",
		"vo/npc/female01/question02.wav",
		"vo/npc/female01/question03.wav",
		"vo/npc/female01/question04.wav",
		"vo/npc/female01/question05.wav",
		"vo/npc/female01/question06.wav",
		"vo/npc/female01/question07.wav",
		"vo/npc/female01/question08.wav",
		"vo/npc/female01/question09.wav",
		"vo/npc/female01/question10.wav",
		"vo/npc/female01/question11.wav",
		"vo/npc/female01/question12.wav",
		"vo/npc/female01/question13.wav",
		"vo/npc/female01/question14.wav",
		"vo/npc/female01/question15.wav",
		"vo/npc/female01/question16.wav",
		"vo/npc/female01/question17.wav",
		"vo/npc/female01/question18.wav",
		"vo/npc/female01/question19.wav",
		"vo/npc/female01/question20.wav",
		"vo/npc/female01/question21.wav",
		"vo/npc/female01/question22.wav",
		"vo/npc/female01/question23.wav",
		"vo/npc/female01/question25.wav",
		"vo/npc/female01/question26.wav",
		"vo/npc/female01/question27.wav",
		"vo/npc/female01/question28.wav",
		"vo/npc/female01/question29.wav",
		"vo/npc/female01/question30.wav",
		//"vo/npc/female01/question31.wav", -- This is actually a male sound... wtf...
		"vo/npc/female01/vquestion01.wav",
		"vo/npc/female01/vquestion02.wav",
		"vo/npc/female01/vquestion04.wav"
	}
	self.SoundTbl_IdleDialogueAnswer = {
		"vo/npc/female01/answer01.wav",
		"vo/npc/female01/answer02.wav",
		"vo/npc/female01/answer03.wav",
		"vo/npc/female01/answer04.wav",
		"vo/npc/female01/answer05.wav",
		"vo/npc/female01/answer07.wav",
		"vo/npc/female01/answer08.wav",
		"vo/npc/female01/answer09.wav",
		"vo/npc/female01/answer10.wav",
		"vo/npc/female01/answer11.wav",
		"vo/npc/female01/answer12.wav",
		"vo/npc/female01/answer13.wav",
		"vo/npc/female01/answer14.wav",
		"vo/npc/female01/answer15.wav",
		"vo/npc/female01/answer16.wav",
		"vo/npc/female01/answer17.wav",
		"vo/npc/female01/answer18.wav",
		"vo/npc/female01/answer19.wav",
		"vo/npc/female01/answer20.wav",
		"vo/npc/female01/answer21.wav",
		"vo/npc/female01/answer22.wav",
		"vo/npc/female01/answer23.wav",
		"vo/npc/female01/answer25.wav",
		"vo/npc/female01/answer26.wav",
		"vo/npc/female01/answer27.wav",
		"vo/npc/female01/answer28.wav",
		"vo/npc/female01/answer29.wav",
		"vo/npc/female01/answer30.wav",
		"vo/npc/female01/answer31.wav",
		"vo/npc/female01/answer32.wav",
		"vo/npc/female01/answer33.wav",
		"vo/npc/female01/answer34.wav",
		"vo/npc/female01/answer35.wav",
		"vo/npc/female01/answer36.wav",
		"vo/npc/female01/answer37.wav",
		"vo/npc/female01/answer38.wav",
		"vo/npc/female01/answer39.wav",
		"vo/npc/female01/answer40.wav",
		"vo/npc/female01/squad_affirm03.wav",
		"vo/npc/female01/vanswer01.wav",
		"vo/npc/female01/vanswer04.wav",
		"vo/npc/female01/vanswer08.wav",
		"vo/npc/female01/vanswer13.wav"
	}
	self.SoundTbl_CombatIdle = {
		"vo/npc/female01/squad_affirm05.wav",
		"vo/npc/female01/squad_affirm06.wav",
		"vo/canals/female01/stn6_go_nag02.wav"
	}
	self.SoundTbl_OnReceiveOrder = {
		"vo/npc/female01/ok01.wav",
		"vo/npc/female01/ok02.wav",
		"vo/npc/female01/squad_approach02.wav",
		"vo/npc/female01/squad_approach03.wav",
		"vo/npc/female01/squad_approach04.wav"
	}
	self.SoundTbl_FollowPlayer = {
		"vo/npc/female01/leadon01.wav",
		"vo/npc/female01/leadon02.wav",
		"vo/npc/female01/leadtheway01.wav",
		"vo/npc/female01/leadtheway02.wav",
		"vo/npc/female01/letsgo01.wav",
		"vo/npc/female01/letsgo02.wav",
		"vo/npc/female01/okimready01.wav",
		"vo/npc/female01/okimready02.wav",
		"vo/npc/female01/okimready03.wav",
		"vo/npc/female01/readywhenyouare01.wav",
		"vo/npc/female01/readywhenyouare02.wav",
		"vo/npc/female01/squad_affirm01.wav",
		"vo/npc/female01/squad_affirm02.wav",
		"vo/npc/female01/squad_affirm03.wav",
		"vo/npc/female01/squad_affirm04.wav",
		"vo/npc/female01/squad_affirm07.wav",
		"vo/npc/female01/squad_affirm08.wav",
		"vo/npc/female01/squad_affirm09.wav",
		"vo/npc/female01/squad_follow03.wav",
		"vo/npc/female01/squad_train01.wav",
		"vo/npc/female01/squad_train02.wav",
		"vo/npc/female01/squad_train03.wav",
		"vo/npc/female01/squad_train04.wav",
		"vo/npc/female01/yougotit02.wav"
	}
	self.SoundTbl_UnFollowPlayer = {
		"vo/npc/female01/holddownspot01.wav",
		"vo/npc/female01/holddownspot02.wav",
		"vo/npc/female01/illstayhere01.wav",
		"vo/npc/female01/imstickinghere01.wav",
		"vo/npc/female01/littlecorner01.wav",
		"vo/canals/female01/gunboat_farewell.wav",
		"vo/canals/female01/gunboat_giveemhell.wav",
		"vo/canals/airboat_go_nag03.wav",
		"vo/coast/odessa/female01/stairman_follow03.wav"
	}
	self.SoundTbl_MoveOutOfPlayersWay = {
		"vo/npc/female01/excuseme01.wav",
		"vo/npc/female01/excuseme02.wav",
		"vo/npc/female01/outofyourway02.wav",
		"vo/npc/female01/pardonme01.wav",
		"vo/npc/female01/pardonme02.wav",
		"vo/npc/female01/sorry01.wav",
		"vo/npc/female01/sorry02.wav",
		"vo/npc/female01/sorry03.wav",
		"vo/npc/female01/sorrydoc01.wav",
		"vo/npc/female01/sorrydoc02.wav",
		"vo/npc/female01/sorrydoc04.wav",
		"vo/npc/female01/sorryfm01.wav",
		"vo/npc/female01/sorryfm02.wav",
		"vo/npc/female01/whoops01.wav"
	}
	self.SoundTbl_MedicBeforeHeal = {
		"vo/npc/female01/health01.wav",
		"vo/npc/female01/health02.wav",
		"vo/npc/female01/health03.wav",
		"vo/npc/female01/health04.wav",
		"vo/npc/female01/health05.wav"
	}
	self.SoundTbl_MedicAfterHeal = {}
	self.SoundTbl_MedicReceiveHeal = {}
	self.SoundTbl_OnPlayerSight = {
		"vo/npc/female01/abouttime01.wav",
		"vo/npc/female01/abouttime02.wav",
		"vo/npc/female01/ahgordon01.wav",
		"vo/npc/female01/ahgordon02.wav",
		"vo/npc/female01/docfreeman01.wav",
		"vo/npc/female01/docfreeman02.wav",
		"vo/npc/female01/freeman.wav",
		"vo/npc/female01/hellodrfm01.wav",
		"vo/npc/female01/hellodrfm02.wav",
		"vo/npc/female01/heydoc01.wav",
		"vo/npc/female01/heydoc02.wav",
		"vo/npc/female01/hi01.wav",
		"vo/npc/female01/hi02.wav",
		"vo/npc/female01/squad_greet01.wav",
		"vo/npc/female01/squad_greet04.wav",
		"vo/canals/female01/gunboat_owneyes.wav",
		"vo/canals/gunboat_heyyourefm.wav"
	}
	self.SoundTbl_Investigate = {
		"vo/npc/female01/startle01.wav",
		"vo/npc/female01/startle02.wav"
	}
	self.SoundTbl_LostEnemy = {}
	self.SoundTbl_Alert = {
		"vo/npc/female01/headsup01.wav",
		"vo/npc/female01/headsup02.wav",
		"vo/npc/female01/heretheycome01.wav",
		"vo/npc/female01/incoming02.wav",
		"vo/npc/female01/overhere01.wav",
		"vo/npc/female01/overthere01.wav",
		"vo/npc/female01/overthere02.wav",
		"vo/npc/female01/squad_away02.wav",
		"vo/npc/female01/upthere01.wav",
		"vo/npc/female01/upthere02.wav",
		"vo/canals/female01/stn6_incoming.wav"
	}
	self.SoundTbl_CallForHelp = {
		"vo/npc/female01/help01.wav",
		"vo/canals/arrest_helpme.wav"
	}
	self.SoundTbl_BecomeEnemyToPlayer = {
		"vo/npc/female01/heretohelp01.wav",
		"vo/npc/female01/heretohelp02.wav",
		"vo/npc/female01/notthemanithought01.wav",
		"vo/npc/female01/notthemanithought02.wav",
		"vo/npc/female01/wetrustedyou01.wav",
		"vo/npc/female01/wetrustedyou02.wav"
	}
	self.SoundTbl_WeaponReload = {
		"vo/npc/female01/coverwhilereload01.wav",
		"vo/npc/female01/coverwhilereload02.wav",
		"vo/npc/female01/gottareload01.wav"
	}
	self.SoundTbl_BeforeMeleeAttack = {}
	self.SoundTbl_MeleeAttack = {}
	self.SoundTbl_MeleeAttackExtra = {}
	self.SoundTbl_MeleeAttackMiss = {}
	self.SoundTbl_GrenadeAttack = {}
	self.SoundTbl_OnGrenadeSight = {
		"vo/npc/female01/getdown02.wav",
		"vo/npc/female01/gethellout.wav",
		"vo/npc/female01/runforyourlife01.wav",
		"vo/npc/female01/runforyourlife02.wav",
		"vo/npc/female01/strider_run.wav",
		"vo/npc/female01/takecover02.wav",
		"vo/npc/female01/uhoh.wav",
		"vo/npc/female01/watchout.wav"
	}
	self.SoundTbl_OnDangerSight = {
		"vo/npc/female01/getdown02.wav",
		"vo/npc/female01/takecover02.wav",
		"vo/npc/female01/uhoh.wav",
		"vo/npc/female01/watchout.wav"
	}
	self.SoundTbl_OnKilledEnemy = {
		"vo/npc/female01/gotone01.wav",
		"vo/npc/female01/gotone02.wav",
		"vo/npc/female01/likethat.wav",
		"vo/npc/female01/nice01.wav",
		"vo/npc/female01/nice02.wav",
		"vo/npc/female01/yeah02.wav",
		"vo/coast/odessa/female01/nlo_cheer01.wav",
		"vo/coast/odessa/female01/nlo_cheer02.wav",
		"vo/coast/odessa/female01/nlo_cheer03.wav"
	}
	self.SoundTbl_AllyDeath = {
		"vo/npc/female01/goodgod.wav",
		"vo/npc/female01/no01.wav",
		"vo/npc/female01/no02.wav",
		"vo/npc/female01/ohno.wav",
		"vo/coast/odessa/female01/nlo_cubdeath01.wav",
		"vo/coast/odessa/female01/nlo_cubdeath02.wav"
	}
	self.SoundTbl_Pain = {
		"vo/npc/female01/imhurt01.wav",
		"vo/npc/female01/imhurt02.wav",
		"vo/npc/female01/ow01.wav",
		"vo/npc/female01/ow02.wav",
		"vo/npc/female01/pain01.wav",
		"vo/npc/female01/pain02.wav",
		"vo/npc/female01/pain03.wav",
		"vo/npc/female01/pain04.wav",
		"vo/npc/female01/pain05.wav"
	}
	self.SoundTbl_DamageByPlayer = {
		"vo/npc/female01/onyourside.wav",
		"vo/npc/female01/stopitfm.wav",
		"vo/npc/female01/watchwhat.wav",
		"vo/trainyard/female01/cit_hit01.wav",
		"vo/trainyard/female01/cit_hit02.wav",
		"vo/trainyard/female01/cit_hit03.wav",
		"vo/trainyard/female01/cit_hit04.wav",
		"vo/trainyard/female01/cit_hit05.wav"
	}
	self.SoundTbl_Death = {
		"vo/npc/female01/pain06.wav",
		"vo/npc/female01/pain07.wav",
		"vo/npc/female01/pain08.wav",
		"vo/npc/female01/pain09.wav"
	}
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/