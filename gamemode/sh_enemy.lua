-- Enemies
HORDE.enemies = {}
HORDE.bosses = {}
HORDE.enemies_normalized = {}
HORDE.bosses_normalized = {}

-- Creates a Horde enemy.
function HORDE:CreateEnemy(name, class, weight, wave, is_elite, health_scale, damage_scale, reward_scale, model_scale, color, weapon, spawn_limit, boss_properties, mutation, skin, model, spawn_min, gadget_drop)
    if name == nil or class == nil or wave == nil or wave <= 0 or name == "" or class == "" then return end
    local enemy = {}
    enemy.name = name
    enemy.class = class
    enemy.weight = math.max(0,weight)
    enemy.wave = math.max(1,wave)
    enemy.health_scale = health_scale and health_scale or 1
    enemy.damage_scale = damage_scale and damage_scale or 1
    enemy.reward_scale = reward_scale and reward_scale or 1
    enemy.model_scale = model_scale and model_scale or 1
    enemy.color = color
    enemy.weapon = weapon
    enemy.spawn_limit = spawn_limit or 0
    enemy.is_elite = is_elite and is_elite or 0
    enemy.boss_properties = boss_properties and boss_properties or {}
    enemy.spawn_min = spawn_min or 0
    -- Prevent infinite rounds
    if enemy.boss_properties then
        if enemy.boss_properties.unlimited_enemies_spawn and (not enemy.boss_properties.end_wave) then
            enemy.boss_properties.end_wave = true
        end
    end
    enemy.mutation = mutation or nil
    if skin and skin ~= "" then
        enemy.skin = skin
    end
    enemy.gadget_drop = gadget_drop or nil
    if model and model ~= "" then enemy.model = model end

    HORDE.enemies[name .. tostring(enemy.wave)] = enemy
end

function HORDE:NormalizeEnemiesWeightOnWave(enemies)
    local total_weight = 0
    for name, weight in pairs(enemies) do
        total_weight = total_weight + weight
    end
    for name, weight in pairs(enemies) do
        enemies[name] = weight / total_weight
    end
end

function HORDE:GetForcedEnemiesOnWave(enemies, enemy_wave, total_enemies)
    local forced = {}
    for name, _ in pairs(enemies) do
        local enemy = HORDE.enemies[name .. tostring(enemy_wave)]
        if enemy.spawn_min and enemy.spawn_min > 0 then
            forced[name] = {}
            for i = 1, enemy.spawn_min do
                table.insert(forced[name], math.random(1, total_enemies))
            end
        end
    end
    return forced
end

function HORDE:NormalizeEnemiesWeight()
    if table.IsEmpty(HORDE.enemies) then return end

    for _, enemy in pairs(HORDE.enemies) do
        if enemy.boss_properties and enemy.boss_properties.is_boss and enemy.boss_properties.is_boss == true then
            if not HORDE.bosses[enemy.wave] then HORDE.bosses[enemy.wave] = {} end
            HORDE.bosses[enemy.name .. enemy.wave] = enemy
        end
    end

    for wave = 1, HORDE.max_max_waves do
        HORDE.enemies_normalized[wave] = {}
        local total_weight = 0
        for _, enemy in pairs(HORDE.enemies) do
            if enemy.boss_properties and enemy.boss_properties.is_boss and enemy.boss_properties.is_boss == true then
                goto cont
            end
            if enemy.wave == wave then
                total_weight = total_weight + enemy.weight
            end
            ::cont::
        end
        for _, enemy in pairs(HORDE.enemies) do
            if enemy.boss_properties and enemy.boss_properties.is_boss and enemy.boss_properties.is_boss == true then
                goto cont
            end
            if enemy.wave == wave then
                -- For some reason lua table key does not support nested tables lmao
                HORDE.enemies_normalized[wave][enemy.name] = enemy.weight / total_weight
            end
            ::cont::
        end
    end

    for wave = 1, HORDE.max_max_waves do
        HORDE.bosses_normalized[wave] = {}
        local total_weight = 0
        for _, enemy in pairs(HORDE.bosses) do
            if enemy.wave == wave then
                total_weight = total_weight + enemy.weight
            end
        end
        for _, enemy in pairs(HORDE.bosses) do
            if enemy.wave == wave then
                HORDE.bosses_normalized[wave][enemy.name] = enemy.weight / total_weight
            end
        end
    end

end

HORDE.InvalidateHordeEnemyCache = 1
HORDE.CachedHordeEnemies = nil
HORDE.GetCachedHordeEnemies = function()
    if HORDE.InvalidateHordeEnemyCache == 1 then
        local tab = util.TableToJSON(HORDE.enemies)
        local str = util.Compress(tab)
        HORDE.CachedHordeEnemies = str
        HORDE.InvalidateHordeEnemyCache = 0
    end
    return HORDE.CachedHordeEnemies
end

function HORDE:SyncEnemiesTo(ply)
    local str = HORDE.GetCachedHordeEnemies()
    net.Start("Horde_SyncEnemies")
        net.WriteUInt(string.len(str), 32)
        net.WriteData(str, string.len(str))
    net.Send(ply)
end

function HORDE:SyncMutationsTo(ply)
    net.Start("Horde_SyncMutations")
        -- Send the client simplified mutations
        local muts = {}
        for mut_name, mut in pairs(HORDE.mutations) do
            muts[mut_name] = mut.Description
        end
        net.WriteTable(muts)
    net.Send(ply)
end

function HORDE:SetEnemiesData()
    if SERVER then
        HORDE:NormalizeEnemiesWeight()

        if GetConVarNumber("horde_default_enemy_config") == 1 then return end
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
        end

        file.Write("horde/enemies.txt", util.TableToJSON(HORDE.enemies))
    end
end

local function GetEnemiesData()
    if SERVER then
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
            return
        end

        if file.Read("horde/enemies.txt", "DATA") then
            local t = util.JSONToTable(file.Read("horde/enemies.txt", "DATA"))
            -- Integrity
            for _, enemy in pairs(t) do
                if enemy.name == nil or enemy.name == "" or enemy.class == nil or enemy.class == "" or enemy.weight == nil or enemy.wave == nil then
                    HORDE:SendNotification("Enemy config file validation failed! Please update your file or delete it.", 0)
                    return
                else
                    if not enemy.weapon then
                        enemy.weapon = ""
                    end
                end
            end

            -- Be careful of backwards compataiblity
            HORDE.enemies = t
            HORDE:NormalizeEnemiesWeight()

            print("[HORDE] - Loaded custom enemy config.")
        end
    end
end

function HORDE:GetDefaultEnemiesData ()
    -- name, class, weight, wave, elite, health_scale, damage_scale, reward_scale, model_scale, color
    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  1, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  1, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  1, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.75,  1, true, 1, 1, 1, 1)
																					  --elite, hs, ds, rs, ms
    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  2, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  2, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  2, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	0.75,  2, false, 1, 1, 1, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  2, false, 0.75, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.75,  2, true, 1, 1, 1, 1)

	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  3, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	0.75,  3, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  3, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  3, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Wraith", "npc_vj_horde_wraith",                  	0.30,  3, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  3, false, 0.75, 1, 1, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.75,  3, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.75,  3, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.50,  3, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)

    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  4, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Cyst", "npc_vj_horde_cyst",                  	0.30,  4, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	0.75,  4, false, 1, 1, 1, 1)
   	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  4, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  4, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Wraith", "npc_vj_horde_wraith",                  	0.30,  4, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  4, false, 0.75, 1, 1, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 1.00,  4, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Healer", "npc_vj_horde_healer",                      0.60,  4, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.75,  4, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.50,  4, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.50,  4, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)

    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  5, false, 1, 1, 1, 1) --if boss minions spawn!!
	HORDE:CreateEnemy("Cyst", "npc_vj_horde_cyst",                  	0.05,  5, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	0.75,  5, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  5, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  5, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  5, false, 0.75, 1, 1, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.10,  5, false, 1, 1.1, 1, 1)
    	HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.60,  5, false, 1, 1.1, 1, 1)
	HORDE:CreateEnemy("Healer", "npc_vj_horde_healer",                      0.20,  5, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.75,  5, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.25,  5, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.25,  5, true, 1, 1, 1, 1)
	
    	HORDE:CreateEnemy("Scylla",  "npc_vj_horde_scylla",       1, 5, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=1.0, nil, nil}, nil, nil, nil, nil, {gadget="horde_drop_iridescent", drop_rate=1})
	
    	HORDE:CreateEnemy("Executioner","npc_vj_horde_executioner",    1, 5, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.0, nil, nil}, nil, nil, nil, nil, {gadget="horde_drop_axe", drop_rate=1})
	
    	HORDE:CreateEnemy("Virulent","npc_vj_horde_virulent",    1, 5, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.25, nil, nil}, nil, nil, nil, nil, {gadget="horde_drop_hellfire", drop_rate=1})
	
    --HORDE:CreateEnemy("Platoon Generalist",  "npc_vj_horde_platoon_generalist",    1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    --{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.5, nil, nil})
	
    --HORDE:CreateEnemy("Platoon Generalist",  "npc_drg_horde_platoon_generalist",    1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    --{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.0, music="sound/ocpack/tobehereremix.mp3", music_duration=SoundDuration("ocpack/tobehereremix.mp3")})
	
    --HORDE:CreateEnemy("Behemoth","npc_vj_horde_behemoth",    1, 5, true,  1, 1, 10, 1, nil, nil, nil,
    --{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.35, nil, nil})
	
    /*HORDE:CreateEnemy("Platoon Heavy",  "npc_drg_horde_platoon_heavy",    1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.0, music="sound/ocpack/tobehereremix.mp3", music_duration=SoundDuration("ocpack/tobehereremix.mp3")})
	
    HORDE:CreateEnemy("Platoon Demo",  "npc_drg_horde_platoon_demolitionist",    1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.0, music="sound/ocpack/tobehereremix.mp3", music_duration=SoundDuration("ocpack/tobehereremix.mp3")})*/
	
    	HORDE:CreateEnemy("Xen Host Unit","npc_vj_horde_xen_host_unit", 1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.5, nil, nil}, "none", nil, nil, nil, {gadget="horde_drop_iridescent", drop_rate=1})

    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  6, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Cyst", "npc_vj_horde_cyst",                  	0.3,  6, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	0.75,  6, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  6, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  6, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Wraith", "npc_vj_horde_wraith",                  	0.3,  6, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  6, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.5,  6, false, 1, 1, 1.1, 1)
    	HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.75,  6, false, 1, 1, 1.1, 1, nil,nil,nil,nil,nil,nil,nil,1)
    --HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.50,  6, false, 1, 1, 1.1, 1, nil,nil,nil,nil,nil,nil,nil,1)
	HORDE:CreateEnemy("Healer", "npc_vj_horde_healer",                      0.8,  6, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  1.00,  6, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.75,  6, true, 1, 1, 1.25, 1)
    	--HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.75,  6, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.75,  6, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Gonome",      "npc_vj_gonome_remake",                0.75,  6, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Weeper","npc_vj_horde_weeper",                       0.30,  6, true, 1, 1, 1.5, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.20,  6, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)

    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  7, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Cyst", "npc_vj_horde_cyst",                  	0.4,  7, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	1.00,  7, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  7, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  7, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Wraith", "npc_vj_horde_wraith",                  	0.4,  7, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  7, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.5,  7, false, 1, 1, 1.1, 1)
    	HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.6,  7, false, 1, 1, 1.1, 1)
    --HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.45,  7, false, 1, 1, 1.1, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Plague Soldier", "npc_vj_horde_plague_soldier",      0.1,  7, false, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
	HORDE:CreateEnemy("Healer", "npc_vj_horde_healer",                      0.8,  7, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.75,  7, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Blight", "npc_vj_horde_blight",                      0.1,  7, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.5,  7, true, 1, 1, 1.25, 1)
    --HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.5,  7, true, 1, 1, 1.25, 1)
   	HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.5,  7, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Gonome",      "npc_vj_gonome_remake",                0.3,  7, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Weeper","npc_vj_horde_weeper",                       0.3,  7, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.1,  7, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Lesion", "npc_vj_horde_lesion",                      0.06,  7, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
	HORDE:CreateEnemy("Peacekeeper", "npc_vj_horde_peacekeeper",            0.05,  7, true, 1, 1, 1.5, 1)

    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  8, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Cyst", "npc_vj_horde_cyst",                  	0.4,  8, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	1.00,  8, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  8, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  8, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Wraith", "npc_vj_horde_wraith",                  	0.4,  8, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.5,  8, false, 1, 1, 1.1, 1)
    	HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.5,  8, false, 1, 1, 1.1, 1)
    --HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.4,  8, false, 1, 1, 1.1, 1)
    	HORDE:CreateEnemy("Plague Soldier", "npc_vj_horde_plague_soldier",      0.1,  8, false, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Healer", "npc_vj_horde_healer",                      0.8,  8, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.6,  8, true, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Blight", "npc_vj_horde_blight",                      0.1,  8, true, 1, 1, 1.5, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.75,  8, true, 1, 1, 1.25, 1)
    --HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.5,  8, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.5,  8, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Plague Sniper", "npc_vj_horde_plague_sniper",      	0.1,  8, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Traducer", "npc_vj_traducer",      			0.06,  8, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Deterrent", "npc_vj_deterrent",      		0.06,  8, false, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Weeper","npc_vj_horde_weeper",                       0.3,  8, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.1,  8, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    --HORDE:CreateEnemy("Yeti",   "npc_vj_horde_yeti",                        0.1,  8, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Lesion", "npc_vj_horde_lesion",                      0.06,  8, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
	HORDE:CreateEnemy("Sieger", "npc_vj_horde_sieger",                  	0.05,  8, false, 1, 1, 1.5, 1)
	HORDE:CreateEnemy("Peacekeeper", "npc_vj_horde_peacekeeper",            0.05,  8, true, 1, 1, 1.5, 1)
	HORDE:CreateEnemy("Dynamic Duo", "npc_vj_horde_dynamicduo",             0.05,  8, true, 1, 1, 1.5, 1)
	HORDE:CreateEnemy("Pariah", "npc_vj_horde_pariah",            		0.05,  8, true, 1, 1, 1.5, 1)
	
--function HORDE:CreateEnemy(name, class, weight, wave, is_elite, health_scale, damage_scale, reward_scale, model_scale, color, weapon, spawn_limit, boss_properties, mutation, skin, model, spawn_min, gadget_drop)
    	HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  9, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Cyst", "npc_vj_horde_cyst",                  	0.4,  9, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Scragg", "npc_vj_horde_scragg",                  	1.00,  9, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  1.00,  9, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 1.00,  9, false, 1, 1, 1, 1)
	HORDE:CreateEnemy("Wraith", "npc_vj_horde_wraith",                  	0.4,  9, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.5,  9, false, 1, 1, 1.1, 1)
    	HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.1,  9, false, 1, 1, 1.1, 1)
    --HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.4,  9, false, 1, 1, 1.1, 1)
    	HORDE:CreateEnemy("Plague Soldier", "npc_vj_horde_plague_soldier",      0.1,  9, false, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Healer", "npc_vj_horde_healer",                      0.8,  9, false, 1, 1, 1, 1)
    	HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.6,  9, true, 1, 1, 1, 1)
	HORDE:CreateEnemy("Plague Sniper", "npc_vj_horde_plague_sniper",      	0.1,  9, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Blight", "npc_vj_horde_blight",                      0.1,  9, true, 1, 1, 1.5, 1)
    	HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.75,  9, true, 1, 1, 1.25, 1)
    --HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.5,  9, true, 1, 1, 1.25, 1)
    	HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.5,  9, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Traducer", "npc_vj_traducer",      			0.06,  9, true, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Deterrent", "npc_vj_deterrent",      		0.06,  9, false, 1, 1, 1.25, 1)
	HORDE:CreateEnemy("Gonome Armored", "npc_vj_gonomearmor",         	0.2,  9, true, 1, 1, 1.25, 1, nil,nil,nil,nil,"decay",nil,nil)
    	HORDE:CreateEnemy("Weeper","npc_vj_horde_weeper",                       0.3,  9, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.1,  9, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    --HORDE:CreateEnemy("Yeti",   "npc_vj_horde_yeti",                        0.1,  9, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Lesion", "npc_vj_horde_lesion",                      0.06,  9, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    	HORDE:CreateEnemy("Plague Elite", "npc_vj_horde_plague_elite",          0.045,  9, true, 1, 1, 1.5, 1, nil,nil,nil,nil,nil,nil,nil,1)
	HORDE:CreateEnemy("Sieger", "npc_vj_horde_sieger",                  	0.05,  9, false, 1, 1, 1.5, 1)
	HORDE:CreateEnemy("Dynamic Duo", "npc_vj_horde_dynamicduo",             0.025,  9, true, 1, 1, 1.5, 1)
	HORDE:CreateEnemy("Peacekeeper", "npc_vj_horde_peacekeeper",            0.05,  9, true, 1, 1, 1.5, 1)
	HORDE:CreateEnemy("Pariah", "npc_vj_horde_pariah",            		0.05,  9, true, 1, 1, 1.5, 1)

    	HORDE:CreateEnemy("zombie poison",    "npc_poisonzombie",        1,  10, false, 1, 1, 1, 1, nil)
	
    	HORDE:CreateEnemy("Bulldozer",     "npc_vj_horde_bulldozer",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0, nil, nil})
    	HORDE:CreateEnemy("Rekindled Behemoth",     "npc_vj_horde_rekindled_behemoth",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0, nil, nil})
    	HORDE:CreateEnemy("Super Zombie",     "npc_vj_zombiesuper",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0, nil, nil})
    	HORDE:CreateEnemy("Psychic Unit",     "npc_vj_horde_xen_psychic_unit",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0, nil, nil})
    	--HORDE:CreateEnemy("Duo Boss",     "npc_vj_horde_duoboss",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    	--{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0, nil, nil})
    	--HORDE:CreateEnemy("Plague Platoon",  "npc_vj_horde_plague_platoon2",    1, 10, true, 1, 1, 10, 1, nil, nil, nil,
    	--{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.0, nil, nil})
    	HORDE:CreateEnemy("Devastator",     "npc_drg_horde_devastator",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0, music="ocpack/music/sanguescuro.mp3", music_duration=234})
    	HORDE:CreateEnemy("Gamma Gonome",  "npc_vj_horde_gamma_gonome",    1, 10, true, 1, 1, 10, 1, nil, nil, nil,
    	{is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.0, nil, nil})
    
    	HORDE:NormalizeEnemiesWeight()

    print("[HORDE] - Loaded default enemy config.")
end

-- Startup
if SERVER then
    util.AddNetworkString("Horde_SetEnemiesData")

    if GetConVar("horde_external_lua_config"):GetString() and GetConVar("horde_external_lua_config"):GetString() ~= "" then
    else
        if GetConVarNumber("horde_default_enemy_config") == 1 then
            HORDE:GetDefaultEnemiesData()
        else
            GetEnemiesData()
        end
    end

    net.Receive("Horde_SetEnemiesData", function (len, ply)
        if not ply:IsSuperAdmin() then return end
        local enemies_len = net.ReadUInt(32)
        local data = net.ReadData(enemies_len)
        local str = util.Decompress(data)
        HORDE.enemies = util.JSONToTable(str)
        HORDE.InvalidateHordeEnemyCache = 1
        HORDE:SetEnemiesData()
    end)
end
