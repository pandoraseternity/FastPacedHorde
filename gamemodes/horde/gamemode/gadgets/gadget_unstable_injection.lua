GADGET.PrintName = "Unstable Injection"
GADGET.Description =
[[Gives you a random effect out of the following:
- Recover 40% health.
- Gain 2 Adrenaline or 35 Barrier.
- Gain Fortify/Berserk for 25 seconds]]
GADGET.Icon = "items/gadgets/unstable_injection.png"
GADGET.Duration = 0
GADGET.Cooldown = 10
GADGET.Active = true
GADGET.Droppable = true
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_unstable_injection" then return end
    sound.Play("horde/gadgets/injection.ogg", ply:GetPos())

    local p = math.random(1,3)
    if p == 1 then
        sound.Play("items/medshot4.wav", ply:GetPos())
        local healinfo = HealInfo:New({amount=ply:GetMaxHealth() * 0.4, healer=ply})
        HORDE:OnPlayerHeal(ply, healinfo)
    elseif p == 2 then
        local q = math.random(1,2)
        if q == 1 then
            ply:Horde_AddAdrenalineStack(2)
			ply:Horde_SetAdrenalineStackDuration(10)
        else
            ply:Horde_AddBarrierStack(35)
        end
    elseif p == 3 then
        local q = math.random(1,2)
        if q == 1 then
            ply:Horde_AddBerserk(25)
        else
            ply:Horde_AddFortify(25)
        end
    else
        ply:Horde_AddDebuffBuildup(HORDE.Status_Decay, 30)
    end
end