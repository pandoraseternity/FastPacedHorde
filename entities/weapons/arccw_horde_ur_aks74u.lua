if !file.Exists("arccw/shared/sh_1_ur.lua","LUA") then return end

include("weapons/arccw_ur_ak.lua")

SWEP.Category = "ArcCW - Horde"

SWEP.PrintName = "KFSU-76" -- make this something russian and cool
SWEP.TrueName = "AKS-74U"
if GetConVar("arccw_truenames"):GetBool() then
    SWEP.PrintName = SWEP.TrueName
end

SWEP.Attachments = {
    {
        PrintName = "Optic",
        DefaultAttName = "Iron Sights",
        Slot = {"optic","optic_sniper","ur_ak_optic"},
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0, 2, 4.92),
            vang = Angle(0, -90, 0),
        },
        CorrectivePos = Vector(0, 0, -0.0),
        CorrectiveAng = Angle(-1.9, 180.15, 0),
        VMScale = Vector(1, 1, 1),
        -- SlideAmount = {
        --     vmin = Vector(0, 2-1, 4.55),
        --     vmax = Vector(0, 2+0.5, 4.55),
        -- },
--        RequireFlags = {"cover_rail"},
--        HideIfBlocked = true,
        -- InstalledEles = {"optic_rail"},
    },
    {
        PrintName = "Barrel",
        DefaultAttName = "16\" Standard Barrel",
        DefaultAttIcon = Material("entities/att/ur_ak/barrel/std.png", "mips smooth"),
        Slot = "ur_ak_barrel",
		Hidden = true,
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0,12, 1.9),
            vang = Angle(90, -90, -90),
        },
    },
    {
        PrintName = "Handguard",
        DefaultAttName = "Factory Handguard",
        DefaultAttIcon = Material("entities/att/ur_ak/handguards/std.png", "mips smooth"),
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0,12, 1.9),
            vang = Angle(90, -90, -90),
        },
        Slot = "ur_ak_hg",
        ExcludeFlags = {"barrel_carbine"},
    },
    {
        PrintName = "Muzzle",
        DefaultAttName = "Standard Muzzle",
        Slot = {"muzzle","ur_ak_muzzle"},
        Bone = "tag_weapon",
        VMScale = Vector(1.2, 1.2, 1.2),
        WMScale = VMScale,
        Offset = {
            vpos = Vector(0, 24.6, 2.7),
            vang = Angle(0, 270, 0),
        },
        ExcludeFlags = {"ur_ak_nomuzzle"},
        --Installed = "ur_ak_muzzle_akm"
    },
    {
        PrintName = "Receiver",
        DefaultAttName = "7.62x39mm Reciever",
		Hidden = true,
        DefaultAttIcon = Material("entities/att/uc_bullets/762x39.png", "mips smooth"),
        Slot = {"ur_ak_cal"},
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(2.8, -4.2, -11.5),
            vang = Angle(90, 0, -90),
        },
        DefaultFlags = {"cal_default"}
    },
    {
        PrintName = "Magazine",
        Slot = {"ur_ak_mag"},
        DefaultAttName = "30-Round Mag",
        DefaultAttIcon = Material("entities/att/ur_ak/magazines/762_30.png", "mips smooth"),
    },
    {
        PrintName = "Underbarrel",
        Slot = {"foregrip","ur_ak_ub"},
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0,12, 1.9),
            vang = Angle(90, -90, -90),
        },
        VMScale = Vector(1, 1, 1),
        SlideAmount = {
            vmin = Vector(0,10.5,1.9),
            vmax = Vector(0,13.5,1.9)
        },
        InstalledEles = {"rail_fg"},
        ExcludeFlags = {"ak_noubs"},
        MergeSlots = {17},
    },
    {
        PrintName = "Tactical",
        Slot = {"tac"},
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0, 19.6, 2.1),
            vang = Angle(0, 270, 0),
        },
        GivesFlags = {"tac"},
        --InstalledEles = {"ud_m16_clamp_fullsize"}
    },
    {
        PrintName = "Grip Type",
        Slot = {"ur_ak_grip"},
        DefaultAttName = "Factory Grip",
        DefaultAttIcon = Material("entities/att/ur_ak/grip_modern.png", "mips smooth"),
        ExcludeFlags = {"stock_vepr"},
    },
    {
        PrintName = "Stock",
        Slot = {"ur_ak_stock"},
        DefaultAttName = "Factory Stock",
        DefaultAttIcon = Material("entities/att/ur_ak/stock/n.png", "mips smooth"),
    },
    {
        PrintName = "Ammo Type",
        DefaultAttName = "\"FMJ\" Full Metal Jacket",
        DefaultAttIcon = Material("entities/att/arccw_uc_ammo_generic.png", "mips smooth"),
        Slot = "uc_ammo",
    },
    {
        PrintName = "Powder Load",
        Slot = "uc_powder",
        DefaultAttName = "Standard Load"
    },
    {
        PrintName = "Training Package",
        Slot = "uc_tp",
        DefaultAttName = "Basic Training"
    },
    {
        PrintName = "Internals",
        Slot = "uc_fg", -- Fire group
        DefaultAttName = "Standard Internals"
    },
    {
        PrintName = "Dust Cover",
        DefaultAttName = "Ribbed Dust Cover",
        DefaultAttIcon = Material("entities/att/ur_ak/dustcover_stock.png", "mips smooth"),
        Slot = {"ur_ak_cover"},
        FreeSlot = true,
    },
    {
        PrintName = "Charm",
        Slot = {"charm", "fml_charm", "ur_ak_charm"},
        FreeSlot = true,
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0.6, 6.7, 2.2),
            vang = Angle(90, -90, -90),
        },
    },
    {
        PrintName = "M203 slot",
        Slot = "uc_ubgl",
        Bone = "tag_weapon",
        Offset = {
            vpos = Vector(0, 9.9, 2.9),
            vang = Angle(90, -90, -90),
        },
        InstalledEles = {"rail_fg"},
        ExcludeFlags = {"ak_noubs","barrel_rpk"},
        Hidden = true,
    }
}

SWEP.Attachments[2].Installed = "ur_ak_barrel_krinkov"
SWEP.Attachments[5].Installed = "ur_ak_cal_545"
SWEP.Attachments[10].Installed = "ur_ak_stock_aks"

SWEP.NPCWeaponType = "weapon_smg1"