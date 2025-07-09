GADGET.PrintName = "IV Injection"
GADGET.Description = "Recover 50 health."
GADGET.Icon = "items/gadgets/iv_injection.png"
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Active = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_iv_injection" then return end
    sound.Play("horde/gadgets/injection.ogg", ply:GetPos())
    sound.Play("items/medshot4.wav", ply:GetPos())
    local healinfo = HealInfo:New({amount=50, healer=ply})
    HORDE:OnPlayerHeal(ply, healinfo)
    ply.Horde_IV = true
    timer.Simple(5, function ()
        if IsValid(ply) then
            ply.Horde_IV = nil
        end
    end)
end

GADGET.Hooks.Horde_PlayerMoveBonus = function(ply, bonus_walk, bonus_run)
    if ply.Horde_IV then
        bonus_walk.more = bonus_walk.more * 1.5
        bonus_run.more = bonus_run.more * 1.5
    end
end