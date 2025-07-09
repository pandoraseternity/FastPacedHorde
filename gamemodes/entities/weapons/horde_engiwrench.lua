AddCSLuaFile()

if CLIENT then
	if buildermenu then buildermenu:Remove() end
	--SWEP.WepSelectIcon		= surface.GetTextureID("vgui/entities/weapon_builder") 
	SWEP.BounceWeaponIcon	= false 
	language.Add("horde_engiwrench", "Builder")
	--killicon.Add("weapon_builder", "effects/killicons/weapon_builder", color_white )
end

--[[ -- put this into the entity code you want to become buildable

Builder_AddClass("sent_mysent", {
	PrintName = ENT.PrintName,
	Name = "sent_mysent", -- our class name
	mdl = "models/resident_evil/t-virus_vial_shattered.mdl", -- our in construction model
	cost = 25 -- ammount of hammer swings
})

]]
	
Builder_EntitiesNum = 0
Builder_EntitiesLoaded = false
timer.Simple( 1, function()
	local tab, ent = list.Get( "SpawnableEntities" ), scripted_ents.GetList()
	local tab2 = list.Get( "NPC" )
	for k, v in pairs( Horde_EntitiesTBL ) do
		if v.lua and !istable( ent[ v.Name ] ) then
			Horde_EntitiesTBL[ k ] = nil
			continue
		end
		Builder_EntitiesNum = Builder_EntitiesNum +1
	end
	Builder_EntitiesLoaded = true
end )

Horde_EntitiesTBL = {
	[ "npc_turret_floor" ] = { taps = 4, EntName = "npc_turret_floor", PrintName = "Rebel Turret", mdl = "models/combine_turrets/floor_turret.mdl", money = 1000, limit = 3},
	[ "npc_vj_horde_shotgun_turret" ] = { taps = 4, EntName = "npc_vj_horde_shotgun_turret", PrintName = "Shotgun Turret", mdl = "models/combine_turrets/floor_turret.mdl", money = 1200, limit = 3},
	[ "npc_vj_horde_rocket_turret" ] = { taps = 5, EntName = "npc_vj_horde_rocket_turret", PrintName = "Rocket Turret", mdl = "models/horde/rocket_turret/rocket_turret.mdl", money = 1350, limit = 2},
	[ "npc_vj_horde_sniper_turret" ] = { taps = 5, EntName = "npc_vj_horde_sniper_turret", PrintName = "Sniper Turret", mdl = "models/combine_turrets/ground_turret.mdl", money = 1500, limit = 2},
	[ "npc_vj_horde_laser_turret" ] = { taps = 6, EntName = "npc_vj_horde_laser_turret", PrintName = "Laser Turret", mdl = "models/horde/rocket_turret/rocket_turret.mdl", money = 1500, limit = 2},
	[ "npc_vj_horde_survey" ] = { taps = 6, EntName = "npc_vj_horde_survey", PrintName = "Gatekeeper/Defense Machine", mdl = "models/Zombie/Poison.mdl", money = 2000, limit = 2},
	[ "npc_vj_horde_combat_bot" ] = { taps = 7, EntName = "npc_vj_horde_combat_bot", PrintName = "Combat Bot", mdl = "models/dog.mdl", money = 2500, limit = 1},
}

function BuilderIsCreature( ent ) return ( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:GetClass():find("prop_ragdoll") ) end

SWEP.PrintName			= "Builder"		
SWEP.Slot				= 5
SWEP.SlotPos			= 10
SWEP.DrawAmmo			= false
SWEP.HoldType			= "melee" 

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Purpose			= "Fight zombies using minions."
SWEP.Instructions		= "Left Click to progress building. \nRight click to deconstruct. \nReload to open menu."
SWEP.Category           = "Horde"
SWEP.DrawCrosshair		= false
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.ViewModelFOV		= 65
SWEP.ViewModelFlip		= false
SWEP.UseHands 			= true
--models/weapons/c_hammer1.mdl models/weapons/w_hammer1.mdl
SWEP.ViewModel			= "models/weapons/c_hammer1.mdl"
SWEP.WorldModel			= "models/weapons/w_hammer1.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 0.5
SWEP.Primary.Force			= 150
SWEP.Primary.Damage			= 30

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Delay			= 1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"
SWEP.nextreload = 0
SWEP.warningtap = 0

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetWeaponHoldType(self.HoldType)

	self.EntityName = NULL

	self.BT = NULL
	
	self.Idle = 0
	self.IdleTimer = CurTime() + 1
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
	self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
	
	self.modelrad = 128
	self.modelheight = 0
	self.buildEnt = NULL
	self.cooldwn = CurTime()
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	self:NextThink( CurTime() + self:SequenceDuration() )
	return true
end

function SWEP:OnDrop( )
	self:Holster()
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:Holster()
	if IsValid(self.buildEnt) then
		self.buildEnt:Remove()
	end
	
	self.Idle = 0
	self.IdleTimer = CurTime()
	return true
end

function SWEP:Think()
	local own = self:GetOwner()
	
	if SERVER && self:GetNWBool( "ReadytoBuild", false ) == true then
		if self.modelrad == nil then return end
		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * (96),--+buildingent:GetModelBounds()
			filter = self.Owner,
			mask = MASK_SOLID,
		} )
		if tr.Hit then
			if !IsValid(self.buildEnt) then
				self.buildEnt = ents.Create("sent_construction")
				if !IsValid(self.buildEnt) then return end
				self.buildEnt.EntToBuild = self:GetBuildEntity()
				self.buildEnt:SetColor(Color(255,255,255,50))
				self.buildEnt:SetModel(self:GetBuildEntModel())
				self.buildEnt:SetRenderMode(RENDERMODE_TRANSCOLOR)
				self.buildEnt:SetPos(tr.HitPos + tr.HitNormal*self.modelheight)
				self.buildEnt:SetAngles(Angle(0,own:GetAngles().y+180,0))
				self.buildEnt:SetPlayer(own)
				self.buildEnt:SetState( 0 )
				self.modelrad = self.buildEnt:GetModelRadius()
				local mins, maxs = self.buildEnt:GetModelBounds()
				
				if mins == nil then return end
				self.modelheight = -mins.z
			else
				self.buildEnt:SetPos(tr.HitPos + tr.HitNormal*self.modelheight)
				self.buildEnt:SetAngles(Angle(0,self.Owner:GetAngles().y+180,0))
				if self.buildEnt.EntToBuild != self:GetBuildEntity() then
					if IsValid(self.buildEnt) then
						self.buildEnt:Remove()
					end
				end
			end
		elseif tr.Hit == false then
			if !IsValid(self.buildEnt) then return end
			self.buildEnt:Remove()
		end
		
	elseif SERVER && self:GetNWBool( "ReadytoBuild", false ) == false then
		if !IsValid(self.buildEnt) then return end
		self.buildEnt:Remove()
	end
	
end

function SWEP:PrimaryAttack()
        --ply:Horde_AddMoney(-(ply:Horde_GetMoney()))
        --ply:Horde_SyncEconomy() .FalldamageImmune = true :SetNWEntity("HordeOwner", ply)
	local own = self:GetOwner()
    local dir = self:GetForward()
    local src = own:GetShootPos() - dir * 64
	own:LagCompensation( true )
	
	if SERVER && self:GetNWBool( "ReadytoBuild", false ) == true then
		if self.modelrad == nil then return end
		local tr2 = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * (96),--+buildingent:GetModelBounds()
			filter = self.Owner,
			mask = MASK_SOLID,
		} )
		if tr2.Hit then
			if own:Horde_GetMoney() <= self:GetBuildEntMoney() then
				self:EmitSound( "weapons/wrench_hit_build_fail.wav",80,math.random( 95, 100 ) )
				self:EmitSound( "buttons/button8.wav",80,math.random( 95, 100 ) )
				self.buildEnt:Remove()
				self:SetNWBool( "ReadytoBuild", false )
			return end
			local own = self:GetOwner()
			local drop_entities = own:Horde_GetDropEntities()
			if drop_entities[self.buildEnt.EntToBuild] then
				if drop_entities[self.buildEnt.EntToBuild] >= self:GetBuildEntLimit() then 
				self:EmitSound( "weapons/wrench_hit_build_fail.wav",80,math.random( 95, 100 ) )
				self:EmitSound( "buttons/button8.wav",80,math.random( 95, 100 ) )
				self.buildEnt:Remove()
				self:SetNWBool( "ReadytoBuild", false )
				--print(self.buildEnt.EntToBuild)
				return end
			end
			--print(self:GetBuildEntMoney())
			local EntToBuildClassname = self.buildEnt.EntToBuild
			self.buildEnt:SetColor(Color(255,255,255,100))
			self.buildEnt.EntToBuildCost = self:GetBuildEntTaps()
			self.buildEnt:SetNWEntity("HordeOwner", own)
			self.buildEnt:SetOwner(own)
			self.buildEnt:Spawn()
			self.buildEnt:Activate()
			--self.buildEnt:SetOwned( own )
			self.buildEnt:SetNick( self:GetBuildEntPrintName() )
			self.buildEnt:SetState( 1 )
			self.buildEnt = NULL
			sound.Play("weapons/building.wav",self:GetPos() + self:GetUp()*16,80,120)
			own:Horde_AddMoney(-self:GetBuildEntMoney())
			own:Horde_SyncEconomy()
			self:SetNWBool( "ReadytoBuild", false )
		end
	end
	
	local tr = util.TraceHull( {
	start = own:GetShootPos(),
	endpos = own:GetShootPos() + own:GetAimVector() * 96,
	filter = own,
	mask = MASK_SHOT_HULL,
	} )
	if !IsValid( tr.Entity ) then
		tr = util.TraceHull( {
		start = own:GetShootPos(),
		endpos = own:GetShootPos() + own:GetAimVector() * 96,
		filter = own,
		mins = Vector( -16, -16, 0 ),
		maxs = Vector( 16, 16, 0 ),
		mask = MASK_SHOT_HULL,
		} )
	end
	own:SetAnimation( PLAYER_ATTACK1 )--or tr.Entity == Entity( 0 )
	self:SendWeaponAnim( ACT_VM_HITCENTER )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	own:EmitSound( "weapons/iceaxe/iceaxe_swing1.wav",80,math.random( 95, 100 ) )
	if SERVER and ( IsValid( tr.Entity ) && !tr.Entity:IsWorld() ) then
		own:EmitSound( ")weapons/cbar_hitbod"..math.random(1,3)..".wav", 80, math.random( 95, 100 ) )
		if HORDE:IsEnemy(tr.Entity) then
			self:FireBullets({
				Attacker = own,
				Damage = 60,
				Force = 1,
				Distance = 1024,
				HullSize = 16,
				Num = 1,
				Tracer = 1,
				Src = src,
				Dir = dir,
				Spread = Vector(0, 0, 0),
				IgnoreEntity = self,
			})
		elseif tr.Entity:GetClass() == "sent_construction" then
			local own = self:GetOwner()
			tr.Entity:SetProgress( math.Round(tr.Entity:GetProgress() + 100/tr.Entity.EntToBuildCost,2) )
			own:Horde_AddMoney(-(25))
			own:Horde_SyncEconomy()
		end
	elseif SERVER and ( tr.Entity:IsWorld() ) then
		own:EmitSound( "weapons/cbar_hit"..math.random(1,2)..".wav",80,math.random( 95, 100 ) )
	end
	own:LagCompensation( false )
end

function SWEP:SecondaryAttack()	
	local own = self:GetOwner()
    local dir = self:GetForward()
    local src = own:GetShootPos() - dir * 64
	own:LagCompensation( true )
	
	local tr = util.TraceHull( {
	start = own:GetShootPos(),
	endpos = own:GetShootPos() + own:GetAimVector() * 96,
	filter = own,
	mins = Vector( -12, -12, -12 ),
	maxs = Vector( 12, 12, 12 ),
	mask = MASK_SHOT_HULL,
	} )
	
	own:SetAnimation( PLAYER_ATTACK1 )
	self:SendWeaponAnim( ACT_VM_HITCENTER )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	own:EmitSound( "horde/weapons/jotuun/attack.ogg",80,math.random( 95, 100 ) )
	if SERVER and ( IsValid( tr.Entity ) && !tr.Entity:IsWorld() ) then
		own:EmitSound( "horde/weapons/jotuun/hit1.ogg",80,math.random( 95, 100 ) )
		local v2 = tr.Entity
		local drop_entities = own:Horde_GetDropEntities()
		if tr.Entity:GetClass() == "sent_construction" then
			own:Horde_AddMoney(self:GetBuildEntMoney())
			own:Horde_SyncEconomy()
			v2:Remove()
		elseif drop_entities[v2:GetClass()] && self.warningtap < 1 then
			self.warningtap = self.warningtap + 1
			own:PrintMessage( HUD_PRINTCENTER, "You sure you wanna sell this?" )
			timer.Simple( 3, function() if self.warningtap == 1 then
					own:PrintMessage( HUD_PRINTCENTER, "Selling status reset, tap twice to sell once more" )
					self.warningtap = self.warningtap - 1
				end
			end )
		elseif drop_entities[v2:GetClass()] && self.warningtap == 1 then
			sound.Play("weapons/building.wav",self:GetPos() + self:GetUp()*16,80,120)
			own:Horde_AddMoney(v2:GetNWInt("SellMoney"))
			own:Horde_SyncEconomy()
			v2:Remove() 
			self.warningtap = 0
		elseif HORDE:IsEnemy(tr.Entity) then
			self:FireBullets({
				Attacker = own,
				Damage = 120,
				Force = 1,
				Distance = 1024,
				HullSize = 16,
				Num = 1,
				Tracer = 1,
				Src = src,
				Dir = dir,
				Spread = Vector(0, 0, 0),
				IgnoreEntity = self,
			})
		end
	elseif SERVER and ( tr.Entity:IsWorld() ) then
		own:EmitSound( "weapons/cbar_hit"..math.random(1,2)..".wav",80,math.random( 95, 100 ) )
	end
	own:LagCompensation( false )
end

function SWEP:SetupDataTables() --there is a :Set and a :Get for each variable
 
	--self:NetworkVar( "Entity", 0, "BuildEntity" )
	self:NetworkVar( "String", 0, "BuildEntity" )
	self:NetworkVar( "String", 1, "BuildEntModel" )
	self:NetworkVar( "String", 2, "BuildEntPrintName" )
	self:NetworkVar( "Int", 0, "BuildEntTaps" )
	self:NetworkVar( "Int", 1, "BuildEntMoney" )
	self:NetworkVar( "Int", 2, "BuildEntAmount" )
	self:NetworkVar( "Int", 3, "BuildEntLimit" )
end

--	[ "combine_mine" ] = { taps = 2, EntName = "combine_mine", PrintName = "Combine Mine", mdl = "models/props_combine/combine_mine01.mdl", money = 250, limit = 1},
if SERVER then
	util.AddNetworkString( "sendToBuilder2" )
	util.AddNetworkString( "builderMenu2" )
	net.Receive("sendToBuilder2",function(len,ply)
		local cls = net.ReadString()
		if !istable( Horde_EntitiesTBL[ cls ] ) then return end
		if IsValid( ply ) and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() == "horde_engiwrench" then
			local tab = Horde_EntitiesTBL[ cls ]
			local weap = ply:GetActiveWeapon()
			weap:SetBuildEntTaps(tab.taps)
			--weap:SetNWString( "WORK", tab.EntName ) cause you dont wanna work you piece of shit
			weap:SetBuildEntity(tab.EntName)
			weap:SetBuildEntModel(tab.mdl)
			weap:SetBuildEntPrintName(tab.PrintName)
			weap:SetBuildEntMoney(tab.money)
			weap:SetBuildEntLimit(tab.limit)
			weap:SetNWBool( "ReadytoBuild", true )
		end
	end)
	
else -- CLIENT
	net.Receive("builderMenu2",function()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) and wep:GetClass() == "horde_engiwrench" then
			wep:Reload()
		end
	end)
end


function SWEP:Reload()
	if ( !self:IsValid() ) or !Builder_EntitiesLoaded then return false end
	if CurTime() > self.nextreload then
		self.nextreload = CurTime() + 1
		if SERVER then
			net.Start( "builderMenu2" )
			net.Send( self.Owner )
			return
		end local new = false
		if !IsValid( buildermenu2 ) then new = true
			buildermenu = vgui.Create( "DFrame" )
			buildermenu:SetSize( ScrW() / 2.2, ScrH() / 1.5 )
			buildermenu:SetTitle( "" )
			buildermenu:SetIcon( "icon16/script_gear.png" )
			buildermenu:SetDraggable( false )
			buildermenu:SetAlpha( 1 )
			buildermenu:ShowCloseButton(false)
		end local frame = buildermenu
		frame:AlphaTo( 255, 0.25 )
		frame:MakePopup()
		frame:Center()
		frame:Show()
		frame.B_Close = false
		frame:SetKeyboardInputEnabled( true )
		frame:SetMouseInputEnabled( true )
		frame.N_Scrap = 0
		if !new then return end
		function frame:Paint( w, h )
			if IsValid( LocalPlayer() ) then
				frame.N_Scrap = LocalPlayer():Horde_GetMoney()
			end--:GetNWInt( "Scrap" )
			Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
			surface.SetDrawColor(255, 255, 255, (150 + math.sin(RealTime() * 5.2) * 100) * .8)
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.DrawOutlinedRect( 0, 0, w, 25 )
			draw.TextShadow( {
				text = "Builder Menu\t[Money:"..frame.N_Scrap.."]",
				pos = { 26, 12 },
				font = "Trebuchet24",
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER,
				color = Color( 225, 255, 0 )
			}, 1, 255 )
		end
		function frame:DoClose()
			if frame.B_Close then return end frame.B_Close = true
			frame:AlphaTo( 1, 0.25 )
			frame:SetKeyboardInputEnabled( false )
			frame:SetMouseInputEnabled( false )
			timer.Simple( 0.25, function()
				if IsValid( frame ) and frame.B_Close then frame:Hide() end
			end )
		end
        local CloseButton = frame:Add( "DButton" )  local pax = CloseButton
		pax:SetText( "" )
		pax:SetPos( 810, 3 )
		pax:SetSize( 60, 18 )
		pax.B_Hover = false
		function pax:Paint( w, h )
			draw.TextShadow( {
				text = "Close",
				pos = { w/2, h/2 },
				font = "CloseCaption_Normal",
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = ( pax.B_Hover and Color( 255, 0, 0 ) or Color( 255, 255, 255 ) )
			}, 1, 255 )
		end
		function pax:DoClick() frame:DoClose() end
		function pax:OnCursorEntered() pax.B_Hover = true end
		function pax:OnCursorExited() pax.B_Hover = false end
		
		local PropPanel = vgui.Create( "ContentContainer", frame )
		PropPanel:SetTriggerSpawnlistChange( false )
		PropPanel:Dock( FILL )

		local Categorised = {}

		Categorised[ "Available Entities ("..Builder_EntitiesNum..")" ] = Horde_EntitiesTBL

		for CategoryName, v in SortedPairs( Categorised ) do
			local Header = vgui.Create( "ContentHeader", PropPanel )
			Header:SetText( CategoryName )
			PropPanel:Add( Header )
			for k, WeaponTable in SortedPairsByMemberValue( v, "PrintName" ) do
				if WeaponTable.PrintName ~= nil then
					local icon = vgui.Create( "ContentIcon", PropPanel )
					icon.ClassName = k
					
					local iconpath = "entities/"..WeaponTable.PrintName.. ".png"
					if !file.Exists( "materials/"..iconpath, "game" ) then
						iconpath = "vgui/entities/"..WeaponTable.PrintName.. ".vmt"
					end
					
					icon:SetMaterial( iconpath )
					icon:SetName( WeaponTable.PrintName )--and WeaponTable.cost*5
					icon:SetToolTip( "Cost: "..( WeaponTable.money or "???" ).." Taps: "..( WeaponTable.taps or "???" ).." Limit: "..( WeaponTable.limit or "???" ) )
					icon.DoClick = function()
						frame:DoClose()
						net.Start("sendToBuilder2")
						net.WriteString( icon.ClassName )
						net.SendToServer()
						--print(WeaponTable.Name)
					end
					PropPanel:Add( icon )
				end
			end
			
		end
	end

end



if CLIENT then
	surface.CreateFont( "ScrapFont", {
		font = "Digital-7",
		size = 50,
		weight = 400,
		scanlines = true,
		antialias = true
	})
	surface.CreateFont( "ScrapFont2", {
		font = "Digital-7",
		size = 36,
		weight = 400,
		scanlines = true,
		antialias = true
	})
	local scrap = Material( "icon/refined_metal.png" )
	/*hook.Add( "HUDPaint", "BuilderHud", function()
		local traceRes = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
		local fade = LocalPlayer().UIScrapFade or 0
		local negative = 0
		local w = 50
		local h = ScrH()/3
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) then
			if wep:GetClass() == "horde_engiwrench" then
				fade = 200
			end
		end
		if fade > negative then
			local alpha = math.Clamp(fade,negative,100)/100
			if fade > negative then
				LocalPlayer().UIScrapFade = math.Clamp(fade,negative,400) - 1
				w = math.Clamp(fade,negative,100)/2
			end
			surface.SetDrawColor(255, 200, 25, (150 + math.sin(RealTime() * 5.2) * 100) * .8*alpha)
			surface.DrawOutlinedRect( w, h, 128, 128 )
				
			surface.SetDrawColor( 0, 0, 0, 128 * alpha )
			surface.DrawRect( w, h, 128, 128 )
				
			surface.SetDrawColor(255, 255, 255, 255 * alpha)
			surface.SetMaterial(scrap)
			surface.DrawTexturedRect(w, h - 20, 128, 128)
				
			draw.SimpleText( tostring(math.Clamp(LocalPlayer():Horde_GetMoney())), "ScrapFont", w + 65, h + 78, Color( 255, 200, 25, 255 * alpha ), 1, 0 )
		end
	end )*/

	if true then local nam = "builderef1"
        local EFFECT = {}
        function EFFECT:Init( data )
            local pos = data:GetOrigin()
            self:SetRenderBounds( -Vector( 32, 32, 32 ), Vector( 32, 32, 32 ) )
            self.Emitter = ParticleEmitter( pos )
            for i=1, math.random( 8, 16 ) do
                local particle = self.Emitter:Add( "effects/spark", pos )
                particle:SetVelocity( VectorRand():GetNormalized()*math.random( 48, 96 ) )
                particle:SetLifeTime( 0 )
                particle:SetDieTime( 0.5 )
                local Siz = math.Rand( 1, 3 )
                particle:SetStartSize( Siz )
                particle:SetEndSize( 0 )
                particle:SetStartLength( Siz*2 )
                particle:SetEndLength( Siz )
                particle:SetStartAlpha( 128 )
                particle:SetEndAlpha( 0 )
                particle:SetColor( 255, 255, 128 )
                particle:SetLighting( false )
                particle:SetCollide( true )
                particle:SetGravity( Vector( 0, 0, -128 ) )
                particle:SetBounce( 1 )
            end
            for i=1, 4 do
                local particle = self.Emitter:Add( "particle/particle_smokegrenade1", pos )
                if particle then
                    particle:SetVelocity( VectorRand():GetNormalized()*math.random( 32, 64 ) )
                    particle:SetLifeTime( 0 )
                    particle:SetDieTime( math.Rand( 0.5, 1 ) )
                    particle:SetStartAlpha( 32 )
                    particle:SetEndAlpha( 0 )
                    local Siz = math.Rand( 12, 24 )
                    particle:SetStartSize( Siz/4 )
                    particle:SetEndSize( Siz )
                    particle:SetRoll( math.random( 0, 360 ) )
                    particle:SetColor( 128, 128, 128 )
                    particle:SetGravity( Vector( 0, 0, math.random( 32, 64 ) ) )
                    particle:SetAirResistance( 256 )
                    particle:SetCollide( true )
                    particle:SetBounce( 1 )
                end
            end
            local dlight = DynamicLight( 0 )
            if dlight then
                dlight.pos = pos
                dlight.r = 255
                dlight.g = 255
                dlight.b = 128
                dlight.brightness = 1
                dlight.decay = 128
                dlight.size = 64
                dlight.dietime = CurTime()+0.5
            end
			for i=1, math.random( 1, 4 ) do
				local ef = EffectData()  ef:SetOrigin( pos ) util.Effect( "builderef2", ef )
			end
        end
        function EFFECT:Think() return false end
        function EFFECT:Render() return end
        effects.Register( EFFECT, nam )
	end
	if true then local nam = "builderef2"
		local EFFECT = {}
		function EFFECT:Init( data )
			self.Entity:SetModel( "models/gibs/metal_gib"..math.random( 1, 5 )..".mdl" )
			self.Entity:PhysicsInit( SOLID_VPHYSICS )
			self.Entity:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )
			self.Entity:SetModelScale( math.Rand( 0.25, 0.5 ) )
			self.Entity:SetRenderMode( RENDERMODE_TRANSCOLOR )
			local phys = self.Entity:GetPhysicsObject()
			if IsValid( phys ) then
				phys:Wake()
				phys:EnableMotion( true )
				phys:SetMaterial( "gmod_silent" )
				phys:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
				local vel = VectorRand():GetNormalized()*math.Rand( 64, 128 )
				vel = Vector( vel.x, vel.y, math.abs( vel.z ) )
				phys:SetVelocity( vel ) phys:Wake()
			end
			self.LifeTime = CurTime() +math.Rand( 0.5, 1 )
			self.LifeAlp = 255
		end
		function EFFECT:PhysicsCollide( data, physobj ) end
		function EFFECT:Think()
			local own = self.Entity
			if self.LifeTime < CurTime() then
				self.LifeAlp = Lerp( 0.05, self.LifeAlp, 0 )
				self.Entity:SetColor( Color( own:GetColor().r, own:GetColor().g, own:GetColor().b, self.LifeAlp ) )
				if self.LifeAlp <= 1 then return false end
			end return true
		end
		function EFFECT:Render() self.Entity:DrawModel() end
		effects.Register( EFFECT, nam )
	end
end