

include("weapons/arccw_ud_m16.lua")

SWEP.Category = "ArcCW - Horde"

SWEP.PrintName = "RAYCAR-0 Grenadier"
SWEP.TrueName = "M16A2 Grenadier"
if GetConVar("arccw_truenames"):GetBool() then
    SWEP.PrintName = SWEP.TrueName
end

SWEP.Attachments = {
    {
        PrintName = "Optic",
        DefaultAttName = "Iron Sights",
        InstalledEles = {"upper_flat"},
        Slot = {"optic","optic_sniper","ud_m16_rs"},
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0, -1.75, 3),
            vang = Angle(90, 0, -90),
        },
        SlideAmount = {
            vmin = Vector(0, -1.6, 3 - 2),
            vmax = Vector(0, -1.6, 3 + 1),
        },
    },
    {
        PrintName = "Barrel",
        DefaultAttName = "20\" Standard Barrel",
        DefaultAttIcon = Material("entities/att/acwatt_ud_m16_barrel_20.png", "smooth mips"),
        Slot = "ud_m16_blen",
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(2.8, -4.2, -11.5),
            vang = Angle(90, 0, -90),
        },
    },
    {
        PrintName = "Handguard",
        DefaultAttName = "Ribbed Handguard",
        DefaultAttIcon = Material("entities/att/acwatt_ud_m16_hg_ribbed.png", "smooth mips"),
        Slot = "ud_m16_hg",
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0, -1.63, -0.41),
            vang = Angle(90, 0, -90),
        },
        ExcludeFlags = {"sd"}
    },
    {
        PrintName = "Muzzle",
        DefaultAttName = "Standard Muzzle",
        Slot = {"muzzle", "ud_m16_muzzle"},
        Bone = "m16_parent",
        VMScale = Vector(1, 1, 1),
        WMScale = VMScale,
        Offset = {
            vpos = Vector(0, -.33, 23.27),
            vang = Angle(90, 0, -90),
        },
        ExcludeFlags = {"sd", "m16_stub"},
    },
    {
        PrintName = "Upper Receiver",
        DefaultAttName = "5.56x45mm Upper",
        DefaultAttIcon = Material("entities/att/uc_bullets/556x45.png", "smooth mips"),
        Slot = {"ud_m16_receiver"},
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(2.8, -4.2, -11.5),
            vang = Angle(90, 0, -90),
        },
        ExcludeFlags = {"ud_m16_fpw"}
    },
    {
        PrintName = "Lower Receiver",
        DefaultAttName = "Burst Lower",
        DefaultAttIcon = Material("entities/att/acwatt_ud_m16_receiver_default.png", "smooth mips"),
        Slot = {"ud_m16_fcg"},
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(2.8, -4.2, -11.5),
            vang = Angle(90, 0, -90),
        },
        ExcludeFlags = {"m16_nolower"}
    },
    {
        PrintName = "Underbarrel",
        Slot = "foregrip",
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0, 6, 11),
            vang = Angle(90, 0, -90),
        },
        InstalledEles = {"rail_fg"},
        ExcludeFlags = {"m16_lmg", "m16_stub"},
		--Hidden = true,
        SlideAmount = {
            vmin = Vector(0, .65, 11.5),
            vmax = Vector(0, .65, 7.5),
        },
		MergeSlots = {18},
    },
    {
        PrintName = "Tactical",
        Slot = {"tac"},
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0, 0.3, 21.25),
            vang = Angle(90, 0, -90),
        },
        GivesFlags = {"tac"},
        --InstalledEles = {"ud_m16_clamp_fullsize"}
    },
    {
        PrintName = "Grip Type",
        Slot = {"ud_m16_grip"},
        DefaultAttName = "Standard Grip",
        DefaultAttIcon = Material("entities/att/acwatt_ud_m16_grip_default.png", "smooth mips"),
        ExcludeFlags = {"m16_adar"}
    },
    {
        PrintName = "Stock",
        Slot = {"ud_m16_stock","go_stock"},
        DefaultAttName = "Full Stock",
        DefaultAttIcon = Material("entities/att/acwatt_ud_m16_stock_default.png", "smooth mips"),
        -- GSO support
        InstalledEles = {"stock_231_tube"},
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(-0.02, 0, -3.25),
            vang = Angle(90, 0, -90),
        },
        VMScale = Vector(1.16, 1.16, 1.16),
    },
    {
        PrintName = "Magazine",
        Slot = {"ud_m16_mag"},
        DefaultAttName = "30-Round Mag",
        DefaultAttIcon = Material("entities/att/acwatt_ud_m16_mag_30.png", "smooth mips"),
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
        PrintName = "Front Sight",
        Slot = {"ud_m16_fs", "ud_m16_charm"},
        FreeSlot = true,
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0, -1.65, 16.75), -- 21.75 or 15.75
            vang = Angle(90, 0, -90),
        },
        ExcludeFlags = {"sight_magpul"}
    },
    {
        PrintName = "Charm",
        Slot = {"charm", "fml_charm"}, -- "ud_m16_charm"
        FreeSlot = true,
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0.48, 0.5, 3.9),
            vang = Angle(90, 0, -90),
        },
        -- MergeSlots = {17}
    },
    {
        PrintName = "M203 slot",
        Slot = "uc_ubgl",
        Bone = "m16_parent",
        Offset = {
            vpos = Vector(0, -0.4, 7.2),
            vang = Angle(90, 0, -90),
        },
        Hidden = true,
        InstalledEles = {"rail_fg"},
        ExcludeFlags = {"m16_lmg", "m16_stub"},
    }
}

SWEP.Attachments[3].Installed = "ud_m16_hg_heat"
SWEP.Attachments[16].Installed = "ud_m16_charm_ch"
SWEP.Attachments[18].Installed = "uc_ubgl_m203"-- UBGLs go in the funny hidden slot, not the UB slot

