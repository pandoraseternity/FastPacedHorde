GADGET.PrintName = "Specialized Operative Goggles"
GADGET.Description =[[These resistance goggles "guide" your arms towards the target's position.
Will automatically lock onto a target within a short distance.
+10% evasion.]]
GADGET.Icon = "items/gadgets/aimbot.png"
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Active = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply, gadget)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_aimbot" then return end
	
	if ply.Horde_Aimbot == true then 
		ply.Horde_Aimbot = nil
	return end
	
	ply.Horde_Aimbot = true
	ply:EmitSound("ambient/machines/machine1_hit1.wav", 10000, 100, 2)
	
	timer.Simple(15,function() if IsValid(self) then
		ply.Horde_Aimbot = nil
		ply:EmitSound("ambient/machines/machine1_hit2.wav", 10000, 100, 2)
	end end)
	
end

GADGET.Hooks.Horde_OnUnsetGadget = function (ply, gadget)
    if CLIENT then return end
    if gadget ~= "gadget_aimbot" then return end
    local id = ply:SteamID()
	ply.Horde_Aimbot = nil
end

GADGET.Hooks.PlayerTick = function(ply, mv)
    if ply:Horde_GetGadget() ~= "gadget_aimbot" then return end
	
	if ply.Horde_Aimbot == true then
		for k, ene in pairs(ents.FindInSphere( ply:GetPos(), 500 )) do
			if HORDE:IsEnemy(ene) && ene:Health() > 0 && ply:Visible( ene ) then--ene:HeadTarget( ply:GetPos() ):Angle() ene:GetPos():Angle() 
				if ene:GetAttachment(ene:LookupAttachment("eyes")) ~= nil then
					ply:SetEyeAngles(( ene:GetAttachment(ene:LookupAttachment( "eyes" )).Pos - ply:GetShootPos() ):Angle() )
				elseif ene:GetAttachment(ene:LookupAttachment("forward")) ~= nil then
					ply:SetEyeAngles(( ene:GetAttachment(ene:LookupAttachment( "forward" )).Pos - ply:GetShootPos() ):Angle() )
				else 
					ply:SetEyeAngles(( ene:WorldSpaceCenter() - ply:GetShootPos() ):Angle() )
				end
			end 
		end
	
end end

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmg, bonus)
    if SERVER and ply.Horde_Aimbot and ply:Horde_GetGadget() == "gadget_aimbot" then
        bonus.evasion = bonus.evasion + 0.1
    end
end

