GADGET.PrintName = "Drone Pack"
GADGET.Description = "Deploys multiple temporary drones. \nThese drones can shoot down projectiles. \nThese cannot shoot down bullets or extremely powerful attacks. \nDrones are destroyed when duration expires."
GADGET.Icon = "items/npc_combat_bot.png"
GADGET.Duration = 20
GADGET.Cooldown = 35
GADGET.Active = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_drone_pack" then return end

/*local function SpawnDrone(pos, angles, force)
	local ent = ents.Create("npc_vj_horde_drone")
    local pos = ply:WorldSpaceCenter()
    local dir = (ply:GetEyeTrace().HitPos - pos)
    dir:Normalize()
    local drop_pos = pos + dir * force
    drop_pos.z = pos.z + 15
    ent:SetPos(drop_pos)
    ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
    ply:Horde_AddDropEntity(ent:GetClass(), ent)
    ent:SetNWEntity("HordeOwner", ply)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent:SetColor(Color(255,0,0,255))
    ent:Spawn()
end*/
	
	local ent = ents.Create("npc_vj_horde_drone")
    local pos = ply:WorldSpaceCenter()
    local dir = (ply:GetEyeTrace().HitPos - pos)
    dir:Normalize()
    local drop_pos = pos + dir
    drop_pos.z = pos.z + 15
    ent:SetPos(drop_pos)
    ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
    ply:Horde_AddDropEntity(ent:GetClass(), ent)
    ent:SetNWEntity("HordeOwner", ply)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent:SetColor(Color(255,0,0,255))
    ent:Spawn()
	
    local ent2 = ents.Create("npc_vj_horde_drone")
	local drop_pos2 = pos + dir * 75
    ent2:SetPos(drop_pos2)
    ent2:SetAngles(Angle(0, ply:GetAngles().y, 0))
    ply:Horde_AddDropEntity(ent2:GetClass(), ent2)
    ent2:SetNWEntity("HordeOwner", ply)
    ent2:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent2:SetColor(Color(255,0,0,255))
    ent2:Spawn()
	
    local ent3 = ents.Create("npc_vj_horde_drone")
	local drop_pos3 = pos + dir * 100
    ent3:SetPos(drop_pos3)
    ent3:SetAngles(Angle(0, ply:GetAngles().y, 0))
    ply:Horde_AddDropEntity(ent3:GetClass(), ent3)
    ent3:SetNWEntity("HordeOwner", ply)
    ent3:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent3:SetColor(Color(255,0,0,255))
    ent3:Spawn()

    -- Minions have no player collsion
    ent:AddRelationship("player D_LI 99")
    --ent.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
    local npc_info = list.Get("NPC")[ent:GetClass()]
    if not npc_info then
        print("[HORDE] NPC does not exist in ", list.Get("NPC"))
    end
    local wpns = npc_info["Weapons"]
    if wpns then
        local wpn = wpns[math.random(#wpns)]
        ent:Give(wpn)
    end
    -- Special case for turrets
    local id = ent:GetCreationID()
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent2:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent3:SetCollisionGroup(COLLISION_GROUP_WORLD)
    timer.Create("Horde_MinionCollision" .. id, 1, 0, function ()
        if not ent:IsValid() then timer.Remove("Horde_MinionCollision" .. id) return end
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent2:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent3:SetCollisionGroup(COLLISION_GROUP_WORLD)
    end)
    ply:Horde_SetMinionCount(ply:Horde_GetMinionCount() + 3)

    ent:CallOnRemove("Horde_EntityRemoved", function()
        if ent:IsValid() and ply:IsValid() then
            timer.Remove("Horde_MinionCollision" .. ent:GetCreationID())
            ent:GetNWEntity("HordeOwner"):Horde_RemoveDropEntity(ent:GetClass(), ent:GetCreationID(), true)
            ent:GetNWEntity("HordeOwner"):Horde_SyncEconomy()
            ply:Horde_SetMinionCount(ply:Horde_GetMinionCount() - 3)
        end
    end)

    timer.Simple(20, function()
        if not ent:IsValid() then return end --, Entity(0), Entity(0)
        ent:TakeDamage(9999)
		ent2:TakeDamage(9999)
		ent3:TakeDamage(9999)
    end)
end
