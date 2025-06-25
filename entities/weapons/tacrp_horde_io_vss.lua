SWEP.Base = "tacrp_base"
SWEP.Spawnable = true

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "VSS Vintorez Medic Rifle"
SWEP.Category = "Tactical RP - Horde"

if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "" )
SWEP.BounceWeaponIcon = true
end

--SWEP.SubCatTier = "2Operator"
--SWEP.SubCatType = "6Precision Rifle"

SWEP.Description = "Integrally-suppressed marksman medic rifle with high fire rate and low recoil.\nEquipped with a 6x scope by default."

SWEP.ViewModel = "models/weapons/tacint_extras/v_vss.mdl"
SWEP.WorldModel = "models/weapons/tacint_extras/w_vss.mdl"

SWEP.Slot = 2

SWEP.BalanceStats = {
    [TacRP.BALANCE_SBOX] = {
        MoveSpeedMult = 0.85,
        ShootingSpeedMult = 0.75,
        SightedSpeedMult = 0.75,
        MeleeSpeedMult = 1,
        ReloadSpeedMult = 1,
    },
    [TacRP.BALANCE_TTT] = {
        Damage_Max = 15,
        Damage_Min = 12,
        Range_Min = 800,
        Range_Max = 4000,
        RPM = 650,

        RecoilSpreadPenalty = 0.005,
        HipFireSpreadPenalty = 0.035,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 4,
            [HITGROUP_CHEST] = 1.5,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 0.8,
            [HITGROUP_RIGHTARM] = 0.8,
            [HITGROUP_LEFTLEG] = 0.6,
            [HITGROUP_RIGHTLEG] = 0.6,
            [HITGROUP_GEAR] = 0.6
        },

        ReloadTimeMult = 1.25,

        MoveSpeedMult = 0.9,
        ShootingSpeedMult = 0.8,
        MeleeSpeedMult = 1,
        SightedSpeedMult = 0.5,
        ReloadSpeedMult = 0.65,
    },
    [TacRP.BALANCE_PVE] = {
        Damage_Max = 13,
        Damage_Min = 8,
        Range_Min = 1000,
        Range_Max = 5000,
        RPM = 600,

        MoveSpeedMult = 0.85,
        ShootingSpeedMult = 0.75,
        SightedSpeedMult = 0.75,
        MeleeSpeedMult = 1,
        ReloadSpeedMult = 1,
    },
}

SWEP.TTTReplace = TacRP.TTTReplacePreset.AssaultRifle

// "ballistics"

SWEP.Damage_Max = 40
SWEP.Damage_Min = 20
SWEP.Range_Min = 700 // distance for which to maintain maximum damage
SWEP.Range_Max = 6000 // distance at which we drop to minimum damage
SWEP.Penetration = 9 // units of metal this weapon can penetrate
SWEP.ArmorPenetration = 0.925

SWEP.BodyDamageMultipliers = {
    [HITGROUP_HEAD] = 3.5,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 1.25,
    [HITGROUP_LEFTARM] = 1,
    [HITGROUP_RIGHTARM] = 1,
    [HITGROUP_LEFTLEG] = 0.85,
    [HITGROUP_RIGHTLEG] = 0.85,
    [HITGROUP_GEAR] = 0.9
}

SWEP.MuzzleVelocity = 16000

// misc. shooting

SWEP.Firemode = 1
SWEP.RPM = 600

SWEP.Spread = 0.0005

SWEP.ShootTimeMult = 0.5

SWEP.RecoilPerShot = 1
SWEP.RecoilMaximum = 8
SWEP.RecoilResetTime = 0.12
SWEP.RecoilDissipationRate = 10
SWEP.RecoilFirstShotMult = 0.4

SWEP.RecoilVisualKick = 0.5
SWEP.RecoilKick = 2
SWEP.RecoilStability = 0.6
SWEP.RecoilAltMultiplier = 150

SWEP.RecoilSpreadPenalty = 0.0027
SWEP.HipFireSpreadPenalty = 0.01

SWEP.CanBlindFire = true

// handling

SWEP.MoveSpeedMult = 0.925
SWEP.ShootingSpeedMult = 0.75
SWEP.SightedSpeedMult = 0.55

SWEP.ReloadSpeedMult = 1

SWEP.AimDownSightsTime = 0.44
SWEP.SprintToFireTime = 0.4

SWEP.Sway = 1.3
SWEP.ScopedSway = 0.1

SWEP.FreeAimMaxAngle = 5.5

// hold types

SWEP.HoldType = "ar2"
SWEP.HoldTypeSprint = "passive"
SWEP.HoldTypeBlindFire = false

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.PassiveAng = Angle(0, 0, 0)
SWEP.PassivePos = Vector(0, -2, -5)

SWEP.BlindFireAng = Angle(0, 5, 0)
SWEP.BlindFirePos = Vector(3, -2, -5)

SWEP.SprintAng = Angle(30, -15, 0)
SWEP.SprintPos = Vector(5, 0, -2)

SWEP.SightAng = Angle(0.05, 0, 0)
SWEP.SightPos = Vector(-4.66, -7.5, -2.7)

SWEP.CorrectivePos = Vector(0, 0, -0.05)
SWEP.CorrectiveAng = Angle(0.75, 0.7, 0)

SWEP.HolsterVisible = true
SWEP.HolsterSlot = TacRP.HOLSTER_SLOT_BACK
SWEP.HolsterPos = Vector(5, -2, -6)
SWEP.HolsterAng = Angle(0, 0, 0)

// scope

SWEP.Scope = true
SWEP.ScopeOverlay = Material("tacrp/scopes/pso1.png", "mips smooth") // Material("path/to/overlay")
SWEP.ScopeFOV = 90 / 6
SWEP.ScopeLevels = 1
SWEP.ScopeHideWeapon = true
SWEP.ScopeOverlaySize = 0.9

SWEP.ClipSize = 20
SWEP.Ammo = "smg1"

SWEP.ReloadTimeMult = 1
SWEP.DropMagazineModel = "models/weapons/tacint_extras/magazines/vss.mdl"
SWEP.DropMagazineImpact = "plastic"

SWEP.ReloadUpInTime = 1.65
SWEP.DropMagazineTime = 0.65

// sounds

local path = "tacint_extras/vss/"
local path1 = "tacrp_extras/ak47/"

SWEP.Sound_Shoot = "^" .. path .. "fire.wav"

SWEP.Vol_Shoot = 80
SWEP.ShootPitchVariance = 2.5 // amount to vary pitch by each shot

// effects

// the .qc attachment for the muzzle
SWEP.QCA_Muzzle = 1
// ditto for shell
SWEP.QCA_Eject = 2

SWEP.MuzzleEffect = "muzzleflash_suppressed"
SWEP.EjectEffect = 2

// anims

SWEP.AnimationTranslationTable = {
    ["deploy"] = "unholster",
    ["fire1"] = "fire1_M",
    ["fire2"] = "fire2_M",
    ["fire3"] = "fire3_M",
    ["fire4"] = "fire4_M",
    ["fire5"] = "fire5_M",
    ["melee"] = {"melee1", "melee2"}
}

SWEP.DeployTimeMult = 2.25

// attachments

SWEP.AttachmentElements = {
    ["tactical"] = {
        BGs_VM = {
            {2, 1}
        },
        BGs_WM = {
            {2, 1}
        },
    },
    ["irons"] = {
        BGs_VM = {
            {2, 2}
        },
        BGs_WM = {
            {2, 2}
        },
    },
}


SWEP.Attachments = {
    [1] = {
        PrintName = "Optic",
        Category = {"ironsights", "optic_cqb", "optic_medium", "optic_sniper"},
        Bone = "ValveBiped.AK47_rootbone",
        WMBone = "Box01",
        InstalledElements = {"tactical"},
        AttachSound = "tacrp/weapons/optic_on.wav",
        DetachSound = "tacrp/weapons/optic_off.wav",
        VMScale = 0.75,
        Pos_VM = Vector(-5.25, 0.15, 4),
        Ang_VM = Angle(90, 0, 0),
        Pos_WM = Vector(0, 3, 0.2),
        Ang_WM = Angle(0, -90, 0),
    },
    [2] = {
        PrintName = "Tactical",
        Category = "tactical",
        Bone = "ValveBiped.AK47_rootbone",
        WMBone = "Box01",
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
        Pos_VM = Vector(-3.25, -0.1, 19),
        Pos_WM = Vector(0, 19, -2),
        Ang_VM = Angle(90, 0, -90),
        Ang_WM = Angle(0, -90, 180),
    },
    [3] = {
        PrintName = "Accessory",
        Category = {"acc", "acc_sling", "acc_duffle", "perk_extendedmag", "acc_bipod"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
    },
    [4] = {
        PrintName = "Bolt",
        Category = {"bolt_automatic"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [5] = {
        PrintName = "Trigger",
        Category = {"trigger_semi"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [6] = {
        PrintName = "Ammo",
        Category = {"ammo_rifle"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [7] = {
        PrintName = "Perk",
        Category = {"perk", "perk_melee", "perk_shooting", "perk_reload"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
    },
}

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_extras_vss.remove_clip", path .. "clipin1.wav")
addsound("tacint_extras_vss.insert_clip", path .. "clipin2.wav")
addsound("tacint_extras_vss.boltaction", path1 .. "bolt.mp3")
addsound("tacint_extras_vss.Buttstock_Back", path .. "buttstock_back.wav")



function SWEP:Hook_PostShoot()
    local ply = self:GetOwner()--ply:EmitSound("horde/weapons/mp7m/heal.ogg", 125, 100, 1, CHAN_AUTO)
    local tr = util.TraceLine(util.GetPlayerTrace(ply))
    if tr.Hit then
        local effectdata = EffectData()
        effectdata:SetOrigin(tr.HitPos)
        effectdata:SetRadius(50)
        util.Effect("horde_heal_mist", effectdata)

        local attacker = self

        if self.Owner:IsValid() then
            attacker = self.Owner
        end
	if SERVER then
        for _, ent in pairs(ents.FindInSphere(tr.HitPos, 50)) do
            if ent:IsPlayer() then
				--if ent == ply then return end
                local healinfo = HealInfo:New({amount=8, healer=self.Owner})
                HORDE:OnPlayerHeal(ent, healinfo)
            elseif ent:GetClass() == "npc_vj_horde_antlion" then
                local healinfo = HealInfo:New({amount=10, healer=self.Owner})
                HORDE:OnAntlionHeal(ent, healinfo)
            elseif ent:IsNPC() or ent:IsNextBot() then
                local dmg = DamageInfo()
                dmg:SetDamage(20)
                dmg:SetDamageType(DMG_NERVEGAS)
                dmg:SetAttacker(self.Owner)
                dmg:SetInflictor(self)
                dmg:SetDamagePosition(tr.HitPos)
                ent:TakeDamageInfo(dmg)
            end
        end
    end
end
end

function SWEP:Hook_PostThink()
    if SERVER then return end
    local tr = util.TraceHull({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 5000,
        filter = filter,
        mins = Vector(-20, -20, -8),
        maxs = Vector(20, 20, 8),
        mask = MASK_SHOT_HULL
    })

    if tr.Hit and tr.Entity and tr.Entity:IsPlayer()then
        self.Horde_HealTarget = tr.Entity
    else
        self.Horde_HealTarget = nil
    end
end

local function nv_center(ent)
	return ent:LocalToWorld(ent:OBBCenter())
end

function SWEP:Hook_GetHintCapabilities()
    if self.Horde_HealTarget then
        local pos = nv_center(self.Horde_HealTarget):ToScreen()
		surface.SetDrawColor(Color(50, 200, 50))
        surface.DrawCircle(pos.x, pos.y, 30)
        --surface.DrawLine(pos.x, 0, pos.x, ScrH())
        --surface.DrawLine(0, pos.y, ScrW(), pos.y)
        draw.DrawText(self.Horde_HealTarget:Health(), "Trebuchet24",
        pos.x - 15, pos.y - 15, Color(50, 200, 50), TEXT_ALIGN_LEFT)
    end
end
