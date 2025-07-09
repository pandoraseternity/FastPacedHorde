if not ArcCWInstalled then return end
if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/arccw_horde_machete")
    SWEP.DrawWeaponInfoBox	= false
    SWEP.BounceWeaponIcon = false
    killicon.Add("arccw_horde_machete", "vgui/hud/arccw_horde_machete", Color(0, 0, 0, 255))
end
SWEP.Base = "arccw_horde_base_melee"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "ArcCW - Horde" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "Cored Machete"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Clearly, someone is insane enough to make this."
SWEP.Trivia_Manufacturer = "Odessa Cabbage"
SWEP.Trivia_Calibre = "N/A"
SWEP.Trivia_Mechanism = "Sharp Edge"
SWEP.Trivia_Country = "Xen"
SWEP.Trivia_Year = 2022

SWEP.Slot = 0

SWEP.NotForNPCs = true

SWEP.UseHands = true

SWEP.ViewModel = "models/horde/weapons/c_machete.mdl"
SWEP.WorldModel = "models/horde/weapons/c_machete.mdl"
SWEP.ViewModelFOV = 45
SWEP.WorldModelOffset = {
    pos        =    Vector(-15, 6, -7),
    ang        =    Angle(-10, 0, 190),
    bone    =    "ValveBiped.Bip01_R_Hand",
}

SWEP.DefaultSkin = 0
SWEP.DefaultWMSkin = 0

SWEP.MeleeDamage = 210
SWEP.Melee2Damage = 255

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeRange = 70
SWEP.MeleeAttackTime = 0.3
SWEP.MeleeTime = 0.8
SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2

SWEP.Melee2 = true
SWEP.Melee2Range = 80
SWEP.Melee2AttackTime = 0.5
SWEP.Melee2Time = 1.1
SWEP.Melee2Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2

SWEP.MeleeSwingSound = {
    "horde/weapons/mjollnir/swing_1.ogg",
    "horde/weapons/mjollnir/swing_2.ogg"
}
SWEP.MeleeMissSound = {
    "horde/weapons/mjollnir/swing_1.ogg",
    "horde/weapons/mjollnir/swing_2.ogg"
}
SWEP.MeleeHitSound = {
    "horde/weapons/machete/machete_impact_world1.mp3",
    "horde/weapons/machete/machete_impact_world2.mp3"
}
SWEP.MeleeHitNPCSound = {
    "horde/weapons/machete/melee_machete_01.mp3",
    "horde/weapons/machete/melee_machete_02.mp3",
    "horde/weapons/machete/melee_machete_03.mp3"
}

SWEP.NotForNPCs = true

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "MELEE"
    },
}

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee2"

SWEP.Primary.ClipSize = -1

SWEP.AttachmentElements = {
}

SWEP.Attachments = {
}

SWEP.Animations = {
    ["idle"] = false,
    ["draw"] = {
        Source = "draw",
        Time = 0.8,
    },
    ["ready"] = {
        Source = "draw",
        Time = 0.8,
    },
    ["bash"] = {
        Source = {"attack1", "attack2", "attack3",},
        Time = 0.8,
    },
    ["bash2"] = {
        Source = "heavyattack",
        Time = 1,
    },
}

SWEP.IronSightStruct = false

SWEP.ActivePos = Vector(3, 4.5, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 0, 0)

SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(0, -3, -2)
SWEP.HolsterAng = Angle(-10, 0, 0)

SWEP.ChargeSound = Sound("ambient/fire/ignite.wav")

function SWEP:SecondaryAttack()
    if self:GetNextSecondaryFire() > CurTime() then return end
	self:EmitSound(self.ChargeSound)
	self:EmitSound("npc/waste_scanner/grenade_fire.wav")
	ParticleEffect("citadel_shockwave_b",self:GetPos(),Angle(0,0,0),nil)
	if SERVER then
        self:SetNextSecondaryFire(CurTime() + 2)
		util.VJ_SphereDamage(self.Owner,self.Owner,self:GetPos(),250,math.random(220,450),DMG_BLAST,true,true)
		util.ScreenShake(self:GetPos(), 100, 500, 1, 1600)
		self:SendWeaponAnim(ACT_VM_DRAW)
		for k, v in pairs(ents.FindInSphere(self.Owner:GetPos(), 200)) do
			if v:IsNPC() && v:Disposition(self:GetOwner()) == D_HT then
				if v:Disposition(self:GetOwner()) != D_HT then return end
				v:SetVelocity(self:GetUp()*180 + self:GetForward()*500)
			end
		end
    end
		
	end

function SWEP:Hook_Think()

	/*if CLIENT then
	local dlight = DynamicLight(self.Owner:EntIndex(),false)
	if ( dlight ) then
		dlight.pos = self.Owner:GetPos() + self.Owner:GetUp()*15
		dlight.r = 0
		dlight.g = 50
		dlight.b = 255
		dlight.brightness = 5
		dlight.Decay = 1000
		dlight.Size = 160
		dlight.DieTime = CurTime() + 1
		dlight.noworld = false
		dlight.nomodel = false

	end
    end*/
end


function SWEP:Hook_PreBash(info)

if SERVER then
for _, ent in pairs(ents.FindInSphere(self.Owner:GetPos(), 150)) do
	if ent:IsNPC() or ent:IsNextBot() then
		if (self.Owner:GetEyeTrace().Entity:IsNPC() or self.Owner:GetEyeTrace().Entity:IsNextBot()) then
			self.Owner:Horde_AddBerserk(4)
			self.Owner:Horde_AddFortify(4)
			self.Owner:Horde_AddHaste(4)
			self:EmitSound("items/medshot4.wav", 300, 100, 1, CHAN_AUTO)
			HORDE:SelfHeal(self.Owner, 20)
			end
		end
	end
end

end
