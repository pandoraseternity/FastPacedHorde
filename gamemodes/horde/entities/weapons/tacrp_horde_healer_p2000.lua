SWEP.Base = "tacrp_base"
SWEP.Spawnable = true

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "HK P2000 Medic Pistol"
SWEP.Category = "Tactical RP - Horde"

SWEP.SubCatTier = "3Security"
SWEP.SubCatType = "1Sidearm"

SWEP.Description = "Well-rounded police handgun."
SWEP.Description_Quote = "It's so fucking boring."

SWEP.Trivia_Caliber = "9x19mm"
SWEP.Trivia_Manufacturer = "Heckler & Koch"
SWEP.Trivia_Year = "2002"

SWEP.Faction = TacRP.FACTION_COALITION
SWEP.Credits = "Assets: Tactical Intervention"

SWEP.ViewModel = "models/weapons/tacint/v_p2000.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_p2000.mdl"

SWEP.Slot = 1

SWEP.BalanceStats = {
    [TacRP.BALANCE_SBOX] = {
        Damage_Max = 26,
        Damage_Min = 12,
        RPM = 500,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 2,
            [HITGROUP_CHEST] = 1,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 1,
            [HITGROUP_RIGHTARM] = 1,
            [HITGROUP_LEFTLEG] = 0.75,
            [HITGROUP_RIGHTLEG] = 0.75,
            [HITGROUP_GEAR] = 0.9
        },

        MoveSpeedMult = 1,
        ShootingSpeedMult = 1,
        SightedSpeedMult = 1,
        MeleeSpeedMult = 1,
        ReloadSpeedMult = 1,
    },
    [TacRP.BALANCE_TTT] = {
        Damage_Max = 15,
        Damage_Min = 10,
        Range_Min = 500,
        Range_Max = 2000,
        RPM = 420,

        RecoilResetInstant = true,
        RecoilMaximum = 8,
        RecoilResetTime = 0.22,
        RecoilDissipationRate = 10,
        RecoilSpreadPenalty = 0.003,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 2.5,
            [HITGROUP_CHEST] = 1,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 0.9,
            [HITGROUP_RIGHTARM] = 0.9,
            [HITGROUP_LEFTLEG] = 0.75,
            [HITGROUP_RIGHTLEG] = 0.75,
            [HITGROUP_GEAR] = 0.9
        },

        ReloadTimeMult = 1.2 * 1.25,

        MoveSpeedMult = 1,
        ShootingSpeedMult = 1,
        MeleeSpeedMult = 1,
        SightedSpeedMult = 0.75,
        ReloadSpeedMult = 0.9,
    },
    [TacRP.BALANCE_PVE] = {
        Damage_Max = 9,
        Damage_Min = 4,
        RPM = 500,
        RecoilKick = 4,

        MoveSpeedMult = 1,
        ShootingSpeedMult = 1,
        SightedSpeedMult = 1,
        MeleeSpeedMult = 1,
        ReloadSpeedMult = 1,
    },
}

SWEP.TTTReplace = TacRP.TTTReplacePreset.Pistol

// "ballistics"

SWEP.Damage_Max = 24
SWEP.Damage_Min = 10
SWEP.Range_Min = 500
SWEP.Range_Max = 2000
SWEP.Penetration = 3
SWEP.ArmorPenetration = 0.55

SWEP.MuzzleVelocity = 11500

SWEP.BodyDamageMultipliers = {
    [HITGROUP_HEAD] = 3,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 1,
    [HITGROUP_LEFTARM] = 1,
    [HITGROUP_RIGHTARM] = 1,
    [HITGROUP_LEFTLEG] = 0.75,
    [HITGROUP_RIGHTLEG] = 0.75,
    [HITGROUP_GEAR] = 0.9
}

// misc. shooting

SWEP.Firemode = 1

SWEP.RPM = 450

SWEP.Spread = 0.0055

SWEP.RecoilResetInstant = false
SWEP.RecoilPerShot = 1
SWEP.RecoilMaximum = 4
SWEP.RecoilResetTime = 0.02
SWEP.RecoilDissipationRate = 16
SWEP.RecoilFirstShotMult = 1

SWEP.RecoilVisualKick = 1
SWEP.RecoilKick = 4
SWEP.RecoilStability = 0.4

SWEP.RecoilSpreadPenalty = 0.003
SWEP.HipFireSpreadPenalty = 0.01

SWEP.CanBlindFire = true

// handling

SWEP.MoveSpeedMult = 1
SWEP.ShootingSpeedMult = 1
SWEP.SightedSpeedMult = 1

SWEP.ReloadSpeedMult = 1

SWEP.AimDownSightsTime = 0.2
SWEP.SprintToFireTime = 0

SWEP.Sway = 1
SWEP.ScopedSway = 0.5

SWEP.FreeAimMaxAngle = 3

// hold types

SWEP.HoldType = "revolver"
SWEP.HoldTypeSprint = "normal"
SWEP.HoldTypeBlindFire = false

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_PISTOL

SWEP.PassiveAng = Angle(0, 0, 0)
SWEP.PassivePos = Vector(0, -2, -5)

SWEP.BlindFireAng = Angle(0, 5, 0)
SWEP.BlindFirePos = Vector(0, -2, -5)

SWEP.BlindFireSuicideAng = Angle(-130, 0, 45)
SWEP.BlindFireSuicidePos = Vector(25, 15, -6)

SWEP.SprintAng = Angle(0, 30, 0)
SWEP.SprintPos = Vector(2, 0, -12)

SWEP.SightAng = Angle(-0.01, 0.14, 0)
SWEP.SightPos = Vector(-3.47, 0, -3.35)

SWEP.CorrectivePos = Vector(0, 0, 0)
SWEP.CorrectiveAng = Angle(0, 0, 0)

SWEP.HolsterVisible = true
SWEP.HolsterSlot = TacRP.HOLSTER_SLOT_PISTOL
SWEP.HolsterPos = Vector(0, 3, -4)
SWEP.HolsterAng = Angle(90, 0, 0)

// reload

SWEP.ClipSize = 15 --// 13 not realism :(
SWEP.Ammo = "pistol"

SWEP.ReloadUpInTime = 0.85
SWEP.DropMagazineTime = 0.2

SWEP.ReloadTimeMult = 1

SWEP.DropMagazineModel = "models/weapons/tacint/magazines/p2000.mdl"
SWEP.DropMagazineImpact = "pistol"

// sounds

local path = "tacrp/weapons/p2000/p2000_"

SWEP.Sound_Shoot = "^" .. path .. "fire-1.wav"
SWEP.Sound_Shoot_Silenced = path .. "fire_silenced-1.wav"

SWEP.Vol_Shoot = 110
SWEP.ShootPitchVariance = 2.5 // amount to vary pitch by each shot

// effects

// the .qc attachment for the muzzle
SWEP.QCA_Muzzle = 4

SWEP.MuzzleEffect = "muzzleflash_pistol"

// anims

SWEP.AnimationTranslationTable = {
    ["deploy"] = "draw",
    ["fire_iron"] = "shoot2",
    ["fire"] = {"shoot1", "shoot2", "shoot3"},
    ["blind_fire"] = {"blind_shoot1", "blind_shoot2", "blind_shoot3"},
    ["melee"] = {"melee1", "melee2"}
}

SWEP.ProceduralIronFire = {
    vm_pos = Vector(0, -0.5, -0.6),
    vm_ang = Angle(0, 2, 0),
    t = 0.2,
    tmax = 0.2,
    bones = {
        {
            bone = "ValveBiped.slide",
            pos = Vector(0, 0, -3),
            t0 = 0,
            t1 = 0.1,
        },
        {
            bone = "ValveBiped.hammer",
            ang = Angle(-15, 0, 0),
            t0 = 0,
            t1 = 0.15,
        },
        {
            bone = "ValveBiped.Bip01_R_Finger1",
            ang = Angle(0, -15, 0),
            t0 = 0,
            t1 = 0.2,
        },
        {
            bone = "ValveBiped.Bip01_R_Finger11",
            ang = Angle(-35, 0, 0),
            t0 = 0,
            t1 = 0.15,
        },
    },
}

SWEP.NoIdle = true

SWEP.ShootTimeMult = 0.5

SWEP.LastShot = true

// attachments

SWEP.Attachments = {
    [1] = {
        PrintName = "Optic",
        Category = "optic_pistol",
        Bone = "ValveBiped.slide",
        WMBone = "Box01",
        AttachSound = "tacrp/weapons/optic_on.wav",
        DetachSound = "tacrp/weapons/optic_off.wav",
        VMScale = 1,
        WMScale = 1,
        Pos_VM = Vector(0.05, 0, 0),
        Ang_VM = Angle(0, 90, 180),
        Pos_WM = Vector(0, -1, -1),
        Ang_WM = Angle(0, -90, 0),
    },
    [2] = {
        PrintName = "Muzzle",
        Category = "silencer",
        Bone = "ValveBiped.barrel_assembly",
        WMBone = "Box01",
        AttachSound = "tacrp/weapons/silencer_on.wav",
        DetachSound = "tacrp/weapons/silencer_off.wav",
        VMScale = 0.5,
        WMScale = 0.5,
        Pos_VM = Vector(-0.5, 0.39, 6),
        Ang_VM = Angle(90, 0, 0),
        Pos_WM = Vector(0, 8, -1.5),
        Ang_WM = Angle(0, -90, 0),
    },
    [3] = {
        PrintName = "Tactical",
        Category = "tactical",
        Bone = "ValveBiped.p2000_rootbone",
        WMBone = "Box01",
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
        VMScale = 1.1,
        WMScale = 1.3,
        Pos_VM = Vector(-2, 0, 6),
        Ang_VM = Angle(90, 0, 180),
        Pos_WM = Vector(0, 5, -2.75),
        Ang_WM = Angle(0, -90, 180),
    },
    [4] = {
        PrintName = "Accessory",
        Category = {"acc", "acc_extmag_pistol", "acc_holster", "acc_brace"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
    },
    [5] = {
        PrintName = "Bolt",
        Category = {"bolt_automatic"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [6] = {
        PrintName = "Trigger",
        Category = {"trigger_semi"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [7] = {
        PrintName = "Ammo",
        Category = {"ammo_pistol"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [8] = {
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

addsound("tacint_p2000.clip_in", path .. "clip_in.wav")
addsound("tacint_p2000.clip_in-mid", path .. "clip_in-mid.wav")
addsound("tacint_p2000.clip_out", path .. "clip_out.wav")
addsound("tacint_p2000.slide_action", path .. "slide_action.wav")
addsound("tacint_p2000.slide_shut", path .. "slide_shut.wav")
addsound("tacint_p2000.cock_hammer", path .. "cockhammer.wav")

SWEP.healtime = 0
function SWEP:ToggleSafety(onoff)

if self.healtime < CurTime() then
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
	ply:EmitSound("horde/weapons/mp7m/heal.ogg", 125, 100, 1, CHAN_AUTO)
	self.healtime = CurTime() + 0.5
	self:SetNextPrimaryFire(CurTime() + 0.2)
	if SERVER then
        for _, ent in pairs(ents.FindInSphere(tr.HitPos, 50)) do
            if ent:IsPlayer() then
				--if ent == ply then return end
                local healinfo = HealInfo:New({amount=20, healer=self.Owner})
                HORDE:OnPlayerHeal(ent, healinfo)
            elseif ent:GetClass() == "npc_vj_horde_antlion" then
                local healinfo = HealInfo:New({amount=20, healer=self.Owner})
                HORDE:OnAntlionHeal(ent, healinfo)
            elseif ent:IsNPC() then
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

	
    if self:GetValue("Firemode") == 0 then return end
    onoff = onoff or !self:GetSafe()

    self:SetSafe(onoff)

    if onoff == true then
        self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)
    end

    if CLIENT then self.LastHintLife = CurTime() end
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
