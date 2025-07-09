SPELL.PrintName       = "Astral Beam"
SPELL.Weapon          = {"horde_astral_relic"}
SPELL.Mind            = {65}
SPELL.ChargeTime      = {5}
SPELL.ChargeRelease   = nil
SPELL.Cooldown        = 60
SPELL.Upgrades          = 3
SPELL.Slot            = HORDE.Spell_Slot_Reload
SPELL.DamageType      = {HORDE.DMG_BLAST, HORDE.DMG_LIGHTNING}
SPELL.Icon            = "spells/neutron_beam.png"
SPELL.Type            = {HORDE.Spell_Type_Hitscan}
SPELL.Description     = [[Fires a wide astral beam at the target. The beam deals devastating damage.]]
SPELL.Fire            = function (ply, wpn, charge_stage)
	ply:EmitSound("horde/weapons/nether_relic/nether_star_launch.ogg", 100, math.random(90, 110))
	local ent = ents.Create("projectile_horde_astral_beam")
    ent:SetOwner(ply)
	ent.beam = 0
	ent:SetCharged(charge_stage)

	local level = ply:Horde_GetSpellUpgrade("astral_beam")
	ent:SetSpellLevel(level)
	ent:SetSpellBaseDamages({math.floor(75 + math.pow(level, 2) * 15)})
	ent.timetoremove = 3 + (level * 1)
    ent:SetPos( ply:EyePos() + (ply:GetAimVector() * 16 ))
	ent:SetAngles( ply:EyeAngles() )
	ent:Spawn()
	--ent:SetParent(ply)

end
SPELL.Price                      = 1500
SPELL.Upgrades                   = 3
SPELL.Upgrade_Description        = "Increases damage and duration."
SPELL.Upgrade_Prices             = function (upgrade_level)
    return 850 + 100 * upgrade_level
end