function EFFECT:Init( data )

self.Position = data:GetStart()
self.WeaponEnt = data:GetEntity()
self.Attachment = data:GetAttachment()
self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
self.EndPos = data:GetOrigin()

self.Alpha = 255
self.FlashA = 255
end

function EFFECT:Think()
self.FlashA = self.FlashA - 1500 * FrameTime()
if ( self.FlashA < 0 ) then
self.FlashA = 0 end
self.Alpha = self.Alpha - 1500 * FrameTime()
if ( self.Alpha < 0 ) then
return false
end
return true
end

function EFFECT:Render()

render.SetMaterial( Material( "sprites/tp_beam001" ) )
render.DrawBeam( self.StartPos, self.EndPos, 50, 75, 250, Color( 255, 255, 255, math.Clamp( self.Alpha, 0, 255 ) ) )
end