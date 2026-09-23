local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    error("[AdminAbuse] This must run as a LocalScript, not a server Script.")
end

local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then
    error("[AdminAbuse] PlayerGui was not available. Put the LocalScript in StarterPlayerScripts or StarterGui.")
end

local function findPath(root, ...)
    local current = root
    for _, name in ipairs({ ... }) do
        current = current and current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

local function tryRequire(moduleScript)
    if not moduleScript or not moduleScript:IsA("ModuleScript") then return nil end
    local ok, result = pcall(require, moduleScript)
    return ok and result or nil
end

local function fallbackNotification(data)
    data = data or {}
    local text = tostring(data.Message or data.Text or "")
        :gsub("<[^>]->", "")
        :gsub("\n", " ")
    local ok = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Admin Abuse",
            Text = text,
            Duration = tonumber(data.Time) or 5,
        })
    end)
    if not ok then warn("[AdminAbuse] " .. text) end
end

local loadedAreas = tryRequire(findPath(ReplicatedStorage, "Data", "Areas"))
local areas = type(loadedAreas) == "table" and loadedAreas or { Directory = {} }

local function usableNotification(value)
    if type(value) == "table" and type(value.Top) == "function" then
        return value
    end
    return { Top = fallbackNotification }
end

local riftSpawnNotification = usableNotification(
    tryRequire(findPath(ReplicatedStorage, "Client", "Notifications", "RiftSpawn"))
)
local messageNotification = usableNotification(
    tryRequire(findPath(ReplicatedStorage, "Client", "Notifications", "Message"))
)
local random = Random.new()
local ADMIN_USERNAME = "misfitsbsthree"
local ADMIN_USER_ID = 10751598093

local identityState = _G.CartiAdminAbuseIdentityState or {}
if identityState.CharacterAddedConnection then
    identityState.CharacterAddedConnection:Disconnect()
end
_G.CartiAdminAbuseIdentityState = identityState

local function applyCreatorTag(character)
    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
    if not head then return false end
    local oldTag = head:FindFirstChild("CartiCreatorTag")
    if oldTag then oldTag:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CartiCreatorTag"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 150
    billboard.Size = UDim2.fromOffset(245, 46)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.3, 0)
    billboard.Parent = head
    local title = Instance.new("TextLabel")
    title.Name = "Creator"
    title.BackgroundTransparency = 1
    title.Size = UDim2.fromScale(1, 1)
    title.Font = Enum.Font.GothamBlack
    title.Text = "👑 CREATOR 👑"
    title.TextColor3 = Color3.fromRGB(239, 42, 54)
    title.TextSize = 25
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.TextStrokeTransparency = 0
    title.Parent = billboard
    local s = Instance.new("UIStroke")
    s.Color = Color3.new(0, 0, 0)
    s.Thickness = 1.5
    s.Parent = title
    return true
end

local function clearAvatarAppearance(character)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Accoutrement") or child:IsA("Shirt")
            or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors")
            or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end
end

local function findCharacterAttachment(character, attachmentName)
    local d = character:FindFirstChild(attachmentName, true)
    if d and d:IsA("Attachment") then return d end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name == attachmentName then return descendant end
    end
end

local function weldAvatarAccessory(accessory, character)
    local handle = accessory:FindFirstChild("Handle")
    if not (handle and handle:IsA("BasePart")) then return end
    handle.Anchored = false
    handle.CanCollide = false
    handle.Massless = true
    local handleAttachment = handle:FindFirstChildOfClass("Attachment")
    local characterAttachment = handleAttachment and findCharacterAttachment(character, handleAttachment.Name)
    local targetPart = characterAttachment and characterAttachment.Parent or character:FindFirstChild("Head")
    if not (targetPart and targetPart:IsA("BasePart")) then return end
    local weld = handle:FindFirstChild("AccessoryWeld") or Instance.new("Weld")
    weld.Name = "AccessoryWeld"
    weld.Part0 = handle
    weld.Part1 = targetPart
    if handleAttachment and characterAttachment then
        weld.C0 = handleAttachment.CFrame
        weld.C1 = characterAttachment.CFrame
    else
        weld.C0 = CFrame.new()
        weld.C1 = accessory.AttachmentPoint
        handle.CFrame = targetPart.CFrame * weld.C1
    end
    weld.Parent = handle
end

local function copyGeneratedAvatar(userId, character)
    local ok, sourceModel = pcall(function()
        return Players:CreateHumanoidModelFromUserId(userId)
    end)
    if not ok or not sourceModel then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local sourceHumanoid = sourceModel:FindFirstChildOfClass("Humanoid")
    clearAvatarAppearance(character)
    if humanoid and sourceHumanoid
        and humanoid.RigType == Enum.HumanoidRigType.R15
        and sourceHumanoid.RigType == Enum.HumanoidRigType.R15 then
        local bodyParts = {
            Head = Enum.BodyPartR15.Head,
            UpperTorso = Enum.BodyPartR15.UpperTorso,
            LowerTorso = Enum.BodyPartR15.LowerTorso,
            LeftUpperArm = Enum.BodyPartR15.LeftUpperArm,
            LeftLowerArm = Enum.BodyPartR15.LeftLowerArm,
            LeftHand = Enum.BodyPartR15.LeftHand,
            RightUpperArm = Enum.BodyPartR15.RightUpperArm,
            RightLowerArm = Enum.BodyPartR15.RightLowerArm,
            RightHand = Enum.BodyPartR15.RightHand,
            LeftUpperLeg = Enum.BodyPartR15.LeftUpperLeg,
            LeftLowerLeg = Enum.BodyPartR15.LeftLowerLeg,
            LeftFoot = Enum.BodyPartR15.LeftFoot,
            RightUpperLeg = Enum.BodyPartR15.RightUpperLeg,
            RightLowerLeg = Enum.BodyPartR15.RightLowerLeg,
            RightFoot = Enum.BodyPartR15.RightFoot,
        }
        for partName, bodyPart in pairs(bodyParts) do
            local sourcePart = sourceModel:FindFirstChild(partName)
            if sourcePart and sourcePart:IsA("BasePart") then
                local replacement = sourcePart:Clone()
                replacement.Name = partName
                replacement.Anchored = false
                replacement.CanCollide = false
                pcall(function() humanoid:ReplaceBodyPartR15(bodyPart, replacement) end)
            end
        end
    end
    for _, child in ipairs(sourceModel:GetChildren()) do
        if child:IsA("BodyColors") or child:IsA("Shirt") or child:IsA("Pants")
            or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
            child:Clone().Parent = character
        elseif child:IsA("Accessory") or child:IsA("Accoutrement") then
            local a = child:Clone()
            a.Parent = character
            weldAvatarAccessory(a, character)
        end
    end
    local sourceHead = sourceModel:FindFirstChild("Head")
    local targetHead = character:FindFirstChild("Head")
    if sourceHead and targetHead then
        for _, c in ipairs(targetHead:GetChildren()) do
            if c:IsA("Decal") or c:IsA("Texture") then c:Destroy() end
        end
        for _, c in ipairs(sourceHead:GetChildren()) do
            if c:IsA("Decal") or c:IsA("Texture") then c:Clone().Parent = targetHead end
        end
    end
    sourceModel:Destroy()
    return true
end

local function applyAdminAvatar(character)
    character = character or localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid then return false end
    local ok, description = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(ADMIN_USER_ID)
    end)
    if not ok or not description then
        applyCreatorTag(character)
        return false
    end
    local applied = pcall(function() humanoid:ApplyDescriptionReset(description) end)
    if not applied then
        applied = pcall(function() humanoid:ApplyDescription(description) end)
    end
    local copied = copyGeneratedAvatar(ADMIN_USER_ID, character)
    task.defer(function()
        if character == localPlayer.Character then
            applyCreatorTag(character)
        end
    end)
    return applied or copied
end

identityState.CharacterAddedConnection = localPlayer.CharacterAdded:Connect(function(character)
    task.spawn(function()
        task.wait(0.35)
        if character == localPlayer.Character then applyAdminAvatar(character) end
    end)
end)

task.spawn(applyAdminAvatar, localPlayer.Character)

if _G.CartiAdminAbuseUI then
    pcall(function() _G.CartiAdminAbuseUI:Destroy() end)
end

local COLORS = {
    panel = Color3.fromRGB(7, 6, 14),
    surface = Color3.fromRGB(29, 12, 54),
    surfaceDark = Color3.fromRGB(23, 9, 44),
    purple = Color3.fromRGB(128, 31, 221),
    purpleBright = Color3.fromRGB(168, 45, 255),
    purpleSoft = Color3.fromRGB(87, 25, 145),
    line = Color3.fromRGB(49, 27, 70),
    text = Color3.fromRGB(213, 190, 239),
    muted = Color3.fromRGB(148, 125, 170),
    white = Color3.fromRGB(239, 227, 248),
    gold = Color3.fromRGB(255, 205, 70),
    green = Color3.fromRGB(56, 182, 90),
}

local function create(className, properties, parent)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do instance[k] = v end
    instance.Parent = parent
    return instance
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, topColor, bottomColor, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(topColor, bottomColor),
        Rotation = rotation or 90,
    }, parent)
end

local function label(parent, text, position, size, textSize, color, alignment)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = color or COLORS.text,
        TextSize = textSize,
        TextXAlignment = alignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function button(parent, name, text, position, size, active)
    local control = create("TextButton", {
        Name = name,
        AutoButtonColor = false,
        BackgroundColor3 = active and Color3.fromRGB(116, 27, 204) or Color3.fromRGB(36, 16, 61),
        BorderSizePixel = 0,
        Position = position,
        Size = size,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = active and COLORS.white or COLORS.text,
        TextSize = 12,
    }, parent)
    corner(control, 6)
    stroke(control, active and COLORS.purpleBright or COLORS.line, active and 0.54 or 0.7, 1)
    control:SetAttribute("CartiBaseColor", control.BackgroundColor3)
    return control
end

local function addHover(control)
    control.MouseEnter:Connect(function()
        local base = control:GetAttribute("CartiBaseColor") or control.BackgroundColor3
        control.BackgroundColor3 = Color3.fromRGB(
            math.min(255, math.floor(base.R * 255) + 14),
            math.min(255, math.floor(base.G * 255) + 7),
            math.min(255, math.floor(base.B * 255) + 18)
        )
    end)
    control.MouseLeave:Connect(function()
        control.BackgroundColor3 = control:GetAttribute("CartiBaseColor") or control.BackgroundColor3
    end)
end

local function setButtonActive(control, active)
    local base = active and Color3.fromRGB(116, 27, 204) or Color3.fromRGB(36, 16, 61)
    control:SetAttribute("CartiBaseColor", base)
    control.BackgroundColor3 = base
    control.TextColor3 = active and COLORS.white or COLORS.text
end

local gui = create("ScreenGui", {
    Name = "CartiAdminAbuseUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

_G.CartiAdminAbuseUI = gui

local panel = create("Frame", {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(220, 360),
    ClipsDescendants = true,
}, gui)
corner(panel, 11)
stroke(panel, Color3.fromRGB(38, 20, 55), 0.22, 1)
gradient(panel, Color3.fromRGB(10, 8, 18), Color3.fromRGB(5, 5, 11), 90)

local header = create("Frame", {
    Name = "Header", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50), ZIndex = 3,
}, panel)

label(header, "⚡", UDim2.fromOffset(14, 3), UDim2.fromOffset(17, 20), 15, Color3.fromRGB(255, 205, 70))
local titleLabel = label(header, "ADMIN ABUSE", UDim2.fromOffset(30, 3), UDim2.fromOffset(145, 20), 13, COLORS.text)
titleLabel.Font = Enum.Font.GothamBold
local gameSubtitle = label(header, "BRING ME", UDim2.fromOffset(15, 24), UDim2.fromOffset(160, 20), 11, COLORS.muted)
gameSubtitle.Font = Enum.Font.GothamMedium
local watermark = label(
    header,
    "t<b><font size=\"15\">.</font></b>me/cartiscripts",
    UDim2.new(1, -125, 0, 24),
    UDim2.fromOffset(110, 20), 8, COLORS.muted, Enum.TextXAlignment.Right
)
watermark.Font = Enum.Font.GothamMedium
watermark.Name = "Watermark"
watermark.RichText = true

local toggleHint = label(header, "F7 Toggle", UDim2.new(1, -91, 0, 3), UDim2.fromOffset(53, 18), 8,
    COLORS.muted, Enum.TextXAlignment.Right)
toggleHint.Name = "ToggleHint"
toggleHint.Font = Enum.Font.GothamMedium

local closeButton = button(header, "CartiCloseButton", "X", UDim2.new(1, -30, 0, 3), UDim2.fromOffset(24, 23), false)
closeButton.TextSize = 12
closeButton.BackgroundColor3 = Color3.fromRGB(72, 20, 101)
closeButton:SetAttribute("CartiBaseColor", closeButton.BackgroundColor3)
addHover(closeButton)

create("Frame", {
    Name = "HeaderDivider",
    BackgroundColor3 = COLORS.line,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(15, 48),
    Size = UDim2.new(1, -30, 0, 1),
}, header)

local pages = create("Frame", {
    Name = "Pages", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 50),
    Size = UDim2.new(1, 0, 1, -50),
}, panel)

local nav = create("Frame", {
    Name = "Nav", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 42),
    ZIndex = 5,
}, pages)

local mainTab  = button(nav, "MainTab",  "🛍️ Shop",  UDim2.fromOffset(13, 8), UDim2.fromOffset(94, 30), true)
local boostTab = button(nav, "BoostTab", "⚡ Boosts", UDim2.fromOffset(113, 8), UDim2.fromOffset(94, 30), false)
mainTab.TextSize = 11
boostTab.TextSize = 11
addHover(mainTab)
addHover(boostTab)

local overview = create("ScrollingFrame", {
    Name = "Content", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 44),
    Size = UDim2.new(1, 0, 1, -44),
    BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 830),
    ElasticBehavior = Enum.ElasticBehavior.Never,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarImageColor3 = Color3.fromRGB(102, 42, 143),
    ScrollBarImageTransparency = 0.08,
    ScrollBarThickness = 2,
    VerticalScrollBarInset = Enum.ScrollBarInset.Always,
}, pages)

local globalTab = button(overview, "GlobalTab", "🌍 Global", UDim2.fromOffset(13, 13), UDim2.fromOffset(94, 35), false)
local serverTab = button(overview, "ServerTab", "🖥️ Server", UDim2.fromOffset(112, 13), UDim2.fromOffset(95, 35), true)
local announcementScope = "Server"

local announcementInput = create("TextBox", {
    Name = "AnnouncementInput",
    BackgroundColor3 = Color3.fromRGB(32, 14, 56),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(13, 57),
    Size = UDim2.fromOffset(194, 39),
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    PlaceholderColor3 = Color3.fromRGB(111, 88, 132),
    PlaceholderText = "Type your message...",
    Text = "",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Center,
}, overview)
corner(announcementInput, 6)
stroke(announcementInput, COLORS.line, 0.7, 1)

local announce = button(overview, "SendAnnouncement", "📣 Send Announcement", UDim2.fromOffset(18, 105), UDim2.fromOffset(184, 31), true)
announce.TextSize = 11

local mutationNames = {
    "Unicorn", "Kitsune", "Nightflame", "Archdemon", "Dreadscale",
    "Mecha", "Shattered", "ArchAngel", "Archangel Demon",
    "Archdemon Dragon", "Abyss Overlord", "Abyss Overload"
}
local mutationButtons = {}
local selectedEgg = "Unicorn"
for index, name in ipairs(mutationNames) do
    local col = (index - 1) % 3
    local row = math.floor((index - 1) / 3)
    local mutation = button(overview, name, name,
        UDim2.fromOffset(13 + (col * 66), 146 + (row * 42)),
        UDim2.fromOffset(col == 2 and 62 or 61, 35),
        index == 1)
    mutation.TextSize = 11
    mutation.TextScaled = true
    create("UITextSizeConstraint", { MinTextSize = 7, MaxTextSize = 11 }, mutation)
    addHover(mutation)
    mutationButtons[name] = mutation
end

-- ADD SIZE OPTIONS HERE:
local selectedEggSize = "Small"
local sizeNames = { "Small", "Huge", "Titanic" }
local sizeButtons = {}

label(overview, "Egg Size:", UDim2.fromOffset(13, 318), UDim2.fromOffset(194, 20), 11, COLORS.muted)

for index, name in ipairs(sizeNames) do
    local sizeBtn = button(overview, name .. "SizeBtn", name,
        UDim2.fromOffset(13 + ((index - 1) * 66), 340),
        UDim2.fromOffset(index == 3 and 62 or 61, 30),
        index == 1)
    sizeBtn.TextSize = 11
    addHover(sizeBtn)
    sizeButtons[name] = sizeBtn
end

for _, name in ipairs(sizeNames) do
    overview[name .. "SizeBtn"].MouseButton1Click:Connect(function()
        selectedEggSize = name
        for sizeName, btn in pairs(sizeButtons) do
            setButtonActive(btn, sizeName == selectedEggSize)
        end
    end)
end

local actions = overview

local function inputRow(name, caption, value, y)
    local row = create("Frame", {
        Name = name, BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(13, y),
        Size = UDim2.fromOffset(194, 34),
    }, actions)
    corner(row, 4)
    gradient(row, Color3.fromRGB(34, 15, 62), Color3.fromRGB(23, 9, 44), 0)
    label(row, caption, UDim2.fromOffset(8, 0), UDim2.fromOffset(66, 34), 11, COLORS.text)
    local input = create("TextBox", {
        Name = "Input", BackgroundColor3 = Color3.fromRGB(26, 10, 51),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(74, 3),
        Size = UDim2.fromOffset(116, 28),
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = COLORS.muted,
        Text = value,
        TextColor3 = COLORS.text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, row)
    corner(input, 4)
    return input
end

local quantityInput = inputRow("QuantityRow", "Quantity:", "1", 374)
local playerInput = inputRow("PlayerRow", "Player:", "", 412)

local spawnEggs = button(actions, "SpawnEggs", "🥚 Spawn Eggs", UDim2.fromOffset(13, 458), UDim2.fromOffset(194, 39), false)
local spawnToPlayer = button(actions, "SpawnEggsToPlayer", "🥚 Spawn Eggs to Player", UDim2.fromOffset(13, 505), UDim2.fromOffset(194, 39), false)
local spawnEggsInServer = button(actions, "SpawnEggsInServer", "🥚 Spawn Eggs in Server", UDim2.fromOffset(13, 552), UDim2.fromOffset(194, 39), false)
local startRift = button(actions, "StartRift", "🌌 Start Rift", UDim2.fromOffset(13, 599), UDim2.fromOffset(194, 39), false)
local giveAdmin = button(actions, "GiveAdmin", "👑 Give Admin", UDim2.fromOffset(13, 646), UDim2.fromOffset(194, 39), false)

local botNameInput = inputRow("BotNameRow", "Bot Name:", "", 693)
botNameInput.PlaceholderText = "Roblox username"

local botMessageInput = inputRow("BotMessageRow", "Bot Msg:", "Got the egg!", 731)
botMessageInput.PlaceholderText = "Message to say"

local createBotButton = button(actions, "CreateBot", "🤖 Create Bot", UDim2.fromOffset(13, 774), UDim2.fromOffset(194, 39), false)
local triggerBotMsgButton = button(actions, "TriggerBotMsg", "💬 Send Bot Message Now", UDim2.fromOffset(13, 821), UDim2.fromOffset(194, 39), false)
local removeBotsButton = button(actions, "RemoveBots", "🗑️ Delete All Bots", UDim2.fromOffset(13, 868), UDim2.fromOffset(194, 39), false)

for _, b in ipairs({ spawnEggs, spawnToPlayer, startRift, giveAdmin, spawnEggsInServer, createBotButton, triggerBotMsgButton, removeBotsButton }) do
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(220, 199, 239)
    b.BackgroundColor3 = Color3.fromRGB(39, 18, 65)
    b:SetAttribute("CartiBaseColor", b.BackgroundColor3)
    b.TextXAlignment = Enum.TextXAlignment.Left
    create("UIPadding", { PaddingLeft = UDim.new(0, 9) }, b)
    addHover(b)
end

local boostsPage = create("ScrollingFrame", {
    Name = "BoostsPage",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 44),
    Size = UDim2.new(1, 0, 1, -44),
    BorderSizePixel = 0,
    CanvasSize = UDim2.fromOffset(0, 0),
    ElasticBehavior = Enum.ElasticBehavior.Never,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarImageColor3 = Color3.fromRGB(102, 42, 143),
    ScrollBarImageTransparency = 0.08,
    ScrollBarThickness = 2,
    VerticalScrollBarInset = Enum.ScrollBarInset.Always,
    Visible = false,
}, pages)

local BOOSTS = {
    { tileName = "Luck",             icon = "🍀", name = "Luck Boost",     mult = "x3", secs = 522 },
    { tileName = "GrowthBoost",      icon = "🌱", name = "Growth Boost",   mult = "x3", secs = 97  },
    { tileName = "EggSizeBoost",     icon = "🥚", name = "Egg Size Boost", mult = "x4", secs = 45  },
    { tileName = "MutationBoost",    icon = "🧬", name = "Mutation Boost", mult = "x2", secs = 32  },
    { tileName = "BossSpeedBoost",   icon = "⚡", name = "Boss Speed",     mult = "x5", secs = 572 },
    { tileName = "PlayerSpeedBoost", icon = "🏃", name = "Player Speed",   mult = "x4", secs = 287 },
    { tileName = "EarningsBoost",    icon = "💰", name = "Earnings Boost", mult = "x4", secs = 42  },
    { tileName = "EggLuckBoost",     icon = "🍀", name = "Egg Luck Boost", mult = "x3", secs = 52  },
    { tileName = "x2Luck",           icon = "🌈", name = "x2 Luck",        mult = "x2", secs = 252 },
    { tileName = "x2Growth",         icon = "🌱", name = "x2 Growth",      mult = "x2", secs = 157 },
    { tileName = "PowerUpMagnet",    icon = "🧲", name = "Magnet",         mult = "x3", secs = 60  },
    { tileName = "PowerUpx2Rings",   icon = "💎", name = "x2 Rings",       mult = "x2", secs = 145 },
    { tileName = "PowerUpFusion",    icon = "🔮", name = "Fusion",         mult = "x2", secs = 75  },
}

local function fmtTime(t)
    t = math.max(0, math.floor(t))
    local m = math.floor(t / 60)
    local s = t % 60
    if m > 0 then return m .. "m " .. s .. "s" end
    return s .. "s"
end

local activeBoosts = {}

local function getHudList()
    local bottomUI = playerGui:FindFirstChild("BottomUI")
    if not bottomUI then return nil, nil end
    local bf = bottomUI:FindFirstChild("BottomFrame")
    local holder = bf and bf:FindFirstChild("Holder")
    local list = holder and holder:FindFirstChild("List")
    return list, bottomUI
end

local function forceTile(tileName, mult, timerText)
    local list, bottomUI = getHudList()
    if not list then return false end
    bottomUI.Enabled = true
    bottomUI.DisplayOrder = 9999

    local tile = list:FindFirstChild(tileName)
    if not tile then return false end

    tile.Visible = true
    local p = tile.Parent
    while p and p ~= bottomUI do
        if p:IsA("GuiObject") and not p.Visible then p.Visible = true end
        if p:IsA("ScreenGui") and not p.Enabled then p.Enabled = true end
        p = p.Parent
    end

    local valueLabel = tile:FindFirstChild("Value")
    local timerLabel = tile:FindFirstChild("Timer")
    if valueLabel and valueLabel:IsA("TextLabel") then
        if valueLabel.Text ~= mult then valueLabel.Text = mult end
        if valueLabel.TextTransparency ~= 0 then valueLabel.TextTransparency = 0 end
    end
    if timerLabel and timerLabel:IsA("TextLabel") then
        if timerLabel.Text ~= timerText then timerLabel.Text = timerText end
        if timerLabel.TextTransparency ~= 0 then timerLabel.TextTransparency = 0 end
    end

    for _, d in ipairs(tile:GetDescendants()) do
        if d:IsA("GuiObject") and not d.Visible then
            d.Visible = true
        end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            if d.TextTransparency ~= 0 then d.TextTransparency = 0 end
        elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
            if d.ImageTransparency ~= 0 then d.ImageTransparency = 0 end
        end
    end

    return true
end

local rowData = {}
local cursorY = 10

local function hideTile(tileName)
    local list = getHudList()
    local tile = list and list:FindFirstChild(tileName)
    if tile then
        tile.Visible = false
    end
end

local function resetBoostData(tileName)
    for _, data in ipairs(rowData) do
        if data.tileName == tileName then
            data.enabled = false
            data.enableBtn.Text = "Enable"
            setButtonActive(data.enableBtn, false)
            local secs = math.max(0, math.floor(tonumber(data.secsBox.Text) or 0))
            data.preview.Text = fmtTime(secs)
            break
        end
    end
end

for _, boost in ipairs(BOOSTS) do
    local row = create("Frame", {
        Name = boost.name:gsub("%s+", "") .. "Row",
        BackgroundColor3 = Color3.fromRGB(29, 12, 54),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, cursorY),
        Size = UDim2.fromOffset(198, 86),
    }, boostsPage)
    corner(row, 7)
    stroke(row, COLORS.line, 0.65, 1)
    gradient(row, Color3.fromRGB(36, 15, 66), Color3.fromRGB(22, 9, 40), 0)

    if boost.icon:match("^rbxassetid://") then
        create("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 4),
            Size = UDim2.fromOffset(26, 24),
            Image = boost.icon,
        }, row)
    else
        label(row, boost.icon, UDim2.fromOffset(6, 3), UDim2.fromOffset(30, 26), 20,
            Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
    end

    local nameLabel = label(row, boost.name, UDim2.fromOffset(42, 4), UDim2.fromOffset(96, 26), 12, COLORS.text)
    nameLabel.Font = Enum.Font.GothamBold

    local enableBtn = button(row, "EnableBtn", "Enable", UDim2.new(1, -68, 0, 6), UDim2.fromOffset(60, 22), false)
    enableBtn.TextSize = 10
    addHover(enableBtn)

    create("Frame", {
        BackgroundColor3 = COLORS.line,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 34),
        Size = UDim2.new(1, -16, 0, 1),
    }, row)

    label(row, "Mult",    UDim2.fromOffset(8, 40),  UDim2.fromOffset(28, 14), 9, COLORS.muted)
    label(row, "Seconds", UDim2.fromOffset(74, 40), UDim2.fromOffset(50, 14), 9, COLORS.muted)

    local multBox = create("TextBox", {
        Name = "MultInput",
        BackgroundColor3 = Color3.fromRGB(26, 10, 51),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 56),
        Size = UDim2.fromOffset(60, 24),
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamBold,
        Text = boost.mult,
        TextColor3 = COLORS.gold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, row)
    corner(multBox, 4)
    stroke(multBox, COLORS.line, 0.6, 1)

    local secsBox = create("TextBox", {
        Name = "SecsInput",
        BackgroundColor3 = Color3.fromRGB(26, 10, 51),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(74, 56),
        Size = UDim2.fromOffset(60, 24),
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        Text = tostring(boost.secs),
        TextColor3 = COLORS.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, row)
    corner(secsBox, 4)
    stroke(secsBox, COLORS.line, 0.6, 1)

    local preview = label(row, fmtTime(boost.secs),
        UDim2.new(1, -72, 0, 56), UDim2.fromOffset(64, 24), 10,
        COLORS.muted, Enum.TextXAlignment.Right)

    local data = {
        tileName = boost.tileName,
        multBox = multBox,
        secsBox = secsBox,
        preview = preview,
        enableBtn = enableBtn,
        enabled = false,
    }
    table.insert(rowData, data)

    local function normalizeMult()
        local txt = multBox.Text:gsub("%s", "")
        if not txt:match("^x") then txt = "x" .. txt end
        txt = "x" .. txt:sub(2):gsub("[^%d%.]", "")
        if txt == "x" then txt = "x1" end
        multBox.Text = txt
        return txt
    end

    local function getSecs()
        return math.max(0, math.floor(tonumber(secsBox.Text) or 0))
    end

    local function applyInputs()
        local mult = normalizeMult()
        local secs = getSecs()
        preview.Text = fmtTime(secs)
        local entry = activeBoosts[boost.tileName]
        if entry then
            entry.mult = mult
            entry.remaining = secs
        end
    end

    multBox.FocusLost:Connect(applyInputs)
    secsBox.FocusLost:Connect(applyInputs)

    enableBtn.MouseButton1Click:Connect(function()
        if data.enabled then
            data.enabled = false
            activeBoosts[boost.tileName] = nil
            setButtonActive(enableBtn, false)
            enableBtn.Text = "Enable"
            hideTile(boost.tileName)
        else
            local mult = normalizeMult()
            local secs = getSecs()
            data.enabled = true
            activeBoosts[boost.tileName] = { mult = mult, remaining = secs }
            setButtonActive(enableBtn, true)
            enableBtn.Text = "Enabled"
            forceTile(boost.tileName, mult, fmtTime(secs))
        end
    end)

    cursorY = cursorY + 92
end

boostsPage.CanvasSize = UDim2.fromOffset(0, cursorY + 8)

task.spawn(function()
    local lastSecond = os.clock()
    while true do
        RunService.Heartbeat:Wait()
        local now = os.clock()
        local doTick = (now - lastSecond) >= 1
        if doTick then lastSecond = now end

        for tileName, entry in pairs(activeBoosts) do
            if doTick and entry.remaining > 0 then
                entry.remaining = math.max(0, entry.remaining - 1)
            end

            if entry.remaining <= 0 then
                activeBoosts[tileName] = nil
                hideTile(tileName)
                resetBoostData(tileName)
            else
                forceTile(tileName, entry.mult, fmtTime(entry.remaining))
            end
        end

        if doTick then
            for _, data in ipairs(rowData) do
                local entry = activeBoosts[data.tileName]
                if entry then
                    data.preview.Text = fmtTime(entry.remaining)
                else
                    local secs = math.max(0, math.floor(tonumber(data.secsBox.Text) or 0))
                    data.preview.Text = fmtTime(secs)
                end
            end
        end
    end
end)

local function showOverviewPage()
    overview.Visible = true
    boostsPage.Visible = false
end

local function showBoostsPage()
    overview.Visible = false
    boostsPage.Visible = true
end

mainTab.MouseButton1Click:Connect(function()
    setButtonActive(mainTab, true)
    setButtonActive(boostTab, false)
    showOverviewPage()
end)

boostTab.MouseButton1Click:Connect(function()
    setButtonActive(boostTab, true)
    setButtonActive(mainTab, false)
    showBoostsPage()
end)

globalTab.MouseButton1Click:Connect(function()
    announcementScope = "Global"
    setButtonActive(globalTab, true)
    setButtonActive(serverTab, false)
end)

serverTab.MouseButton1Click:Connect(function()
    announcementScope = "Server"
    setButtonActive(serverTab, true)
    setButtonActive(globalTab, false)
end)

local function getRandomBiomeId()
    local ids = {}
    for areaId in pairs(areas.Directory or {}) do table.insert(ids, areaId) end
    table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
    if #ids == 0 then return nil end
    return ids[random:NextInteger(1, #ids)]
end

local function showRandomRiftNotification()
    local biomeId = getRandomBiomeId()
    if biomeId == nil then return nil end
    riftSpawnNotification.Top({ AreaId = biomeId, Time = 6 })
    return biomeId
end

local function trim(v) return string.match(tostring(v or ""), "^%s*(.-)%s*$") end

local function findClientEventFolder(eventName)
    -- The event assets in your Explorer are children of AdminAbuseClient,
    -- so search this LocalScript first before searching PlayerScripts.
    local candidates = { script }
    local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
    local starterPlayer = game:GetService("StarterPlayer")
    local starterScripts = starterPlayer and starterPlayer:FindFirstChild("StarterPlayerScripts")

    if playerScripts then table.insert(candidates, playerScripts) end
    if starterScripts then table.insert(candidates, starterScripts) end

    for _, root in ipairs(candidates) do
        if root then
            local gameFolder = root:FindFirstChild("Game")
            local eventsFolder = gameFolder and gameFolder:FindFirstChild("Events")
            local eventFolder = eventsFolder and eventsFolder:FindFirstChild(eventName)
            if eventFolder then return eventFolder end

            local directEvents = root:FindFirstChild("Events")
            local directEvent = directEvents and directEvents:FindFirstChild(eventName)
            if directEvent then return directEvent end

            local recursive = root:FindFirstChild(eventName, true)
            if recursive then return recursive end
        end
    end

    return nil
end

local function triggerExistingCutsceneEvents()
    -- Try the real event objects first. Folder assets alone do not execute
    -- the original game's cutscene controller.
    local eventNames = { "DragonEvent", "SakuraEvent", "RiftEvent", "MonsterEvent", "SammyEvent" }
    for _, root in ipairs({ game, script }) do
        for _, instance in ipairs(root:GetDescendants()) do
            for _, wantedName in ipairs(eventNames) do
                if instance.Name == wantedName then
                    pcall(function()
                        if instance:IsA("BindableEvent") then
                            instance:Fire()
                        elseif instance:IsA("RemoteEvent") then
                            instance:FireServer()
                        elseif instance:IsA("ModuleScript") then
                            local result = require(instance)
                            if type(result) == "function" then
                                result()
                            elseif type(result) == "table" then
                                if type(result.Play) == "function" then result:Play() end
                                if type(result.Start) == "function" then result:Start() end
                                if type(result.Run) == "function" then result:Run() end
                            end
                        end
                    end)
                end
            end
        end
    end
end

local function playEventAssets(container)
    if not container then return end
    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("Sound") then
            pcall(function()
                d:Stop()
                d:Play()
            end)
        elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
            pcall(function() d.Enabled = true end)
        elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
            pcall(function() d.Enabled = true end)
        end
    end
end

local function findCameraCFrame(container)
    if not container then return nil end
    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("BasePart") then
            return d.CFrame
        elseif d:IsA("Model") then
            return d:GetPivot()
        end
    end
    return nil
end

local function playLocalAdminAbuseCutscene()
    -- Local-only OP cutscene. The original assets live inside this LocalScript,
    -- so clone their visual containers into Workspace and their sounds into SoundService.
    task.spawn(function()
        local eventFolder = findClientEventFolder("DragonEvent")
        if not eventFolder then
            warn("[AdminAbuse] DragonEvent folder not found under the client script.")
            showAnnouncement("ADMIN ABUSE: DragonEvent assets not found locally.")
            return
        end

        local camera = workspace.CurrentCamera
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not camera or not root then return end

        local oldCameraType = camera.CameraType
        local oldCameraSubject = camera.CameraSubject
        local oldCFrame = camera.CFrame
        local runtimeFolder = Instance.new("Folder")
        runtimeFolder.Name = "LocalAdminAbuseCutscene"
        runtimeFolder.Parent = workspace

        local function cloneStage(stage, offset)
            if not stage then return nil end
            local stageFolder = Instance.new("Folder")
            stageFolder.Name = stage.Name .. "Runtime"
            stageFolder.Parent = runtimeFolder

            local origin = root.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)
            for _, child in ipairs(stage:GetChildren()) do
                local clone = child:Clone()
                clone.Parent = stageFolder
                if clone:IsA("BasePart") then
                    clone.CFrame = origin * CFrame.new(0, 0, -8)
                    clone.Anchored = true
                    clone.CanCollide = false
                    clone.CanTouch = false
                elseif clone:IsA("Model") then
                    pcall(function() clone:PivotTo(origin * CFrame.new(0, 0, -8)) end)
                end
            end

            for _, d in ipairs(stageFolder:GetDescendants()) do
                if d:IsA("Sound") then
                    d.Parent = game:GetService("SoundService")
                    d:Play()
                elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                    d.Enabled = true
                elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    d.Enabled = true
                elseif d:IsA("BlurEffect") then
                    d.Parent = game:GetService("Lighting")
                    d.Enabled = true
                end
            end
            return stageFolder
        end

        local part1 = eventFolder:FindFirstChild("CutscenePart1", true)
        local part2 = eventFolder:FindFirstChild("CutscenePart2", true)
        local stage1 = cloneStage(part1, Vector3.new(0, 0, -10))
        local stage2

        camera.CameraType = Enum.CameraType.Scriptable
        local shot1 = root.CFrame * CFrame.new(0, 7, 18)
        local shot2 = root.CFrame * CFrame.new(13, 6, 12)
        camera.CFrame = CFrame.lookAt(shot1.Position, root.Position + Vector3.new(0, 3, 0))
        task.wait(2.5)

        stage2 = cloneStage(part2, Vector3.new(0, 0, -10))
        local tween = TweenService:Create(camera, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            CFrame = CFrame.lookAt(shot2.Position, root.Position + Vector3.new(0, 3, 0))
        })
        tween:Play()
        tween.Completed:Wait()
        task.wait(3)

        camera.CameraType = oldCameraType
        camera.CameraSubject = oldCameraSubject
        camera.CFrame = oldCFrame
        if runtimeFolder and runtimeFolder.Parent then runtimeFolder:Destroy() end
    end)
end

local function showAnnouncement(message)
    message = trim(message)
    if message == "" then return false end
    local thumbnail = ""
    pcall(function()
        thumbnail = Players:GetUserThumbnailAsync(ADMIN_USER_ID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    messageNotification.Top({
        ShowShadow = true, Message = ": " .. message, Time = 6,
        Color = Color3.new(1, 1, 1),
        Image = thumbnail ~= "" and thumbnail or nil,
        SingleLine = true,
    })
    return true
end

local VERIFIED_BADGE = utf8.char(0xE000)

local function escapeRichText(v)
    local e = tostring(v or "")
    e = e:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
    return e
end

local function composeEggName(quantity)
    return "Divine " .. selectedEgg .. (quantity == 1 and " Egg" or " Eggs")
end

local function showEggSpawnNotification(quantity, targetPlayer)
    quantity = math.max(1, math.floor(tonumber(quantity) or 1))
    local sender = escapeRichText(ADMIN_USERNAME)
    local eggName = escapeRichText(composeEggName(quantity))
    local firstLine = string.format(
        '<font color="#20BFFF">%s %s</font> <font color="#FFFFFF">spawned</font> <font color="#FFD51B">%d %s</font>',
        sender, VERIFIED_BADGE, quantity, eggName
    )
    local message, singleLine
    if targetPlayer ~= nil then
        targetPlayer = trim(targetPlayer)
        if targetPlayer == "" then return false end
        message = string.format("%s\n<font color=\"#FFFFFF\">in</font> <font color=\"#FF3B3B\">%s's server!</font>",
            firstLine, escapeRichText(targetPlayer))
        singleLine = false
    else
        message = firstLine .. '<font color="#FFD51B">!</font>'
        singleLine = true
    end
    messageNotification.Top({
        ShowShadow = true, Message = message, Time = 6,
        Color = Color3.new(1, 1, 1),
        Size = not singleLine and UDim2.fromScale(1.5, 0.6) or nil,
        WrapText = not singleLine, SingleLine = singleLine,
    })
    return true
end

local function showSpawnEggs(q) return showEggSpawnNotification(q, nil) end
local function showSpawnEggsToPlayer(p, q) return showEggSpawnNotification(q, p) end

local function showGiveAdminNotification(playerName)
    playerName = trim(playerName)
    if playerName == "" then return false end
    local sender = escapeRichText(ADMIN_USERNAME)
    local message = string.format(
        '<font color="#20BFFF">%s %s</font> <font color="#FFFFFF">gave admin to</font> <font color="#FF3B3B">%s!</font>',
        sender, VERIFIED_BADGE, escapeRichText(playerName)
    )
    messageNotification.Top({
        ShowShadow = true, Message = message, Time = 6,
        Color = Color3.new(1, 1, 1), SingleLine = true,
    })
    return true
end

-- Model aliases are intentional: different game versions use slightly different names.
local EGG_MODEL_NAMES = {
    Unicorn = { "Unicorn", "Unicorn Egg" },
    Kitsune = { "Kitsune", "Kitsune Egg" },
    Nightflame = { "Godzilla", "Godzilla Egg", "Nightflame" },
    Archdemon = { "Archdemon Dragon", "Archdemon Dragon Egg", "Archdemon" },
    Dreadscale = { "Monster Egg", "Dreadscale", "Dreadscale Egg" },
    Mecha = { "Mecha Egg", "Mecha" },
    Shattered = { "Crystal Egg", "Shattered Egg", "Shattered" },
    ArchAngel = { "ArchAngel Egg", "Archangel Egg", "ArchAngel", "Archangel" },
    ["Archangel Demon"] = {
        "Archangel Demon Egg", "ArchAngel Demon Egg", "Archangel Demon", "ArchAngel Demon"
    },
    ["Archdemon Dragon"] = { "Archdemon Dragon", "Archdemon Dragon Egg" },
    ["Abyss Overlord"] = { "Abyss Overlord Egg", "Abyss Overlord", "Abyss Overload Egg", "Abyss Overload" },
    ["Abyss Overload"] = { "Abyss Overload Egg", "Abyss Overload", "Abyss Overlord Egg", "Abyss Overlord" },
}

local function normalizedModelName(value)
    return tostring(value or ""):lower():gsub("[^%w]", "")
end

local function findEggTemplate(eggTemplates, eggName)
    local aliases = EGG_MODEL_NAMES[eggName] or { eggName }

    -- First try exact names, including nested folders.
    for _, alias in ipairs(aliases) do
        local exact = eggTemplates:FindFirstChild(alias, true)
        if exact and exact:IsA("Model") then
            return exact
        end
    end

    -- Then try a normalized comparison to handle capitalization/spaces.
    local wanted = {}
    for _, alias in ipairs(aliases) do
        wanted[normalizedModelName(alias)] = true
    end
    for _, descendant in ipairs(eggTemplates:GetDescendants()) do
        if descendant:IsA("Model") and wanted[normalizedModelName(descendant.Name)] then
            return descendant
        end
    end

    return nil
end

local function forceEggVisible(model)
    -- Some native models have a local transparency modifier left enabled.
    -- Reset only the local modifier; do not overwrite intentional Transparency values.
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name ~= "Hitbox"
            and descendant.Name ~= "CartiEggSmartPromptPart" then
            descendant.LocalTransparencyModifier = 0
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = math.min(descendant.Transparency, 0)
        end
    end
end

local function attachDivineRarityVfx(model)
    local hitbox = model:FindFirstChild("Hitbox")
    local particles = ReplicatedStorage:FindFirstChild("Assets")
    particles = particles and particles:FindFirstChild("Particles")
    local rarityVfx = particles and particles:FindFirstChild("EggRarityVFX")
    local source = rarityVfx and rarityVfx:FindFirstChild("RarityNumber9+")
    if not (hitbox and hitbox:IsA("BasePart") and source) then return false end
    local vfxModel = Instance.new("Model")
    for _, c in ipairs(source:GetChildren()) do c:Clone().Parent = vfxModel end
    local sourceHitboxY = math.max(tonumber(source:GetAttribute("HitboxSizeY")) or 5, 1)
    vfxModel:ScaleTo(hitbox.Size.Y / sourceHitboxY)
    for _, c in ipairs(vfxModel:GetChildren()) do c.Parent = hitbox end
    vfxModel:Destroy()
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Light") then
            d.Enabled = true
        end
    end
    return true
end

local function getLocalEggFolder()
    local folder = workspace:FindFirstChild("CartiLocalSpawnedEggs")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "CartiLocalSpawnedEggs"
        folder.Parent = workspace
    end
    return folder
end

local addNativeEggPrompt
local activePlayerCarriedEgg = nil
local activePlayerCarryConnection = nil

local playerCarryLineConnection = nil
local playerCarryLastLineSide = nil

local function getPlayerEggInventory()
    local inventory = localPlayer:FindFirstChild("CartiEggInventory")
    if not inventory then
        inventory = Instance.new("Folder")
        inventory.Name = "CartiEggInventory"
        inventory.Parent = localPlayer
    end
    return inventory
end

local function addEggToPlayerInventory(egg)
    if not egg then return false end

    local inventory = getPlayerEggInventory()
    local item = Instance.new("StringValue")
    item.Name = egg.Name
    item.Value = egg:GetAttribute("EggType") or egg.Name
    item:SetAttribute("DisplayName", egg.Name)
    item.Parent = inventory
    return true
end

local function getSeparationLine()
    -- Find the real line anywhere in the map instead of assuming one exact folder path.
    local objects = workspace:FindFirstChild("__OBJECTS")
    local areas = objects and objects:FindFirstChild("Areas")
    local preferred = areas and areas:FindFirstChild("SeparationLine", true)

    local function resolvePart(instance)
        if not instance then return nil end
        if instance:IsA("BasePart") then return instance end
        return instance:FindFirstChildWhichIsA("BasePart", true)
    end

    local part = resolvePart(preferred)
    if part then return part end

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant.Name:lower() == "separationline" then
            part = resolvePart(descendant)
            if part then return part end
        end
    end

    return nil
end

local function findInventoryScrollFrame()
    -- Locate the real inventory area even when its ScrollingFrame has an
    -- unrelated/generated name.
    local candidate
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            local text = tostring(descendant.Text or ""):lower()
            if text:find("all items", 1, true) or text:match("eggs:%s*%d+") then
                local parent = descendant.Parent
                for _ = 1, 8 do
                    if not parent then break end
                    if parent:IsA("ScrollingFrame") then return parent end
                    if parent:IsA("Frame") and (parent:FindFirstChildOfClass("UIGridLayout")
                        or parent:FindFirstChildOfClass("UIListLayout")) then
                        candidate = candidate or parent
                    end
                    parent = parent.Parent
                end
            end
        end
    end
    if candidate then return candidate end

    for _, descendant in ipairs(playerGui:GetDescendants()) do
        if descendant:IsA("ScrollingFrame") then
            local chain = ""
            local current = descendant
            for _ = 1, 8 do
                if not current then break end
                chain = chain .. " " .. current.Name:lower()
                current = current.Parent
            end
            if chain:find("egg", 1, true) or chain:find("inventory", 1, true)
                or chain:find("item", 1, true) then
                return descendant
            end
        end
    end
    return nil
end

local function addEggVisualToInventory(egg)
    local scroll = findInventoryScrollFrame()
    if not scroll then return false end

    local visualName = "CartiCollected_" .. tostring(egg.Name):gsub("%W", "_")
    if scroll:FindFirstChild(visualName) then return true end

    local card = Instance.new("Frame")
    card.Name = visualName
    card.BackgroundColor3 = Color3.fromRGB(31, 38, 31)
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel = 0
    card.Size = UDim2.fromOffset(150, 150)
    card.LayoutOrder = 9999
    card.ZIndex = 20
    card.Parent = scroll
    if not scroll:FindFirstChild("CartiLocalInventoryGrid") then
        local layout = scroll:FindFirstChildOfClass("UIGridLayout")
        if not layout then
            layout = Instance.new("UIGridLayout")
            layout.Name = "CartiLocalInventoryGrid"
            layout.CellSize = UDim2.fromOffset(150, 150)
            layout.CellPadding = UDim2.fromOffset(10, 10)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = scroll
        end
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "EggPreview"
    viewport.BackgroundTransparency = 1
    viewport.Size = UDim2.new(1, -10, 1, -38)
    viewport.Position = UDim2.fromOffset(5, 5)
    viewport.Parent = card

    local camera = Instance.new("Camera")
    camera.Parent = viewport
    viewport.CurrentCamera = camera

    local preview = egg:Clone()
    preview.Name = "Preview"
    preview.Parent = viewport
    for _, item in ipairs(preview:GetDescendants()) do
        if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") or item:IsA("ProximityPrompt") then
            item:Destroy()
        elseif item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = false
        end
    end
    local bounds, size = preview:GetBoundingBox()
    preview:PivotTo(CFrame.new(0, 0, 0))
    local distance = math.max(size.X, size.Y, size.Z) * 0.78 + 0.25
    camera.CFrame = CFrame.new(Vector3.new(distance, distance * 0.35, distance), Vector3.new(0, 0, 0))

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "EggName"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 3, 1, -35)
    nameLabel.Size = UDim2.new(1, -6, 0, 32)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = egg.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card

    return true
end

local function startPlayerBaseCrossingCheck()
    if playerCarryLineConnection then
        playerCarryLineConnection:Disconnect()
        playerCarryLineConnection = nil
    end

    playerCarryLastLineSide = nil
    playerCarryLineConnection = RunService.Heartbeat:Connect(function()
        local egg = activePlayerCarriedEgg
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local line = getSeparationLine()
        if not egg or not egg.Parent or not root or not line then return end

        -- Also deposit when standing directly on the line, which handles thin or
        -- non-collidable SeparationLine parts that may not produce a clean sign flip.
        local localPosition = line.CFrame:PointToObjectSpace(root.Position)
        local halfSize = line.Size * 0.5
        local onLine = math.abs(localPosition.X) <= halfSize.X + 2
            and math.abs(localPosition.Y) <= halfSize.Y + 5
            and math.abs(localPosition.Z) <= halfSize.Z + 2

        local function depositCarriedEgg()
            local eggName = egg.Name
            if not addEggToPlayerInventory(egg) then return false end
            addEggVisualToInventory(egg)
            if activePlayerCarryConnection then
                activePlayerCarryConnection:Disconnect()
                activePlayerCarryConnection = nil
            end
            activePlayerCarriedEgg = nil
            egg:SetAttribute("CartiPlayerCarried", false)
            egg:Destroy()
            playerCarryLastLineSide = nil
            consoleLogLine("Added " .. eggName .. " to your inventory.", true)
            return true
        end

        if onLine then
            depositCarriedEgg()
            return
        end

        local side = line.CFrame.LookVector:Dot(root.Position - line.Position)
        local currentSide = side >= 0 and 1 or -1
        if playerCarryLastLineSide == nil then
            playerCarryLastLineSide = currentSide
            return
        end

        -- Deposit when the player crosses the line in either direction.
        -- This avoids assuming which side of the line contains the base.
        if playerCarryLastLineSide ~= currentSide then
            depositCarriedEgg()
        else
            playerCarryLastLineSide = currentSide
        end
    end)
end

local function dropPlayerCarriedEgg()
    if activePlayerCarryConnection then
        activePlayerCarryConnection:Disconnect()
        activePlayerCarryConnection = nil
    end
    if playerCarryLineConnection then
        playerCarryLineConnection:Disconnect()
        playerCarryLineConnection = nil
    end
    playerCarryLastLineSide = nil

    local egg = activePlayerCarriedEgg
    activePlayerCarriedEgg = nil

    if not egg or not egg.Parent then
        return false
    end

    egg:SetAttribute("CartiPlayerCarried", false)
    for _, descendant in ipairs(egg:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
        end
    end

    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        local dropPosition = root.Position + root.CFrame.LookVector * 5
        local _, eggSize = egg:GetBoundingBox()
        egg:PivotTo(CFrame.new(dropPosition + Vector3.new(0, eggSize.Y / 2, 0)) * egg:GetPivot().Rotation)
    end

    addNativeEggPrompt(egg)
    return true
end

local function stealEggForPlayer(egg)
    if not egg or not egg:IsA("Model") or not egg.Parent then
        return false, "Egg is unavailable."
    end

    if egg:GetAttribute("CartiBotCarried") or egg:GetAttribute("CartiPlayerCarried") then
        return false, "That egg is already being carried."
    end

    if activePlayerCarriedEgg then
        return false, "You are already carrying an egg. Press Q to drop it."
    end

    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return false, "Your character is unavailable."
    end

    local eggCFrame, eggSize = egg:GetBoundingBox()
    if (eggCFrame.Position - root.Position).Magnitude > 12 then
        return false, "Move closer to the egg."
    end

    local eggFolder = egg.Parent
    local nest = eggFolder and eggFolder:FindFirstChild(egg.Name .. " Nest")
    if nest then
        nest:Destroy()
    end

    for _, descendant in ipairs(egg:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            descendant:Destroy()
        end
    end

    egg:SetAttribute("CartiPlayerCarried", true)
    activePlayerCarriedEgg = egg

    for _, descendant in ipairs(egg:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.Massless = true
        end
    end

    local pivotToBottom = egg:GetPivot().Position.Y - (eggCFrame.Position.Y - (eggSize.Y / 2))
    local carryHeight = pivotToBottom - (humanoid.HipHeight + root.Size.Y / 2) + 0.9
    local carryForward = math.max(2.5, math.max(eggSize.X, eggSize.Z) * 0.35)

    activePlayerCarryConnection = RunService.Heartbeat:Connect(function()
        if not activePlayerCarriedEgg or not activePlayerCarriedEgg.Parent
            or not character.Parent or not root.Parent
            or humanoid.Health <= 0 then
            dropPlayerCarriedEgg()
            return
        end

        activePlayerCarriedEgg:PivotTo(root.CFrame * CFrame.new(0, carryHeight, -carryForward))
    end)

    startPlayerBaseCrossingCheck()

    return true, "Stole " .. egg.Name .. ". Press Q to drop it."
end

function addNativeEggPrompt(model)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "CarryAreaEgg"
    prompt.ActionText = "Steal"
    prompt.ObjectText = "Egg"
    prompt.HoldDuration = 1.2
    prompt.MaxActivationDistance = 8
    prompt.RequiresLineOfSight = false
    prompt.Style = Enum.ProximityPromptStyle.Default
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.ClickablePrompt = true
    prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton

    -- Put the prompt on a small invisible part near the egg's bottom.
    -- This prevents players from needing to jump to activate the prompt.
    local oldPromptPart = model:FindFirstChild("CartiEggPromptPart")
    if oldPromptPart then oldPromptPart:Destroy() end

    local boundsCFrame, boundsSize = model:GetBoundingBox()
    local promptPart = Instance.new("Part")
    promptPart.Name = "CartiEggPromptPart"
    promptPart.Size = Vector3.new(
        math.max(3.5, math.min(boundsSize.X, 8)),
        2.25,
        math.max(3.5, math.min(boundsSize.Z, 8))
    )
    promptPart.Transparency = 1
    promptPart.Anchored = true
    promptPart.CanCollide = false
    promptPart.CanTouch = false
    promptPart.CanQuery = false
    promptPart.CFrame = CFrame.new(
        boundsCFrame.Position.X,
        boundsCFrame.Position.Y - (boundsSize.Y / 2) + 1.15,
        boundsCFrame.Position.Z
    )
    promptPart.Parent = model
    prompt.Parent = promptPart

    prompt.Triggered:Connect(function(triggeringPlayer)
        if triggeringPlayer and triggeringPlayer ~= localPlayer then
            return
        end

        local ok, message = stealEggForPlayer(model)
        consoleLogLine(message, ok)
    end)

    return prompt
end

local function getNativeNestTemplate()
    local objects = workspace:FindFirstChild("__OBJECTS")
    local areasFolder = objects and objects:FindFirstChild("Areas")
    local guardAreas = areasFolder and areasFolder:FindFirstChild("GuardAreas")
    if not guardAreas then return nil end
    for _, d in ipairs(guardAreas:GetDescendants()) do
        if d:IsA("Model") and d.Name == "NestModel" then return d end
    end
    return nil
end

local function makePassThrough(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.CanTouch = false
        end
    end
end

local function groundModelAt(model, targetPosition, raycastFilter)
    local templateRotation = model:GetPivot().Rotation
    model:PivotTo(CFrame.new(targetPosition) * templateRotation)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = raycastFilter
    params.IgnoreWater = false
    params.RespectCanCollide = true
    local hit = workspace:Raycast(targetPosition + Vector3.new(0, 24, 0), Vector3.new(0, -100, 0), params)
    local groundY = hit and hit.Position.Y or targetPosition.Y - 3
    local boundingCFrame, boundingSize = model:GetBoundingBox()
    local offset = groundY + (boundingSize.Y / 2) - boundingCFrame.Position.Y
    model:PivotTo(model:GetPivot() + Vector3.new(0, offset, 0))
    return groundY
end

local function spawnNativeEggModels(quantity)
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local eggTemplates = findPath(ReplicatedStorage, "Assets", "Models", "Eggs")
    if not eggTemplates then
        warn("[AdminAbuse] ReplicatedStorage.Assets.Models.Eggs was not found.")
        return false
    end
    local template = findEggTemplate(eggTemplates, selectedEgg)
    if not template then
        warn("[AdminAbuse] Egg model not found for: " .. tostring(selectedEgg))
        return false
    end
    quantity = math.clamp(math.floor(tonumber(quantity) or 1), 1, 20)
    local folder = getLocalEggFolder()
    local nestTemplate = getNativeNestTemplate()
    local columns = math.min(quantity, 5)
    local spacing = 28
    for index = 1, quantity do
        local row = math.floor((index - 1) / columns)
        local column = (index - 1) % columns
        local horizontalOffset = (column - ((columns - 1) / 2)) * spacing
        local forwardOffset = 16 + (row * spacing)
        local targetPosition = rootPart.Position
            + (rootPart.CFrame.LookVector * forwardOffset)
            + (rootPart.CFrame.RightVector * horizontalOffset)
        local clone = template:Clone()
        clone.Name = "Divine " .. selectedEgg .. " Egg"
        forceEggVisible(clone)
        attachDivineRarityVfx(clone)
        local sizeMultiplier = 1
        if selectedEggSize == "Huge" then
            sizeMultiplier = 2
        elseif selectedEggSize == "Titanic" then
            sizeMultiplier = 3.5
        end

        clone:ScaleTo(clone:GetScale() * 4 * sizeMultiplier)
        clone.Parent = folder
        makePassThrough(clone)
        if nestTemplate then
            local nest = nestTemplate:Clone()
            nest.Name = clone.Name .. " Nest"
            nest.Parent = folder
            local _, eggSize = clone:GetBoundingBox()
            local _, originalNestSize = nest:GetBoundingBox()
            local origD = math.max(originalNestSize.X, originalNestSize.Z)
            if origD > 0 then
                local desiredD = math.max(eggSize.X, eggSize.Z) * 1.2
                nest:ScaleTo(nest:GetScale() * (desiredD / origD))
            end
            makePassThrough(nest)
            local groundY = groundModelAt(nest, targetPosition, { character, folder })
            local eggSpotBottom = nest:FindFirstChild("EggSpotBottom", true)
            if eggSpotBottom and eggSpotBottom:IsA("BasePart") then
                local fullSink = groundY - eggSpotBottom.Position.Y
                nest:PivotTo(nest:GetPivot() + Vector3.new(0, fullSink * 0.5, 0))
            end
            local _, scaledNestSize = nest:GetBoundingBox()
            local nestCFrame = nest:GetBoundingBox()
            local seatPosition = eggSpotBottom and eggSpotBottom.Position
                or Vector3.new(targetPosition.X, nestCFrame.Position.Y + (scaledNestSize.Y / 2), targetPosition.Z)
            clone:PivotTo(CFrame.new(seatPosition) * clone:GetPivot().Rotation)
            local eggCFrame, seatedEggSize = clone:GetBoundingBox()
            local eggBottom = eggCFrame.Position.Y - (seatedEggSize.Y / 2)
            clone:PivotTo(clone:GetPivot() + Vector3.new(0, seatPosition.Y - eggBottom, 0))
        else
            groundModelAt(clone, targetPosition, { character, folder })
        end
        addNativeEggPrompt(clone)
    end
    return true, quantity
end

local function getBotFolder()
    local folder = workspace:FindFirstChild("CartiLocalBots")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "CartiLocalBots"
        folder.Parent = workspace
    end
    return folder
end

local function spawnedEggChoices()
    local folder = workspace:FindFirstChild("CartiLocalSpawnedEggs")
    local choices = {}
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and child.Name:match(" Egg$")
                and not child:GetAttribute("CartiBotCarried") then
                table.insert(choices, child)
            end
        end
    end
    return choices, folder
end

local function floorYAt(position, exclude)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = exclude or {}
    params.IgnoreWater = false
    params.RespectCanCollide = true
    local hit = workspace:Raycast(position + Vector3.new(0, 40, 0), Vector3.new(0, -140, 0), params)
    return hit and hit.Position.Y or position.Y
end

local function placeBotOnFloor(bot, position, lookAtPosition, exclude)
    local rotation = CFrame.new()
    local flatLook = Vector3.new(lookAtPosition.X, position.Y, lookAtPosition.Z)
    if (flatLook - position).Magnitude > 0.1 then
        rotation = CFrame.lookAt(position, flatLook).Rotation
    end
    bot:PivotTo(CFrame.new(position) * rotation)
    local boundsCFrame, boundsSize = bot:GetBoundingBox()
    local groundY = floorYAt(position, exclude)
    local bottomY = boundsCFrame.Position.Y - (boundsSize.Y / 2)
    bot:PivotTo(bot:GetPivot() + Vector3.new(0, groundY - bottomY, 0))
end

local function nativeCharacterAnimationId(folderName, animationName, fallback)
    local character = localPlayer.Character
    local animate = character and character:FindFirstChild("Animate")
    local folder = animate and animate:FindFirstChild(folderName)
    local animation = folder and folder:FindFirstChild(animationName)
    return animation and animation:IsA("Animation") and animation.AnimationId or fallback
end

local function loadBotTrack(humanoid, animationId, priority, looped)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
    animator.Parent = humanoid
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
    animation:Destroy()
    if not ok or not track then return nil end
    track.Priority = priority
    track.Looped = looped
    return track
end

local function moveBotTo(bot, destination, timeout)
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    local root = bot:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end
    local started = os.clock()
    local lastCommand = 0
    while bot.Parent and humanoid.Health > 0 and os.clock() - started < timeout do
        local flatDistance = (Vector3.new(root.Position.X, 0, root.Position.Z)
            - Vector3.new(destination.X, 0, destination.Z)).Magnitude
        if flatDistance <= 4 then
            humanoid:MoveTo(root.Position)
            return true
        end
        if os.clock() - lastCommand >= 1.5 then
            humanoid:MoveTo(destination)
            lastCommand = os.clock()
        end
        RunService.Heartbeat:Wait()
    end
    return false
end

local function removeEggPromptNear(egg)
    local eggCFrame, eggSize = egg:GetBoundingBox()
    local radius = math.max(eggSize.X, eggSize.Y, eggSize.Z)
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "CartiEggSmartPromptPart"
            and (child.Position - eggCFrame.Position).Magnitude <= radius then
            child:Destroy()
        end
    end
end

local function carryEggWithBot(bot, egg, eggFolder)
    local root = bot:FindFirstChild("HumanoidRootPart")
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return nil end
    egg:SetAttribute("CartiBotCarried", true)
    removeEggPromptNear(egg)
    local nest = eggFolder and eggFolder:FindFirstChild(egg.Name .. " Nest")
    if nest then nest:Destroy() end
    for _, d in ipairs(egg:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.CanTouch = false
            d.Massless = true
        end
    end
    local eggBoundsCFrame, eggBoundsSize = egg:GetBoundingBox()
    local pivotToBottom = egg:GetPivot().Position.Y - (eggBoundsCFrame.Position.Y - (eggBoundsSize.Y / 2))
    local rootGroundOffset = humanoid.HipHeight + (root.Size.Y / 2)
    local carryHeight = pivotToBottom - rootGroundOffset + 0.75
    local carryForward = math.max(2.5, math.max(eggBoundsSize.X, eggBoundsSize.Z) * 0.3)
    local connection = RunService.Heartbeat:Connect(function()
        if bot.Parent and egg.Parent and root.Parent then
            egg:PivotTo(root.CFrame * CFrame.new(0, carryHeight, -carryForward))
        end
    end)
    return connection
end

local function makeBotChat(bot, message)
    message = trim(message)
    if message == "" then return end
    
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            pcall(function()
                channel:DisplaySystemMessage(bot.Name .. ": " .. message)
            end)
        end
    else
        pcall(function()
            game:GetService("Chat"):Chat(bot:FindFirstChild("Head") or bot.PrimaryPart, message, Enum.ChatColor.White)
        end)
    end
end

local function triggerActiveBotMessage(customMessage)
    customMessage = trim(customMessage)
    if customMessage == "" then customMessage = "Got the egg!" end
    local folder = workspace:FindFirstChild("CartiLocalBots")
    if not folder then return false end
    for _, bot in ipairs(folder:GetChildren()) do
        if bot:IsA("Model") then
            makeBotChat(bot, customMessage)
        end
    end
    return true
end

local function removeAllBots()
    local folder = workspace:FindFirstChild("CartiLocalBots")
    if folder then folder:Destroy() end
    local eggFolder = workspace:FindFirstChild("CartiLocalSpawnedEggs")
    if eggFolder then
        for _, child in ipairs(eggFolder:GetChildren()) do
            if child:IsA("Model") and child:GetAttribute("CartiBotCarried") then
                child:Destroy()
            end
        end
    end
    return true
end

local function makeBotNonCollidable(bot)
    for _, descendant in ipairs(bot:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
        end
    end
end

local function createEggStealingBot(username, customMessage)
    username = trim(username)
    customMessage = trim(customMessage)
    if customMessage == "" then customMessage = "Got the egg!" end

    if username == "" then return false, "Enter a Roblox username" end
    
    local userId
    local resolved = pcall(function() userId = Players:GetUserIdFromNameAsync(username) end)
    if not resolved or not userId then return false, "Roblox user not found" end
    local created, bot = pcall(function() return Players:CreateHumanoidModelFromUserId(userId) end)
    if not created or not bot then return false, "Could not create bot avatar" end
    
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    local root = bot:FindFirstChild("HumanoidRootPart")
    local separationLine = getSeparationLine()
    if not humanoid or not root or not (separationLine and separationLine:IsA("BasePart")) then
        bot:Destroy()
        return false, "Bot rig or safe-zone line is unavailable"
    end
    
    bot.Name = username
    humanoid.DisplayName = username
    humanoid.NameDisplayDistance = 120
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    humanoid.WalkSpeed = 340
    bot.PrimaryPart = root
    bot.Parent = getBotFolder()

    makeBotNonCollidable(bot)
    bot.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
        end
    end)

    local lineRight = separationLine.CFrame.RightVector
    local lineForward = separationLine.CFrame.LookVector

    local eggChoices, eggFolder = spawnedEggChoices()
    
    if #eggChoices == 0 then
        local baseSpawnPos = separationLine.Position - (lineForward * 10)
        placeBotOnFloor(bot, baseSpawnPos, baseSpawnPos + lineForward, { bot })
        
        task.spawn(function()
            while bot.Parent and humanoid.Health > 0 do
                local randomOffset = Vector3.new(random:NextNumber(-6, 6), 0, random:NextNumber(-4, 4))
                local wanderTarget = baseSpawnPos + randomOffset
                wanderTarget = Vector3.new(wanderTarget.X, floorYAt(wanderTarget, { bot }), wanderTarget.Z)
                
                local runId = humanoid.RigType == Enum.HumanoidRigType.R6
                    and "rbxassetid://180426354"
                    or nativeCharacterAnimationId("run", "RunAnim", "rbxassetid://913376220")
                local runTrack = loadBotTrack(humanoid, runId, Enum.AnimationPriority.Movement, true)
                if runTrack then
                    runTrack:Play(0.15)
                    runTrack:AdjustSpeed(1.5)
                end
                
                moveBotTo(bot, wanderTarget, 10)
                
                if runTrack then runTrack:Stop(0.15) end
                humanoid:MoveTo(root.Position)
                
                task.wait(random:NextNumber(2, 5))
            end
        end)
        return true, bot
    end

    local targetEgg = eggChoices[random:NextInteger(1, #eggChoices)]
    local eggCFrame, eggSize = targetEgg:GetBoundingBox()
    
    local lateral = math.clamp(lineRight:Dot(eggCFrame.Position - separationLine.Position),
        -(separationLine.Size.X / 2) + 6, (separationLine.Size.X / 2) - 6)
    local spawnPosition = separationLine.Position + (lineRight * lateral) - (lineForward * 5)
    placeBotOnFloor(bot, spawnPosition, eggCFrame.Position, { bot, eggFolder })
    
    local approachDirection = Vector3.new(-targetEgg:GetPivot().LookVector.X, 0, -targetEgg:GetPivot().LookVector.Z)
    approachDirection = approachDirection.Magnitude > 0.1 and approachDirection.Unit or lineForward
    local approachRadius = (math.max(eggSize.X, eggSize.Z) / 2) + 3
    local approachPosition = eggCFrame.Position + (approachDirection * approachRadius)
    approachPosition = Vector3.new(approachPosition.X, floorYAt(approachPosition, { bot, eggFolder }), approachPosition.Z)
    
    local runId = humanoid.RigType == Enum.HumanoidRigType.R6
        and "rbxassetid://180426354"
        or nativeCharacterAnimationId("run", "RunAnim", "rbxassetid://913376220")
    local runTrack = loadBotTrack(humanoid, runId, Enum.AnimationPriority.Movement, true)
    if runTrack then
        runTrack:Play(0.15)
        runTrack:AdjustSpeed(humanoid.WalkSpeed / 16)
    end
    
    task.spawn(function()
        local reachedEgg = moveBotTo(bot, approachPosition, 45)
        if not reachedEgg or not bot.Parent or not targetEgg.Parent then
            bot:Destroy()
            return
        end
        if runTrack then runTrack:Stop(0.15) end
        humanoid:MoveTo(root.Position)
        bot:PivotTo(bot:GetPivot() + Vector3.new(approachPosition.X - root.Position.X, 0, approachPosition.Z - root.Position.Z))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        local faceEgg = Vector3.new(eggCFrame.Position.X, root.Position.Y, eggCFrame.Position.Z)
        if (faceEgg - root.Position).Magnitude > 0.1 then
            root.CFrame = CFrame.lookAt(root.Position, faceEgg)
        end
        task.wait(1)

        local stealId = humanoid.RigType == Enum.HumanoidRigType.R6
            and "rbxassetid://182393478"
            or nativeCharacterAnimationId("toolnone", "ToolNoneAnim", "rbxassetid://507768375")
        local stealTrack = loadBotTrack(humanoid, stealId, Enum.AnimationPriority.Action, true)
        if stealTrack then stealTrack:Play(0.1) end
        local carryConnection = carryEggWithBot(bot, targetEgg, eggFolder)
        
        local exitLateral = math.clamp(lineRight:Dot(root.Position - separationLine.Position),
            -(separationLine.Size.X / 2) + 6, (separationLine.Size.X / 2) - 6)
        local exitPosition = separationLine.Position + (lineRight * exitLateral) - (lineForward * 10)
        exitPosition = Vector3.new(exitPosition.X, floorYAt(exitPosition, { bot, eggFolder }), exitPosition.Z)
        
        if runTrack then
            runTrack:Play(0.1)
            runTrack:AdjustSpeed(humanoid.WalkSpeed / 16)
        end
        
        moveBotTo(bot, exitPosition, 30)
        
        if runTrack then runTrack:Stop(0.15) end
        humanoid:MoveTo(root.Position)
        root.Anchored = true
        
        -- Wait 3 to 5 seconds after getting the egg, then cleanup bot and egg
        task.wait(random:NextNumber(3, 5))
        if carryConnection then
            carryConnection:Disconnect()
        end
        if targetEgg and targetEgg.Parent then
            targetEgg:Destroy()
        end
        if bot and bot.Parent then
            bot:Destroy()
        end
    end)
    return true, bot
end

local callbacks = {
    SendAnnouncement = showAnnouncement,
    SpawnEggs = showSpawnEggs,
    SpawnEggsToPlayer = showSpawnEggsToPlayer,
    StartRift = showRandomRiftNotification,
    GiveAdmin = showGiveAdminNotification,
    SpawnEggsInServer = spawnNativeEggModels,
    CreateBot = createEggStealingBot,
    TriggerBotMsg = triggerActiveBotMessage,
    RemoveBots = removeAllBots,
}

local integrityFailed = false
local integrityConnection
local api = {}

function api.SetCallbacks(newCallbacks)
    if integrityFailed then return false end
    for name, cb in pairs(newCallbacks or {}) do
        if callbacks[name] ~= nil and type(cb) == "function" then callbacks[name] = cb end
    end
    return true
end

function api.ShowOverview()
    overview.Visible = true
    boostsPage.Visible = false
    overview.CanvasPosition = Vector2.zero
end

function api.ShowBoosts()
    overview.Visible = false
    boostsPage.Visible = true
end

function api.ShowActions()
    overview.Visible = true
    boostsPage.Visible = false
    overview.CanvasPosition = Vector2.new(0, 266)
end

function api.SetPlayerName(name) playerInput.Text = tostring(name or "") end
function api.SetQuantity(amount) quantityInput.Text = tostring(math.max(1, math.floor(tonumber(amount) or 1))) end

function api.SetSelectedEgg(name)
    if not mutationButtons[name] then return false end
    selectedEgg = name
    for eggName, eggButton in pairs(mutationButtons) do
        setButtonActive(eggButton, eggName == selectedEgg)
    end
    return true
end

function api.GetSelectedEgg() return selectedEgg end
function api.SetAnnouncementMessage(m) announcementInput.Text = tostring(m or "") end

function api.SendAnnouncement(message)
    if message ~= nil then announcementInput.Text = tostring(message) end
    return callbacks.SendAnnouncement(announcementInput.Text)
end

function api.StartRift() return callbacks.StartRift() end
function api.ShowSpawnEggs(q) return callbacks.SpawnEggs(q or quantityInput.Text) end
function api.ShowSpawnEggsToPlayer(p, q) return callbacks.SpawnEggsToPlayer(p or playerInput.Text, q or quantityInput.Text) end

function api.GiveAdmin(playerName)
    if playerName ~= nil then playerInput.Text = tostring(playerName) end
    return callbacks.GiveAdmin(playerInput.Text)
end

function api.SpawnEggsInServer(q) return callbacks.SpawnEggsInServer(q or quantityInput.Text) end

function api.CreateBot(username, customMessage)
    if username ~= nil then botNameInput.Text = tostring(username) end
    if customMessage ~= nil then botMessageInput.Text = tostring(customMessage) end
    return callbacks.CreateBot(botNameInput.Text, botMessageInput.Text)
end

function api.TriggerBotMsg(customMessage)
    if customMessage ~= nil then botMessageInput.Text = tostring(customMessage) end
    return callbacks.TriggerBotMsg(botMessageInput.Text)
end

function api.RemoveBots()
    return callbacks.RemoveBots()
end

function api.Destroy()
    integrityFailed = true
    if integrityConnection then
        integrityConnection:Disconnect()
        integrityConnection = nil
    end
    if _G.CartiAdminAbuse == api then _G.CartiAdminAbuse = nil end
    if gui.Parent then gui:Destroy() end
end

_G.CartiAdminAbuse = api

integrityConnection = RunService.Heartbeat:Connect(function()
    local intact = watermark.Parent == header
        and watermark:IsDescendantOf(gui)
        and watermark.Name == "Watermark"
        and watermark.Text == "t<b><font size=\"15\">.</font></b>me/cartiscripts"
        and watermark.RichText
        and watermark.TextSize == 8
        and watermark.Font == Enum.Font.GothamMedium
        and watermark.TextXAlignment == Enum.TextXAlignment.Right
        and watermark.Visible
        and watermark.TextTransparency == 0
    if intact then return end
    integrityFailed = true
    for name in pairs(callbacks) do
        callbacks[name] = function() return false end
    end
    if _G.CartiAdminAbuse == api then _G.CartiAdminAbuse = nil end
    integrityConnection:Disconnect()
    integrityConnection = nil
    if gui.Parent then gui:Destroy() end
end)

for _, name in ipairs(mutationNames) do
    overview[name].MouseButton1Click:Connect(function() api.SetSelectedEgg(name) end)
end

announce.MouseButton1Click:Connect(function()
    callbacks.SendAnnouncement(announcementInput.Text)
end)

announcementInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then callbacks.SendAnnouncement(announcementInput.Text) end
end)

spawnEggs.MouseButton1Click:Connect(function()
    callbacks.SpawnEggs(math.max(1, tonumber(quantityInput.Text) or 1))
end)

spawnToPlayer.MouseButton1Click:Connect(function()
    callbacks.SpawnEggsToPlayer(playerInput.Text, math.max(1, tonumber(quantityInput.Text) or 1))
end)

startRift.MouseButton1Click:Connect(function() callbacks.StartRift() end)
giveAdmin.MouseButton1Click:Connect(function() callbacks.GiveAdmin(playerInput.Text) end)
spawnEggsInServer.MouseButton1Click:Connect(function() callbacks.SpawnEggsInServer(quantityInput.Text) end)

createBotButton.MouseButton1Click:Connect(function()
    callbacks.CreateBot(botNameInput.Text, botMessageInput.Text)
end)

triggerBotMsgButton.MouseButton1Click:Connect(function()
    callbacks.TriggerBotMsg(botMessageInput.Text)
end)

removeBotsButton.MouseButton1Click:Connect(function()
    callbacks.RemoveBots()
end)

botNameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then callbacks.CreateBot(botNameInput.Text, botMessageInput.Text) end
end)

botMessageInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then callbacks.CreateBot(botNameInput.Text, botMessageInput.Text) end
end)

closeButton.MouseButton1Click:Connect(api.Destroy)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F7 and gui.Parent then
        gui.Enabled = not gui.Enabled
    end
end)

local dragging = false
local dragStart
local panelStart

header.InputBegan:Connect(function(input)
    local inputType = input.UserInputType
    if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then return end
    dragging = true
    dragStart = input.Position
    panelStart = panel.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
    end)
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    local inputType = input.UserInputType
    if inputType ~= Enum.UserInputType.MouseMovement and inputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    panel.Position = UDim2.new(
        panelStart.X.Scale, panelStart.X.Offset + delta.X,
        panelStart.Y.Scale, panelStart.Y.Offset + delta.Y
    )
end)

-- These two pathfinding implementations were older experiments appended to
-- the file. The active bot controller above is the only one that should run.
if false then
-- Services
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

-- Configuration
local EXIT_POSITION = Vector3.new(0, 0, 50) -- Change this to your actual exit/delivery position vector
local WAIT_TIME_BEFORE_DESTROY = 3 -- Seconds to wait after reaching the exit before destroying

local function setupEggBot(botCharacter, carriedEgg)
	local humanoid = botCharacter:WaitForChild("Humanoid")
	local rootPart = botCharacter:WaitForChild("HumanoidRootPart")

	-- Make bot non-collidable with players if needed
	for _, part in ipairs(botCharacter:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(rootPart.Position, EXIT_POSITION)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		
		for _, waypoint in ipairs(waypoints) do
			humanoid:MoveTo(waypoint.Position)
			
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end
			
			-- Wait until the bot reaches the current waypoint
			local reached = false
			local connection
			connection = humanoid.MoveToFinished:Connect(function(isReached)
				reached = true
				if connection then
					connection:Disconnect()
				end
			end)
			
			-- Timeout safeguard in case it gets stuck
			task.spawn(function()
				task.wait(2)
				if not reached then
					reached = true
					if connection then
						connection:Disconnect()
					end
				end
			end)
			
			repeat task.wait() until reached
		end
		
		-- Reached the exit position
		task.wait(WAIT_TIME_BEFORE_DESTROY)
		
		-- Clean up the carried egg and the bot character
		if carriedEgg and carriedEgg.Parent then
			carriedEgg:Destroy()
		end
		
		if botCharacter and botCharacter.Parent then
			botCharacter:Destroy()
		end
	else
		warn("Pathfinding failed: " .. tostring(errorMessage))
	end
end

-- Example trigger function (call this when the bot successfully picks up an egg)
-- setupEggBot(myBotModel, myEggPart)
-- Services
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

-- Configuration
local EXIT_POSITION = Vector3.new(0, 0, 50) -- Change to your exit/delivery position vector
local WAIT_TIME_BEFORE_DESTROY = 3

-- Helper function to move a bot to a target position with realistic walking and jumping
local function moveToTarget(humanoid, targetPosition)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(humanoid.RootPart.Position, targetPosition)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		
		-- Background task for realistic random jumps while moving
		local isMoving = true
		task.spawn(function()
			while isMoving and humanoid and humanoid.Parent do
				task.wait(math.random(2, 5))
				if isMoving and humanoid.FloorMaterial ~= Enum.Material.Air then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end)

		for _, waypoint in ipairs(waypoints) do
			if not humanoid or not humanoid.Parent then break end
			
			humanoid:MoveTo(waypoint.Position)
			
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			
			-- Wait until waypoint is reached with a timeout safeguard
			local reached = false
			local connection
			connection = humanoid.MoveToFinished:Connect(function()
				reached = true
				if connection then connection:Disconnect() end
			end)
			
			local timeout = tick() + 2.5
			repeat 
				task.wait(0.1) 
			until reached or tick() > timeout
			
			if connection then connection:Disconnect() end
		end
		
		isMoving = false
	else
		warn("Pathfinding failed: " .. tostring(errorMessage))
	end
end

-- Main Bot Controller Function
local function runEggBot(botCharacter, egg1, egg2)
	local humanoid = botCharacter:WaitForChild("Humanoid")
	local rootPart = botCharacter:WaitForChild("HumanoidRootPart")
	
	humanoid.RootPart = rootPart

	-- Make bot non-collidable with players
	for _, part in ipairs(botCharacter:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	-- Randomly decide whether this bot will go for the 2nd egg (50% chance)
	local collectTwoEggs = math.random() > 0.5 and egg1 and egg2

	if collectTwoEggs then
		-- 1. Go to First Egg
		moveToTarget(humanoid, egg1.Position)
		
		-- Destroy the first egg immediately upon arrival
		if egg1 and egg1.Parent then
			egg1:Destroy()
		end
		
		task.wait(0.5) -- Small pause

		-- 2. Go to Second Egg
		moveToTarget(humanoid, egg2.Position)
		
		-- 3. Head to Exit with the second egg (Only 2-egg bots survive up to this point)
		moveToTarget(humanoid, EXIT_POSITION)
		
		-- Brief pause before disappearing
		task.wait(WAIT_TIME_BEFORE_DESTROY)
		
		-- Cleanup second egg and bot
		if egg2 and egg2.Parent then
			egg2:Destroy()
		end
		if botCharacter and botCharacter.Parent then
			botCharacter:Destroy()
		end
	else
		-- Single-egg path: Get the target egg, destroy it, and immediately destroy the bot right there
		local targetEgg = egg1 or egg2
		if targetEgg then
			moveToTarget(humanoid, targetEgg.Position)
			
			if targetEgg and targetEgg.Parent then
				targetEgg:Destroy()
			end
		end
		
		-- Instantly destroy the bot since it only collected one egg
		if botCharacter and botCharacter.Parent then
			botCharacter:Destroy()
		end
	end
end

-- Example trigger:
-- runEggBot(myBotModel, firstEggPart, secondEggPart)
end


-- ============================================================
-- PURPLE SERVER-CONSOLE STYLE COMMAND PANEL
-- Toggle with F8 or the Console button in the header.
-- This console routes commands to the existing local functions
-- in this script. Server-authoritative commands require a server
-- RemoteEvent implementation in your own game.
-- ============================================================

do
    local consoleOpen = false
    local consoleDragging = false
    local consoleDragStart
    local consolePanelStart

    local consoleGui = create("Frame", {
        Name = "ServerConsolePanel",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(540, 370),
        BackgroundColor3 = Color3.fromRGB(7, 5, 14),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    }, gui)
    corner(consoleGui, 10)
    stroke(consoleGui, COLORS.purpleSoft, 0.15, 1)
    gradient(consoleGui, Color3.fromRGB(18, 8, 31), Color3.fromRGB(5, 4, 10), 90)

    local consoleHeader = create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 44),
        ZIndex = 51,
    }, consoleGui)

    local consoleTitle = label(consoleHeader, "SERVER CONSOLE", UDim2.fromOffset(14, 0),
        UDim2.fromOffset(220, 28), 13, COLORS.text)
    consoleTitle.Font = Enum.Font.GothamBold
    label(consoleHeader, "PURPLE ADMIN TERMINAL", UDim2.fromOffset(15, 22),
        UDim2.fromOffset(220, 17), 8, COLORS.muted)

    local consoleClose = button(consoleHeader, "ConsoleClose", "X",
        UDim2.new(1, -34, 0, 8), UDim2.fromOffset(25, 25), false)
    addHover(consoleClose)

    create("Frame", {
        BackgroundColor3 = COLORS.line,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(12, 42),
        Size = UDim2.new(1, -24, 0, 1),
        ZIndex = 51,
    }, consoleHeader)

    local consoleLog = create("ScrollingFrame", {
        Name = "Log",
        Position = UDim2.fromOffset(12, 52),
        Size = UDim2.new(1, -24, 1, -112),
        BackgroundColor3 = Color3.fromRGB(3, 3, 8),
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.purpleBright,
        ZIndex = 51,
    }, consoleGui)
    corner(consoleLog, 5)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
    }, consoleLog)
    local consoleLayout = create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, consoleLog)

    local consoleInput = create("TextBox", {
        Name = "CommandInput",
        Position = UDim2.new(0, 12, 1, -48),
        Size = UDim2.new(1, -24, 0, 34),
        BackgroundColor3 = Color3.fromRGB(30, 12, 52),
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Code,
        PlaceholderText = "Enter a command or type /help",
        PlaceholderColor3 = COLORS.muted,
        Text = "",
        TextColor3 = COLORS.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
    }, consoleGui)
    corner(consoleInput, 5)
    stroke(consoleInput, COLORS.line, 0.35, 1)
    create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, consoleInput)

    local function consoleLogLine(message, success)
        local line = label(consoleLog, "> " .. tostring(message),
            UDim2.new(), UDim2.new(1, -4, 0, 19), 12,
            success == false and Color3.fromRGB(255, 85, 105) or COLORS.green)
        line.Font = Enum.Font.Code
        line.AutomaticSize = Enum.AutomaticSize.Y
        line.TextWrapped = true
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.LayoutOrder = #consoleLog:GetChildren()
        task.defer(function()
            consoleLog.CanvasPosition = Vector2.new(0, consoleLayout.AbsoluteContentSize.Y)
        end)
    end

    local function consolePlayer(name)
        name = trim(name)
        if name == "" then return nil end
        local lowered = string.lower(name)
        for _, target in ipairs(Players:GetPlayers()) do
            if string.lower(target.Name) == lowered or string.lower(target.DisplayName) == lowered then
                return target
            end
        end
        return nil
    end

    local function runConsoleCommand(raw)
        raw = trim(raw)
        if raw == "" then return end

        consoleLogLine(raw, true)
        local pieces = string.split(raw, " ")
        local command = string.lower(pieces[1] or "")
        table.remove(pieces, 1)
        local argumentText = trim(table.concat(pieces, " "))

        if command == "/help" then
            consoleLogLine("/help /players /announcement /globalAnnouncement /teleport /giveadmin /giveowner /giveps /adminabuse /spawn /spawnplayer /rift /bot /botmsg /removebots", true)

        elseif command == "/players" then
            local names = {}
            for _, target in ipairs(Players:GetPlayers()) do
                table.insert(names, target.Name)
            end
            consoleLogLine(#names .. " player(s): " .. table.concat(names, ", "), true)

        elseif command == "/announcement" or command == "/announce" then
            if argumentText == "" then
                consoleLogLine("Usage: /announcement message", false)
            else
                local ok = showAnnouncement(argumentText)
                consoleLogLine(ok and "Announcement displayed." or "Announcement failed.", ok)
            end

        elseif command == "/globalannouncement" or command == "/globalannounce" then
            if argumentText == "" then
                consoleLogLine("Usage: /globalAnnouncement message", false)
            else
                -- The existing script has no server MessagingService bridge.
                -- Keep this local and clearly report what happened.
                local ok = showAnnouncement("[GLOBAL] " .. argumentText)
                consoleLogLine(ok and "Local global-style announcement displayed. Add a server bridge for cross-server delivery." or "Announcement failed.", ok)
            end

        elseif command == "/teleport" then
            local target = consolePlayer(pieces[1])
            local character = localPlayer.Character
            local targetCharacter = target and target.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                root.CFrame = targetRoot.CFrame + Vector3.new(3, 0, 0)
                consoleLogLine("Teleported to " .. target.Name .. ".", true)
            else
                consoleLogLine("Player not found or character unavailable.", false)
            end

        elseif command == "/giveadmin" then
            if argumentText == "" then
                consoleLogLine("Usage: /giveadmin player", false)
            else
                consoleLogLine(showGiveAdminNotification(argumentText) and "Admin notification displayed." or "Invalid player name.", true)
            end

        elseif command == "/giveowner" then
            if argumentText == "" then
                consoleLogLine("Usage: /giveowner player", false)
            else
                local message = string.format('<font color="#20BFFF">%s %s</font> <font color="#FFFFFF">gave owner to</font> <font color="#FF3B3B">%s!</font>', escapeRichText(ADMIN_USERNAME), VERIFIED_BADGE, escapeRichText(argumentText))
                messageNotification.Top({ ShowShadow = true, Message = message, Time = 6, Color = Color3.new(1, 1, 1), SingleLine = true })
                consoleLogLine("Owner notification displayed.", true)
            end

        elseif command == "/giveps" then
            if argumentText == "" then
                consoleLogLine("Usage: /giveps player", false)
            else
                local message = string.format('<font color="#20BFFF">%s %s</font> <font color="#FFFFFF">gave a private server to</font> <font color="#FF3B3B">%s!</font>', escapeRichText(ADMIN_USERNAME), VERIFIED_BADGE, escapeRichText(argumentText))
                messageNotification.Top({ ShowShadow = true, Message = message, Time = 6, Color = Color3.new(1, 1, 1), SingleLine = true })
                consoleLogLine("Private-server notification displayed.", true)
            end

        elseif command == "/cutscene" or command == "/opcutscene" then
            playLocalAdminAbuseCutscene()
            consoleLogLine("Dragon cutscene started locally.", true)

        elseif command == "/adminabuse" or command == "/abuse" then
            local amount = math.clamp(math.floor(tonumber(pieces[1]) or 10), 1, 20)
            playLocalAdminAbuseCutscene()
            local spawned, count = spawnNativeEggModels(amount)
            local announcementOk = showAnnouncement("ADMIN ABUSE: " .. tostring(count or amount) .. " egg(s) spawned!")
            consoleLogLine(spawned and announcementOk and "Admin Abuse started with cutscene." or "Admin Abuse partially started locally.", spawned)

        elseif command == "/spawn" then
            local amount = math.max(1, math.floor(tonumber(pieces[1]) or 1))
            local ok = spawnNativeEggModels(amount)
            consoleLogLine(ok and ("Spawned " .. amount .. " egg(s).") or "Egg spawn failed.", ok)

        elseif command == "/spawnplayer" then
            local targetName = pieces[1]
            local amount = math.max(1, math.floor(tonumber(pieces[2]) or 1))
            local ok = showSpawnEggsToPlayer(targetName, amount)
            consoleLogLine(ok and "Spawn-to-player notification displayed." or "Invalid target.", ok)

        elseif command == "/rift" then
            local result = showRandomRiftNotification()
            consoleLogLine(result and ("Rift notification displayed for " .. tostring(result) .. ".") or "Rift notification failed.", result ~= nil)

        elseif command == "/bot" then
            local username = pieces[1]
            local message = trim(table.concat(pieces, " "):gsub("^" .. (username or "") .. "%s*", ""))
            local ok, result = createEggStealingBot(username, message)
            consoleLogLine(ok and "Bot created: " .. tostring(username) or tostring(result), ok)

        elseif command == "/botmsg" then
            local ok = triggerActiveBotMessage(argumentText)
            consoleLogLine(ok and "Bot message triggered." or "No bot folder found.", ok)

        elseif command == "/removebots" then
            local ok = removeAllBots()
            consoleLogLine(ok and "All local bots removed." or "Could not remove bots.", ok)

        else
            consoleLogLine("Unknown command. Type /help.", false)
        end
    end

    local function setConsoleVisible(visible)
        consoleOpen = visible
        consoleGui.Visible = visible
        if visible then
            consoleInput:CaptureFocus()
        else
            consoleInput:ReleaseFocus()
        end
    end

    consoleInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            runConsoleCommand(consoleInput.Text)
            consoleInput.Text = ""
        end
    end)

    consoleClose.MouseButton1Click:Connect(function()
        setConsoleVisible(false)
    end)

    consoleHeader.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        consoleDragging = true
        consoleDragStart = input.Position
        consolePanelStart = consoleGui.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                consoleDragging = false
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not consoleDragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - consoleDragStart
        consoleGui.Position = UDim2.new(
            consolePanelStart.X.Scale, consolePanelStart.X.Offset + delta.X,
            consolePanelStart.Y.Scale, consolePanelStart.Y.Offset + delta.Y
        )
    end)

    local consoleButton = button(header, "OpenConsole", "Console",
        UDim2.new(1, -190, 0, 3), UDim2.fromOffset(58, 23), false)
    consoleButton.TextSize = 9
    addHover(consoleButton)
    consoleButton.MouseButton1Click:Connect(function()
        setConsoleVisible(not consoleOpen)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.F8 then
            setConsoleVisible(not consoleOpen)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Q and activePlayerCarriedEgg then
            local ok = dropPlayerCarriedEgg()
            consoleLogLine(ok and "Dropped carried egg." or "No egg to drop.", ok)
        end
    end)

    consoleLogLine("Server Console initialized.", true)
    consoleLogLine("Type /help to view available commands.", true)
end

return api
