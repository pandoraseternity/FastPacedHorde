GADGET.PrintName = "Inner Peace"
GADGET.Description =
[[Follow the flow of battle, and overcome the horde.
Every time you kill an elite, gain 1 stamina.
50% reduced buildups from all sources.
Dashing into an enemy will stun them, and take 25% more damage.]]
GADGET.Icon = "items/gadgets/unstable_injection.png"
GADGET.Duration = 0
GADGET.Cooldown = 0
GADGET.Active = false
GADGET.Droppable = false
GADGET.Params = {
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus, inflictor)
    if ply:Horde_GetGadget() ~= "gadget_inner_peace" then return end
    bonus.less = bonus.less * 0.5
end

GADGET.Hooks.ULTRAKILL_DashHook = function (ply)
    if ply:Horde_GetGadget() ~= "gadget_inner_peace" then return end
	
for k, ent in pairs(ents.FindAlongRay( ply:WorldSpaceCenter(), ply:WorldSpaceCenter() + ply:GetForward()*100, Vector( -10, -10, -10 ), Vector( 10, 10, 10 ) )) do

	if ply.Dashing && HORDE:IsEnemy(ent) then
		ent:Horde_AddStun(2)
		ent.Vunerable = true
		ply:Horde_AddPhasing(0.5, function ()
			ply:SetLocalVelocity(Vector(0,0,0))
		end)
		timer.Simple(0.25, function() ply:SetLocalVelocity(Vector(0,0,0)) end)
		timer.Simple(4, function() if IsValid(ent) then
			ent.Vunerable = nil
		end			
		end)
end
		
end
end

GADGET.Hooks.EntityTakeDamage = function (victim, dmginfo)
    --if ply:Horde_GetGadget() ~= "gadget_inner_peace" then return end
    local attacker = dmginfo:GetAttacker()
    if (victim:IsNPC() or victim:IsNextBot()) and attacker:IsPlayer() and victim.Vunerable then
        dmginfo:SetDamage( dmginfo:GetDamage() * 1.25 )
    end
end

GADGET.Hooks.Horde_OnEnemyKilled = function(victim, killer, wpn)
    if killer:Horde_GetGadget() ~= "gadget_inner_peace" then return end
	
	if killer:IsPlayer() && (victim:Horde_IsElite() or victim:GetMaxHealth() > 1000) then
	killer:SetNW2Int("AbilityStamina", killer:GetNW2Int("AbilityStamina", killer:GetNW2Int("AbilityStamina")) + 1 )
	net.Start("ULTRAKILL_UpdateStaminaCount")
	net.WriteUInt(killer:GetNW2Int("AbilityStamina", GetConVar("ultrakill_max_stamina"):GetInt()), 31)
	net.WriteBool(false)
	net.Send(killer)
	killer:EmitSound("horde/gadgets/energy_shield_on.ogg")
	end
end

