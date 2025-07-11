local EXPECTED_HEADER = "Horde_Rank"
local EXPECTED_HEADER_TOKENS = "Horde_Skull_Tokens"

function HORDE:SaveSkullTokens(ply)
	if GetConVar("horde_enable_sandbox"):GetInt() == 1 then return end
	if not ply:IsValid() then return end
	if not ply.Horde_Skull_Tokens_Loaded then return end

	local path, strm

	if not file.IsDir("horde/tokens", "DATA") then
		file.CreateDir("horde/tokens", "DATA")
	end

	path = "horde/tokens/" .. HORDE:ScrubSteamID(ply) .. ".txt"

	strm = file.Open(path, "wb", "DATA")
		strm:Write(EXPECTED_HEADER_TOKENS)
        strm:WriteLong(ply:Horde_GetSkullTokens())
	strm:Close()
end

function HORDE:SaveRank(ply)
	if GetConVar("horde_enable_rank"):GetInt() == 0 then return end
	if not ply:IsValid() then return end
	if not ply.Horde_Rank_Loaded then return end

	local path, strm

	if not file.IsDir("horde/ranks", "DATA") then
		file.CreateDir("horde/ranks", "DATA")
	end

	path = "horde/ranks/" .. HORDE:ScrubSteamID(ply) .. ".txt"

	strm = file.Open(path, "wb", "DATA" )
		strm:Write(EXPECTED_HEADER)
        for name, class in pairs(HORDE.classes) do
            strm:WriteShort(class.order)
            strm:WriteLong(ply:Horde_GetExp(name))
			strm:WriteShort(ply:Horde_GetLevel(name))
        end

		-- Write subclass data
		for subclass_name, subclass in pairs(HORDE.subclasses) do
			if not subclass.ParentClass then goto cont end
			strm:WriteULong(HORDE.subclass_name_to_crc[subclass.PrintName])
			strm:WriteLong(ply:Horde_GetExp(subclass.PrintName))
			strm:WriteShort(ply:Horde_GetLevel(subclass.PrintName))
			::cont::
		end
	strm:Close()
end

function HORDE:LoadSkullTokens(ply)
	if not ply:IsValid() then return end
	local path, strm

	if not file.IsDir("horde/tokens", "DATA") then
		file.CreateDir("horde/tokens", "DATA")
	end

	path = "horde/tokens/" .. HORDE:ScrubSteamID(ply) .. ".txt"

	if not file.Exists(path, "DATA") then
		print("Path", path, "does not exist!")
		ply:Horde_SetSkullTokens(0)
		ply.Horde_Skull_Tokens_Loaded = true
		return
	end

	strm = file.Open(path, "rb", "DATA")
		local header = strm:Read(#EXPECTED_HEADER_TOKENS)

		if header == EXPECTED_HEADER_TOKENS then
			local tokens = strm:ReadLong()
			ply:Horde_SetSkullTokens(tokens)
		else
			ply:Horde_SetSkullTokens(0)
		end
	strm:Close()

	ply.Horde_Skull_Tokens_Loaded = true
end

function HORDE:LoadRank(ply)
	if not ply:IsValid() then return end
	if GetConVar("horde_enable_rank"):GetInt() == 0 then return end

	local path, strm

	if not file.IsDir("horde/ranks", "DATA") then
		file.CreateDir("horde/ranks", "DATA")
	end

	path = "horde/ranks/" .. HORDE:ScrubSteamID(ply) .. ".txt"

	if not file.Exists(path, "DATA") then
		print("Path", path, "does not exist!")
		ply.Horde_Rank_Loaded = true
		return
	end

	strm = file.Open(path, "rb", "DATA")
		local header = strm:Read(#EXPECTED_HEADER)

		if header == EXPECTED_HEADER then
			for _, _ in pairs(HORDE.classes) do
                local order = strm:ReadShort()
				local exp = strm:ReadLong()
				local level = strm:ReadShort()
				if order == nil then
				else
					local class_name = HORDE.order_to_class_name[order]
					ply:Horde_SetLevel(class_name, level)
					ply:Horde_SetExp(class_name, exp)
				end
            end

			-- Read subclass data
			while not strm:EndOfFile() do
				local order = strm:ReadULong()
				local exp = strm:ReadLong()
				local level = strm:ReadShort()
				if order == nil then
				else
					local class_name = HORDE.order_to_subclass_name[tostring(order)]
					ply:Horde_SetLevel(class_name, level)
					ply:Horde_SetExp(class_name, exp)
				end
				::cont::
			end
		else
			for _, class in pairs(HORDE.classes) do
				ply:Horde_SetLevel(class.name, 0)
                ply:Horde_SetExp(class.name, 0)
            end
		end
	strm:Close()

	ply.Horde_Rank_Loaded = true
end

local expMultiConvar = GetConVar("horde_experience_multiplier")
local startXpMult = HORDE.Difficulty[HORDE.CurrentDifficulty].xpMultiStart
local endXpMult = HORDE.Difficulty[HORDE.CurrentDifficulty].xpMultiEnd
local endMinusStartXp = endXpMult - startXpMult

if GetConVar("horde_enable_sandbox"):GetInt() == 0 and GetConVar("horde_enable_rank"):GetInt() == 1 then
	hook.Add("Horde_OnEnemyKilled", "Horde_GiveExp", function(victim, killer, wpn)

		local wavePercent = HORDE.current_wave / HORDE.max_waves
		local roundXpMulti = startXpMult + ( wavePercent * endMinusStartXp ) --This gets the xp multi number between min and max multi based on round
		local expMulti = roundXpMulti * expMultiConvar:GetInt()

		if HORDE.current_wave <= 0 or GetConVar("sv_cheats"):GetInt() == 1 then return end
		if not killer:IsPlayer() or not killer:IsValid() or not killer:Horde_GetClass() then return end
		local class_name = killer:Horde_GetCurrentSubclass()
		if killer:Horde_GetLevel(class_name) >= HORDE.max_level then return end
		if victim:Horde_IsElite() then
			expMulti = expMulti * 1.5
			local p = math.random()
			if p < 0.01 or (p < 0.1 and killer:Horde_GetGadget() == "gadget_corporate_mindset") then
                killer:Horde_AddSkullTokens(1)
				net.Start("PrintSkullNotify")
				net.Send(killer)
			end
		end
		killer:Horde_SetExp(class_name, killer:Horde_GetExp(class_name) + math.floor(expMulti) )
		HORDE:SaveRank(killer)
	end)
end