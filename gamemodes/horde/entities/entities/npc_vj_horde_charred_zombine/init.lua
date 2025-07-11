AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {"models/vj_zombies/zombine.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 350
ENT.HullType = HULL_WIDE_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 45
ENT.MeleeAttackDistance = 30 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 70 -- How far does the damage go?
ENT.SlowPlayerOnMeleeAttack = true -- If true, then the player will slow down
ENT.SlowPlayerOnMeleeAttack_RunSpeed = 100 -- Running Speed when Slow Player is on
ENT.SlowPlayerOnMeleeAttackTime = 5 -- How much time until player's Speed resets
ENT.MeleeAttackBleedEnemy = false -- Should the player bleed when attacked by melee
ENT.FootStepTimeRun = 0.4 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.6 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
ENT.FlinchAnimationDecreaseLengthAmount = 0.4 -- This will decrease the time it can move, attack, etc. | Use it to fix animation pauses after it finished the flinch animation
ENT.HitGroupFlinching_Values = {{HitGroup = {HITGROUP_HEAD}, Animation = {ACT_FLINCH_HEAD}}, {HitGroup = {HITGROUP_LEFTARM}, Animation = {ACT_FLINCH_LEFTARM}}, {HitGroup = {HITGROUP_RIGHTARM}, Animation = {ACT_FLINCH_RIGHTARM}}, {HitGroup = {HITGROUP_LEFTLEG}, Animation = {ACT_FLINCH_LEFTLEG}}, {HitGroup = {HITGROUP_RIGHTLEG}, Animation = {ACT_FLINCH_RIGHTLEG}}}
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_zombies/zombine/gear1.wav", "vj_zombies/zombine/gear2.wav", "vj_zombies/zombine/gear3.wav"}
ENT.SoundTbl_Idle = {"vj_zombies/zombine/idle1.wav", "vj_zombies/zombine/idle2.wav", "vj_zombies/zombine/idle3.wav", "vj_zombies/zombine/idle4.wav", "vj_zombies/zombine/idle5.wav"}
ENT.SoundTbl_Alert = {"vj_zombies/zombine/alert1.wav", "vj_zombies/zombine/alert2.wav", "vj_zombies/zombine/alert3.wav", "vj_zombies/zombine/alert4.wav", "vj_zombies/zombine/alert5.wav", "vj_zombies/zombine/alert6.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_zombies/zombine/attack1.wav", "vj_zombies/zombine/attack2.wav", "vj_zombies/zombine/attack3.wav", "vj_zombies/zombine/attack4.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav", "vj_zombies/slow/miss3.wav", "vj_zombies/slow/miss4.wav"}
ENT.SoundTbl_Pain = {"vj_zombies/zombine/pain1.wav", "vj_zombies/zombine/pain2.wav", "vj_zombies/zombine/pain3.wav", "vj_zombies/zombine/pain4.wav"}
ENT.SoundTbl_Death = {"vj_zombies/zombine/die1.wav", "vj_zombies/zombine/die2.wav"}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100

-- Custom
ENT.Zombine_GrenadeOut = false
ENT.Zombie_LastAnimSet = 0 -- 0 = Regular no grenade
ENT.Immune_Fire = true
ENT.CanFlinch = 1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(13, 13, 60), Vector(-13, -13, 0))
	self:Ignite(9999999)
	self:SetColor(Color(125,50,50))
	self:SetBodygroup( 1,1 )
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_IntMsg(ply)
	ply:ChatPrint("JUMP: To Pull Grenade (One time event!)")
end

ENT.grenadethrow = 0
ENT.CVar		= "horde_difficulty"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	local ene = self:GetEnemy()
	
	-- Pull out the grenade
	if self.Zombine_GrenadeOut == false && ((self.VJ_IsBeingControlled == true && self.VJ_TheController:KeyDown(IN_JUMP)) or (self.VJ_IsBeingControlled == false)) then
		if self.VJ_IsBeingControlled == true then
			self.VJ_TheController:PrintMessage(HUD_PRINTCENTER, "Pulling Grenade Out!")
			self:Zombine_CreateGrenade()
		elseif IsValid(ene) && self.LatestEnemyDistance <= 250 then
			self:Zombine_CreateGrenade()
		end
	end
	
	if cvars.Number(self.CVar, 1) >= 4 && CurTime() > self.grenadethrow then
		if IsValid(self) && IsValid(ene) && self:Visible(ene) then
			self:VJ_ACT_PLAYACTIVITY("attackd", true, false, true)
			for x=1, 2 do
			self.Grenade = ents.Create("arccw_thr_shrapnel")
			self.Grenade:SetPos(self:WorldSpaceCenter())
			self.Grenade:SetOwner(self)
			self.Grenade:Spawn()
			self.Grenade:Activate()
			self.Grenade:Input("SetTimer", self:GetOwner(), self:GetOwner(), 3)
			local phys = self.Grenade:GetPhysicsObject()
			if IsValid(phys) && IsValid(ene) then
				phys:SetVelocity(self:CalculateProjectile("Line", self:WorldSpaceCenter(), ene:GetPos() +ene:GetUp()*20, 1500 ))
			end
			self.grenadethrow = CurTime() + 6
			end
		end
	end
	
	if cvars.Number(self.CVar, 1) >= 2 && CurTime() > self.grenadethrow && cvars.Number(self.CVar, 1) < 4 then
		if IsValid(self) && IsValid(ene) && self:Visible(ene) then
			self:VJ_ACT_PLAYACTIVITY("attackd", true, false, true)
			for x=1, 2 do
			self.Grenade = ents.Create("npc_grenade_frag")
			self.Grenade:SetPos(self:WorldSpaceCenter())
			self.Grenade:SetOwner(self)
			self.Grenade:Spawn()
			self.Grenade:Activate()
			self.Grenade:Input("SetTimer", self:GetOwner(), self:GetOwner(), 3)
			self.Grenade:GetPhysicsObject():ApplyForceCenter(self:GetForward()*1000)
			self.grenadethrow = CurTime() + 6
			end
		end
	end
	
	-- Animation Control
	-- Has grenade
	if IsValid(self.Zombine_Grenade) == true then
		self.AnimTbl_IdleStand = {VJ_SequenceToActivity(self,"idle_grenade")}
		if IsValid(ene) then
			if self.LatestEnemyDistance < 1000 then
				self.AnimTbl_Walk = {VJ_SequenceToActivity(self,"run_all_grenade")}
				self.AnimTbl_Run = {VJ_SequenceToActivity(self,"run_all_grenade")}
			else
				self.AnimTbl_Walk = {VJ_SequenceToActivity(self,"walk_all_grenade")}
				self.AnimTbl_Run = {VJ_SequenceToActivity(self,"walk_all_grenade")}
			end
		else
			self.AnimTbl_Walk = {VJ_SequenceToActivity(self,"walk_all_grenade")}
			self.AnimTbl_Run = {VJ_SequenceToActivity(self,"run_all_grenade")}
		end
	-- NO grenade
	else
		self.AnimTbl_IdleStand = {ACT_IDLE}
		if IsValid(ene) then
			if self.LatestEnemyDistance < 1000 then
				self.AnimTbl_Walk = {ACT_RUN}
				self.AnimTbl_Run = {ACT_RUN}
			else
				self.AnimTbl_Walk = {ACT_WALK}
				self.AnimTbl_Run = {ACT_WALK}
			end
		else
			self.AnimTbl_Walk = {ACT_WALK}
			self.AnimTbl_Run = {ACT_RUN}
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Zombine_CreateGrenade()
	self.Zombine_GrenadeOut = true
	self:VJ_ACT_PLAYACTIVITY("pullgrenade", true, false, true)
	timer.Simple(0.6, function()
		if IsValid(self) then
			self.Zombine_Grenade = ents.Create("npc_grenade_frag")
			self.Zombine_Grenade:SetOwner(self)
			self.Zombine_Grenade:SetParent(self)
			self.Zombine_Grenade:Fire("SetParentAttachment", "grenade_attachment", 0)
			self.Zombine_Grenade:Spawn()
			self.Zombine_Grenade:Activate()
			self.Zombine_Grenade:Input("SetTimer", self:GetOwner(), self:GetOwner(), 3)
			self.Zombine_Grenade.VJ_IsPickedUpDanger = true -- So humans detect as picked up and they won't pick it up
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
    self.AnimTbl_MeleeAttack = {"vjseq_fastattack"}
    self.TimeUntilMeleeAttackDamage = 0.4
    self.MeleeAttackDamage = 25
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	if IsValid(self.Zombine_Grenade) then
		local att = self:GetAttachment(self:LookupAttachment("grenade_attachment"))
		self.Zombine_Grenade:SetOwner(NULL)
		self.Zombine_Grenade:SetParent(NULL)
		self.Zombine_Grenade:Fire("ClearParent")
		self.Zombine_Grenade:SetMoveType(MOVETYPE_VPHYSICS)
		self.Zombine_Grenade:SetPos(att.Pos)
		self.Zombine_Grenade:SetAngles(att.Ang)
		local phys = self.Zombine_Grenade:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableGravity(true)
			phys:Wake()
		end
	end
end

function ENT:CustomOnMeleeAttack_AfterChecks(hitEnt, isProp)
    if isProp then return end
    if hitEnt and IsValid(hitEnt) and hitEnt:IsPlayer() then
        hitEnt:Horde_AddDebuffBuildup(HORDE.Status_Ignite, 35)
    end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsFireDamage(dmginfo) then
		dmginfo:ScaleDamage(0.75)
	elseif HORDE:IsColdDamage(dmginfo) or HORDE:IsMeleeDamage(dmginfo) then
		dmginfo:ScaleDamage(1.25)
	end
end

VJ.AddNPC("Charred Zombine","npc_vj_horde_charred_zombine", "Zombies")