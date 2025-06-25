util.AddNetworkString("Horde_HighlightEntities")
util.AddNetworkString("Horde_DeathMarkHighlight")
util.AddNetworkString("Horde_HunterMarkHighlight")
util.AddNetworkString("Horde_RemoveDeathMarkHighlight")
util.AddNetworkString("Horde_RemoveHunterMarkHighlight")
util.AddNetworkString("Horde_MarkRemainingEnemies")
util.AddNetworkString("Horde_GameEnd")
if SERVER then
util.AddNetworkString("Horde_BossMusicNet")
end

local horde_players_count = 0
local horde_spawned_ammoboxes = {}
local horde_ammobox_refresh_timer = HORDE.ammobox_refresh_interval / 2
local horde_in_break = nil
local horde_perk_progress = 1
local horde_current_enemies_list = {}
local horde_force_spawn_enemies = {}

HORDE.horde_boss = nil
HORDE.horde_boss_name = nil
HORDE.finished_objs = 0
HORDE.max_objs = 0
local horde_boss_spawned = false
local horde_boss_reposition = false
local horde_boss_properties = nil
local boss_music_loop = nil
local boss_music_boolean = false

HORDE.BreakTimerUpdate = 0
HORDE.DirectorIntervalUpdate = 0

-- These are for horde default bosses only,
local horde_boss_critical = nil

HORDE.horde_active_holdzones = nil
local horde_has_escapezone = nil

local entmeta = FindMetaTable("Entity")
function entmeta:Horde_SetMostRecentAttacker(attacker)
	self.most_recent_attacker = attacker
end

function entmeta:Horde_GetMostRecentAttacker()
	return self.most_recent_attacker
end

function entmeta:Horde_SetName(name)
    self.horde_name = name
end

function entmeta:Horde_GetName()
    return self.horde_name
end

function entmeta:Horde_SetBossProperties(boss_properties)
    self.horde_boss_properties = boss_properties
end

function entmeta:Horde_GetBossProperties()
    return self.horde_boss_properties
end

function entmeta:Horde_SetElite()
    self.Horde_Elite = true
end

function entmeta:Horde_IsElite()
    return self.Horde_Elite
end

hook.Add("InitPostEntity", "Horde_Init", function()
    HORDE.ai_nodes = {}
    local horde_nodes = {}
    for _, node in pairs(ents.FindByClass("info_horde_enemy_spawn")) do -- Only include nodes that are enabled
        if not node.Disabled then
            table.insert(horde_nodes, node)
        end
    end
    local horde_boss_nodes = {}
    for _, node in pairs(ents.FindByClass("info_horde_boss_spawn")) do
        if not node.Disabled then
            table.insert(horde_boss_nodes, node)
        end
    end
    HORDE.spawned_enemies = {}
    HORDE.found_ai_nodes = false
    HORDE.found_horde_nodes = false
    if not table.IsEmpty(horde_nodes) then
        for _, node in pairs(horde_nodes) do
            local new_node = {}
            new_node["pos"] = node:GetPos()
            table.insert(HORDE.ai_nodes, new_node)
        end
        HORDE.found_horde_nodes = true
        HORDE.found_ai_nodes = true
    else
        ParseFile()
    end

    if not table.IsEmpty(horde_boss_nodes) then
        HORDE.boss_spawns = {}
        for _, node in pairs(horde_boss_nodes) do
            table.insert(HORDE.boss_spawns, node:GetPos())
        end
    end

    HORDE.ammobox_nodes = {}
    local ammobox_nodes = ents.FindByClass("info_horde_ammobox_spawn")
    if not table.IsEmpty(ammobox_nodes) then
        for _, node in pairs(ammobox_nodes) do
            table.insert(HORDE.ammobox_nodes, node:GetPos())
        end
    end

    HORDE.has_buy_zone = not table.IsEmpty(ents.FindByClass("trigger_horde_buyzone"))

    -- Check spawn distribution
    HORDE.spawn_distribution = HORDE.SPAWN_PROXIMITY
    if not table.IsEmpty(ents.FindByClass("info_horde_spawn_distribution_uniform")) then
        HORDE.spawn_distribution = HORDE.SPAWN_UNIFORM
    elseif not table.IsEmpty(ents.FindByClass("info_horde_spawn_distribution_proximity_noisy")) then
        HORDE.spawn_distribution = HORDE.SPAWN_PROXIMITY_NOISY
    end

    -- Load economy
    for _, ent in pairs(ents.FindByClass("logic_horde_economy")) do
        ent:KeyValue("startingmoney", ent:GetInternalVariable("startingmoney"))
        ent:KeyValue("killrewardbase", ent:GetInternalVariable("killrewardbase"))
        ent:KeyValue("roundbonusbase", ent:GetInternalVariable("roundbonusbase"))
    end

    HORDE:LoadObjectives()
end)

hook.Add("EntityKeyValue", "Horde_EntityKeyValue", function(ent)
    if HORDE.found_horde_nodes then return end
    if ent:GetClass() == "info_player_teamspawn" then
        local valid = true
        for k,v in pairs(HORDE.ai_nodes) do
            if v["pos"] and v["pos"] == ent:GetPos() then
                valid = false
            end
        end

        if valid then
            local node = {
                pos = ent:GetPos(),
                yaw = 0,
                offset = 0,
                type = 0,
                info = 0,
                zone = 0,
                neighbor = {},
                numneighbors = 0,
                link = {},
                numlinks = 0
            }
            table.insert(HORDE.ai_nodes, node)
        end
    end
end)

function HORDE:OnEnemyKilled(victim, killer, weapon)
    if IsValid(victim) and victim:IsNPC() and not victim:GetVar("horde_killed") then
        victim:SetVar("horde_killed", true)
        if IsValid(killer) and killer:IsPlayer() then
            hook.Run("Horde_OnEnemyKilled", victim, killer, weapon)
        end
		local boss_properties = victim:Horde_GetBossProperties()
        if victim.Horde_Gadget_On_Death then
			--if boss_properties then
				--local bossdrop = ents.Create(Horde_Gadget_On_Death)
				--bossdrop
				--bossdrop:SetPos(victim:GetPos())
				--bossdrop:Spawn()
			--return end
            local gadget_box = ents.Create("horde_gadgetbox")
			if boss_properties then
				gadget_box.BossGadget = true
			end
            gadget_box.Horde_Gadget = victim.Horde_Gadget_On_Death
            gadget_box:SetPos(victim:GetPos())
            gadget_box:Spawn()
        end
    end
    if HORDE.spawned_enemies[victim:EntIndex()] then
        HORDE.spawned_enemies[victim:EntIndex()] = nil
        if (not HORDE.horde_boss) or (HORDE.horde_boss and (not horde_boss_properties.unlimited_enemies_spawn)) then
            HORDE.alive_enemies_this_wave = HORDE.alive_enemies_this_wave - 1
            --if (not HORDE.horde_has_active_objective) or (HORDE.killed_enemies_this_wave <= math.min(100, HORDE.total_enemies_this_wave_fixed * 0.5)) then --(not HORDE.horde_has_active_objective) or 
                HORDE.killed_enemies_this_wave = HORDE.killed_enemies_this_wave + 1
            else
                HORDE.total_enemies_this_wave = HORDE.total_enemies_this_wave + 1
            --end
           -- So the wave ends immediately after cooking the last enemy
            if HORDE.total_enemies_this_wave <= 0 and HORDE.alive_enemies_this_wave <= 0 then
                --HORDE.DirectorIntervalUpdate = CurTime() + 1
				timer.Adjust("Horde_Main", 1, nil, nil)
            end
        end

        --if (HORDE.total_enemies_this_wave_fixed - HORDE.killed_enemies_this_wave) <= 20 then
            --net.Start("Horde_HighlightEntities")
            --net.WriteUInt(HORDE.render_highlight_enemies, 3)
            --net.Broadcast()
        --end

        if not HORDE.horde_has_active_objective then
            if HORDE.endless == 1 then
                if HORDE.horde_boss and HORDE.horde_boss:IsValid() and HORDE.horde_boss:Health() > 0 then
                    HORDE:BroadcastEnemiesCountMessage(true, tostring(HORDE.current_wave) .. " / ∞", 0)
                else
                    HORDE:BroadcastEnemiesCountMessage(false, tostring(HORDE.current_wave) .. " / ∞", HORDE.total_enemies_this_wave_fixed - HORDE.killed_enemies_this_wave)
                end
            else
                if HORDE.horde_boss and HORDE.horde_boss:IsValid() and HORDE.horde_boss:Health() > 0 then
                    HORDE:BroadcastEnemiesCountMessage(true, tostring(HORDE.current_wave) .. " / " .. tostring(HORDE.max_waves), 0)
                else
                    HORDE:BroadcastEnemiesCountMessage(false, tostring(HORDE.current_wave) .. " / " .. tostring(HORDE.max_waves), HORDE.total_enemies_this_wave_fixed - HORDE.killed_enemies_this_wave)
                end
            end
        end
		
        local boss_properties = victim:Horde_GetBossProperties()
        local defer_reward = false
        local reward = 0
        if killer:IsValid() and killer:IsPlayer() or killer:GetNWEntity("HordeOwner"):IsPlayer() then
            if IsValid(killer) and killer:GetNWEntity("HordeOwner"):IsPlayer() then killer = killer:GetNWEntity("HordeOwner") end
            local scale = 1
            if victim:GetVar("reward_scale") then
                scale = victim:GetVar("reward_scale")
            end

            reward = HORDE.kill_reward_base * scale
            hook.Run("Horde_OnGivePlayerReward", killer, reward)
            if boss_properties and boss_properties.is_boss then
                -- Boss reward is global. Defer reward.
                defer_reward = true
            end
            if not defer_reward then
                if IsValid(victim.Horde_Assist) and victim.Horde_Assist ~= killer then
                    victim.Horde_Assist:Horde_AddMoney(reward * 0.1)
                    victim.Horde_Assist:Horde_SyncEconomy()
                    killer:Horde_AddMoney(reward * 0.9)
                else
                    killer:Horde_AddMoney(reward)
					--print( "onThink has been called" )
                end
            end

            if victim:Horde_IsElite() then
                if not HORDE.player_elite_kills[killer:SteamID()] then HORDE.player_elite_kills[killer:SteamID()] = 0 end
                HORDE.player_elite_kills[killer:SteamID()] = HORDE.player_elite_kills[killer:SteamID()] + 1
            end

            killer:AddFrags(1)
            killer:Horde_SyncEconomy()
        end

        -- When a boss is killed.
        if boss_properties then
            -- There could only be 1 boss.
            HORDE.horde_boss = nil
            horde_boss_properties = nil
            if boss_properties.end_wave and boss_properties.end_wave == true then
                if HORDE.current_wave == HORDE.max_waves and HORDE.has_escape_zones then
                    -- Activate escape zone
                    local zones = HORDE:GetEscapeZones()
                    HORDE.horde_active_escapezones = zones
                    for id, zone in pairs(zones) do
                        zone.Horde_Activated = true
                    end
                    HORDE:StartObjective(HORDE.OBJECTIVE_ESCAPE, {zones=zones})
                    HORDE.horde_has_active_objective = true
                else
                    HORDE:WaveEnd()
					hook.Run("HordeWaveEnd", HORDE.current_wave)
                end
            end

            -- Boss reward is global.
            for _, ply in pairs(player.GetAll()) do
                ply:Horde_AddMoney(reward)
                ply:Horde_SyncEconomy()
            end
        end

        victim:Horde_SetMostRecentAttacker(nil)
    end



    --if HORDE.total_enemies_this_wave <= 0 and HORDE.alive_enemies_this_wave <= 0 then
        --HORDE:WaveEnd()
        --hook.Run("HordeWaveEnd", HORDE.current_wave)
    --end
end

hook.Add("OnNPCKilled", "Horde_EnemyKilled", function(victim, killer, weapon)
    HORDE:OnEnemyKilled(victim, killer, weapon)
	--print( "onThink has been called" )
end)

-- Corpse settings
if GetConVar("horde_corpse_cleanup"):GetInt() == 1 then
	RunConsoleCommand("g_ragdoll_maxcount", "0")
    hook.Add("OnEntityCreated", "Horde_CorpseRemoval", function(ent)
        if ent:IsRagdoll() then
            timer.Simple(0, function ()
                if ent:IsValid() then
                    ent:Horde_SetMostRecentAttacker(nil)
                    ent:Remove()
                end
            end)
        end
    end)
else
    RunConsoleCommand("g_ragdoll_maxcount", "20") -- default value
end

-- Record statistics
hook.Add("PostEntityTakeDamage", "Horde_PostDamage", function (ent, dmg, took)
    if took then
        if ent:IsNPC() or ent:IsNextBot() then
            if dmg:GetAttacker():IsPlayer() then
                local id = dmg:GetAttacker():SteamID()
                if not HORDE.player_damage[id] then HORDE.player_damage[id] = 0 end
                HORDE.player_damage[id] = HORDE.player_damage[id] + dmg:GetDamage()
                ent:Horde_SetMostRecentAttacker(dmg:GetAttacker())
                if GetConVar("horde_testing_display_damage"):GetInt() == 1 then
                    local dmgtype = HORDE:GetDamageType(dmg)
                        if dmgtype == HORDE.DMG_PURE then
                            HORDE:SendNotification("You dealt " .. dmg:GetDamage() .. " damage to " .. ent:GetClass(), 0, dmg:GetAttacker())
                        else
                            HORDE:SendNotification("You dealt " .. dmg:GetDamage() .. " " .. HORDE.DMG_TYPE_STRING[dmgtype] .. " damage to " .. ent:GetClass(), 0, dmg:GetAttacker())
                        end
                end

                local boss_properties = ent:Horde_GetBossProperties()
                if boss_properties and boss_properties.is_boss and boss_properties.is_boss == true then
                    net.Start("Horde_SyncBossHealth")
                    net.WriteInt(ent:Health(), 32)
                    net.Broadcast()

                    -- Some special music for horde default boss.
                    if GetConVar("horde_default_enemy_config"):GetInt() == 1 and HORDE.horde_boss and HORDE.horde_boss:IsValid() and boss_music_loop and not horde_boss_critical and ent.Critical then
                        timer.Remove("Horde_BossMusic")
                        boss_music_loop:Stop()
                        local fierce_music = {"music/hl1_song10.mp3", "music/hl2_song4.mp3", "music/hl2_song25_teleporter.mp3"}
                        local fierce_music_duration = {103, 65, 43}
                        local selected_id = math.random(#fierce_music)
                        boss_music_loop = CreateSound(game.GetWorld(), fierce_music[selected_id])
                        boss_music_loop:SetSoundLevel(0)
                        timer.Create("Horde_BossMusic", fierce_music_duration[selected_id], 0, function()
                            boss_music_loop:Stop()
                            boss_music_loop:Play()
                        end)
                        boss_music_loop:Play()
                        horde_boss_critical = true
                    end
                end
            end
            --if ent:Health() <= 0 then ent:Remove() return end
        elseif ent:IsPlayer() and (dmg:GetAttacker():IsNPC() or dmg:GetAttacker():IsNextBot()) then
            local id = ent:SteamID()
            if not HORDE.player_damage_taken[id] then HORDE.player_damage_taken[id] = 0 end
            HORDE.player_damage_taken[id] = HORDE.player_damage_taken[id] + dmg:GetDamage()
            if GetConVar("horde_testing_display_damage"):GetInt() == 1 then
                local dmgtype = HORDE:GetDamageType(dmg)
                if dmgtype == HORDE.DMG_PURE then
                    HORDE:SendNotification("You received " .. dmg:GetDamage() .. " damage from " .. dmg:GetAttacker():GetClass(), 0, ent)
                else
                    HORDE:SendNotification("You received " .. dmg:GetDamage() .. " " .. HORDE.DMG_TYPE_STRING[dmgtype] ..  " damage from " .. dmg:GetAttacker():GetClass(), 0, ent)
                end
            end
        end
    end
end)

hook.Add("ScaleNPCDamage", "Horde_HeadshotCounter", function (npc, hitgroup, dmg)
    if npc:IsValid() and dmg:GetAttacker():IsPlayer() and hitgroup == HITGROUP_HEAD then
        local id = dmg:GetAttacker():SteamID()
        if not HORDE.player_headshots[id] then HORDE.player_headshots[id] = 0 end
        HORDE.player_headshots[id] = HORDE.player_headshots[id] + 1
    end
end)

hook.Add("EntityRemoved", "Horde_EntityRemoved", function(ent)
    if (ent:IsNPC() or ent:IsNextBot()) and ent:Horde_GetMostRecentAttacker() then
        HORDE:OnEnemyKilled(ent, ent:Horde_GetMostRecentAttacker())
    else
        if HORDE.spawned_enemies[ent:EntIndex()] then
            HORDE.spawned_enemies[ent:EntIndex()] = nil
            HORDE.alive_enemies_this_wave = HORDE.alive_enemies_this_wave - 1
            HORDE.total_enemies_this_wave = HORDE.total_enemies_this_wave + 1
            local count = HORDE.spawned_enemies_count[ent:Horde_GetName()]
            if count and count > 0 then
                HORDE.spawned_enemies_count[ent:Horde_GetName()] = count - 1
            end
            if ent.Horde_Forced_Spawn_Flag then
                local name = ent.Horde_Forced_Spawn_Flag
                table.insert(horde_force_spawn_enemies[name], math.random(1, HORDE.total_enemies_this_wave_fixed))
            end
        end
    end
end)

-- This resets the director.
function HORDE:HardResetDirector()
    HORDE.start_game = false
    HORDE.killed_enemies_this_wave = 0
    HORDE.total_enemies_this_wave = 0
    HORDE.alive_enemies_this_wave = 0
    HORDE.current_wave = 0
    HORDE.current_break_time = HORDE.total_break_time
    horde_in_break = nil
    horde_boss_spawned = false
    HORDE.horde_boss = nil
    horde_boss_properties = nil
    horde_boss_reposition = false
    HORDE.horde_boss_name = nil
    if boss_music_boolean == true && boss_music_loop then
		timer.Remove("Horde_BossMusic")
		HordeBossMusic(boss_music_loop, true)
        boss_music_boolean = false
		boss_music_loop = nil
    end
    net.Start("Horde_SyncGameInfo")
        net.WriteUInt(HORDE.current_wave, 16)
    net.Broadcast()
end

-- This resets the enemies.
function HORDE:HardResetEnemies()
    local enemies = HORDE:ScanEnemies()
    if not table.IsEmpty(enemies) then
        for _, enemy in pairs(enemies) do
            enemy:Horde_SetMostRecentAttacker(nil)
            enemy:Remove()
        end
    end
    HORDE.spawned_enemies_count = {}
end

local mins = Vector( -30, -30, 0 )
local maxs = Vector( 30, 30, 80 )
local heightOffset = Vector( 0, 0, 5 )

local function isSuitableSpawn( vec )
    if not util.IsInWorld( vec ) then return false end

    local trace = util.TraceHull( {
        start = vec + heightOffset,
        endpos = vec + heightOffset,
        mins = mins,
        maxs = maxs,
        mask = MASK_NPCSOLID,
    } )

    if trace.Hit then
        debugoverlay.Box( vec + heightOffset, mins, maxs, 1, Color( 255, 0, 0, 0 ) )
        debugoverlay.Text( vec, tostring( trace.Entity ), 1, false )
        return false
    end

    local line1 = vec + heightOffset
    local line2 = vec + Vector( 0, 0, -65 )
    local groundTrace = util.TraceLine( {
        start = line1,
        endpos = line2,
    } )

    if not groundTrace.Hit then
        debugoverlay.Line( line1, line2, 1, Color( 255, 0, 0 ), true )
        debugoverlay.Text( vec, "No ground", 1, false )
        return false
    end

    debugoverlay.Box( vec, mins, maxs, 1, Color( 0, 255, 0, 0 ) )
    return true
end

-- Spawns a Horde enemy at the give position.
-- The enemy is tracked by Horde.
HORDE.NPCS = list.Get("NPC")
function HORDE:SpawnEnemy(enemy, pos)
    local npc_info = HORDE.NPCS[enemy.class]
    if not npc_info then
        HORDE:SendNotification("NPC " .. enemy.class .. " does not exist.", 1)
    end

    local spawned_enemy = ents.Create(enemy.class)
    spawned_enemy:SetPos(pos)
    spawned_enemy:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
    timer.Simple(0, function() spawned_enemy:SetAngles(Angle(0, math.random(0, 360), 0)) end)
    spawned_enemy:Spawn()

    HORDE.spawned_enemies[spawned_enemy:EntIndex()] = true
    spawned_enemy:Horde_SetName(enemy.name)

    if npc_info["Model"] then
        spawned_enemy:SetModel(npc_info["Model"])
    end

    if npc_info["SpawnFlags"] then
        -- We need to cleanup corpses otherwise it's going to be a mess
        spawned_enemy:SetKeyValue("spawnflags", bit.bor(npc_info["SpawnFlags"], SF_NPC_FADE_CORPSE))
    end

    if npc_info["KeyValues"] then
        for k, v in pairs(npc_info["KeyValues"]) do
            spawned_enemy:SetKeyValue(k, v)
        end
    end

    spawned_enemy:Fire("StartPatrolling")
    spawned_enemy:Fire("SetReadinessHigh")
    if spawned_enemy:IsNPC() then
        spawned_enemy:SetNPCState(NPC_STATE_COMBAT)
    end

    if enemy.model_scale and enemy.model_scale ~= 1 then
        timer.Simple(0, function()
            if not spawned_enemy:IsValid() then return end
            local scale = spawned_enemy:GetModelScale() * enemy.model_scale
            if not scale or scale == 0 or scale < 0.5 or scale > 10 then
                scale = 1
            end
            if scale ~= spawned_enemy:GetModelScale() then
                spawned_enemy:SetModelScale(scale)
            end
        end)
    end
	
	
	/*local pos = spawned_enemy:GetPos()
	local medictf2 = ents.FindInSphere(pos, 300)
	local nearest = nil 
	local nearestDist = 500000
	timer.Create( "groupup" .. spawned_enemy:EntIndex(), 0, 0, function() if IsValid(spawned_enemy) && IsValid(spawned_enemy:GetEnemy()) then
		if (enemy.is_elite and enemy.is_elite == true) or (enemy.boss_properties and enemy.boss_properties.is_boss == true) then return end
		local medictf2 = ents.FindInSphere(pos, 300)
        for _, ent in pairs(medictf2) do
			local dist = ent:GetPos():DistToSqr(spawned_enemy:GetPos())
            if IsValid(ent) && ent:IsNPC() && ent:Disposition(spawned_enemy) != D_HI && ent:GetPos():Distance(spawned_enemy:GetPos()) <= 2500 then
				local dist = ent:GetPos():DistToSqr(spawned_enemy:GetPos())
                nearest = ent
                nearestDist = dist
			end
			if nearest then
				local hello = nearest
				local grouptr = util.TraceLine( {
					start = hello:GetPos(),
					endpos = hello:GetPos() + hello:GetRight()*math.random(-30,30) + hello:GetForward()*math.random(-30,30),
					filter = Entity( 1 )
				} )
				if grouptr.HitWorld == false then
				spawned_enemy:SetPos(hello:GetPos() + hello:GetRight()*math.random(-30,30) + hello:GetForward()*math.random(-30,30))
				end
			end
		end
	end end )*/

    if enemy.boss_properties and enemy.boss_properties.is_boss == true then
        spawned_enemy:Horde_SetBossProperties(enemy.boss_properties)
    end

    -- Health settings
    if enemy.is_elite and enemy.is_elite == true then
        spawned_enemy:Horde_SetElite()
        local scale
        local add
        if enemy.boss_properties and enemy.boss_properties.is_boss == true then
            scale = horde_players_count
            add = 0.75
        else
            scale = math.min(8, horde_players_count)
            add = 0.60
            if scale > 4 then
                add = 0.55
            end
        end
        spawned_enemy:SetMaxHealth(spawned_enemy:GetMaxHealth() * math.max(HORDE.Difficulty[HORDE.CurrentDifficulty].eliteHealthScaleMultiplier, scale * HORDE.Difficulty[HORDE.CurrentDifficulty].eliteHealthScaleMultiplier * (add + HORDE.Difficulty[HORDE.CurrentDifficulty].eliteHealthScaleAdd)))
    end

    if enemy.health_scale then
        spawned_enemy:SetMaxHealth(spawned_enemy:GetMaxHealth() * enemy.health_scale)
    end

    if HORDE.endless == 1 then
        spawned_enemy:SetMaxHealth(spawned_enemy:GetMaxHealth() * HORDE.endless_health_multiplier)
    end

    spawned_enemy:SetMaxHealth(spawned_enemy:GetMaxHealth() * HORDE.Difficulty[HORDE.CurrentDifficulty].healthMultiplier)

    spawned_enemy:SetHealth(spawned_enemy:GetMaxHealth())

    if enemy.reward_scale then
        spawned_enemy:SetVar("reward_scale", enemy.reward_scale)
    end

    if enemy.damage_scale then
        spawned_enemy:SetVar("damage_scale", enemy.damage_scale)
    end

    if enemy.color then
        spawned_enemy:SetColor(enemy.color)
        spawned_enemy:SetRenderMode(RENDERMODE_TRANSCOLOR)
    end

    if enemy.weapon then
        if enemy.weapon == "" or enemy.weapon == "_gmod_none" then
            -- Do nothing
        elseif enemy.weapon == "_gmod_default" then
            local wpns = npc_info["Weapons"]
            if wpns then
                local wpn = wpns[math.random(#wpns)]
                spawned_enemy:Give(wpn)
            end
        else
            spawned_enemy:Give(enemy.weapon)
        end
    end

    if enemy.skin then
        spawned_enemy:SetSkin(enemy.skin)
    end

    if enemy.model then
        spawned_enemy:SetModel(enemy.model)
    end

    if enemy.gadget_drop then
        local gadget = enemy.gadget_drop.gadget
        local drop_rate = enemy.gadget_drop.drop_rate
        if drop_rate and gadget and drop_rate > 0 then--and HORDE.items[gadget]
            local p = math.random()
            if p <= drop_rate then
                spawned_enemy.Horde_Gadget_On_Death = gadget
            end
        end
    end

    spawned_enemy:SetLagCompensated(true)

    -- Mutation
    if enemy.mutation and enemy.mutation ~= "" then
        timer.Simple(0.1, function() spawned_enemy:Horde_SetMutation(enemy.mutation) end)
    else
        local mut_prob = 0
        if enemy.is_elite and enemy.is_elite == true then
            if enemy.boss_properties and enemy.boss_properties.is_boss == true then
                if HORDE.CurrentDifficulty >= 2 then
                    mut_prob = 1.0
                else
                    mut_prob = 0
                end
            else
                mut_prob = HORDE.Difficulty[HORDE.CurrentDifficulty].eliteMutationProbability
            end
        else
            mut_prob = HORDE.Difficulty[HORDE.CurrentDifficulty].mutationProbability
        end

        if mut_prob > 0 then
            local p = math.random()
            if p <= mut_prob then
                local mut = HORDE.current_mutations[math.random(1, #HORDE.current_mutations)]
                timer.Simple(0.1, function()
                    if !IsValid(spawned_enemy) then return end
                    spawned_enemy:Horde_SetMutation(mut)
                end)
            end

            if HORDE.CurrentDifficulty >= 4 then
                p = math.random()
                if p <= HORDE.Difficulty[HORDE.CurrentDifficulty].mutationProbability then
                    local mut = HORDE.current_mutations[math.random(1, #HORDE.current_mutations)]
                    timer.Simple(0.2, function() spawned_enemy:Horde_SetMutation(mut) end)
                end
            end
        end
    end

    spawned_enemy.Horde_Debuff_Threshold = math.min(500, math.max(50, spawned_enemy:GetMaxHealth() * 0.2))

    hook.Run("HordeEnemySpawn", spawned_enemy)
    return spawned_enemy
end

-- Scan for Horde enemies.
function HORDE:ScanEnemies()
    local enemies = {}
    for ent_idx, _ in pairs(HORDE.spawned_enemies) do
        if not IsValid(Entity(ent_idx)) then
            HORDE.spawned_enemies[ent_idx] = nil
        else
            table.insert(enemies, Entity(ent_idx))
        end
    end
    return enemies
end

-- Removes enemies that are too far away from players.
function HORDE:RemoveDistantEnemies(enemies)
    if HORDE.found_horde_nodes then return end
    for _, enemy in pairs(enemies) do
        local boss_properties = enemy:Horde_GetBossProperties()
        local closest = 99999
        local closest_z = 99999
        local closest_ply = nil
        local enemy_pos = enemy:GetPos()

        for _, ply in pairs(player.GetAll()) do
            if ply:Alive() then
                local dist = enemy_pos:Distance(ply:GetPos())
                local z_dist = math.abs(ply:GetPos().z - enemy_pos.z)

                if dist < closest then
                    closest_ply = ply
                    closest = dist
                end
                if z_dist < closest_z then
                    closest_z = z_dist
                end
            end
        end

        if closest > HORDE.max_spawn_distance or (closest_z > GetConVarNumber("horde_max_spawn_z_distance")) then
            -- Do not remove bosses, change their positions instead.
            if boss_properties and boss_properties.is_boss and boss_properties.is_boss == true then
                horde_boss_reposition = true
            else
                table.RemoveByValue(enemies, enemy)
                if enemy:IsValid() then
                    enemy:Horde_SetMostRecentAttacker(nil)
                    enemy:Remove()
                end
            end
        else
            if enemy:IsValid() and enemy:IsNPC() then
                enemy:SetLastPosition(closest_ply:GetPos())
                enemy:SetTarget(closest_ply)
            end
        end
    end
end

local maxZDistanceCvar = GetConVar( "horde_max_spawn_z_distance" )
function HORDE:GetValidNodes( enemies )
    local valid_nodes = {}

    if HORDE.spawn_distribution == HORDE.SPAWN_UNIFORM then
        for _, node in pairs( HORDE.ai_nodes ) do
            table.insert( valid_nodes, node["pos"] )
        end
        return valid_nodes
    end

    local spawnPoints = {}
    for _, node in pairs( HORDE.ai_nodes ) do
        local vec = node["pos"]
        for _ = 1, math.random( 3, 5 ) do
            local r2 = 75 * math.sqrt( math.random() )
            local theta2 = 2 * math.pi * math.random()
            local x2 = r2 * math.cos( theta2 )
            local y2 = r2 * math.sin( theta2 )

            local point = vec + Vector( x2, y2, 0 )
            table.insert( spawnPoints, point )
        end
    end

    for _, nodePos in ipairs( spawnPoints ) do
        local valid = false
        for _, ply in pairs( player.GetAll() ) do
            if ply:Alive() then
                local dist = nodePos:Distance( ply:GetPos() )
                local z_dist = math.abs( nodePos.z - ply:GetPos().z )

                if dist <= HORDE.min_spawn_distance then
                    valid = false
                    break
                elseif dist < HORDE.max_spawn_distance then
                    valid = true
                end

                if z_dist > maxZDistanceCvar:GetInt() then
                    valid = false
                end
            end
        end

        if not valid then
            continue
        end

        for _, enemy in pairs( enemies ) do
            local dist = nodePos:Distance( enemy:GetPos() )
            if dist <= HORDE.spawn_radius then
                continue
            end
        end

        if not isSuitableSpawn( nodePos ) then
            continue
        end

        table.insert( valid_nodes, nodePos )
    end

    return valid_nodes
end

-- Add/remove ai/boss nodes.
-- Can be compressed, but I left it at that for the sake of clarity.
function HORDE:AddAINode(pos)
	local new_node = {}
	new_node["pos"] = pos
	for i, node in pairs(HORDE.ai_nodes) do -- Making sure that duplicate nodes are not being added
		if node["pos"] == pos then return end
	end
	table.insert(HORDE.ai_nodes, new_node)
end

function HORDE:RemoveAINode(pos)
	for i, node in pairs(HORDE.ai_nodes) do
		if node["pos"] == pos then
			table.remove(HORDE.ai_nodes, i)
		end
	end
end

function HORDE:AddBossNode(pos)
	for i, node in pairs(HORDE.boss_spawns) do
		if node == pos then return end
	end
	table.insert(HORDE.boss_spawns, pos)
end

function HORDE:RemoveBossNode(pos)
	for i, node in pairs(HORDE.boss_spawns) do
		if node == pos then
			table.remove(HORDE.boss_spawns, i)
		end
	end
end

-- Loops over valid nodes and spawn enemies.
-- Boss should not be spawned in this function.
function HORDE:SpawnEnemies(enemies, valid_nodes)
    for i = 0, math.random(HORDE.min_base_enemy_spawns_per_think + HORDE.Difficulty[HORDE.CurrentDifficulty].additionalPack + math.floor(horde_players_count/2), HORDE.max_base_enemy_spawns_per_think + HORDE.Difficulty[HORDE.CurrentDifficulty].additionalPack + horde_players_count) do
        if (#enemies + 1 <= HORDE.max_enemies_alive) and (HORDE.total_enemies_this_wave > 0) then
            local pos = table.Random(valid_nodes)
            if pos ~= nil then
                table.RemoveByValue(valid_nodes, pos)
                local z = pos.z
                pos = pos + VectorRand() * 5
                pos.z = z
                local p = math.random()
                local p_cum = 0
                local spawned_enemy
                local enemy_wave = ((HORDE.current_wave - 1) % HORDE.max_max_waves) + 1

                -- This in fact should not happen
                if table.IsEmpty(horde_current_enemies_list) then
                    HORDE:SendNotification("Current enemy list is empty!", 1)
                    return
                end

                -- Check if we need to force spawn
                local renormalize = nil
                for name, orders in pairs(horde_force_spawn_enemies) do
                    for idx, order in pairs(orders) do
                        if HORDE.total_enemies_this_wave < order then
                            horde_force_spawn_enemies[name][idx] = nil
                            -- Spawn
                            local enemy = HORDE.enemies[name .. tostring(enemy_wave)]
                            if enemy.spawn_limit and enemy.spawn_limit > 0 then
                                -- Do not spawn if exceeds spawn limit
                                local count = HORDE.spawned_enemies_count[name]
                                if count and count >= enemy.spawn_limit then
                                    renormalize = true
                                    horde_current_enemies_list[name] = nil
                                    goto cont3
                                else
                                    spawned_enemy = HORDE:SpawnEnemy(enemy, pos + Vector(0,0,HORDE.enemy_spawn_z))
                                    table.insert(enemies, spawned_enemy)
                                    spawned_enemy.Horde_Forced_Spawn_Flag = name
                                    if count then
                                        HORDE.spawned_enemies_count[name] = count + 1
                                    else
                                        HORDE.spawned_enemies_count[name] = 1
                                    end
                                    goto cont2
                                end
                            else
                                spawned_enemy = HORDE:SpawnEnemy(enemy, pos + Vector(0,0,HORDE.enemy_spawn_z))
                                table.insert(enemies, spawned_enemy)
                                spawned_enemy.Horde_Forced_Spawn_Flag = name
                                goto cont2
                            end
                        end
                    end
                    ::cont3::
                end

                for name, weight in pairs(horde_current_enemies_list) do
                    p_cum = p_cum + weight
                    if p <= p_cum then
                        local enemy = HORDE.enemies[name .. tostring(enemy_wave)]
                        if enemy.spawn_limit and enemy.spawn_limit > 0 then
                            -- Do not spawn if exceeds spawn limit
                            local count = HORDE.spawned_enemies_count[name]
                            if count and count >= enemy.spawn_limit then
                                renormalize = true
                                horde_current_enemies_list[name] = nil
                                goto cont
                            else
                                spawned_enemy = HORDE:SpawnEnemy(enemy, pos + Vector(0,0,HORDE.enemy_spawn_z))
                                table.insert(enemies, spawned_enemy)
                                if count then
                                    HORDE.spawned_enemies_count[name] = count + 1
                                else
                                    HORDE.spawned_enemies_count[name] = 1
                                end
                            end
                        else
                            spawned_enemy = HORDE:SpawnEnemy(enemy, pos + Vector(0,0,HORDE.enemy_spawn_z))
                            table.insert(enemies, spawned_enemy)
                        end

                        break
                    end
                    ::cont::
                end

                ::cont2::

                if renormalize then
                    HORDE:NormalizeEnemiesWeightOnWave(horde_current_enemies_list)
                end

                HORDE.total_enemies_this_wave = HORDE.total_enemies_this_wave - 1
                HORDE.alive_enemies_this_wave = HORDE.alive_enemies_this_wave + 1
            end
        else
            break
        end
    end
end

function HordeBossMusic(music, endmusic)
	if GetConVar("horde_enable_music"):GetInt() != 1 then return end
	net.Start("Horde_BossMusicNet")
	net.WriteString(music)--enemy.boss_properties.music)
	net.WriteBool(endmusic)
	net.Broadcast()
end

-- Spawns a Horde boss. Boss is unique.
function HORDE:SpawnBoss(enemies, valid_nodes)
    if (HORDE.horde_boss_name) and (#enemies + 1 <= HORDE.max_enemies_alive) and (not HORDE.horde_boss) and (HORDE.total_enemies_this_wave > 0) then
        -- Boss is unique
        local pos = table.Random(valid_nodes)
        if not pos then return end
        table.RemoveByValue(valid_nodes, pos)
        local spawned_enemy
        local enemy_wave = ((HORDE.current_wave - 1) % HORDE.max_max_waves) + 1

        local enemy = HORDE.bosses[HORDE.horde_boss_name .. tostring(enemy_wave)]
		boss_music_loop = enemy.boss_properties.music --keeps the filelocation of the music
		boss_music_boolean = true
        enemy.is_elite = true
        spawned_enemy = HORDE:SpawnEnemy(enemy, pos + Vector(0,0,HORDE.enemy_spawn_z))
        spawned_enemy:SetVar("is_boss", true)
        HORDE.horde_boss = spawned_enemy
        horde_boss_reposition = false
        table.insert(enemies, spawned_enemy)

        net.Start("Horde_SyncBossSpawned")
        net.WriteString(enemy.name)
        net.WriteInt(spawned_enemy:GetMaxHealth(),32)
        net.WriteInt(spawned_enemy:Health(),32)
        net.Broadcast()
		if enemy.boss_properties.music then
			--boss_music_loop = enemy.boss_properties.music
			HordeBossMusic(enemy.boss_properties.music)
            if enemy.boss_properties.music_duration and enemy.boss_properties.music_duration > 0 then
				timer.Create("Horde_BossMusic", enemy.boss_properties.music_duration, 0, function()
				HordeBossMusic(enemy.boss_properties.music)
				end)
			end
		end

        net.Start("Horde_HighlightEntities")
        net.WriteUInt(HORDE.render_highlight_enemies, 3)
        net.Broadcast()

        timer.Simple(5, function()
            net.Start("Horde_HighlightEntities")
            net.WriteUInt(HORDE.render_highlight_disable, 3)
            net.Broadcast()
        end)

        HORDE.total_enemies_this_wave = HORDE.total_enemies_this_wave - 1
        HORDE.alive_enemies_this_wave = HORDE.alive_enemies_this_wave + 1
    end
end

function HORDE:RepositionBoss(valid_nodes)
    if (not HORDE.horde_boss) or (not horde_boss_spawned) then return end
    local pos = table.Random(valid_nodes)
    if not pos then return end
    HORDE.horde_boss:SetPos(pos)
end

function HORDE:CheckBossStuck()
    if (not HORDE.horde_boss) or (not horde_boss_spawned) then return end
    local pos = HORDE.horde_boss:GetPos()
    local tr = util.TraceHull({
        start = pos,
        endpos = pos,
        filter = HORDE.horde_boss,
        mins = HORDE.horde_boss:OBBMins(),
        maxs = HORDE.horde_boss:OBBMaxs(),
    })
    if tr.Hit then
        local ent = tr.Entity
        if ent:IsValid() and ent:IsWorld() then
            horde_boss_reposition = true
            print("[HORDE] Boss is stuck. Attempting to reposition...")
        end
    end
end

function HORDE:SpawnAmmoboxes(valid_nodes)
    for _, box in pairs(horde_spawned_ammoboxes) do
        if box:IsValid() then box:Remove() end
    end
    horde_spawned_ammoboxes = {}

    for i = 0, math.min(table.Count(player.GetAll()), HORDE.ammobox_max_count_limit) + HORDE.Difficulty[HORDE.CurrentDifficulty].additionalAmmoBoxes do
        local pos = table.Random(valid_nodes)
        local spawned_ammobox = ents.Create("horde_ammobox")
        spawned_ammobox:SetPos(pos)
        spawned_ammobox:Spawn()
        table.insert(horde_spawned_ammoboxes, spawned_ammobox)
    end

    if table.Count(horde_spawned_ammoboxes) > 0 then
        net.Start("Horde_HighlightEntities")
        net.WriteUInt(HORDE.render_highlight_ammoboxes, 3)
        net.Broadcast()
    end

    horde_ammobox_refresh_timer = HORDE.ammobox_refresh_interval
end

-- Referenced some spawning mechanics from Zombie Invasion+
local director_interval = 3
if GetConVarNumber("horde_director_interval") then
    director_interval = math.max(1, GetConVarNumber("horde_director_interval"))
end

-- Start's a break between waves.
function HORDE:StartBreak()
    if horde_in_break then return end
    horde_in_break = true
    timer.Adjust("Horde_Main", director_interval, nil, nil)
    net.Start("Horde_SyncGameInfo")
    net.WriteUInt(HORDE.current_wave, 16)
    net.Broadcast()
    timer.Create("Horder_Counter", 1, 0, function()
        if not HORDE.start_game then return end
        HORDE:BroadcastBreakCountDownMessage(HORDE.current_break_time, false)

        if HORDE.Skip_Wave_Timer then
            HORDE.current_break_time = 0
        end

        if 0 < HORDE.current_break_time then
            HORDE.current_break_time = HORDE.current_break_time - 1
        elseif HORDE.current_break_time == 0 then
            -- New round
            timer.Adjust("Horde_Main", 1, nil, nil)
            HORDE.current_wave = HORDE.current_wave + 1
            net.Start("Horde_SyncGameInfo")
            net.WriteUInt(HORDE.current_wave, 16)
            net.Broadcast()
            HORDE:BroadcastBreakCountDownMessage(0, false)
            horde_in_break = nil
            timer.Remove("Horder_Counter")
        end
    end)
end

function HORDE:InBreak()
    return horde_in_break
end

-- Starts a wave.
-- 1. Sets the spawn configuration for the current wave.
-- 2. Decides the boss to spawn, if there is one available.
function HORDE:WaveStart()
    timer.Adjust("Horde_Main", director_interval, nil, nil)
    HORDE.Skip_Wave_Timer = nil
    if (HORDE.enemies_normalized == nil) or table.IsEmpty(HORDE.enemies_normalized) then
        HORDE:HardResetDirector()
        HORDE:SendNotification("Enemies list is empty. Config the enemy list or no enemies wil spawn.", 1)
        HORDE.start_game = false
        return
    end

    if HORDE.endless == 0 and table.IsEmpty(HORDE.enemies_normalized[HORDE.current_wave]) then
        HORDE:SendNotification("No enemy config set for this wave. Falling back to previous wave settings.", 1)
    end

    local current_wave = ((HORDE.current_wave - 1) % HORDE.max_max_waves) + 1

    local countablePlayerCount = 0
    for _, ply in ipairs( player.GetAll() ) do
        local result = hook.Run("Horde_ShouldCountPlayer", ply)
        if result ~= false then
            countablePlayerCount = countablePlayerCount + 1
        end
    end
    horde_players_count = countablePlayerCount

    horde_current_enemies_list = table.Copy(HORDE.enemies_normalized[current_wave])
    local enemyMulti = 1
    local playerCountMultiplier = math.ceil( horde_players_count * enemyMulti )

    if HORDE.endless == 0 then
        -- No endless
        HORDE.total_enemies_this_wave = HORDE.total_enemies_per_wave[HORDE.current_wave] * playerCountMultiplier
    else
        if HORDE.total_enemies_per_wave[HORDE.current_wave] ~= nil then
             -- If we have enough waves, still use them
             HORDE.total_enemies_this_wave = HORDE.total_enemies_per_wave[HORDE.current_wave] * playerCountMultiplier
        else
            -- Use wave 10 settings scaled
            HORDE.total_enemies_this_wave = (HORDE.total_enemies_per_wave[HORDE.max_max_waves] + 5 * (HORDE.current_wave - HORDE.max_max_waves)) * playerCountMultiplier
            -- Scale damage and health
            HORDE.endless_damage_multiplier = math.max(1, 1.1 ^ (HORDE.current_wave - HORDE.max_max_waves))
            HORDE.endless_health_multiplier = math.max(1, 1.1 ^ (HORDE.current_wave - HORDE.max_max_waves))
        end
    end

    -- Get mutations
    HORDE.current_mutations = {}
    for _, mutation in pairs(HORDE.mutations_rand) do
        if mutation == "shadow" then goto cont end
        if mutation.Wave and HORDE.current_wave >= mutation.Wave then
            table.insert(HORDE.current_mutations, mutation.ClassName)
        elseif not mutation.Wave then
            table.insert(HORDE.current_mutations, mutation.ClassName)
        end
        ::cont::
    end

    -- Additional custom scaling
    if GetConVar("horde_total_enemies_scaling"):GetInt() > 1 then
        HORDE.total_enemies_this_wave = HORDE.total_enemies_this_wave * GetConVar("horde_total_enemies_scaling"):GetInt()
    end


    HORDE.total_enemies_this_wave_fixed = HORDE.total_enemies_this_wave
    local max_enemies_alive_base = GetConVarNumber("horde_max_enemies_alive_base")
    local scale = GetConVarNumber("horde_max_enemies_alive_scale_factor")
    local max_enemies_alive_max = GetConVarNumber("horde_max_enemies_alive_max")
    HORDE.max_enemies_alive = math.floor(math.min(max_enemies_alive_max, max_enemies_alive_base * HORDE.Difficulty[HORDE.CurrentDifficulty].maxEnemiesAliveScaleFactor + scale * horde_players_count))
    HORDE.alive_enemies_this_wave = 0
    HORDE.current_break_time = -1
    HORDE.killed_enemies_this_wave = 0

    -- Decides the boss to spawn.
    local has_boss = HORDE.bosses_normalized[current_wave] and not table.IsEmpty(HORDE.bosses_normalized[current_wave])
    if has_boss then
        local p = math.random()
        local p_cum = 0
        for name, weight in pairs(HORDE.bosses_normalized[current_wave]) do
            p_cum = p_cum + weight
            if p <= p_cum then
                HORDE.horde_boss_name = name
                break
            end
        end

        horde_boss_properties = HORDE.bosses[HORDE.horde_boss_name .. current_wave].boss_properties
        if horde_boss_properties.enemies_spawn_threshold <= 0 and horde_boss_properties.end_wave == true then
            -- No enemies will spawn, just the boss.
            HORDE.total_enemies_this_wave = 1
            HORDE.total_enemies_this_wave_fixed = 1
        end
    end

    horde_ammobox_refresh_timer = HORDE.ammobox_refresh_interval
    if HORDE.endless == 1 then
        if horde_boss_properties then
            HORDE:BroadcastEnemiesCountMessage(true, tostring(HORDE.current_wave) .. " / ∞", 0)
        else
            HORDE:BroadcastEnemiesCountMessage(false, tostring(HORDE.current_wave) .. " / ∞", HORDE.total_enemies_this_wave_fixed - HORDE.killed_enemies_this_wave)
        end
    else
        if horde_boss_properties then
            HORDE:BroadcastEnemiesCountMessage(true, tostring(HORDE.current_wave) .. " / " .. tostring(HORDE.max_waves), 0)
        else
            HORDE:BroadcastEnemiesCountMessage(false, tostring(HORDE.current_wave) .. " / " .. tostring(HORDE.max_waves), HORDE.total_enemies_this_wave_fixed - HORDE.killed_enemies_this_wave)
        end
    end

    local enemy_wave = ((HORDE.current_wave - 1) % HORDE.max_max_waves) + 1
    horde_force_spawn_enemies = HORDE:GetForcedEnemiesOnWave(horde_current_enemies_list, enemy_wave, HORDE.total_enemies_this_wave_fixed)

    -- Close all the shop menus
    net.Start("Horde_ForceCloseShop")
    net.Broadcast()

    if not HORDE.has_buy_zone then
        net.Start("Horde_SyncStatus")
        net.WriteUInt(HORDE.Status_CanBuy, 8)
        net.WriteUInt(0, 8)
        net.Broadcast()
    end

    -- Get objectives, if there are any
    if not has_boss then
        local holdzones = HORDE:GetHoldZones(current_wave)
        local payload_spawns = HORDE:GetPayloadSpawns(current_wave)
        local payload_destinations = HORDE:GetPayloadDestinations(current_wave)

        HORDE.horde_active_holdzones = nil

        local has_hold_obj = holdzones and not table.IsEmpty(holdzones)
        local has_payload_obj = payload_spawns and not table.IsEmpty(payload_spawns) and payload_destinations and not table.IsEmpty(payload_destinations)
        if has_hold_obj and has_payload_obj then
            local p = math.random()
            if p <= 0.5 then
                has_hold_obj = nil
            else
                has_payload_obj = nil
            end
        end

        HORDE.max_objs = 0
        HORDE.finished_objs = 0
        if has_hold_obj then
            HORDE.horde_active_holdzones = holdzones
            for id, zone in pairs(holdzones) do
                zone:Horde_SetActivated(true)
                HORDE:StartObjective(HORDE.OBJECTIVE_HOLD, {zone=zone})
            end
            HORDE.horde_has_active_objective = true
        elseif has_payload_obj then
            HORDE.horde_active_payload_spawns = payload_spawns
            HORDE.horde_active_payload_destinations = payload_destinations

            for id, spawn in pairs(payload_spawns) do
                spawn.Horde_Activated = true
                HORDE:StartObjective(HORDE.OBJECTIVE_PAYLOAD, {spawn=spawn})
            end

            for id, dest in pairs(payload_destinations) do
                dest.Horde_Activated = true
                HORDE:StartPayloadDestination(dest)
            end
            HORDE.horde_has_active_objective = true
        end
    end

    for _, ent in pairs(ents.FindByClass("logic_horde_waves")) do
        if ent.Wave == current_wave or ent.Wave == -1 then
            ent:Input("onwavestart", ent, ent, current_wave)
        end
    end
end

-- Ends a wave.
function HORDE:WaveEnd()
    timer.Remove("Horde_BossMusic")
    if boss_music_boolean == true && boss_music_loop then
		HordeBossMusic(boss_music_loop, true)
        boss_music_boolean = false
		boss_music_loop = nil
    end

    HORDE.current_break_time = HORDE.total_break_time
    HORDE.horde_boss = nil
    HORDE.horde_boss_name = nil
    horde_in_break = nil
    horde_boss_spawned = false
    horde_boss_properties = nil
    horde_boss_reposition = false
    horde_boss_critical = false

    HORDE:StartBreak()
    local enemies = HORDE:ScanEnemies()
    if not table.IsEmpty(enemies) then
        for _, enemy in pairs(enemies) do
            enemy:Horde_SetMostRecentAttacker(nil)
            enemy:Remove()
        end
    end
    HORDE.spawned_enemies_count = {}

    if (HORDE.current_wave >= HORDE.max_waves) and (HORDE.endless == 0) then
        -- TODO: change this magic number
        if boss_music_loop then boss_music_loop:Stop() end
        HORDE:GameEnd("VICTORY")

        boss_music_loop = CreateSound(game.GetWorld(), "horde/music/OpForEnding.mp3")
        boss_music_loop:SetSoundLevel(0)
        timer.Create("Horde_BossMusic", 60, 0, function()
            boss_music_loop:Stop()
            boss_music_loop:Play()
        end)
        boss_music_loop:Play()
    else
		HORDE:StartBreak()
        HORDE:BroadcastBreakCountDownMessage(0, true)
        HORDE:SendNotification("Wave Completed!", 0)

        -- Send Tips
        local tip = HORDE:GetTip()
        if tip then
            net.Start("Horde_SyncTip")
                net.WriteString(HORDE:GetTip())
            net.Broadcast()
        end
    end

    net.Start("Horde_HighlightEntities")
    net.WriteUInt(HORDE.render_highlight_disable, 3)
    net.Broadcast()

    for _, ply in pairs(player.GetAll()) do
        if not ply:Alive() then ply:Spawn() end
        HORDE.player_class_changed[ply:SteamID()] = false
        HORDE.player_ready[ply] = 0
        
        net.Start("Horde_PlayerReadySync")
            net.WriteTable(HORDE.player_ready)
        net.Broadcast()
        
        if (HORDE.current_wave < HORDE.max_waves and (HORDE.endless == 0)) or (HORDE.endless == 1) then
            -- Show Leaderboards
            net.Start("Horde_ShowLeaderboardsTemporarily")
            net.Send(ply)

            -- Send Tips
            local tip = HORDE:GetTip()
            if tip then
                net.Start("Horde_SyncTip")
                    net.WriteString(HORDE:GetTip())
                net.Send(ply)
                local id = ply:SteamID()
                timer.Create("Horde_TipsTimer" .. id, 10, 0, function()
                    if not HORDE:InBreak() or HORDE.current_break_time <= 10 then timer.Remove("Horde_TipsTimer" .. id) return end
                    net.Start("Horde_SyncTip")
                        net.WriteString(HORDE:GetTip())
                    net.Send(ply)
                end)
            end
        end
    end
    if GetConVarNumber("horde_npc_cleanup") == 1 then
        for _, ent in pairs(ents.GetAll()) do
            if ent:IsNPC() and not ent:GetNWEntity("HordeOwner"):IsPlayer() then
                ent:Remove()
            end
        end
    end

    -- Also turnoff boss health bar.
    net.Start("Horde_SyncBossHealth")
        net.WriteInt(0, 32)
    net.Broadcast()

    -- Global Wave End Effects
    if horde_perk_progress <= 4 and HORDE:Horde_GetWaveForPerk(horde_perk_progress) and HORDE.current_wave >= HORDE:Horde_GetWaveForPerk(horde_perk_progress) then
        timer.Simple(1, function()
            HORDE:SendNotification("Tier " .. horde_perk_progress .. " perks have been unlocked!", 0)
            horde_perk_progress = horde_perk_progress + 1
        end)
    end
    for _, ply in pairs(player.GetAll()) do
        -- Minion life recovery
        if HORDE.player_drop_entities[ply:SteamID()] then
            for _, ent in pairs(HORDE.player_drop_entities[ply:SteamID()]) do
                if IsValid( ent ) and ent:IsNPC() then
                    ent:SetHealth(ent:GetMaxHealth())
                end
            end
        end
        -- Round bonus
        ply:Horde_AddMoney(HORDE.round_bonus_base)
        ply:Horde_SyncEconomy()
        ply:Horde_SetGivenStarterWeapons(nil)
        ply:Horde_ApplyPerksForClass()
        if GetConVar("horde_enable_rank"):GetInt() == 1 then
            HORDE:SaveRank(ply)
        end

        ply:Horde_SyncExp()
        HORDE:TryAddTopTen(ply)
    end

    if not HORDE.has_buy_zone then
        net.Start("Horde_SyncStatus")
        net.WriteUInt(HORDE.Status_CanBuy, 8)
        net.WriteUInt(1, 8)
        net.Broadcast()
    end

    for _, ent in pairs(ents.FindByClass("logic_horde_waves")) do
        if ent.Wave == HORDE.current_wave or ent.Wave == -1 then
            ent:Input("onwaveend", ent, ent, HORDE.current_wave)
        end
    end
end

-- Referenced some spawning mechanics from Zombie Invasion+

-- Game Director. Executes at every given interval.
-- The director is responsible for:
-- 1. spawning enemies/ammoboxes.
-- 2. updating player/wave states.
function HORDE:Direct()
    if table.Count(player.GetAll()) <= 0 then
        -- Reset game state
        HORDE:HardResetDirector()
        HORDE:HardResetEnemies()
        HORDE.player_ready = {}
    end

    if not HORDE.start_game then
        HORDE:HardResetDirector()
        HORDE:HardResetEnemies()

        local ready_count = 0
        local total_player = 0
        for _, ply in pairs(player.GetAll()) do
            if HORDE.player_ready[ply] == 1 then
                ready_count = ready_count + 1
            end
            total_player = total_player + 1
        end

        if total_player > 0 and total_player == ready_count then
            HORDE.start_game = true
        else
            HORDE:BroadcastPlayersReadyMessage(tostring(ready_count) .. "/" .. tostring(total_player))
        end
        return
    end

    if not HORDE.found_ai_nodes then
        ParseFile()
    end

    if not HORDE.ai_nodes or table.IsEmpty(HORDE.ai_nodes) then
        print("[HORDE] No info_node(s) in map! NPCs will not spawn.")
        HORDE:SendNotification("Map has no info nodes! NPCs will not spawn.", 1)
        return
    end

    if (not HORDE.found_horde_nodes) and (#HORDE.ai_nodes <= 35) then
        print("Enemies may not spawn well on this map, please try another.")
    end

    if HORDE.current_break_time > 0 and HORDE.current_break_time <= HORDE.total_break_time then
        HORDE:StartBreak()
    end

    if HORDE.current_break_time > 0 then
        return
    end

    -- Start round
    if HORDE.current_break_time == 0 then
        HORDE:WaveStart()
        hook.Run("HordeWaveStart", HORDE.current_wave)
    end

    -- Decrease ammobox refresh timer
    if HORDE.enable_ammobox == 1 then
        horde_ammobox_refresh_timer = horde_ammobox_refresh_timer - director_interval
        net.Start("Horde_AmmoboxCountdown")
        net.WriteInt(horde_ammobox_refresh_timer, 8)
        net.Broadcast()
    end

    -- Check enemy
    local enemies = HORDE:ScanEnemies()
    HORDE:RemoveDistantEnemies(enemies)

    if #enemies >= HORDE.max_enemies_alive then
        return
    end

    --Get valid nodes
    local valid_nodes = HORDE:GetValidNodes(enemies)
    if #valid_nodes > 0 then
        -- If we already have a boss, check if he is stuck.
        HORDE:CheckBossStuck()

        -- Spawn boss
        local wave = HORDE.current_wave % HORDE.max_max_waves
        if wave == 0 then wave = 10 end
        local has_boss = HORDE.bosses_normalized[wave]
        if has_boss and (not horde_boss_spawned) and (not HORDE.horde_boss) then
            if HORDE.boss_spawns and #HORDE.boss_spawns > 0 then
                HORDE:SpawnBoss(enemies, HORDE.boss_spawns)
            else
                HORDE:SpawnBoss(enemies, valid_nodes)
            end
            hook.Run("HordeBossSpawn", HORDE.horde_boss)
            horde_boss_spawned = true
        elseif horde_boss_reposition then
            HORDE:RepositionBoss(valid_nodes)
            horde_boss_reposition = false
        end

        --Spawn enemies
        if (not horde_boss_properties) then
            HORDE:SpawnEnemies(enemies, valid_nodes)
        else
            if HORDE.horde_boss and (HORDE.horde_boss:Health() <= horde_boss_properties.enemies_spawn_threshold * HORDE.horde_boss:GetMaxHealth()) then
                HORDE:SpawnEnemies(enemies, valid_nodes)
            end
        end

        -- Spawn ammoboxes
        if horde_ammobox_refresh_timer <= 0 and #valid_nodes > 0 then
            if HORDE.ammobox_nodes and not (table.IsEmpty(HORDE.ammobox_nodes)) then
                HORDE:SpawnAmmoboxes(HORDE.ammobox_nodes)
            else
                HORDE:SpawnAmmoboxes(valid_nodes)
            end
        end
    end
	
    if (HORDE.total_enemies_this_wave_fixed - HORDE.killed_enemies_this_wave) <= 10 then
        local remaining = {}
        for _, enemy in ipairs(enemies) do
            remaining[enemy] = enemy:GetPos()
        end
        
        net.Start("Horde_MarkRemainingEnemies")
        net.WriteTable(remaining)
        net.Broadcast()
    end

    if HORDE.total_enemies_this_wave <= 0 and HORDE.alive_enemies_this_wave <= 0 and (not HORDE.horde_has_active_objective) then
        HORDE:WaveEnd()
        hook.Run("HordeWaveEnd", HORDE.current_wave)
    end
end

--timer.Create("Horde_Main", director_interval, 0, function ()
    --ProtectedCall( function()
        --HORDE:Direct()
    --end )
--end)

timer.Create("Horde_Main", director_interval, 0, function()
    local status, err = pcall(function() HORDE:Direct() end)

    if not status then
        print(err)
    end
end)
