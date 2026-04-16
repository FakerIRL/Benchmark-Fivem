Camera = {}

local cam      = nil
local _c1, _c2 = nil, nil
local _moving  = false

local function lerp(a, b, t) return a + (b - a) * t end
local function ease(t) return t < 0.5 and 2*t*t or 1 - (-2*t+2)^2/2 end

function Camera.Create(c1data, c2data)
    Camera.Destroy()
    _c1 = c1data
    _c2 = c2data
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
    SetCamCoord(cam, c1data.pos.x, c1data.pos.y, c1data.pos.z)
    SetCamRot(cam,   c1data.rot.x, c1data.rot.y, c1data.rot.z, 2)
    SetCamFov(cam,   c1data.fov)
end

function Camera.Activate()
    if not cam then return end
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
end

-- Retourne la position corrigée si le chemin traverse un mur
local function collisionSafe(fromX, fromY, fromZ, toX, toY, toZ)
    local handle = StartShapeTestRay(fromX, fromY, fromZ, toX, toY, toZ, 1 + 16, -1, 0)
    local retval, hit, hitCoords = GetShapeTestResult(handle)
    if retval == 1 and hit then
        -- Reculer légèrement depuis le point d'impact
        local dx, dy, dz = toX - fromX, toY - fromY, toZ - fromZ
        local dl = math.sqrt(dx*dx + dy*dy + dz*dz)
        if dl > 0 then
            return hitCoords.x - (dx/dl)*0.5,
                   hitCoords.y - (dy/dl)*0.5,
                   hitCoords.z - (dz/dl)*0.5
        end
    end
    return toX, toY, toZ
end

-- Interpolation manuelle avec anti-collision murs
function Camera.StartMotion(duration)
    if not cam or not _c1 or not _c2 then return end
    _moving = true

    Citizen.CreateThread(function()
        local start   = GetGameTimer()
        local prevX   = _c1.pos.x
        local prevY   = _c1.pos.y
        local prevZ   = _c1.pos.z

        while _moving do
            Citizen.Wait(0)
            if not cam or not DoesCamExist(cam) then break end

            local t  = math.min((GetGameTimer() - start) / duration, 1.0)
            local e  = ease(t)

            local tx = lerp(_c1.pos.x, _c2.pos.x, e)
            local ty = lerp(_c1.pos.y, _c2.pos.y, e)
            local tz = lerp(_c1.pos.z, _c2.pos.z, e)

            -- Anti-traversée de murs
            local fx, fy, fz = collisionSafe(prevX, prevY, prevZ, tx, ty, tz)

            SetCamCoord(cam, fx, fy, fz)
            SetCamRot(cam,
                lerp(_c1.rot.x, _c2.rot.x, e),
                lerp(_c1.rot.y, _c2.rot.y, e),
                lerp(_c1.rot.z, _c2.rot.z, e), 2)
            SetCamFov(cam, lerp(_c1.fov, _c2.fov, e))

            prevX, prevY, prevZ = fx, fy, fz
            if t >= 1.0 then break end
        end
        _moving = false
    end)
end

function Camera.Destroy()
    _moving = false
    if cam and DoesCamExist(cam) then DestroyCam(cam, false); cam = nil end
end

function Camera.Restore()
    Camera.Destroy()
    RenderScriptCams(false, false, 0, true, false)
end
