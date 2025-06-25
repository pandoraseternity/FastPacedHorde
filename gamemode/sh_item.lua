-- Economy variables
HORDE.items = {}

HORDE.ENTITY_PROPERTY_WPN = 1
HORDE.ENTITY_PROPERTY_GIVE = 2
HORDE.ENTITY_PROPERTY_DROP = 3
HORDE.ENTITY_PROPERTY_ARMOR = 4
HORDE.ENTITY_PROPERTY_GADGET = 5

HORDE.categories = {"Melee", "Pistol", "SMG", "Shotgun", "Rifle", "MG", "Explosive", "Special", "Equipment", "Attachment", "Gadget"}
HORDE.entity_categories = {"Special", "Equipment"}
HORDE.arccw_attachment_categories = {"Optic", "Underbarrel", "Tactical", "Barrel", "Muzzle", "Magazine", "Stock", "Slide", "Ammo Type", "Perk"}
HORDE.starter_weapons = {}

HORDE.max_weight = 15
HORDE.default_ammo_price = 10

function HORDE:IsMeleeItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Melee"
end

function HORDE:IsPistolItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Pistol"
end

function HORDE:IsSMGItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "SMG"
end

function HORDE:IsRifleItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Rifle"
end

function HORDE:IsShotgunItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Shotgun"
end

function HORDE:IsMGItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "MG"
end

function HORDE:IsExplosiveItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Explosive"
end

function HORDE:IsSpecialItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Special"
end

function HORDE:IsEquipmentItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Equipment"
end

function HORDE:IsAttachmentItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Attachment"
end

function HORDE:IsGadgetItem(class)
    return HORDE.items[class] and HORDE.items[class].category == "Gadget"
end

-- Creates a Horde item. The item will appear in the shop.
function HORDE:CreateItem(category, name, class, price, weight, description, whitelist, ammo_price, secondary_ammo_price, entity_properties, shop_icon, levels, skull_tokens, dmgtype, infusions, starter_classes, hidden, blacklist)
    if category == nil or name == nil or class == nil or price == nil or weight == nil or description == nil then return end
    if name == "" or class == "" then return end
    if not table.HasValue(HORDE.categories, category) then return end
    if string.len(name) <= 0 or string.len(class) <= 0 then return end
    if price < 0 or weight < 0 then return end
    local item = {}
    item.category = category
    item.name = name
    item.class = class
    item.price = price
    item.skull_tokens = skull_tokens or 0
    item.weight = weight
    item.description = description
    item.whitelist = whitelist
    item.ammo_price = ammo_price
    item.secondary_ammo_price = secondary_ammo_price
    if entity_properties then
        item.entity_properties = entity_properties
    else
        item.entity_properties = {type=HORDE.ENTITY_PROPERTY_WPN}
    end
    if item.class == "_horde_armor_100" then
        item.entity_properties = {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}
    end
    if shop_icon and shop_icon ~= "" then
        item.shop_icon = shop_icon
    end
    item.total_levels = 0
    if levels then
        item.levels = levels
        local total_levels = 0
        for _, level in pairs(levels) do
            total_levels = total_levels + level
        end
        item.total_levels = total_levels
    end
    item.dmgtype = dmgtype or nil
    item.infusions = infusions or nil
    item.starter_classes = starter_classes or nil
    item.hidden = hidden or nil
	--item.blacklist = blacklist
    HORDE.items[item.class] = item
    HORDE:SetItemsData()
end

function HORDE:CreateGadgetItem(class, price, weight, whitelist, levels, dmgtype, hidden)
    local gadget = HORDE.gadgets[class]
    HORDE:CreateItem("Gadget", gadget.PrintName, class, price, weight, "", whitelist, 10, -1, {type=HORDE.ENTITY_PROPERTY_GADGET}, nil, levels, nil, dmgtype, nil, nil, hidden)
end

HORDE.InvalidateHordeItemCache = 1
HORDE.CachedHordeItems = nil
HORDE.GetCachedHordeItems = function()
    if HORDE.InvalidateHordeItemCache == 1 then
        local tab = util.TableToJSON(HORDE.items)
        local str = util.Compress(tab)
        HORDE.CachedHordeItems = str
        HORDE.InvalidateHordeItemCache = 0
    end
    return HORDE.CachedHordeItems
end

function HORDE:SyncItems()
    local str = HORDE.GetCachedHordeItems()
    if player then
        for _, ply in pairs(player.GetAll()) do
            net.Start("Horde_SyncItems")
            net.WriteUInt(string.len(str), 32)
            net.WriteData(str, string.len(str))
            net.Send(ply)
        end
    end
end

function HORDE:SetItemsData()
    if SERVER then
        if GetConVarNumber("horde_default_item_config") == 1 then return end
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
        end

        file.Write("horde/items.txt", util.TableToJSON(HORDE.items))

        HORDE:SyncItems()
    end
end

local function GetStarterWeapons()
    for class, item in pairs(HORDE.items) do
        if item.starter_classes then
            for _, starter_subclass in pairs(item.starter_classes) do
                if not HORDE.starter_weapons[starter_subclass] then HORDE.starter_weapons[starter_subclass] = {} end
                table.insert(HORDE.starter_weapons[starter_subclass], class)
            end
        end
    end
end

local function GetItemsData()
    if SERVER then
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
            return
        end

        if file.Read("horde/items.txt", "DATA") then
            local t = util.JSONToTable(file.Read("horde/items.txt", "DATA"))

            for _, item in pairs(t) do
                if item.name == "" or item.class == "" or item.name == nil or item.category == nil or item.class == nil or item.ammo_price == nil or item.secondary_ammo_price == nil then
                    HORDE:SendNotification("Item config file validation failed! Please update your file or delete it.", 1)
                    return
                end
            end
            HORDE.items = t

            print("[HORDE] - Loaded custom item config.")
        end

        GetStarterWeapons()

        HORDE:SyncItems()
    end
end

function HORDE:GetDefaultGadgets()
    HORDE:CreateGadgetItem("gadget_detoxifier", 1500, 0, nil, {Medic=4})
    HORDE:CreateGadgetItem("gadget_heat_plating", 1500, 0, nil, {Cremator=4})
    HORDE:CreateGadgetItem("gadget_arctic_plating", 1500, 0, nil) 
    HORDE:CreateGadgetItem("gadget_shock_plating", 1500, 0, nil, {Warden=4})
    HORDE:CreateGadgetItem("gadget_blast_plating", 1500, 0, nil, {Demolition=4})
    HORDE:CreateGadgetItem("gadget_diamond_plating", 1750, 0, nil, {Berserker=3,Heavy=3})
    HORDE:CreateGadgetItem("gadget_corporate_mindset", 2000, 0, nil, {Survivor=5,Medic=5,Assault=5,Demolition=5,Berserker=5,Engineer=5,Warden=5,Cremator=5,Heavy=5,Ghost=5})

    HORDE:CreateGadgetItem("gadget_vitality_booster", 2500, 1, {Survivor=true}, {Survivor=5})
    HORDE:CreateGadgetItem("gadget_damage_booster", 2500, 1, {Survivor=true}, {Survivor=10})
    HORDE:CreateGadgetItem("gadget_agility_booster", 2500, 1, {Survivor=true}, {Survivor=15})
    HORDE:CreateGadgetItem("gadget_resistance_booster", 2500, 1, {Survivor=true}, {Survivor=20})
    HORDE:CreateGadgetItem("gadget_ultimate_booster", 4000, 3, {Survivor=true}, {Survivor=25})
	--techno wings

    HORDE:CreateGadgetItem("gadget_iv_injection", 2000, 1, {Assault=true}, {Assault=5})
    HORDE:CreateGadgetItem("gadget_cortex", 2500, 1, {Assault=true}, {Assault=10})
    HORDE:CreateGadgetItem("gadget_neuro_amplifier", 3000, 2, {Assault=true}, {Assault=15})
    HORDE:CreateGadgetItem("gadget_ouroboros", 3000, 3, {Assault=true}, {Assault=20})
    --HORDE:CreateGadgetItem("gadget_hyperdrive", 3250, 1, {Assault=true}, {Assault=25})

    HORDE:CreateGadgetItem("gadget_life_diffuser", 2000, 1, {Medic=true}, {Medic=5}, {HORDE.DMG_POISON})
    HORDE:CreateGadgetItem("gadget_projectile_launcher_heal", 2500, 2, {Medic=true}, {Medic=10}, {HORDE.DMG_POISON})
    HORDE:CreateGadgetItem("gadget_healing_beam", 2500, 2, {Medic=true}, {Medic=15}, {HORDE.DMG_POISON})
    HORDE:CreateGadgetItem("gadget_steroid", 3000, 1, {Medic=true}, {Medic=20}) --transcendance
    HORDE:CreateGadgetItem("gadget_aegis", 3000, 2, {Medic=true}, {Medic=25})
	--defiance

    HORDE:CreateGadgetItem("gadget_energy_shield", 2000, 1, {Heavy=true}, {Heavy=5})
    HORDE:CreateGadgetItem("gadget_hardening_injection", 2500, 1, {Heavy=true}, {Heavy=10})
    HORDE:CreateGadgetItem("gadget_exoskeleton", 2750, 3, {Heavy=true}, {Heavy=15})
    HORDE:CreateGadgetItem("gadget_ulpa_filter", 3000, 2, {Heavy=true}, {Heavy=20})
    HORDE:CreateGadgetItem("gadget_armor_fusion",    3000, 2, {Heavy=true}, {Heavy=25})

    HORDE:CreateGadgetItem("gadget_proximity_defense", 2000, 1, {Demolition=true}, {Demolition=5})
    HORDE:CreateGadgetItem("gadget_projectile_launcher_blast", 2500, 2, {Demolition=true}, {Demolition=10}, {HORDE.DMG_BLAST})
    HORDE:CreateGadgetItem("gadget_nitrous_propellor", 2500, 2, {Demolition=true}, {Demolition=15})
    HORDE:CreateGadgetItem("gadget_ied", 3000, 3, {Demolition=true}, {Demolition=20}, {HORDE.DMG_BLAST})
    HORDE:CreateGadgetItem("gadget_nuke", 3000, 4, {Demolition=true}, {Demolition=25}, {HORDE.DMG_BLAST})

    HORDE:CreateGadgetItem("gadget_optical_camouflage", 2500, 1, {Ghost=true}, {Ghost=5})
    HORDE:CreateGadgetItem("gadget_projectile_launcher_ballistic", 2500, 2, {Ghost=true}, {Ghost=10}, {HORDE.DMG_BALLISTIC})
    HORDE:CreateGadgetItem("gadget_death_mark", 2500, 2, {Ghost=true}, {Ghost=15}, {HORDE.DMG_BLUNT})
    HORDE:CreateGadgetItem("gadget_assassin_optics", 3000, 2, {Ghost=true}, {Ghost=20})

    HORDE:CreateGadgetItem("gadget_quantum_tunnel", 2000, 1, {Engineer=true}, {Engineer=5})
    HORDE:CreateGadgetItem("gadget_voidout", 2250, 1, {Engineer=true}, {Engineer=10})
    HORDE:CreateGadgetItem("gadget_turret_pack", 2500, 3, {Engineer=true}, {Engineer=15})
    HORDE:CreateGadgetItem("gadget_e_parasite", 2750, 2, {Engineer=true}, {Engineer=20}, {HORDE.DMG_BLUNT})
    --HORDE:CreateGadgetItem("gadget_aerial_turret", 2500, 3, {Engineer=true}, {Engineer=25})

    HORDE:CreateGadgetItem("gadget_chakra", 2500, 1, {Berserker=true}, {Berserker=5})
    HORDE:CreateGadgetItem("gadget_flash", 2500, 2, {Berserker=true}, {Berserker=10}, {HORDE.DMG_SLASH})
    HORDE:CreateGadgetItem("gadget_berserk_armor", 2500, 2, {Berserker=true}, {Berserker=15})
    HORDE:CreateGadgetItem("gadget_hemocannon", 3000, 3, {Berserker=true}, {Berserker=20}, {HORDE.DMG_SLASH})
    HORDE:CreateGadgetItem("gadget_omnislash", 3250, 2, {Berserker=true}, {Berserker=25}, {HORDE.DMG_SLASH})

    HORDE:CreateGadgetItem("gadget_solar_array", 2000, 1, {Warden=true}, {Warden=5})
    HORDE:CreateGadgetItem("gadget_projectile_launcher_shock", 2500, 2, {Warden=true}, {Warden=10}, {HORDE.DMG_LIGHTNING})
    HORDE:CreateGadgetItem("gadget_watchtower_pack", 50, 1, {Warden=true}, {Warden=15})
    HORDE:CreateGadgetItem("gadget_shock_nova", 3000, 3, {Warden=true}, {Warden=20}, {HORDE.DMG_LIGHTNING})

    HORDE:CreateGadgetItem("gadget_butane_can", 2000, 1, {Cremator=true}, {Cremator=5}, {HORDE.DMG_FIRE})
    HORDE:CreateGadgetItem("gadget_projectile_launcher_fire", 2500, 2, {Cremator=true}, {Cremator=10}, {HORDE.DMG_FIRE})
    HORDE:CreateGadgetItem("gadget_barbeque", 2750, 2, {Cremator=true}, {Cremator=15})
    HORDE:CreateGadgetItem("gadget_hydrogen_burner", 3000, 3, {Cremator=true}, {Cremator=20})
    --HORDE:CreateGadgetItem("gadget_ion_cannon", 3000, 3, {Cremator=true}, {Cremator=25})

    -- Droppable Gadgets
    HORDE:CreateGadgetItem("gadget_vitality_shard", 500, 0)
    HORDE:CreateGadgetItem("gadget_damage_shard", 500, 0)
    HORDE:CreateGadgetItem("gadget_agility_shard", 500, 0)
    HORDE:CreateGadgetItem("gadget_cleansing_shard", 500, 0)
    HORDE:CreateGadgetItem("gadget_matriarch_womb", 50, 0, nil, nil, nil, true)
    HORDE:CreateGadgetItem("gadget_unstable_injection", 50, 0, nil, nil, nil, true)
    HORDE:CreateGadgetItem("gadget_hellfire_tincture", 50, 0, nil, nil, nil, true)
    HORDE:CreateGadgetItem("gadget_specimen_crystal_small", 200, 0, nil, nil, nil, true)
    HORDE:CreateGadgetItem("gadget_specimen_crystal_medium", 500, 0, nil, nil, nil, true)
    HORDE:CreateGadgetItem("gadget_specimen_crystal_large", 1000, 0, nil, nil, nil, true)
	HORDE:CreateGadgetItem("gadget_glorious_will", 50, 0, nil, nil, nil, true)
	HORDE:CreateGadgetItem("gadget_iridescent_pearl", 50, 0, nil, nil, nil, true)
    HORDE:CreateGadgetItem("gadget_elixir", 1000, 0, nil, nil, nil, true)
end

function HORDE:GetDefaultItemInfusions()
    local melee_blunt_infusions = {HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Concussive, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    local melee_slash_infusions = {HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Hemo, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    HORDE.items["arccw_horde_stunstick"].infusions = melee_blunt_infusions
    HORDE.items["arccw_horde_crowbar"].infusions = melee_blunt_infusions
    HORDE.items["tacrp_m_css"].infusions = melee_slash_infusions
    --HORDE.items["arccw_horde_kunai"].infusions = {HORDE.Infusion_Chrono, HORDE.Infusion_Hemo, HORDE.Infusion_Flaming, HORDE.Infusion_Arctic, HORDE.Infusion_Galvanizing, HORDE.Infusion_Septic, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    HORDE.items["arccw_horde_machete"].infusions = melee_slash_infusions
    HORDE.items["arccw_horde_axe"].infusions = melee_slash_infusions
    HORDE.items["arccw_horde_katana"].infusions = {HORDE.Infusion_Chrono, HORDE.Infusion_Hemo, HORDE.Infusion_Flaming, HORDE.Infusion_Arctic, HORDE.Infusion_Galvanizing, HORDE.Infusion_Septic, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    HORDE.items["arccw_horde_bat"].infusions = melee_blunt_infusions
	HORDE.items["tacrp_m_tonfa"].infusions = melee_blunt_infusions
    HORDE.items["arccw_horde_chainsaw"].infusions = melee_slash_infusions
    HORDE.items["tacrp_m_fasthawk"].infusions = melee_slash_infusions
    HORDE.items["tacrp_m_heathawk"].infusions = melee_slash_infusions
	HORDE.items["tfa_kf2_pulverizer"].infusions = melee_blunt_infusions
	HORDE.items["tfa_kf2_mace"].infusions = melee_blunt_infusions
    HORDE.items["arccw_horde_jotuun"].infusions = {HORDE.Infusion_Chrono, HORDE.Infusion_Arctic, HORDE.Infusion_Septic, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    HORDE.items["arccw_horde_inferno_blade"].infusions = {HORDE.Infusion_Chrono, HORDE.Infusion_Flaming, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    HORDE.items["arccw_horde_mjollnir"].infusions = {HORDE.Infusion_Chrono, HORDE.Infusion_Galvanizing, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}
    HORDE.items["arccw_horde_zweihander"].infusions = {HORDE.Infusion_Chrono, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Rejuvenating}

    local ballistic_infusions_light = {HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver}
	
	local ballistic_infusions_smgs = { HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver }

	local infusions_medic = { HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling, HORDE.Infusion_Quality, HORDE.Infusion_Rejuvenating, HORDE.Infusion_Septic }
	
    local ballistic_infusions_rifles = { HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling, HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Quicksilver, HORDE.Infusion_Siphoning }
	
	local ballistic_infusions_shotguns = { HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling, HORDE.Infusion_Quality, HORDE.Infusion_Concussive, HORDE.Infusion_Siphoning }
		
    --local ballistic_infusions_sniper_rifles = { HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling,
        --HORDE.Infusion_Quality, HORDE.Infusion_Quicksilver, HORDE.Infusion_Siphoning }
		
    local ballistic_infusions_mg_rifles = { HORDE.Infusion_Ruination, HORDE.Infusion_Chrono, HORDE.Infusion_Impaling,
        HORDE.Infusion_Quality, HORDE.Infusion_Titanium, HORDE.Infusion_Siphoning }
	
    for class, item in pairs(HORDE.items) do
		if HORDE:IsPistolItem(item.class) then
			item.infusions = ballistic_infusions_light 
		elseif HORDE:IsSMGItem(item.class) then
			item.infusions = infusions_medic --makes smgs more special
		elseif HORDE:IsRifleItem(item.class) then
			item.infusions = ballistic_infusions_rifles
		elseif HORDE:IsShotgunItem(item.class) then
			item.infusions = ballistic_infusions_shotguns
		elseif HORDE:IsMGItem(item.class) then
			item.infusions = ballistic_infusions_mg_rifles
		end
    end 

end

function HORDE:GetDefaultItemsData()
--category, name, class, price, weight, description, whitelist, ammo_price, secondary_ammo_price, entity_properties, shop_icon, levels, skull_tokens, dmgtype, infusions, starter_classes, hidden)
    HORDE:CreateItem("Melee",      "Combat Knife",   "tacrp_m_css",    100,  1, "A reliable bayonet.\nCan use perks.",
    nil, 10, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH}, nil, {"Berserker", "Samurai", "Survivor", "Psycho"})
    HORDE:CreateItem("Melee",      "Crowbar",        "arccw_horde_crowbar", 1250,  2, "A trusty crowbar.\nEasy to use.",
    nil, 10, -1, nil, "items/hl2/weapon_crowbar.png", nil, nil, {HORDE.DMG_BLUNT})
    HORDE:CreateItem("Melee",      "Machete",        "arccw_horde_machete", 1000,  2, "A large machete.\nEasy to use.",
    nil, 10, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Fireaxe",        "arccw_horde_axe",       1500,  3, "Fireaxe.\nHeavy, but can chops most enemies in half.",
    nil, 10, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Police Baton",        "tacrp_m_tonfa",       1500,  2, "Specialized police baton that can use perks.",
    {Survivor=true, Psycho = true, Berserker = true, Samurai = true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Fasthawk",        "tacrp_m_fasthawk",       1500,  2, "Axe-shaped weapon.\nCan use perks.",
    {Survivor=true, Psycho = true, Berserker = true, Samurai = true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Stunstick",      "arccw_horde_stunstick", 1500,  2, "Electric baton.\nDeals extra Lightning damage.",
    nil, 10, -1, nil, "items/hl2/weapon_stunstick.png", nil, nil, {HORDE.DMG_BLUNT, HORDE.DMG_LIGHTNING})
    HORDE:CreateItem("Melee",      "Heathawk",        "tacrp_m_heathawk",       2000,  3, "Axe-shaped weapon that doesn't actually use heat.\n Can use perks.",
    {Survivor=true, Psycho = true, Berserker = true, Samurai = true}, 10, -1, nil, nil, {Samurai=50}, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Katana",         "arccw_horde_katana",  2000,  3, "Ninja sword.\nLong attack range and fast attack speed.",
    {Survivor=true, Berserker = true, Samurai = true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Bat",            "arccw_horde_bat",     2000,  3, "Sturdy baseball bat.\nHits like a truck.",
    {Survivor=true, Psycho = true, Berserker = true, Samurai = true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BLUNT})
    HORDE:CreateItem("Melee",      "Chainsaw",       "arccw_horde_chainsaw",2500, 4, "Brrrrrrrrrrrrrrrr.\n\nHold RMB to saw through enemies.\nDeals a lot more damage when using ammo.",
    {Berserker = true, Samurai = true}, 10, -1, nil, nil, {Berserker=2}, nil, {HORDE.DMG_SLASH})
	
    HORDE:CreateItem("Melee",      "Inferno",        "arccw_horde_inferno_blade",   2500, 4, "A blazing curved sword with hidden power.\n\nPress RMB to activate/deactivate the weapon.\n\nWhen deactivated, the weapon deals Slashing damage.\n\nWhen activated, the weapon deals extra splashing Fire damage.\nHowever, the user takes Fire damage over time.",
    {Berserker = true, Samurai = true, Cremator=true}, 10, -1, nil, nil, {Berserker=2, Cremator=4}, nil, {HORDE.DMG_SLASH, HORDE.DMG_FIRE})
	
    HORDE:CreateItem("Melee",      "Jötunn",         "arccw_horde_jotuun",     2500, 4, "A cursed spiked mace forged with permafrost material.\n\nPress RMB to deliver a powerful ice blast.\nPerforming the ice blast increases Frostbite buildup on you.",
    {Berserker = true, Samurai = true,}, 10, -1, nil, nil, {Berserker=4}, nil, {HORDE.DMG_BLUNT, HORDE.DMG_COLD})
    HORDE:CreateItem("Melee",      "Mjölnir",       "arccw_horde_mjollnir",    3000, 4, "A warhammer embued with electric energy.\n\nPress RMB to charge the weapon.\nCharged attack creates a lightning storm on impact.",
	{Berserker = true, Samurai = true,}, 10, -1, nil, nil, {Berserker=4}, nil, {HORDE.DMG_LIGHTNING})
    HORDE:CreateItem("Melee",      "Pulverizer",       "tfa_kf2_pulverizer",    3000, 4, "Devastating heavy slegehammer.\n\nPress RMB to do a heavy attack with an explosive round.\nPress your TFA Alt-key to block.",
	{Berserker = true, Samurai = true,}, 10, -1, nil, nil, {Berserker=4}, nil, {HORDE.DMG_BLUNT})
    HORDE:CreateItem("Melee",      "Bone Crusher",       "tfa_kf2_mace",    3000, 4, "Heavy mace with a Shield.\n\nPress RMB to do a heavy attack, press LMB for a fast light attack.\nPress your TFA Alt-key to block.",
    {Berserker = true, Samurai = true,}, 10, -1, nil, nil, {Berserker=4}, nil, {HORDE.DMG_BLUNT})
    HORDE:CreateItem("Melee",      "Zweihänder",     "arccw_horde_zweihander",  3000, 5, "A heavy, large two-handed longsword.\nCan easily decapitate enemies in a full swing.",
    {Berserker = true, Samurai = true,}, 10, -1, nil, nil, {Berserker=5}, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Melee",      "Living Machete",     "arccw_horde_living_machete",  3000, 6, "A Machete combined with Mind Energy and a Xen Crystal. \nPossesses life-steal and AOE attacks.",
    {Berserker = true, Samurai = true,}, 10, -1, nil, nil, {Berserker=9}, nil, {HORDE.DMG_SLASH})

    HORDE:CreateItem("Pistol", "9mm", "arccw_horde_9mm", 50, 1, "Combine standard sidearm.",
        nil, 2, -1, nil, "items/hl2/weapon_pistol.png", nil, nil, { HORDE.DMG_BALLISTIC }, nil,
        { "Engineer", "Demolition", "Survivor", "Psycho" })
	
    HORDE:CreateItem("Pistol",     "Medic P2000",       "tacrp_horde_healer_p2000", 50,  1, "Modified P2000 that provides ranged healing.\n\nPress the Safety Key to fire healing darts.\nHealing dart recharges every 0.5 second.",
    {Medic=true,  Hatcher = true}, 2, -1, nil, "items/weapon_medic_9mm.png", nil, nil, {HORDE.DMG_BALLISTIC, HORDE.DMG_POISON}, nil, { "Medic", "Hatcher" })
	
    HORDE:CreateItem("Pistol",     "357",            "arccw_horde_357",        750,  2, "Colt python magnum pistol.\nUsed by Black Mesa security guards.",
    { Medic = true, Hatcher = true, Assault = true, SpecOps = true, Heavy = true, Demolition = true, Survivor = true, Psycho = true, Engineer = true, Warden = true, Overlord = true, Cremator = true, Juggernaut=true, Ghost=true }, 8, -1, nil, "items/hl2/weapon_357.png", nil, nil, {HORDE.DMG_BALLISTIC}, nil, {"Ghost", "Gunslinger"})
	
    HORDE:CreateItem("Pistol",     "Flare Gun",      "arccw_horde_flaregun",   100,  2, "Orion Safety Flare Gun.\nIgnites enemies and deals Fire damage.",
    {Cremator=true}, 3, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE}, nil, {"Cremator"})
	
    HORDE:CreateItem("Pistol",     "Glock",          "arccw_ud_glock",    750,  2, "Glock 18.\nSemi-automatic pistols manufactured in Austrian.",
    { Medic = true, Hatcher = true, Assault = true, SpecOps = true, Heavy = true, Demolition = true, Survivor = true, Psycho = true, Engineer = true, Warden = true, Overlord = true, Cremator = true, Juggernaut=true }, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "USP",            "tacrp_ex_usp",      750,  2, "Universelle Selbstladepistole.\nA semi-automatic pistol developed in Germany by H&K.",
    { Medic = true, Hatcher = true, Assault = true, SpecOps = true, Heavy = true, Demolition = true, Survivor = true, Psycho = true, Engineer = true, Warden = true, Overlord = true, Cremator = true, Juggernaut=true, Ghost=true }, 5, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "P250",           "tacrp_p250",     750,  2, "SIG Sauer P250.\nA low-recoil sidearm with a high rate of fire.",
    { Medic = true, Hatcher = true, Assault = true, SpecOps = true, Heavy = true, Demolition = true, Survivor = true, Psycho = true, Engineer = true, Warden = true, Overlord = true, Cremator = true, Juggernaut=true, Ghost=true }, 5, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "M1911",          "arccw_ur_m1911",   750,  2, "Colt 1911.\nStandard-issue sidearm for the United States Armed Forces.",
    {Ghost=true, Gunslinger=true, Demolition=true, Assault=true, SpecOps=true, Heavy=true, Juggernaut=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "Model 329PD",             "arccw_ur_329",       750,  2, "Model 329PD Revolver.\nDelivers a highly accurate and powerful round,\nbut at the expense of a lengthy trigger-pull.",
	{Ghost=true, Gunslinger=true, Demolition=true, Assault=true, SpecOps=true, Heavy=true, Juggernaut=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "Hardballer",            "tacrp_h_hardballer",      750,  2, "Long-slide hardhitting pistol.\nA semi-automatic pistol developed in Germany by H&K.",
    { Medic = true, Hatcher = true, Assault = true, SpecOps = true, Heavy = true, Demolition = true, Survivor = true, Psycho = true, Engineer = true, Warden = true, Overlord = true, Cremator = true, Juggernaut=true, Ghost=true }, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
	
    HORDE:CreateItem("Pistol",     "Deagle",         "arccw_ur_deagle",   900,  2, "Night Hawk .50C.\nAn iconic pistol that is diffcult to master.",
    {Survivor=true, Ghost=true, Gunslinger=true}, 5, -1, nil, nil, {Ghost=3}, nil, {HORDE.DMG_BALLISTIC})
	
    HORDE:CreateItem("Pistol",     "S&W500",            "tacrp_io_m500",      1000,  2, "Impractical handcannon.\nCertain to destroy your wrists.",
    {Ghost=true, Gunslinger=true}, 8, -1, nil, nil, {Ghost=6}, nil, {HORDE.DMG_BALLISTIC})

    HORDE:CreateItem("Pistol",     "M9",             "tacrp_vertec",       750,  2, "Beretta M9.\nSidearm used by the United States Armed Forces.",
    {Survivor=true, Ghost=true, Gunslinger=true}, 5, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "AF2011",             "tacrp_io_af2011",       1000,  3, "Beretta M9.\nSidearm used by the United States Armed Forces.",
    {Survivor=true, Ghost=true, Heavy=true, Gunslinger=true}, 5, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
	
    HORDE:CreateItem("Pistol",     "Dual 1911",   "tacrp_sd_dual_1911",  1750,  5, "Dual 1911.\nWidely used by law enforcements.",
    {Ghost=true, Gunslinger=true}, 5, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "Dual M9",        "tacrp_sd_dualies",       1750,  5, "Dual Beretta M9.\nSidearm used by the United States Armed Forces.",
    {Ghost=true, Gunslinger=true}, 5, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "Dual Deagle",    "tacrp_sd_dual_degala",   2000,  5, "Dual Night Hawk .50C.\nAn iconic pistol that is diffcult to master.",
    {Ghost=true, Gunslinger=true}, 5, -1, nil, nil, {Ghost=4}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Pistol",     "Dual Micro-Uzi",    "tacrp_sd_dual_uzis",   2000,  5, "Dual Micro Uzis. \nHard to control, but stylish.",
    {Ghost=true, Gunslinger=true}, 5, -1, nil, nil, {Ghost=4}, nil, {HORDE.DMG_BALLISTIC})

    --HORDE:CreateItem("SMG",        "SMG1",           "arccw_horde_smg1",   100, 3, "A compact, fully automatic firearm.",
    --{Assault=true, Heavy=true}, 5, -1, nil, "items/hl2/weapon_smg1.png", nil, nil, {HORDE.DMG_BALLISTIC}, nil, {"Assault", "Heavy", "SpecOps"})

    HORDE:CreateItem("SMG",        "HK94",            "tacrp_civ_mp5",   1250, 2, "Sporter variant of the MP5.\nAssault starter weapon.",
    {Assault=true, SpecOps=true}, 5, -1, nil, nil, {Assault=5}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "USC",            "tacrp_io_usc",   1250, 2, "Sporter variant of the UMP45.\nHeavy starter weapon.",
    {Heavy=true, Juggernaut=true}, 5, -1, nil, nil, {Heavy=5}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "Uzi",            "arccw_ud_uzi",   1250, 2, "UZI Submachine Gun.\nDesigned by Captain (later Major) Uziel Gal of the IDF following the 1948 Arab–Israeli War.",
    {Warden=false}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "MP9",            "tacrp_ex_mp9",   1250, 2, "MP9 Submachine Gun.\nCompact submachine gun.",
    {Medic=true, Assault=true, Heavy=true, Survivor=true, Cremator=true, Engineer=true, Demolition=true, Hatcher=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "Colt SMG",            "arccw_horde_ud_r0635",   1250, 2, "Colt SMG Submachine Gun. Basically a 9mm M4",
    {Medic=true, Assault=true, Heavy=true, Survivor=true, Cremator=true, Engineer=true, Demolition=true, Hatcher=true}, 8, -1, nil, nil, {Survivor=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "MP7",            "tacrp_mp7",   1250, 2, "MP7 Submachine Gun.\nHas high velocity rounds.",
    {Medic=true, Assault=true, Heavy=true, Survivor=true, Cremator=true, Engineer=true, Demolition=true, Hatcher=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "MP40",           "arccw_horde_mp40",  1250, 2, "Maschinenpistole 40.\nDeveloped in Nazi Germany and used extensively by the Axis powers during World War II.",
    {Medic=true, Assault=true, Heavy=true, Survivor=true, Cremator=true, Engineer=true, Demolition=true, Hatcher=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    --HORDE:CreateItem("SMG",        "Mac10",          "arccw_go_mac10",    1500, 2, "Military Armament Corporation Model 10.\nBoasts a high rate of fire,\nwith poor spread accuracy and high recoil as trade-offs.",
    --{Medic=true, Assault=true, Heavy=true, Survivor=true, Cremator=true, Engineer=true, Demolition=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "MP5",            "arccw_ur_mp5",      1500, 3, "Heckler & Koch MP5.\nOften imitated but never equaled,\nthe MP5 is perhaps the most versatile SMG in the world.",
    {Medic=true, Assault=true, Heavy=true, Survivor=true, Engineer=true, Demolition=true, Hatcher=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "UMP45",          "tacrp_ex_ump45",      1750, 3, "KM UMP45.\nA lighter and cheaper successor to the MP5.",
    {Medic=true, Assault=true, Heavy=true, Survivor=true, Hatcher=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "PP Bizon",       "tacrp_sd_bizon",    2000, 3, "PP-19 Bizon.\nOffers a high-capacity magazine that reloads quickly.",
    {Assault=true, Survivor=true, Heavy=true, Survivor=true, Cremator=true, Hatcher=true}, 10, -1, nil, nil, {Assault=2, Medic=2}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("SMG",        "P90",            "tacrp_p90",      2000, 3, "ES C90.\nA Belgian bullpup PDW with a magazine of 50 rounds.",
    {Assault=true, Survivor=true, Heavy=true, Survivor=true, Cremator=true, Hatcher=true}, 12, -1, nil, nil, {Survivor=5}, nil, {HORDE.DMG_BALLISTIC})

    HORDE:CreateItem("SMG",        "SMG1","tfa_projecthl2_smg"  ,2000, 3, "Combine standard-issue sub machine gun. \n\nEquipped with a grenade launcher.",
    {Assault=true, Survivor=true, Hatcher=true, Psycho=true}, 8, 10, nil, nil, {Assault=4, Demolition=5, Survivor=4}, nil, {HORDE.DMG_BALLISTIC})
	
    HORDE:CreateItem("SMG",        "Vector Medic PDW","tacrp_horde_healer_superv",3000, 4, "KRISS Vector Gen I equipped with a medical dart launcher.\nUses an unconventional blowback system that results in its high firerate.\n\nPress B or ZOOM to fire healing darts.\nHealing dart heals 12 health and has a 1.5 second cooldown.",
    {Medic=true, Hatcher=true}, 8, -1, nil, nil, {Medic=3}, nil, {HORDE.DMG_BALLISTIC, HORDE.DMG_POISON})

    HORDE:CreateItem("Shotgun",    "Pump-Action",    "arccw_horde_shotgun",100, 2, "A standard 12-gauge shotgun.",
    {Warden=true}, 6, -1, nil, "items/hl2/weapon_shotgun.png", nil, nil, {HORDE.DMG_BALLISTIC}, nil, {"Warden"})
    HORDE:CreateItem("Shotgun",    "Double Barrel Sawn-Off",  "arccw_horde_ur_dbsawn",    1250, 2, "Double Barrel Shotgun.\nDevastating power at close range.",
    {Survivor=true, Warden=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "Molot Bekas",           "tacrp_bekas",     2000, 4, "Accurate hunting shotgun.",
    {Assault=true, Heavy=true, Survivor=true, Engineer=true, Warden=true, Overlord=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
	HORDE:CreateItem("Shotgun",    "Tomahawk Matador",           "tacrp_tgs12",     1200, 2, "Short barrel shotgun.",
    {Assault=true, Heavy=true, Survivor=true, Engineer=true, Warden=true, Overlord=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "M870",           "arccw_ud_870",      2000, 4, "Remington 870 Shotgun.\nManufactured in the United States.",
    {Assault=true, Heavy=true, Survivor=true, Engineer=true, Warden=true, Overlord=true, SpecOps=true}, 10, -1, nil, nil, {Engineer=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "M1014",         "arccw_ud_m1014",    2500, 4, "Benelli M4 Super 90.\nFully automatic shotgun.",
    {Assault=true, Heavy=true, Survivor=true, Engineer=true, Warden=true, Overlord=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    --HORDE:CreateItem("Shotgun",    "Trench Gun",     "arccw_horde_trenchgun", 2250, 4, "Winchester Model 1200.\nShoots incendiary pellets.",
    --{Warden=true, Cremator=true}, 15, -1, nil, nil, {Warden=1, Cremator=1}, nil, {HORDE.DMG_FIRE}, {HORDE.Infusion_Quality, HORDE.Infusion_Impaling})
    HORDE:CreateItem("Shotgun",    "Double Barrel",  "arccw_ur_db",    2250, 4, "Double Barrel Shotgun.\nDevastating power at close range.",
    {Survivor=true, Warden=true, Overlord=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "SPAS-12",        "arccw_ur_spas12",  2500, 5, "Franchi SPAS-12.\nA combat shotgun manufactured by Italian firearms company Franchi.",
	{Survivor=true, Assault=true, Warden=true, Overlord=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "Saiga 12",  "tacrp_io_saiga",    2500, 4, "Saiga 12.\nDevastating power at close range.",
    {Warden=true, Overlord=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "Typhoon 12",  "tfa_ins2_typhoon12", 2500, 5, "Mag fed 12 gauge automatic shotgun.\nHas a circular mag.",
    {Survivor=true, Warden=true, Overlord=true}, 15, -1, nil, nil, {Warden=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "Jackhammer",  "tacrp_h_jackhammer", 2500, 5, "Bulky automatic shotgun.\nHas a circular mag.",
    {Survivor=true, Warden=true, Overlord=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "KS23",        "tacrp_ks23", 2500, 5, "Powerful shotgun made in the USSR.",
    {Warden=true, Overlord=true}, 15, -1, nil, nil, {Warden=5}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Shotgun",    "AA12",           "tfa_ins2_aa12",  3000, 6, "Atchisson Assault Shotgun.\nDevastating firepower at close to medium range.",
    {Warden=true, Overlord=true}, 20, -1, nil, nil, {Warden=7}, nil, {HORDE.DMG_BALLISTIC})


    HORDE:CreateItem("Rifle",      "Kar98K Varmint",          "tacrp_io_k98_varmint",    1000, 2, "KAR98K firing a weaker, lighter round. \nGhost starter weapon when Green rank and above.",
    {Ghost=true, Survivor=true}, 10, -1, nil, nil, {Ghost=5}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "AK12",          "tacrp_ak_ak12",    2500, 4, "AK12 assault rifle.",
    {Assault=true, Survivor=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "SG551",          "tacrp_sg551",    2500, 4, "SG551 assault rifle.",
    {Assault=true, Survivor=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "AK47",           "arccw_ur_ak",     3000, 5, "Avtomat Kalashnikova.\nA gas-operated, 7.62×39mm assault rifle developed in the Soviet Union.",
    {Assault=true, SpecOps=true}, 15, -1, nil, nil, {Assault=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "M16",           "arccw_ud_m16",       3000, 5, "Colt M16.\nA 5.56×45mm NATO, air-cooled, gas-operated, select fire carbine.",
    {Assault=true, SpecOps=true}, 15, -1, nil, nil, {Assault=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "AUG",            "tacrp_aug",      3000, 4, "Steyr AUG.\nAn Austrian bullpup assault rifle.",
    {Assault=true, SpecOps=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "SCAR-L",         "arccw_myt_uc_scar", 3500, 5, "FN SCAR-L.\nAn assault rifle developed by Belgian manufacturer FN Herstal.",
    {Assault=true,  Ghost=true, SpecOps=true}, 15, -1, nil, nil, {Assault=6, Ghost=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "OSIPR",          "tfa_projecthl2_ar2",   3500, 5, "Overwatch Standard Issue Pulse Rifle.\n\nPress your TFA Alt-fire key to shoot an energy ball. \nFires regular ballistic ammo or energy balls.",
    {Assault=true, SpecOps=true}, 15, -1, nil, "items/hl2/weapon_ar2.png", {Assault=6}, nil, {HORDE.DMG_BALLISTIC})

    HORDE:CreateItem("Rifle",      "Ruger Mini-14",         "tacrp_m1",     50, 1, "Ghost starter weapon.",
    {Ghost=true}, 15, -1, nil, nil, {Ghost=5}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "Nitro Rifle",         "tacrp_h_nitrorifle",     2500, 4, "Elephant double-barrel rifle.\nLot of damage. but little ammo.",
    {Ghost=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "M14",         "tacrp_io_m14",     2500, 4, "M14.\nA battle rifle made in the USA during the Cold War.",
    {Ghost=true, SpecOps=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "FN FAL (DSA58 SA58)",         "tacrp_eo_fal",     2500, 4, "FN FAL.\nA battle rifle designed by Belgian and manufactured by FN Herstal.",
    {Ghost=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "Winchester 1873",         "tacrp_eo_winchester",     2500, 4, "W1873.\nA lever action rifle made in the USA.",
    {Ghost=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "G3",             "arccw_ur_g3",      3000, 4, "G3 Battle Rifle.\nA 7.62×51mm NATO, select-fire battle rifle developed by H&K.",
    {Ghost=true, SpecOps=true}, 15, -1, nil, nil, {Ghost=4}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "AWP",            "arccw_ur_aw",     3000, 5, "Magnum Ghost Rifle.\nA series of sniper rifles manufactured by the United Kingdom.",
    {Ghost=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "M200",           "tacrp_h_intervention",    3250, 6, "CheyTec M200 Intervention.\nAmerican bolt-action sniper rifle.",
    {Ghost=true, SpecOps=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "SVD",           "tacrp_ak_svd",    2550, 5, "Semi-auto Russian sniper rifle.",
    {Ghost=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "Hecate",    "tacrp_ex_hecate",  3500, 7, "Bolt action .50 Rifle.",
    {Ghost=true}, 30, -1, nil, nil, {Ghost=5}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",      "AS50",    "tacrp_as50",  3500, 7, "AS50 Sniper Rifle.\nDoes huge amounts of ballistic damage.",
    {Ghost=true}, 30, -1, nil, nil, {Ghost=7}, nil, {HORDE.DMG_BALLISTIC})
    
	
    HORDE:CreateItem("Rifle",      "AK101",         "arccw_horde_ur_ak101",  3000, 4, "Modified Soviet assault rifle. \nUses 5.56x45mm NATO rounds.",
    {Cremator=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Rifle",      "AK74",         "arccw_horde_ur_ak74",  3000, 4, "Newer AK model that uses weaker rounds.",
    {Survivor=true, Assault=true, Cremator=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Rifle",      "Apollo",         "arccw_horde_apollo",  3000, 5, "Apollo incineration rifle.\nFires energy pellets that melt down enemies.",
    {Cremator=true}, 10, -1, nil, nil, {Cremator=5}, nil, {HORDE.DMG_FIRE})

    HORDE:CreateItem("Rifle",      "Magpul Masada",          "tacrp_eo_masada",    2500, 4, "Masada Rifle created by Remington.",
    {Medic=true, Hatcher=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    --HORDE:CreateItem("Rifle",    "ACR Medic AR",     "arccw_horde_medic_newrifle",    3000, 4, "Remington Adaptive Combat Rifle.\nEquipped with healing dart and medic grenade launcher.\n\nPress USE+RELOAD to equip medic grenade launcher.\nPress B or ZOOM to fire healing dart.\nHealing dart heals 15 health and has a 1.5 second cooldown.",
    --{Medic=true, Hatcher=true}, 10, 20, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Rifle",    "VSS Medic SR",   "tacrp_horde_io_vss",  3750,   5, "A medic DMR that shoots healing darts.\nDamages enemies and heals players.",
    {Medic=true, Hatcher=true}, 22, -1, nil, nil, {Medic=5}, nil, {HORDE.DMG_BALLISTIC})
	
    HORDE:CreateItem("Rifle",    "M16 M203",         "arccw_horde_ud_m16m203",2250,5, "M16A4 equipped with an M203 underbarrel grenade launcher.\nPress USE+RELOAD to equip M203.",
    {Assault=true, Demolition=true, SpecOps=true}, 10, 10, nil, nil, {Assault=4, Demolition=4}, nil, {HORDE.DMG_BALLISTIC, HORDE.DMG_BLAST})

    HORDE:CreateItem("MG",         "RPK",       "arccw_horde_ur_rpk", 2000, 4, "RPK.\nA light-support machine gun variant of the AKM assault rifle.",
    {Heavy=true, Survivor=true}, 25, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "Colt LMG",       "arccw_horde_ud_coltlmg", 2000, 4, "A light-support machine gun variant of the M16 rifle.",
    {Heavy=true, Survivor=true}, 25, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "M249",           "arccw_go_m249",  2500, 4, "M249 light machine gun.\nA gas operated and air-cooled weapon of destruction.",
    {Heavy=true, Survivor=true}, 40, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "PKM",          "tacrp_sd_pkm",      3000, 5, "Heavy machine gun from the USSR.",
    {Heavy=true}, 50, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "MG4",           "tacrp_mg4",      2500, 4, "Heckler & Koch MG4.\nA belt-fed 5.56 mm light machine gun that replaced MG3.",
    {Heavy=true}, 40, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "M240",          "tfa_at_m240_b",     3000, 5, "M240 Bravo.\nFires 7.62mm NATO ammunition.\nEquipped by U.S. Armed Forces.",
    {Heavy=true}, 50, -1, nil, nil, {Heavy=3}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "M60",          "arccw_m60",     3000, 5, "M60.\nFires 7.62mm NATO ammunition.\nUsed during the Vietnam War.",
    {Heavy=true}, 50, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("MG",         "M134 Minigun",         "arccw_minigun",     3500, 10, "GAU-19 rotary heavy machine gun.\nFires .50 BMG catridge at 1,300 rounds per minute.\n\nHold RMB to rev.",
    {Heavy=true}, 50, -1, nil, nil, {Heavy=9}, nil, {HORDE.DMG_BALLISTIC})

    -- Class specific grenades
    HORDE:CreateItem("Explosive",  "Frag Grenade",   "weapon_frag",                    100,  0, "A standard frag grenade.\nGood for crowd control.",
    {Survivor=true, Psycho=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST})
    HORDE:CreateItem("Explosive",  "Stun Grenade",   "arccw_horde_nade_stun",          100,  0, "A grenade that deals minor damage and stuns enemy for 3 seconds.\nStun cooldown is 10 seconds.",
    {Assault=true, SpecOps=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST})
    HORDE:CreateItem("Explosive",  "Shrapnel Grenade",   "arccw_horde_nade_shrapnel",  100,  0, "A grenade that explodes into shrapnels, dealing Ballistic damage in an area.",
    {Heavy=true, Juggernaut=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Explosive",  "Sonar Grenade",   "arccw_horde_nade_sonar",        100,  0, "A grenade that reveals and marks nearby enemies while active.\nMarked enemies take 15% more headshot damage.",
    {Ghost=true, Gunslinger=true}, 100, -1)
    HORDE:CreateItem("Explosive",  "M67 Frag Grenade",    "arccw_horde_m67",                100,  0, "M67 High Explosive Fragmentation Grenade.\nMilitary grade, does large amounts of Blast damage.",
    {Demolition=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST})
    HORDE:CreateItem("Explosive",  "Medic Grenade",  "arccw_nade_medic",               100,  0, "A grenade that releases contiuous bursts of detoxication clouds.\nHeals players and damages enemies.",
    {Medic=true, Hatcher=true}, 100, -1, nil, "items/arccw_nade_medic.png", nil,  nil, {HORDE.DMG_POISON})
    HORDE:CreateItem("Explosive",  "Nanobot Grenade",   "arccw_horde_nade_nanobot",    100,  0, "A grenade that releases streams of repair nanobots.\nHeals minions and players over time.\nHealing is more potent for minions.",
    {Engineer=true}, 100, -1)
    HORDE:CreateItem("Explosive",  "Hemo Grenade",   "arccw_horde_nade_hemo",          100,  0, "A grenade that deals Slashing damage in the area.\nIncreases Bleeding buildup.",
    {Berserker=true, Samurai=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Explosive",  "EMP Grenade",   "arccw_horde_nade_emp",  100,  0, "A grenade that deals rapid Lightning damage in the area.\nYou are safe from the EMP blast.",
    {Warden=true, Overlord=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Explosive",  "Molotov",   "arccw_horde_nade_molotov",            100,  0, "Generates a pool of fire on impact.\nSets everything on fire within its effect.",
    {Cremator=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Explosive",  "Smoke Grenade",   "tacrp_nade_smoke",  100,  0, "A grenade that creates smoke that conceals you and your teammates.",
    {Assault=true, Ghost=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_BALLISTIC})

    HORDE:CreateItem("Explosive",  "SLAM",           "horde_slam",          950,  2, "Selectable Lightweight Attack Munition.\nRMB to detonate. Attach to wall to active laser mode.\n\nAt most 4 SLAMs can be active at the same time.",
    {Demolition=true}, 20, 0, nil, "items/hl2/weapon_slam.png", nil, nil, {HORDE.DMG_BLAST})
    HORDE:CreateItem("Explosive",  "Resistance RPG", "weapon_rpg",         1500,  3, "Laser-guided rocket propulsion device.",
    {Demolition=true, Survivor=true}, 8, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "M320",  "tacrp_m320", 1500,  3, "Simple grenade launcher with a grip.",
    {Demolition=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    --HORDE:CreateItem("Explosive",  "Hopper Mine",  "horde_hopper_mine",  2000,  5, "Combine reactive mines that explode when enemies come in proximity.\nYou can plant at most 5 reactive mines.",
    --{Demolition=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    --HORDE:CreateItem("Explosive",  "Static Mine",  "horde_static_mine",  2000,  5, "Combine reactive mines that hovers in air.\nExplode when enemies come in proximity.\nYou can plant at most 5 reactive mines.",
    --{Demolition=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "M79 GL",         "arccw_ud_m79",    2000,  3, "M79 Grenade Launcher.\nShoots 40x46mm grenades the explodes on impact.",
    {Demolition=true, Survivor=true}, 10, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "Sticky Launcher",  "horde_sticky_launcher", 2500,  3, "Sticky grenade launcher.\nLaunches grenades that stick to surfaces and entities.\n\nRMB to detonate.",
    {Demolition=true}, 25, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "M32 GL",         "arccw_horde_m32",    3000,  5, "Milkor Multiple Grenade Launcher.\nA lightweight 40mm six-shot revolver grenade launcher.",
    {Demolition=true}, 25, -1, nil, nil, {Demolition=3}, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "China Lake",         "tacrp_io_chinalake",    3000,  5, "Rare pump-action grenade launcher holding 4 shots.",
    {Demolition=true}, 25, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "RPG-7",          "arccw_horde_rpg7",   3000,  5, "Ruchnoy Protivotankoviy Granatomyot.\nAnti-tank rocket launcher developed by Soviet Union.",
    {Demolition=true}, 15, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "XM25",         "tacrp_h_xm25",    3000,  5, "Bullpup grenade launcher with a Rangefinder.",
    {Demolition=true}, 25, -1, nil, nil, {Demolition=6}, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "SMAW",         "tacrp_h_smaw",    3000,  5, "Man portable bunker buster with slow rockets.",
    {Demolition=true}, 25, -1, nil, nil, {Demolition=6}, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "Stinger",         "tacrp_ex_stinger",    3250,  6, "Homing Anti-air missile launcher. Repurposed against land enemies.",
    {Demolition=true}, 25, -1, nil, nil, {Demolition=6}, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "M72 LAW",        "arccw_horde_law",   3250,  6, "M72 Light Anti-Armor Weapon.\nFocuses on raw destructive power instead of area of effect.",
    {Demolition=true}, 15, -1, nil, nil, {Demolition=4}, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    HORDE:CreateItem("Explosive",  "FGM-148 JAVELIN",        "arccw_horde_javelin",   3500,  6, "FGM-148 Javelin.\nFires guided shells that requires lock-on.",
    {Demolition=true}, 15, -1, nil, nil, {Demolition=5}, nil, {HORDE.DMG_BLAST}, {HORDE.Infusion_Quality})
    --HORDE:CreateItem("Explosive",  "Thermite",       "arccw_horde_nade_incendiary",   1500,   1, "Generates a pool of fire after some delay.\nSets everything on fire within its effect.",tacrp_ex_stinger
    --{Cremator=true}, 100, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})
    

    HORDE:CreateItem("Special",    "Welder",         "horde_welder",         100,  1, "Engineering welder.\nDamages enemies and heals minions.",
    {Engineer=true}, 50, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, nil, {"Engineer"})
    HORDE:CreateItem("Special",    "Builder",         "horde_engiwrench",         100,  1, "Engineering builder.\nSpawn turrets and damage enemies.",
    {Engineer=true}, 50, -1, nil, nil, nil, nil, {HORDE.DMG_BLAST}, nil, {"Engineer"})
    HORDE:CreateItem("Special",    "Manhack",        "npc_manhack",          900,  2, "Manhack that regenerates on death.\nManhack deals its health as damage to enemies.\nManhack dies on impact.",
    {Engineer=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=5}, "items/npc_manhack.png", nil, nil, {HORDE.DMG_SLASH})
    HORDE:CreateItem("Special",    "Vortigaunt",     "npc_vj_horde_vortigaunt",  1750,  3, "Xen Vortigaunts that can conjure concentrated shock energy blasts.\nThe energy blasts have long range and deal splash damage.",
    {Engineer=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=3}, "items/npc_vortigaunt.png", {Engineer=2}, nil, {HORDE.DMG_LIGHTNING})

    HORDE:CreateItem("Special",    "Hivehand",       "horde_hivehand",       2000,  3, "Organic weapon used by Xen soldiers.\nHas infinite ammo.\nPrimary fire generates homing ricocheting shots.\nSecondary fire rapidly unloads the entire weapon.",
    {Engineer=true}, 2, -1, nil, nil, {Engineer=4}, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Special",    "Spore Launcher", "horde_spore_launcher",2500,  3, "Improvised biological weapon.\nShoots out acidic projectiles that explodes after a short delay.\nHeals players and damages enemies.",
    {Medic=true, Survivor=true, Hatcher=true}, 40, -1, nil, nil, {Medic=3, Survivor=3}, nil, {HORDE.DMG_POISON})
    
    HORDE:CreateItem("Special",    "Watchtower",      "horde_watchtower",        800,  1, "A watchtower that provides resupply.\nGenerates 1 ammobox every 30 seconds.\n(Entity Class: horde_watchtower)",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=4}, "items/horde_watchtower.png")
    HORDE:CreateItem("Special",    "Watchtower MKII",  "horde_watchtower_mk2",  1000,  2, "A watchtower that provides resupply.\nGenerates 1 health vial every 30 seconds.\n(Entity Class: horde_watchtower_mk2)",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=4}, "items/horde_watchtower.png")
    HORDE:CreateItem("Special",    "Watchtower Type-Beacon",  "horde_watchtower_beacon", 1000,  3, "A watchtower that acts as a spawn point and shop.\nProvides additional lighting.\n(Entity Class: horde_watchtower_beacon)",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=1}, "items/horde_watchtower.png", nil, nil, nil)
    HORDE:CreateItem("Special",    "Watchtower MKIII", "horde_watchtower_mk3",   1500,  2, "A watchtower that deters enemies.\nShocks 1 nearby enemy every 1 second.\nDoes 100 Lightning damage.\n(Entity Class: horde_watchtower_mk3)",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=4}, "items/horde_watchtower.png", {Warden=4}, nil, {HORDE.DMG_LIGHTNING})
    HORDE:CreateItem("Special",    "Watchtower Type-Interceptor",  "horde_watchtower_interceptor",   2000,  2, "A watchtower that fires constant laser beams to nearby watchtowers.\nThe laser beam deals Fire damage.\n(Entity Class: horde_watchtower_interceptor)",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=4}, "items/horde_watchtower.png", {Warden=4}, nil, {HORDE.DMG_BLAST})
    HORDE:CreateItem("Special",    "Watchtower Type-Guardian",  "horde_watchtower_guardian", 2000,  2, "A watchtower that provides armor regeneration in an area.\nArmor regeneration does not stack with itself.\n(Entity Class: horde_watchtower_guardian)",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=4}, "items/horde_watchtower.png", {Warden=6}, nil, nil)
    HORDE:CreateItem("Special",    "Shock Roach",  "weapon_horde_shockroach", 2000,  1, "Biological living weapon that has infinite ammo.\nShoots streaks of lightning, along with a singular beam.",
    {Warden=true, Engineer=true}, -1, -1, nil, nil, nil, nil, {HORDE.DMG_LIGHTNING})
    
    HORDE:CreateItem("Special",    "Heat Crossbow",  "arccw_horde_heat_crossbow", 1750,  2, "Improvised sniper weapon.\nHas two firemodes (Ballistic/Impact).\n\nDeals 300% headshot damage.",
    {Survivor=true, Ghost=true}, 2, -1, nil, "items/hl2/weapon_crossbow.png", nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Special",    "Explosive Crossbow",  "weapon_crossbow", 1750,  2, "Improvised sniper explosive weapon.\nUsed for crowd control.",
    {Survivor=true, Ghost=true, Demolition=true}, 10, -1, nil, "items/hl2/weapon_crossbow.png", nil, nil, {HORDE.DMG_BALLISTIC})
    HORDE:CreateItem("Special",    "M2 Flamethrower", "horde_m2",            2500,  3, "M2-2 Flamethrower.\nAn American man-portable backpack flamethrower.",
    {Cremator=true}, 50, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Special",    "Tau Cannon",      "horde_tau",         3000,  4, "A device that uses electromagnetism to ionize particles.\nHold RMB to charge and release a powerful shot.\nDeals more damage as you charge.\nDevice explodes if you overcharge.",
    {Cremator=true}, 15, -1, nil, nil, {Cremator=8}, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Special",    "Gluon Gun", "horde_gluon",            3000,   4, "Quantum Destabilizer.\nAn experimental weapon that fires a devastating laser.",
    {Cremator=true}, 40, -1, nil, nil, {Cremator=10}, nil, {HORDE.DMG_FIRE})
    HORDE:CreateItem("Special",    "Heat Blaster",  "arccw_horde_heat_blaster", 3000,  3, "A projectile launcher that shoots flaming fireballs.\nSwitch firemodes to fire charged shots.",
    {Cremator=true}, 50, -1, nil, nil, nil, nil, {HORDE.DMG_FIRE})

    --[[HORDE:CreateItem("Special",    "Taser",           "arccw_go_taser",      1000,  1, "Taser.",
    {Engineer=true}, 50, -1)]]--

    HORDE:CreateItem("Special", "Void Projector", "horde_void_projector", 0, 11,
        [[Only usable by Necromancer subclass!
    Manipulates dark energy to inflict hypothermia and conjure entities.]],
        { Necromancer = true }, -1, -1, nil, nil, nil, nil, { HORDE.DMG_COLD, HORDE.DMG_PHYSICAL }, nil, { "Necromancer" },
        true)

    HORDE:CreateItem("Special", "Solar Seal", "horde_solar_seal", 0, 11,
        [[Only usable by Artificer subclass!
    Manipulates solar energy to wreak destruction.]],
        { Artificer = true }, -1, -1, nil, nil, nil, nil, { HORDE.DMG_FIRE, HORDE.DMG_LIGHTNING }, nil, { "Artificer" },
        true)

    HORDE:CreateItem("Special", "Astral Relic", "horde_astral_relic", 0, 11,
        [[Only usable by Warlock subclass!
    Manipulates negative energy fields.]],
        { Warlock = true }, -1, -1, nil, nil, nil, nil, { HORDE.DMG_PHYSICAL }, nil, { "Warlock" }, true)

    HORDE:CreateItem("Special", "Carcass Biosystem", "horde_carcass", 0, 13,
        [[Only usable by Carcass subclass!
    Advanced combat biosystem that completely screws up the appearance of its user.
    Leaves behind an unpleasant stench.

    LMB: Punch.
    Hold for a charged punch that deals increased damage in an area.]],
        { Carcass = true }, -1, -1, nil, nil, nil, nil, { HORDE.DMG_PHYSICAL }, nil, { "Carcass" }, true)

    HORDE:CreateItem("Special", "Pheropod", "horde_pheropod", 0, 0,
        [[Only usable by Hatcher subclass!
    Pheropods that can hatch and control alien Antlions.

    LMB: Throw Pod
    Throws a Pheropod at the target, forcing the Antlions to perform range attacks at the target.
    Pods can also heal Antlion for 5% health.

    RMB: Raise Antlion (40 Energy)
    Creates an Antlion that follows you around. Heal Antlion to accelerate evolution.
    HOLD RMB to force Antlions to your location.
    Antlion gains new effects each stage:
    - Stage I:
        - Bug Pulse: Every 5 seconds, generates a pulse that heals players nearby for 5% health.
    - Stage II:
        - Increased health and damage.
        - Increased Aroma Pulse radius and reduce Bug Pulse cooldown.
        - 50% increased Poison damage resistance.
    - Stage III:
        - Increased health, damage and attack speed.
        - Increased Aroma Pulse radius and reduce Bug Pulse cooldown.
        - Immune to Poison damage and Break.]],
        { Hatcher = true }, -1, -1, nil, nil, nil, nil, { HORDE.DMG_SLASH, HORDE.DMG_POISON }, nil, { "Hatcher" }, true)

    HORDE:CreateItem("Equipment", "Medkit", "weapon_horde_medkit", 0, 0,
        "Rechargeble medkit.\nRMB to self-heal, LMB to heal others.",
        nil, 10, -1, nil, "items/weapon_medkit.png", nil, nil, nil, nil, { "Survivor", "Psycho", "Assault", "SpecOps", "Medic", "Hatcher", "Heavy", "Carcass", "Demolition", "Warlock", "Ghost", "Gunslinger", "Engineer", "Necromancer", "Berserker", "Samurai", "Warden", "Overlord", "Cremator", "Artificer", "Juggernaut" })
    HORDE:CreateItem("Equipment", "Alternate Medkit", "tacrp_medkit", 0, 0,
        "Rechargeble medkit.\nRMB to self-heal, LMB to heal others.",
        nil, 10, -1, nil, "items/weapon_medkit.png", nil, nil, nil, nil, { "Survivor", "Psycho", "Assault", "SpecOps", "Medic", "Hatcher", "Heavy", "Carcass", "Demolition", "Warlock", "Ghost", "Gunslinger", "Engineer", "Necromancer", "Berserker", "Samurai", "Warden", "Overlord", "Cremator", "Artificer", "Juggernaut" })
    HORDE:CreateItem("Equipment", "Armorkit", "weapon_armorkit", 100, 0,
        "Rechargeble armorkit.\nRMB to self-heal, LMB to heal others.",
        nil, 10, -1, nil, "items/weapon_medkit.png", nil, nil, nil, nil, nil)
    HORDE:CreateItem("Equipment",  "Health Vial",    "item_healthvial",    15,   0, "A capsule filled with sticky green liquid.\nHeals instantly when picked up.",
    {Medic=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=5}, nil)
    HORDE:CreateItem("Equipment",  "HEV",    "aps_suit_hevv",    2000,   0, "Power suit that gives 50% resistance when powered with more than 50 battery. Will only give 20% resistance when below 50 battery.",
    nil, 10, -1, {type=HORDE.ENTITY_PROPERTY_DROP, x=50, z=15, yaw=0, limit=5}, nil)
    HORDE:CreateItem("Equipment", "Kevlar Armor Battery", "item_battery", 160, 0, "Armor battery.\nEach one provides 15 armor. Personal use only.",
    nil, 10, -1, {type=HORDE.ENTITY_PROPERTY_GIVE}, "items/armor_15.png")
    --HORDE:CreateItem("Equipment", "Full Kevlar Armor", "armor100", 1000, 0, "Full kevlar armor set.\nFills up 100% of your armor bar.",
    --nil, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_100.png")
    HORDE:CreateItem("Equipment", "Advanced Kevlar Armor", "armor_survivor", 1000, 0, "Distinguished Survivor armor.\n\nFills up 100% of your armor bar.\nProvides 5% increased damage resistance.",
    {Survivor=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_survivor.png", {Survivor=30}, 1)
    HORDE:CreateItem("Equipment", "Assault Vest", "armor_assault", 1000, 0, "Distinguished Assault armor.\n\nFills up 100% of your armor bar.\nProvides 8% increased Ballistic damage resistance.",
    {Assault=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_assault.png", {Assault=30}, 1)
    HORDE:CreateItem("Equipment", "Bulldozer Suit", "armor_heavy", 1000, 0, "Distinguished Heavy armor.\n\nFills up 125% of your armor bar.",
    {Heavy=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=125}, "items/armor_heavy.png", {Heavy=30}, 1)
    HORDE:CreateItem("Equipment", "Hazmat Suit", "armor_medic", 1000, 0, "Distinguished Medic armor.\n\nFills up 100% of your armor bar.\nProvides 8% increased Poison damage resistance.",
    {Medic=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_medic.png", {Medic=30}, 1)
    HORDE:CreateItem("Equipment", "Bomb Suit", "armor_demolition", 1000, 0, "Distinguished Demolition armor.\n\nFills up 100% of your armor bar.\nProvides 8% increased Blast damage resistance.",
    {Demolition=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_demolition.png", {Demolition=30}, 1)
    HORDE:CreateItem("Equipment", "Assassin's Cloak", "armor_ghost", 1000, 0, "Distinguished Ghost armor.\n\nFills up 100% of your armor bar.\nProvides 5% increased evasion.",
    {Ghost=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_ghost.png", {Ghost=30}, 1)
    HORDE:CreateItem("Equipment", "Defense Matrix", "armor_engineer", 1000, 0, "Distinguished Engineer armor.\n\nFills up 100% of your armor bar.\nProvides 5% increased damage resistance.",
    {Engineer=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_engineer.png", {Engineer=30}, 1)
    HORDE:CreateItem("Equipment", "Riot Armor", "armor_warden", 1000, 0, "Distinguished Warden armor.\n\nFills up 100% of your armor bar.\nProvides 8% increased Shock and Sonic damage resistance.",
    {Warden=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_warden.png", {Warden=30}, 1)
    HORDE:CreateItem("Equipment", "Molten Armor", "armor_cremator", 1000, 0, "Distinguished Cremator armor.\n\nFills up 100% of your armor bar.\nProvides 8% increased Fire damage resistance.",
    {Cremator=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_cremator.png", {Cremator=30}, 1)
    HORDE:CreateItem("Equipment", "Battle Vest", "armor_berserker", 1000, 0, "Distinguished Berserker armor.\n\nFills up 100% of your armor bar.\nProvides 8% increased Slashing/Blunt damage resistance.",
    {Berserker=true}, 10, -1, {type=HORDE.ENTITY_PROPERTY_ARMOR, armor=100}, "items/armor_berserker.png", {Berserker=30}, 1)
    

    HORDE:GetDefaultGadgets()
    HORDE:GetDefaultItemInfusions()

    if ArcCWInstalled == true and GetConVar("horde_arccw_attinv_free"):GetInt() == 0 then
        print("[HORDE] ArcCW detected. Loading attachments into shop.")
        HORDE.GetArcCWAttachments()
    end

    print("[HORDE] - Loaded default item config.")
end

HORDE.GetArcCWAttachments = function ()
end

function HORDE:IsWatchTower(ent)
    return ent:IsValid() and ent.Horde_WatchTower
end

-- Startup
if SERVER then
    util.AddNetworkString("Horde_SetItemsData")

    if GetConVar("horde_external_lua_config"):GetString() and GetConVar("horde_external_lua_config"):GetString() ~= "" then
    else
        if GetConVarNumber("horde_default_item_config") == 0 then
            GetItemsData()
        else
            HORDE:GetDefaultItemsData()
            GetStarterWeapons()
            HORDE:SyncItems()
        end
    end


    net.Receive("Horde_SetItemsData", function (len, ply)
        if not ply:IsSuperAdmin() then return end
        local items_len = net.ReadUInt(32)
        local data = net.ReadData(items_len)
        local str = util.Decompress(data)
        HORDE.items = util.JSONToTable(str)
        HORDE.InvalidateHordeItemCache = 1
        HORDE:SetItemsData()
    end)
end

if SERVER then
    util.AddNetworkString("Horde_SetUpgrades")
end

if CLIENT then
    net.Receive("Horde_SetUpgrades", function(len, ply)
        local class = net.ReadString()
        local level = net.ReadUInt(8)
        MySelf:Horde_SetUpgrade(class, level)
    end)
end

local plymeta = FindMetaTable("Player")

function plymeta:Horde_GetUpgrade(class)
    if not self.Horde_Upgrades then self.Horde_Upgrades = {} end
    return self.Horde_Upgrades[class] or 0
end

function plymeta:Horde_SetUpgrade(class, level)
    if not self.Horde_Upgrades then self.Horde_Upgrades = {} end
    if SERVER then
        net.Start("Horde_SetUpgrades")
            net.WriteString(class)
            net.WriteUInt(level, 8)
        net.Send(self)
    end
    self.Horde_Upgrades[class] = level
end
