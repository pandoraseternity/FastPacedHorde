AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {"models/zombie/classic.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 350
ENT.HeadHealth = 100
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 32 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 65 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.8
ENT.MeleeAttackBleedEnemy = false -- Should the player bleed when attacked by melee
ENT.FootStepTimeRun = 1 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav","npc/zombie/zombie_voice_idle2.wav","npc/zombie/zombie_voice_idle3.wav","npc/zombie/zombie_voice_idle4.wav","npc/zombie/zombie_voice_idle5.wav","npc/zombie/zombie_voice_idle6.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav","npc/zombie/zombie_alert2.wav","npc/zombie/zombie_alert3.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"zsszombie/miss1.wav","zsszombie/miss2.wav","zsszombie/miss3.wav","zsszombie/miss4.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav","npc/zombie/zombie_pain2.wav","npc/zombie/zombie_pain3.wav","npc/zombie/zombie_pain4.wav","npc/zombie/zombie_pain5.wav","npc/zombie/zombie_pain6.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav","npc/zombie/zombie_die2.wav","npc/zombie/zombie_die3.wav"}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.HasDeathRagdoll = false
ENT.HasGibOnDeath = true
ENT.CVar		= "horde_difficulty"

function ENT:CustomOnInitialize()
    self:SetBodygroup(1,1)
    self:SetColor(Color(255, 0, 255))
    self.HeadHealth = self.HeadHealth * HORDE.Difficulty[HORDE.CurrentDifficulty].healthMultiplier
    self:SetModelScale(1.25, 0)
    self:ManipulateBoneScale(0, Vector(2,2,2))
    self:ManipulateBoneScale(9, Vector(2,2,4))

    self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end

ENT.explode = 0
function ENT:CustomOnThink_AIEnabled()
if cvars.Number(self.CVar, 1) >= 3 && IsValid(self) && IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) <= 90 && self:Visible(self:GetEnemy()) && self.explode == 0 then
if self:GetPos():Distance(self:GetEnemy():GetPos()) > 90 then return end
    local e = EffectData()
	self:SetColor(Color(255, 255, 255))
	sound.Play("ocpack/stalkerwarning.wav", self:GetPos())
	self.explode = 1
timer.Simple(1.25,function() if IsValid(self) then
	sound.Play("npc/antlion/antlion_burst1.wav", self:GetPos())
    e:SetOrigin(self:GetPos())
    util.Effect("exploder_explosion", e, true, true)

    local dmg = DamageInfo()
    dmg:SetInflictor(self)
    dmg:SetAttacker(self)
    dmg:SetDamageType(DMG_ACID)
    dmg:SetDamage(100)
    --util.BlastDamageInfo(dmg, self:GetPos(), 180)
	util.VJ_SphereDamage(self,self,self:GetPos(),250,50,DMG_ACID,false,true, {DisableVisibilityCheck=false, Force=80})
	for k, destroy in pairs(ents.FindInSphere(self:GetPos(), 180)) do
		if destroy:IsNPC() or destroy:IsNextBot() && self:Disposition(destroy) == D_LI then
			destroy:SetHealth(math.Clamp( destroy:GetMaxHealth(), 0, destroy:Health() + destroy:GetMaxHealth() * 0.12 ))
		end
	self:SetHealth(1)
	self:TakeDamageInfo(dmg)
end end end)

end
end

function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
    if hitgroup == HITGROUP_HEAD then
        --self.HasDeathRagdoll = true
        return
    end
    local e = EffectData()
        e:SetOrigin(self:GetPos())
    util.Effect("exploder_explosion", e, true, true)

    local dmg = DamageInfo()
    dmg:SetInflictor(self)
    dmg:SetAttacker(self)
    dmg:SetDamageType(DMG_ACID)
    dmg:SetDamage(100)
    --util.BlastDamageInfo(dmg, self:GetPos(), 250)
	util.VJ_SphereDamage(self,self,self:GetPos(),250,50,DMG_ACID,false,true, {DisableVisibilityCheck=false, Force=80})

	for k, destroy in pairs(ents.FindInSphere(self:GetPos(), 150)) do
	if destroy:IsNPC() or destroy:IsNextBot() && self:Disposition(destroy) == D_LI then
	destroy:SetHealth(math.Clamp( destroy:GetMaxHealth(), 0, destroy:Health() + destroy:GetMaxHealth() * 0.12 ))
	end

    sound.Play("vj_acid/acid_splat.wav", self:GetPos())
	self:SetHealth(1)
	self:TakeDamageInfo( dmg )
end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if hitgroup == HITGROUP_HEAD then
        self.HeadHealth = self.HeadHealth - dmginfo:GetDamage()
        if self.HeadHealth <= 0 then
            self:SetHealth(1)
        end
        dmginfo:ScaleDamage(2)
    elseif HORDE:IsBlastDamage(dmginfo) or HORDE:IsFireDamage(dmginfo) then
        dmginfo:ScaleDamage(1.5)
    elseif HORDE:IsPoisonDamage(dmginfo) then
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)
    end
end

VJ.AddNPC("Exploder","npc_vj_horde_exploder", "Zombies")