```


--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "EarlPisot",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Bisper Hub"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")


--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]
local Config = {
    -- [1] PlatoBoost Settings
    ServiceId       = 32739, -- Your PlatoBoost Service ID
    PlatoSecret     = "17b0a5a2-6842-4812-8fd8-326c12dc372f", -- Your PlatoBoost Secret Key

    -- [2] Anti-Bypass / Global Secret Variable
    Secret          = "EarlPisot", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key, they won't be able to!
    
    -- [3] Scripts & Links
    MainScriptURL   = "https://raw.githubusercontent.com/ching831/BisperKeySystem/refs/heads/main/script.lua", -- The raw URL of your main script
    
    -- [4] Social Media Settings (Set to true to show, false to hide)
    ShowDiscord     = false,
    DiscordURL      = "https://discord.gg/QJhPdCnNaR",
    
    ShowYoutube     = false,
    YoutubeURL      = "",

    -- [5] File System
    KeyFileName     = "Mykey.txt", -- The name of the file where the valid key will be saved for auto-login

    -- [6] GUI Management
    OldGuiName      = "OYB Hub", -- Name of the old GUI to destroy if it's already open
    MainGuiName     = "Bisper Hub", -- Name of the main script's GUI to check if it's already executing

    -- [7] Hub Information & UI Text
    HubName         = "Bisper Hub", -- The main title shown at the top of the GUI
    HubDescription  = "Like and Subscribe" -- The text shown below the title
}

-------------------------------------------------------------------------------
--! LIBRARIES (JSON & CRYPTOGRAPHY) - DO NOT MODIFY
-------------------------------------------------------------------------------
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

-------------------------------------------------------------------------------
--! CORE FUNCTIONS (REQUESTS & VERIFICATION)
-------------------------------------------------------------------------------

local useNonce = true 

local function safeRequest(options)
    local req = request or http_request or syn_request or (http and http.request )
    if not req then return nil, "HTTP requests not supported" end
    local success, response = pcall(function() return req(options) end)
    if success and type(response) == "table" then 
        return response 
    else 
       
        return nil, "Connection Error: " .. tostring(response or "Unknown") 
    end
end

local fSetClipboard = setclipboard or toclipboard or function() end
local fStringChar, fToString, fOsTime, fMathRandom, fMathFloor = string.char, tostring, os.time, math.random, math.floor
local fGetHwid = gethwid or function() return game:GetService("RbxAnalyticsService"):GetClientId() end

local cachedLink, cachedTime = "", 0
local host = "https://api.platoboost.com"

local function checkConnectivity( )
    local response, err = safeRequest({Url = host .. "/public/connectivity", Method = "GET"})
    if not response or (response.StatusCode ~= 200 and response.StatusCode ~= 429) then
        host = "https://api.platoboost.net"
        local fallbackResponse, fallbackErr = safeRequest({Url = host .. "/public/connectivity", Method = "GET"})
        if not fallbackResponse then
            return false 
        end
    end
    return true
end

local function generateNonce()
    local str = ""
    for _ = 1, 16 do str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97) end
    return str
end

local function cacheLink()
    local isConnected = checkConnectivity()
    if not isConnected then
        return false, "Delta/Network Error! Use VPN or change Executor."
    end
    
    if cachedTime + (10*60) < fOsTime() then
        local response, err = safeRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({service = Config.ServiceId, identifier = lDigest(fGetHwid())}),
            Headers = {["Content-Type"] = "application/json"}
        })
        if response and response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            end
        end
        return false, err or "Server Unreachable"
    end
    return true, cachedLink
end

local function redeemKey(key)
    local nonce = generateNonce()
    local body = {identifier = lDigest(fGetHwid()), key = key}
    if useNonce then body.nonce = nonce end
    
    local response, err = safeRequest({
        Url = host .. "/public/redeem/" .. fToString(Config.ServiceId),
        Method = "POST",
        Body = lEncode(body),
        Headers = {["Content-Type"] = "application/json"}
    })
    
    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            if useNonce then
                if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. Config.PlatoSecret) then 
                    if writefile then writefile(Config.KeyFileName, key) end
                    return true, "Success" 
                end
                return false, "Integrity Check Failed"
            end
            if writefile then writefile(Config.KeyFileName, key) end
            return true, "Success"
        end
        return false, decoded.message or "Invalid Key"
    end
    return false, err or "Server Error"
end

-------------------------------------------------------------------------------
--! GUI & MAIN SCRIPT EXECUTION
-------------------------------------------------------------------------------

local function StartMainScript()
    local player = game:GetService("Players").LocalPlayer
    local pGui = player:WaitForChild("PlayerGui")
    
    if pGui:FindFirstChild(Config.OldGuiName) then 
        pGui[Config.OldGuiName]:Destroy() 
        task.wait(0.1)
    end
    
    _G[Config.Secret] = true 
    
    loadstring(game:HttpGet(Config.MainScriptURL))()
end

local function CreateGUI()
    local player = game:GetService("Players").LocalPlayer
    local coreGui = game:GetService("CoreGui")
    local targetParent = coreGui

    if not pcall(function() return coreGui end) then
        targetParent = player:WaitForChild("PlayerGui")
    end

    if targetParent:FindFirstChild("OYB_KeySystem") then
        targetParent.OYB_KeySystem:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OYB_KeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetParent

    -- ============================================================
    -- PREMIUM BLACK + GOLD THEME
    -- ============================================================
    local GOLD = Color3.fromRGB(212, 175, 55)
    local LIGHT_GOLD = Color3.fromRGB(255, 221, 120)
    local DARK_GOLD = Color3.fromRGB(120, 92, 25)
    local BLACK = Color3.fromRGB(8, 8, 9)
    local CARD = Color3.fromRGB(15, 15, 17)
    local CARD_2 = Color3.fromRGB(20, 20, 22)
    local WHITE = Color3.fromRGB(245, 245, 245)
    local MUTED = Color3.fromRGB(150, 150, 155)
    local RED = Color3.fromRGB(220, 70, 70)

    local function Corner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 12)
        c.Parent = parent
        return c
    end

    local function Stroke(parent, color, thickness, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color or GOLD
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = parent
        return s
    end

    local function Gradient(parent, c1, c2, rotation)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2)
        })
        g.Rotation = rotation or 90
        g.Parent = parent
        return g
    end

    local function ButtonHover(button, normalColor, hoverColor)
        button.BackgroundColor3 = normalColor
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hoverColor
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normalColor
        end)
    end

    -- Main screen
    local Screen = Instance.new("Frame")
    Screen.Name = "MainFrame"
    Screen.Size = UDim2.new(0, 390, 0, 560)
    Screen.Position = UDim2.new(0.5, -195, 0.5, -280)
    Screen.BackgroundColor3 = BLACK
    Screen.BorderSizePixel = 0
    Screen.Active = true
    Screen.Parent = ScreenGui
    Corner(Screen, 18)
    Stroke(Screen, DARK_GOLD, 1.5, 0.15)

    -- Soft border glow
    local Glow = Instance.new("Frame")
    Glow.Name = "GoldGlow"
    Glow.Size = UDim2.new(1, 8, 1, 8)
    Glow.Position = UDim2.new(0, -4, 0, -4)
    Glow.BackgroundTransparency = 1
    Glow.ZIndex = 0
    Glow.Parent = ScreenGui
    Corner(Glow, 22)
    local GlowStroke = Stroke(Glow, GOLD, 2, 0.75)

    -- Keep glow behind the main panel
    Screen.ZIndex = 2
    Glow.ZIndex = 1

    -- Dragging
    local UIS = game:GetService("UserInputService")
    local dragging = false
    local dragStart
    local startPos

    Screen.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Screen.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Screen.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            Glow.Position = UDim2.new(
                Screen.Position.X.Scale,
                Screen.Position.X.Offset - 4,
                Screen.Position.Y.Scale,
                Screen.Position.Y.Offset - 4
            )
        end
    end)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 88)
    Header.BackgroundColor3 = Color3.fromRGB(11, 11, 12)
    Header.BorderSizePixel = 0
    Header.ZIndex = 3
    Header.Parent = Screen
    Corner(Header, 18)
    Gradient(Header, Color3.fromRGB(18, 18, 19), Color3.fromRGB(7, 7, 8), 90)

    local GoldLine = Instance.new("Frame")
    GoldLine.Size = UDim2.new(1, -36, 0, 2)
    GoldLine.Position = UDim2.new(0, 18, 1, -2)
    GoldLine.BackgroundColor3 = GOLD
    GoldLine.BorderSizePixel = 0
    GoldLine.ZIndex = 4
    GoldLine.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 0, 34)
    Title.Position = UDim2.new(0, 22, 0, 14)
    Title.BackgroundTransparency = 1
    Title.Text = "BISPER HUB"
    Title.TextColor3 = LIGHT_GOLD
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 4
    Title.Parent = Header

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -90, 0, 22)
    Subtitle.Position = UDim2.new(0, 23, 0, 47)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "PREMIUM ACCESS • KEY SYSTEM"
    Subtitle.TextColor3 = MUTED
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextSize = 10
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 4
    Subtitle.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 34, 0, 34)
    CloseBtn.Position = UDim2.new(1, -48, 0, 17)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = MUTED
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 22
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 5
    CloseBtn.Parent = Header
    Corner(CloseBtn, 10)
    Stroke(CloseBtn, Color3.fromRGB(50, 50, 52), 1)

    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
        CloseBtn.TextColor3 = RED
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        CloseBtn.TextColor3 = MUTED
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- ============================================================
    -- FIXED LIKE + SHARE UI
    -- The old script only changed HubDescription; it never created
    -- Like/Share buttons. These are now actual visible controls.
    -- ============================================================
    local SocialCard = Instance.new("Frame")
    SocialCard.Name = "LikeShareCard"
    SocialCard.Size = UDim2.new(1, -36, 0, 82)
    SocialCard.Position = UDim2.new(0, 18, 0, 102)
    SocialCard.BackgroundColor3 = CARD
    SocialCard.BorderSizePixel = 0
    SocialCard.ZIndex = 3
    SocialCard.Parent = Screen
    Corner(SocialCard, 14)
    Stroke(SocialCard, Color3.fromRGB(55, 45, 25), 1)

    local SocialTitle = Instance.new("TextLabel")
    SocialTitle.Size = UDim2.new(1, -28, 0, 22)
    SocialTitle.Position = UDim2.new(0, 14, 0, 8)
    SocialTitle.BackgroundTransparency = 1
    SocialTitle.Text = "SUPPORT BISPER HUB"
    SocialTitle.TextColor3 = LIGHT_GOLD
    SocialTitle.Font = Enum.Font.GothamBold
    SocialTitle.TextSize = 11
    SocialTitle.TextXAlignment = Enum.TextXAlignment.Left
    SocialTitle.ZIndex = 4
    SocialTitle.Parent = SocialCard

    local LikeBtn = Instance.new("TextButton")
    LikeBtn.Size = UDim2.new(0.47, -6, 0, 38)
    LikeBtn.Position = UDim2.new(0, 10, 0, 35)
    LikeBtn.BackgroundColor3 = Color3.fromRGB(25, 22, 15)
    LikeBtn.BorderSizePixel = 0
    LikeBtn.Text = "  ♡  LIKE"
    LikeBtn.TextColor3 = WHITE
    LikeBtn.Font = Enum.Font.GothamBold
    LikeBtn.TextSize = 12
    LikeBtn.AutoButtonColor = false
    LikeBtn.ZIndex = 4
    LikeBtn.Parent = SocialCard
    Corner(LikeBtn, 10)
    Stroke(LikeBtn, DARK_GOLD, 1)

    local ShareBtn = Instance.new("TextButton")
    ShareBtn.Size = UDim2.new(0.47, -6, 0, 38)
    ShareBtn.Position = UDim2.new(0.53, 0, 0, 35)
    ShareBtn.BackgroundColor3 = Color3.fromRGB(25, 22, 15)
    ShareBtn.BorderSizePixel = 0
    ShareBtn.Text = "  ↗  SHARE"
    ShareBtn.TextColor3 = WHITE
    ShareBtn.Font = Enum.Font.GothamBold
    ShareBtn.TextSize = 12
    ShareBtn.AutoButtonColor = false
    ShareBtn.ZIndex = 4
    ShareBtn.Parent = SocialCard
    Corner(ShareBtn, 10)
    Stroke(ShareBtn, DARK_GOLD, 1)

    LikeBtn.MouseEnter:Connect(function()
        LikeBtn.BackgroundColor3 = Color3.fromRGB(48, 39, 20)
        LikeBtn.TextColor3 = LIGHT_GOLD
    end)
    LikeBtn.MouseLeave:Connect(function()
        LikeBtn.BackgroundColor3 = Color3.fromRGB(25, 22, 15)
        LikeBtn.TextColor3 = WHITE
    end)

    ShareBtn.MouseEnter:Connect(function()
        ShareBtn.BackgroundColor3 = Color3.fromRGB(48, 39, 20)
        ShareBtn.TextColor3 = LIGHT_GOLD
    end)
    ShareBtn.MouseLeave:Connect(function()
        ShareBtn.BackgroundColor3 = Color3.fromRGB(25, 22, 15)
        ShareBtn.TextColor3 = WHITE
    end)

    local function GetGameLink()
        return "https://www.roblox.com/games/" .. tostring(game.PlaceId)
    end

    local function SetStatus(message, color)
        Status.Text = message
        Status.TextColor3 = color or LIGHT_GOLD
    end

    LikeBtn.MouseButton1Click:Connect(function()
        local link = GetGameLink()
        fSetClipboard(link)
        LikeBtn.Text = "  ✓  LINK COPIED"
        SetStatus("Game link copied — open the page and leave a Like!", LIGHT_GOLD)
        task.delay(2, function()
            if LikeBtn and LikeBtn.Parent then
                LikeBtn.Text = "  ♡  LIKE"
            end
        end)
    end)

    ShareBtn.MouseButton1Click:Connect(function()
        local link = GetGameLink()
        fSetClipboard(link)
        ShareBtn.Text = "  ✓  COPIED"
        SetStatus("Game link copied to clipboard!", LIGHT_GOLD)
        task.delay(2, function()
            if ShareBtn and ShareBtn.Parent then
                ShareBtn.Text = "  ↗  SHARE"
            end
        end)
    end)

    -- Description
    local PromoText = Instance.new("TextLabel")
    PromoText.Size = UDim2.new(1, -36, 0, 38)
    PromoText.Position = UDim2.new(0, 18, 0, 192)
    PromoText.BackgroundTransparency = 1
    PromoText.Text = "Like, share and support the hub."
    PromoText.TextColor3 = MUTED
    PromoText.Font = Enum.Font.GothamMedium
    PromoText.TextSize = 12
    PromoText.TextXAlignment = Enum.TextXAlignment.Left
    PromoText.ZIndex = 3
    PromoText.Parent = Screen

    -- Social buttons from config
    local currentYOffset = 232

    if Config.ShowDiscord then
        local DiscordBtn = Instance.new("TextButton")
        DiscordBtn.Size = UDim2.new(1, -36, 0, 40)
        DiscordBtn.Position = UDim2.new(0, 18, 0, currentYOffset)
        DiscordBtn.Text = "  DISCORD"
        DiscordBtn.Font = Enum.Font.GothamBold
        DiscordBtn.TextSize = 12
        DiscordBtn.TextColor3 = WHITE
        DiscordBtn.TextXAlignment = Enum.TextXAlignment.Center
        DiscordBtn.BackgroundColor3 = CARD_2
        DiscordBtn.AutoButtonColor = false
        DiscordBtn.ZIndex = 3
        DiscordBtn.Parent = Screen
        Corner(DiscordBtn, 10)
        Stroke(DiscordBtn, DARK_GOLD, 1)

        DiscordBtn.MouseEnter:Connect(function()
            DiscordBtn.BackgroundColor3 = Color3.fromRGB(42, 35, 19)
        end)
        DiscordBtn.MouseLeave:Connect(function()
            DiscordBtn.BackgroundColor3 = CARD_2
        end)

        DiscordBtn.MouseButton1Click:Connect(function()
            fSetClipboard(Config.DiscordURL)
            SetStatus("Discord invite copied!", LIGHT_GOLD)
        end)

        currentYOffset = currentYOffset + 48
    end

    if Config.ShowYoutube then
        local YTBtn = Instance.new("TextButton")
        YTBtn.Size = UDim2.new(1, -36, 0, 40)
        YTBtn.Position = UDim2.new(0, 18, 0, currentYOffset)
        YTBtn.Text = "  YOUTUBE"
        YTBtn.Font = Enum.Font.GothamBold
        YTBtn.TextSize = 12
        YTBtn.TextColor3 = WHITE
        YTBtn.BackgroundColor3 = CARD_2
        YTBtn.AutoButtonColor = false
        YTBtn.ZIndex = 3
        YTBtn.Parent = Screen
        Corner(YTBtn, 10)
        Stroke(YTBtn, DARK_GOLD, 1)

        YTBtn.MouseEnter:Connect(function()
            YTBtn.BackgroundColor3 = Color3.fromRGB(42, 35, 19)
        end)
        YTBtn.MouseLeave:Connect(function()
            YTBtn.BackgroundColor3 = CARD_2
        end)

        YTBtn.MouseButton1Click:Connect(function()
            if Config.YoutubeURL ~= "" then
                fSetClipboard(Config.YoutubeURL)
                SetStatus("YouTube link copied!", LIGHT_GOLD)
            else
                SetStatus("YouTube link is not configured.", MUTED)
            end
        end)

        currentYOffset = currentYOffset + 48
    end

    -- Key section
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.new(1, -36, 0, 22)
    KeyLabel.Position = UDim2.new(0, 18, 0, currentYOffset)
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.Text = "ACCESS KEY"
    KeyLabel.TextColor3 = LIGHT_GOLD
    KeyLabel.Font = Enum.Font.GothamBold
    KeyLabel.TextSize = 11
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyLabel.ZIndex = 3
    KeyLabel.Parent = Screen

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -36, 0, 44)
    KeyInput.Position = UDim2.new(0, 18, 0, currentYOffset + 26)
    KeyInput.PlaceholderText = "Enter your key..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(105, 105, 110)
    KeyInput.Text = ""
    KeyInput.Font = Enum.Font.GothamSemibold
    KeyInput.TextSize = 13
    KeyInput.BackgroundColor3 = Color3.fromRGB(12, 12, 13)
    KeyInput.TextColor3 = WHITE
    KeyInput.ClearTextOnFocus = false
    KeyInput.ZIndex = 3
    KeyInput.Parent = Screen
    Corner(KeyInput, 10)
    Stroke(KeyInput, Color3.fromRGB(55, 55, 58), 1)

    KeyInput.Focused:Connect(function()
        local s = KeyInput:FindFirstChildOfClass("UIStroke")
        if s then s.Color = GOLD end
    end)
    KeyInput.FocusLost:Connect(function()
        local s = KeyInput:FindFirstChildOfClass("UIStroke")
        if s then s.Color = Color3.fromRGB(55, 55, 58) end
    end)

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Size = UDim2.new(0.48, -5, 0, 42)
    VerifyBtn.Position = UDim2.new(0, 18, 0, currentYOffset + 80)
    VerifyBtn.Text = "VERIFY KEY"
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.TextSize = 12
    VerifyBtn.BackgroundColor3 = GOLD
    VerifyBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
    VerifyBtn.AutoButtonColor = false
    VerifyBtn.ZIndex = 3
    VerifyBtn.Parent = Screen
    Corner(VerifyBtn, 10)

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.48, -5, 0, 42)
    GetKeyBtn.Position = UDim2.new(0.52, 0, 0, currentYOffset + 80)
    GetKeyBtn.Text = "GET KEY"
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 12
    GetKeyBtn.BackgroundColor3 = CARD_2
    GetKeyBtn.TextColor3 = WHITE
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.ZIndex = 3
    GetKeyBtn.Parent = Screen
    Corner(GetKeyBtn, 10)
    Stroke(GetKeyBtn, DARK_GOLD, 1)

    VerifyBtn.MouseEnter:Connect(function()
        VerifyBtn.BackgroundColor3 = LIGHT_GOLD
    end)
    VerifyBtn.MouseLeave:Connect(function()
        VerifyBtn.BackgroundColor3 = GOLD
    end)

    GetKeyBtn.MouseEnter:Connect(function()
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(42, 35, 19)
        GetKeyBtn.TextColor3 = LIGHT_GOLD
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        GetKeyBtn.BackgroundColor3 = CARD_2
        GetKeyBtn.TextColor3 = WHITE
    end)

    local Status = Instance.new("TextLabel")
    Status.Name = "StatusLabel"
    Status.Size = UDim2.new(1, -36, 0, 32)
    Status.Position = UDim2.new(0, 18, 0, currentYOffset + 132)
    Status.BackgroundTransparency = 1
    Status.Text = "Waiting for input..."
    Status.TextColor3 = MUTED
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 11
    Status.TextWrapped = true
    Status.ZIndex = 3
    Status.Parent = Screen

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, -36, 0, 20)
    Footer.Position = UDim2.new(0, 18, 1, -28)
    Footer.BackgroundTransparency = 1
    Footer.Text = "BISPER HUB  •  PREMIUM EDITION"
    Footer.TextColor3 = Color3.fromRGB(95, 80, 45)
    Footer.Font = Enum.Font.GothamBold
    Footer.TextSize = 9
    Footer.TextXAlignment = Enum.TextXAlignment.Center
    Footer.ZIndex = 3
    Footer.Parent = Screen

    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key == "" then
            SetStatus("Please enter a key.", RED)
            return
        end

        VerifyBtn.Text = "VERIFYING..."
        SetStatus("Checking key...", MUTED)

        local success, msg = redeemKey(key)

        if success then
            SetStatus("Success! Loading Bisper Hub...", Color3.fromRGB(100, 220, 130))
            task.wait(0.5)
            ScreenGui:Destroy()
            StartMainScript()
        else
            VerifyBtn.Text = "VERIFY KEY"
            SetStatus(tostring(msg), RED)
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        GetKeyBtn.Text = "LOADING..."
        SetStatus("Generating your key link...", MUTED)

        local success, link = cacheLink()

        if success then
            fSetClipboard(link)
            GetKeyBtn.Text = "COPIED"
            SetStatus("Key link copied to clipboard!", LIGHT_GOLD)
            task.delay(2, function()
                if GetKeyBtn and GetKeyBtn.Parent then
                    GetKeyBtn.Text = "GET KEY"
                end
            end)
        else
            GetKeyBtn.Text = "GET KEY"
            SetStatus(tostring(link), RED)
        end
    end)

    -- Auto-login
    if isfile and isfile(Config.KeyFileName) then
        local savedKey = readfile(Config.KeyFileName)

        if savedKey ~= "" then
            SetStatus("Saved key found — verifying...", MUTED)

            task.spawn(function()
                local success, msg = redeemKey(savedKey)

                if success then
                    SetStatus("Auto-login successful!", Color3.fromRGB(100, 220, 130))
                    task.wait(0.5)
                    ScreenGui:Destroy()
                    StartMainScript()
                else
                    SetStatus("Saved key expired or invalid.", Color3.fromRGB(230, 170, 70))
                end
            end)
        end
    end
end

local player = game:GetService("Players").LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

if pGui:FindFirstChild(Config.MainGuiName) then
    StartMainScript() 
    return
end

CreateGUI()
```
