if !file.Exists("arccw/shared/sh_1_ur.lua","LUA") then return end

include("weapons/arccw_ur_db.lua")

SWEP.Category = "ArcCW - UC Presets"


SWEP.PrintName = "Volga Sawed-off"
SWEP.TrueName = "IZh-58 Sawed-off"
if GetConVar("arccw_truenames"):GetBool() then
    SWEP.PrintName = SWEP.TrueName
end

SWEP.Hook_NameChange = function()
    return (GetConVar("arccw_truenames"):GetBool() and "IZh-58") or "Volga SuperShotgun"
end

SWEP.Attachments = {
    -- {
    --     PrintName = "Optic",
    --     DefaultAttName = "Iron Sights",
    --     Slot = {"optic_lp","optic"},
    --     Bone = "barrels",
    --     Offset = {
    --         vpos = Vector(0.5, -1.75, 1.5),
    --         vang = Angle(0, 90, 0),
    --     },
    --     VMScale = Vector(1,1,1),
    --     CorrectivePos = Vector(0, 0, -0.0),
    --     CorrectiveAng = Angle(0, 180, 0),
    -- },
    {
        PrintName = "Barrel",
        DefaultAttName = "26\" Factory Barrel",
        DefaultAttIcon = Material("entities/att/ur_dbs/blong.png", "smooth mips"),
        Slot = "ur_db_barrel",
        Bone = "body",
		Hidden = true,
        Offset = {
            vpos = Vector(-0.4, -5, -6),
            vang = Angle(0, 90, 0),
        },
    },
    {
        PrintName = "Muzzle",
        Slot = "choke",
    },
    {
        PrintName = "Stock",
        Slot = {"ur_db_stock"},
        DefaultAttName = "Wooden Stock",
        DefaultAttIcon = Material("entities/att/ur_dbs/s.png", "smooth mips"),
		Hidden = true,
    },
    {
        PrintName = "Ammo Type",
        DefaultAttName = "\"BUCK\" #00 Buckshot",
        DefaultAttIcon = Material("entities/att/arccw_uc_ammo_shotgun_generic.png", "mips smooth"),
        Slot = {"ud_ammo_shotgun"},
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
        Slot = {"uc_fg_singleshot", "uc_db_fg"}, -- Fire group
        DefaultAttName = "Standard Internals"
    },
    {
        PrintName = "Charm",
        Slot = {"charm", "fml_charm", "uc_db_tp"},
        FreeSlot = true,
        Bone = "body",
        Offset = {
            vpos = Vector(-0.55, 1, -0.5),
            vang = Angle(0, 90, 0),
        },
    },
}

SWEP.Attachments[1].Installed = "ur_dbs_barrel_sawedoff"
SWEP.Attachments[3].Installed = "ur_dbs_stock_sawedoff"
SWEP.Attachments[7].Installed = "ur_dbs_fg_extractor"