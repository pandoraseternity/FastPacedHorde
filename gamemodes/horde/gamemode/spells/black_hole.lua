SPELL.PrintName       = "Black Hole"
SPELL.Weapon          = {"horde_astral_relic"}
SPELL.Mind            = {65}
SPELL.ChargeTime      = {5}
SPELL.ChargeRelease   = nil
SPELL.Cooldown        = 60
SPELL.Upgrades          = 3
SPELL.Slot            = HORDE.Spell_Slot_Reload
SPELL.DamageType      = {HORDE.DMG_COLD}
SPELL.Icon            = "spells/black_hole.png"
SPELL.Type            = {HORDE.Spell_Type_Projectile, HORDE.Spell_Type_AOE}
SPELL.Description     = [[Generates a black hole that attracts and damages enemies.]]
SPELL.Fire            = function (ply, wpn, charge_stage)
    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end
    local pos = tr.HitPos
    pos.z = pos.z + 100

    local trail = ents.Create( "info_particle_system" )
    trail:SetKeyValue("effect_name", "black_hole")
    trail:SetOwner( ply )
    trail:SetPos( pos )
    trail:SetAngles( ply:GetAngles() )
    trail:Spawn()
    trail:Activate()
    trail:Fire( "start", "", 0 )
    trail:Fire("Kill","", 5)

    sound.Play("horde/spells/black_hole.ogg", pos, 500, 100, 1, CHAN_AUTO)
	
    local flashorigin = trail:GetPos() 
    local flashpower = 400
    local targets = ents.FindInSphere(flashorigin, flashpower)
    if not targets then return end
    for _, k in pairs(targets) do
        if k:IsPlayer() then
            local dist = k:EyePos():Distance(flashorigin)
            local dp = (k:EyePos() - flashorigin):Dot(k:EyeAngles():Forward())

            local time = Lerp( dp, 2.5, 0.25 )

            time = Lerp( dist / flashpower, time, 0 )

            if k:VisibleVec( flashorigin ) then
                k:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 100 ), 2.5, time )
            end

            k:SetDSP( 37, false )

        elseif k:IsNPC() then
            k:Horde_AddDebuffBuildup(HORDE.Status_Stun, 200, attacker, k:GetPos())
			k:NextThink( CurTime() + 6 )
        end
    end

    local level = ply:Horde_GetSpellUpgrade("black_hole")
    local level_bonus = { add = 0}
    hook.Run("Horde_OnSpellLevel", ply, level_bonus, HORDE.spells["black_hole"])
    level = level + level_bonus.add

    local bonus = {increase = 0, more = 1}
	hook.Run("Horde_OnPlayerSpellDamage", ply, bonus)
    local base_damage = math.floor((200 + 17 * math.pow(level, 1.2)) * bonus.more * (1 + bonus.increase))
    for i = 1, 17 do
        timer.Simple((i-1) * 0.2, function ()
            HORDE:ApplyDamageInRadius(pos, 750, HORDE:DamageInfo(base_damage, DMG_REMOVENORAGDOLL, ply, wpn), function (ent)
                local dir = (ent:GetPos() - pos) * -1
                local acc = math.max(500 * 1.05 - dir:Length(), 0 ) * 0.03
                acc = math.Round( acc )
                acc = acc * acc
        
                local phys = ent:GetPhysicsObject()
                if ( IsValid( phys ) ) then
                    local velo = ( dir * acc )
                    phys:ApplyForceOffset( velo, ent:GetPos() )
                    ent:SetVelocity( dir * acc * 0.01 )
                end
            end)
        end)
    end
end
SPELL.Price                      = 1500
SPELL.Upgrades                   = 3
SPELL.Upgrade_Description        = "Increases damage."
SPELL.Upgrade_Prices             = function (upgrade_level)
    return 800 + 100 * upgrade_level
end