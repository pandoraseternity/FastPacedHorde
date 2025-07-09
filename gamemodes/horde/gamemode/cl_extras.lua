hook.Add( "InitPostEntity", "MapVoteRestyle", function()
    if not MapVote then return end
    MapVote.style.colorPrimaryBG = Color( 50, 50, 50, 240 )
    MapVote.style.colorSecondaryFG = Color( 48, 48, 48 )
    MapVote.style.colorTextPrimary = Color( 255, 255, 255 )
    MapVote.style.colorCloseButton = Color( 255, 0, 0 )
    MapVote.style.frameBlur = 2
    MapVote.style.frameCornerRadius = 2
end )

gameevent.Listen( "player_spawn" )
hook.Add( "player_spawn", "FlashWindowOnRespawn", function( data )
    if Player( data.userid ) ~= LocalPlayer() then return end
    if system.HasFocus() then return end
    system.FlashWindow()
end )

local clr = Color(0, 0, 0, 0)
function HORDE.MaskedSphereRing(pos, radius, steps, thickness, color)
    cam.IgnoreZ(false)
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilReferenceValue(1)
    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)
    render.ClearStencil()
    render.SetColorMaterial()

    local r1, r2 = radius, radius + thickness

    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilZFailOperation(STENCIL_INCRSAT)
    render.DrawSphere(pos, -r2, steps, steps, clr)
    render.SetStencilZFailOperation(STENCIL_DECR)
    render.DrawSphere(pos, r2, steps, steps, clr)
    render.SetStencilZFailOperation(STENCIL_INCR)
    render.DrawSphere(pos, -r1, steps, steps, clr)
    render.SetStencilZFailOperation(STENCIL_DECR)
    render.DrawSphere(pos, r1, steps, steps, clr)

    local dir = LocalPlayer():EyeAngles():Forward()

    render.SetStencilCompareFunction( STENCIL_EQUAL )
    render.SetStencilReferenceValue( 1 )
    render.DrawQuadEasy(EyePos() + dir * 10, -dir, 200, 200, color, 0)

    render.SetStencilEnable(false)
end
