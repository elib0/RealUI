local name, ns = ...
local RealUI = RealUI or ns
_G.RealUI = RealUI

RealUI.media = {
    window =        {0.03, 0.03, 0.03, 0.9},
    background =    {0.085, 0.085, 0.085, 0.9},
    colors = {
        red =       {0.85, 0.14, 0.14, 1},
        orange =    {1.00, 0.38, 0.08, 1},
        amber =     {1.00, 0.64, 0.00, 1},
        yellow =    {1.00, 1.00, 0.15, 1},
        green =     {0.13, 0.90, 0.13, 1},
        cyan =      {0.11, 0.92, 0.72, 1},
        blue =      {0.15, 0.61, 1.00, 1},
        purple =    {0.70, 0.28, 1.00, 1},
    },
    textures = {
        plain =     [[Interface\AddOns\nibRealUI\Media\Plain.tga]],
        plain80 =   [[Interface\AddOns\nibRealUI\Media\Plain80.tga]],
        plain90 =   [[Interface\AddOns\nibRealUI\Media\Plain90.tga]],
        border =    [[Interface\AddOns\nibRealUI\Media\Plain.tga]],
    },
    icons = {
        DoubleArrow =   [[Interface\AddOns\nibRealUI\Media\Icons\DoubleArrow]],
        DoubleArrow2 =  [[Interface\AddOns\nibRealUI\Media\Icons\DoubleArrow2]],
        Lightning =     [[Interface\AddOns\nibRealUI\Media\Icons\Lightning]],
        Cross =         [[Interface\AddOns\nibRealUI\Media\Icons\Cross]],
        Flame =         [[Interface\AddOns\nibRealUI\Media\Icons\Flame]],
        Heart =         [[Interface\AddOns\nibRealUI\Media\Icons\Heart]],
        PersonPlus =    [[Interface\AddOns\nibRealUI\Media\Icons\PersonPlus]],
        Shield =        [[Interface\AddOns\nibRealUI\Media\Icons\Shield]],
        Sword =         [[Interface\AddOns\nibRealUI\Media\Icons\Sword]],
    },
}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, addon)
    if event == "PLAYER_LOGIN" then
        -- Do stuff at login
        f:UnregisterEvent("PLAYER_LOGIN")
        f:UnregisterEvent("ADDON_LOADED")
    elseif event == "ADDON_LOADED" then
        if addon == "!Aurora_RealUI" then
            -- Create Aurora namespace incase Aurora is disabled
            Aurora = {}
            Aurora[1] = {} -- F, functions
            Aurora[2] = {} -- C, constants/config
            local F, C = unpack(Aurora)

            -- load RealUI overrides into Aurora namespace
            local auroraStyle = AURORA_CUSTOM_STYLE

            for i = 1, #auroraStyle.copy do
                F[auroraStyle.copy[i]] = auroraStyle.functions[auroraStyle.copy[i]]
            end

            if auroraStyle.classcolors then
                C.classcolours = auroraStyle.classcolors
                local _, class = UnitClass("player")

                r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b
                C.r, C.g, C.b = r, g, b
            end
        elseif addon == "nibRealUI" then
            if not ns.auroraLoaded then
            end
        end
    end
end)

-- Modified from Blizzard's DrawRouteLine
function RealUI:DrawLine(tex, topPoint, botPoint, canvas, relPoint, startX, startY, endX, endY, width)
    tex:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])
    if (not relPoint) then relPoint = "BOTTOMLEFT" end

    -- Determine dimensions and center point of line
    local dx,dy = endX - startX, endY - startY
    local cx,cy = (startX + endX) / 2, (startY + endY) / 2

    -- Normalize direction if necessary
    if (dx < 0) then
        dx,dy = -dx,-dy
    end

    -- Calculate actual length of line
    local l = sqrt((dx * dx) + (dy * dy))

    -- Quick escape if it's zero length
    if (l == 0) then
        tex:SetTexCoord(0,0,0,0,0,0,0,0)
        tex:SetPoint(botPoint, canvas, relPoint, cx,cy)
        tex:SetPoint(topPoint, canvas, relPoint, cx,cy)
        return
    end

    -- Sin and Cosine of rotation, and combination (for later)
    local s,c = -dy / l, dx / l
    local sc = s * c

    -- Calculate bounding box size and texture coordinates
    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy
    if (dy >= 0) then
        Bwid = ((l * c) - (width * s)) * TAXIROUTE_LINEFACTOR_2
        Bhgt = ((width * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2
        BLx, BLy, BRy = (width / l) * sc, s * s, (l / width) * sc
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx 
        TRy = BRx
    else
        Bwid = ((l * c) + (width * s)) * TAXIROUTE_LINEFACTOR_2
        Bhgt = ((width * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2
        BLx, BLy, BRx = s * s, -(l / width) * sc, 1 + (width / l) * sc
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
        TRx = TLy
    end

    -- Set texture coordinates and anchors
    tex:ClearAllPoints()
    tex:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
    tex:SetPoint(botPoint, canvas, relPoint, cx - Bwid, cy - Bhgt)
    tex:SetPoint(topPoint, canvas, relPoint, cx + Bwid, cy + Bhgt)
end

-- Math
RealUI.Round = function(value, places)
    local mult = 10 ^ (places or 0)
    return math.floor(value * mult + 0.5) / mult
end

function RealUI:GetSafeVals(vCur, vMax)
    local percent
    if vCur > 0 and vMax == 0 then
        vMax = vCur
        percent = 0.00000000000001
    elseif vCur == 0 and vMax == 0 then
        percent = 0.00000000000001
    elseif (vCur < 0) or (vMax < 0) then
        vCur = abs(vCur)
        vMax = abs(vMax)
        vMax = max(vCur, vMax)
        percent = vCur / vMax
    else
        percent = vCur / vMax
    end
    return percent, vCur, vMax
end

-- Colors
function RealUI:ColorTableToStr(vals)
    return string.format("%02x%02x%02x", vals[1] * 255, vals[2] * 255, vals[3] * 255)
end

function RealUI:GetDurabilityColor(percent)
    if percent < 0 then
        return 1, 0, 0
    elseif percent <= 0.5 then
        return 1, percent * 2, 0
    elseif percent >= 1 then
        return 0, 1, 0
    else
        return 2 - percent * 2, 1, 0
    end
end
