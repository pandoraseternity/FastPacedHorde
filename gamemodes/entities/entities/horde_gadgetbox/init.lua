AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
ENT.CleanupPriority = 2
ENT.BossGadget = false
function ENT:Initialize()

    self:SetColor(Color(255, 0, 0))
    self:SetModel("models/items/boxmrounds.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)

    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetModelScale(1.5)
    self:SetTrigger(true)
    self:UseTriggerBounds(true, 4)
	self:SetUseType(SIMPLE_USE)

    self.Removing = false
    self:PhysWake()

    timer.Simple(600, function ()
        if self:IsValid() then self:Remove() end
    end)
end

function ENT:StartTouch(entity)
    if !self.Removing
    and entity:IsPlayer()
    and entity:Alive()
    and !entity:IsBot()
    and self.Horde_Gadget 
	and self.BossGadget == false then
	entity:PrintMessage( HUD_PRINTTALK, tostring(self.Horde_Gadget) )
	elseif !self.Removing
    and entity:IsPlayer()
    and entity:Alive()
    and !entity:IsBot()
    and self.Horde_Gadget 
	and self.BossGadget then
	entity:PrintMessage( HUD_PRINTTALK, tostring(self.Horde_Gadget) )
    end
end


function ENT:Use(entity)
    if !self.Removing
    and entity:IsPlayer()
    and entity:Alive()
    and !entity:IsBot()
    and entity:Horde_GetGadget() == nil --no gadget
	and self.BossGadget == false
    and self.Horde_Gadget then
        local weight = HORDE.items[self.Horde_Gadget].weight
        if entity:Horde_GetWeight() < weight then return end
        
        local given_ammo = false 
        entity:Horde_SetGadget(self.Horde_Gadget)
        entity:Horde_SyncEconomy()
        given_ammo = true

        if given_ammo then
            self.Removing = true
            self:Remove()
        end
	elseif !self.Removing
    and entity:IsPlayer()
    and entity:Alive()
    and !entity:IsBot()
    and entity:Horde_GetGadget() --has a gadget already
	and self.BossGadget == false
    and self.Horde_Gadget then
        local weight = HORDE.items[self.Horde_Gadget].weight
        if entity:Horde_GetWeight() < weight then return end
        entity:PrintMessage( HUD_PRINTTALK, "You changed your gadget from " .. tostring(entity:Horde_GetGadget()) .. " to " .. tostring(self.Horde_Gadget) )
		
        local gadget_box = ents.Create("horde_gadgetbox")
        gadget_box.Horde_Gadget = entity:Horde_GetGadget()
        gadget_box:SetPos(self:GetPos())
        gadget_box:Spawn()
        local given_ammo = false
        entity:Horde_SetGadget(self.Horde_Gadget)
        entity:Horde_SyncEconomy()
        given_ammo = true

        if given_ammo then
            self.Removing = true
            self:Remove()
		end
	elseif !self.Removing
    and entity:IsPlayer()
    and entity:Alive()
    and !entity:IsBot()
    and self.BossGadget then--special boss weapon
		entity:Give(self.Horde_Gadget)
		--VJ_EmitSound(self,"buttons/button19.wav",1000)
		self:EmitSound( "buttons/button19.wav", 100, 100, 1, CHAN_AUTO )
		self:Remove()
end
end
