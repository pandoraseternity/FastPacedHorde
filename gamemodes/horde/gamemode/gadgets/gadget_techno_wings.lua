GADGET.PrintName = "Techno Wings"
GADGET.Description = [[
Utility technology used by the Resistance to gain an advantage against both the
Combine and Zombies alike.

Goes on cooldown after 25 seconds.
]]
GADGET.Icon = "items/gadgets/aerial_guard.png"
GADGET.Active = true
GADGET.Duration = 25
GADGET.Cooldown = 40
GADGET.Droppable = false
GADGET.Params = {
    [1] = {value = 0.05, percent = true},
    [2] = {value = 0.5, percent = true},
}
GADGET.Hooks = {}
GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_techno_wings" then return end
    ply:EmitSound("thrusters/hover02.wav")
	local movement = ply:GetMoveType()
    local id = ply:SteamID()
	ply:SetMoveType(4)
    ply:ScreenFade(SCREENFADE.IN, Color(200, 50, 50, 50), 0.1, 10)
    timer.Simple(25, function() if ply:Alive() then
		ply:StopSound("thrusters/hover02.wav")
		ply:EmitSound("buttons/button17.wav")
        if ply:IsValid() then ply:SetMoveType(movement) end
    end end)
end

