-- =========================
-- BrixLib UI Library v1.0
-- Made by Brix
-- =========================

local BrixLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- THEME
-- =========================
local Theme = {
    Background     = Color3.fromRGB(15, 15, 15),
    Secondary      = Color3.fromRGB(22, 22, 22),
    Accent         = Color3.fromRGB(34, 139, 34),
    AccentDark     = Color3.fromRGB(24, 100, 24),
    AccentHover    = Color3.fromRGB(44, 160, 44),
    Text           = Color3.fromRGB(255, 255, 255),
    TextDark       = Color3.fromRGB(170, 170, 170),
    TextDisabled   = Color3.fromRGB(100, 100, 100),
    Toggle_ON      = Color3.fromRGB(34, 139, 34),
    Toggle_OFF     = Color3.fromRGB(50, 50, 50),
    Input          = Color3.fromRGB(28, 28, 28),
    Slider         = Color3.fromRGB(34, 139, 34),
    SliderBG       = Color3.fromRGB(40, 40, 40),
    Divider        = Color3.fromRGB(35, 35, 35),
    Notification   = Color3.fromRGB(20, 20, 20),
    Shadow         = Color3.fromRGB(0, 0, 0),
    TabActive      = Color3.fromRGB(34, 139, 34),
    TabInactive    = Color3.fromRGB(28, 28, 28),
    CloseBtn       = Color3.fromRGB(200, 50, 50),
    MinimizeBtn    = Color3.fromRGB(200, 150, 0),
}

-- =========================
-- UTILITY FUNCTIONS
-- =========================
local function Tween(obj, props, duration, style, direction)
    local tween = TweenService:Create(obj,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function AddShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
end

local function SaveConfig(folder, file, data)
    pcall(function()
        if not isfolder(folder) then makefolder(folder) end
        writefile(folder .. "/" .. file .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function LoadConfig(folder, file)
    local success, result = pcall(function()
        if isfile(folder .. "/" .. file .. ".json") then
            return game:GetService("HttpService"):JSONDecode(readfile(folder .. "/" .. file .. ".json"))
        end
    end)
    return success and result or {}
end

-- =========================
-- NOTIFICATION SYSTEM
-- =========================
local NotifHolder = Instance.new("ScreenGui")
NotifHolder.Name = "BrixLibNotifs"
NotifHolder.ResetOnSpawn = false
NotifHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifHolder.Parent = game.CoreGui

local NotifFrame = Instance.new("Frame")
NotifFrame.Name = "NotifHolder"
NotifFrame.Size = UDim2.new(0, 300, 1, 0)
NotifFrame.Position = UDim2.new(1, -310, 0, 0)
NotifFrame.BackgroundTransparency = 1
NotifFrame.Parent = NotifHolder

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifFrame

local NotifPadding = Instance.new("UIPadding")
NotifPadding.PaddingBottom = UDim.new(0, 16)
NotifPadding.PaddingRight = UDim.new(0, 8)
NotifPadding.Parent = NotifFrame

function BrixLib:Notify(options)
    local title    = options.Title or "BrixLib"
    local content  = options.Content or ""
    local duration = options.Duration or 4
    local ntype    = options.Type or "info"

    local typeColor = Theme.Accent
    local typeIcon  = "ℹ️"
    if ntype == "success" then typeColor = Color3.fromRGB(34, 180, 34) typeIcon = "✅"
    elseif ntype == "warning" then typeColor = Color3.fromRGB(220, 160, 0) typeIcon = "⚠️"
    elseif ntype == "error" then typeColor = Color3.fromRGB(200, 50, 50) typeIcon = "❌"
    end

    local Notif = Instance.new("Frame")
    Notif.Name = "Notification"
    Notif.Size = UDim2.new(1, 0, 0, 70)
    Notif.BackgroundColor3 = Theme.Notification
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    Notif.Position = UDim2.new(1, 10, 0, 0)
    Notif.Parent = NotifFrame
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    AddShadow(Notif)

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = typeColor
    Accent.BorderSizePixel = 0
    Accent.Parent = Notif
    Instance.new("UICorner", Accent).CornerRadius = UDim.new(0, 4)

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 14, 0.5, -15)
    Icon.BackgroundTransparency = 1
    Icon.Text = typeIcon
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = Notif

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -60, 0, 22)
    TitleLbl.Position = UDim2.new(0, 50, 0, 10)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.TextSize = 13
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Notif

    local ContentLbl = Instance.new("TextLabel")
    ContentLbl.Size = UDim2.new(1, -60, 0, 28)
    ContentLbl.Position = UDim2.new(0, 50, 0, 32)
    ContentLbl.BackgroundTransparency = 1
    ContentLbl.Text = content
    ContentLbl.TextColor3 = Theme.TextDark
    ContentLbl.TextSize = 11
    ContentLbl.Font = Enum.Font.Gotham
    ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
    ContentLbl.TextWrapped = true
    ContentLbl.Parent = Notif

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = typeColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = Notif

    Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
    Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(Notif, {Position = UDim2.new(1, 10, 0, 0)}, 0.3)
        task.wait(0.35)
        Notif:Destroy()
    end)
end

-- =========================
-- KEYBIND SYSTEM
-- =========================
local Keybinds = {}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    for key, callback in pairs(Keybinds) do
        if input.KeyCode == key then
            callback()
        end
    end
end)

-- =========================
-- CREATE WINDOW
-- =========================
function BrixLib:CreateWindow(options)
    local WindowTitle  = options.Title or "BrixLib"
    local Subtitle     = options.Subtitle or ""
    local ToggleKey    = options.ToggleKey or Enum.KeyCode.RightShift
    local ConfigFolder = options.ConfigFolder or "BrixLib"
    local ConfigFile   = options.ConfigFile or WindowTitle
    local SavedConfig  = LoadConfig(ConfigFolder, ConfigFile)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "BrixLib_" .. WindowTitle
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 560, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = Gui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    AddShadow(MainFrame)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local SidebarFix = Instance.new("Frame")
    SidebarFix.Size = UDim2.new(0, 20, 1, 0)
    SidebarFix.Position = UDim2.new(1, -20, 0, 0)
    SidebarFix.BackgroundColor3 = Theme.Secondary
    SidebarFix.BorderSizePixel = 0
    SidebarFix.Parent = Sidebar

    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(1, 0, 0, 70)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = Sidebar

    local LogoTitle = Instance.new("TextLabel")
    LogoTitle.Size = UDim2.new(1, -10, 0, 24)
    LogoTitle.Position = UDim2.new(0, 10, 0, 14)
    LogoTitle.BackgroundTransparency = 1
    LogoTitle.Text = WindowTitle
    LogoTitle.TextColor3 = Theme.Accent
    LogoTitle.TextSize = 14
    LogoTitle.Font = Enum.Font.GothamBold
    LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
    LogoTitle.Parent = LogoFrame

    local LogoSub = Instance.new("TextLabel")
    LogoSub.Size = UDim2.new(1, -10, 0, 16)
    LogoSub.Position = UDim2.new(0, 10, 0, 38)
    LogoSub.BackgroundTransparency = 1
    LogoSub.Text = Subtitle
    LogoSub.TextColor3 = Theme.TextDisabled
    LogoSub.TextSize = 10
    LogoSub.Font = Enum.Font.Gotham
    LogoSub.TextXAlignment = Enum.TextXAlignment.Left
    LogoSub.Parent = LogoFrame

    local LogoDivider = Instance.new("Frame")
    LogoDivider.Size = UDim2.new(1, -20, 0, 1)
    LogoDivider.Position = UDim2.new(0, 10, 0, 68)
    LogoDivider.BackgroundColor3 = Theme.Divider
    LogoDivider.BorderSizePixel = 0
    LogoDivider.Parent = Sidebar

    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, 0, 1, -100)
    TabList.Position = UDim2.new(0, 0, 0, 75)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabList.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabList

    local TabListPadding = Instance.new("UIPadding")
    TabListPadding.PaddingLeft = UDim.new(0, 8)
    TabListPadding.PaddingRight = UDim.new(0, 8)
    TabListPadding.PaddingTop = UDim.new(0, 4)
    TabListPadding.Parent = TabList

    local VerLabel = Instance.new("TextLabel")
    VerLabel.Size = UDim2.new(1, 0, 0, 20)
    VerLabel.Position = UDim2.new(0, 0, 1, -24)
    VerLabel.BackgroundTransparency = 1
    VerLabel.Text = "BrixLib v1.0"
    VerLabel.TextColor3 = Theme.TextDisabled
    VerLabel.TextSize = 10
    VerLabel.Font = Enum.Font.Gotham
    VerLabel.Parent = Sidebar

    -- Content area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -150, 1, -10)
    ContentArea.Position = UDim2.new(0, 148, 0, 5)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = ContentArea

    local WinTitle = Instance.new("TextLabel")
    WinTitle.Size = UDim2.new(1, -80, 1, 0)
    WinTitle.BackgroundTransparency = 1
    WinTitle.Text = WindowTitle
    WinTitle.TextColor3 = Theme.Text
    WinTitle.TextSize = 14
    WinTitle.Font = Enum.Font.GothamBold
    WinTitle.TextXAlignment = Enum.TextXAlignment.Left
    WinTitle.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
    CloseBtn.BackgroundColor3 = Theme.CloseBtn
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 560, 0, 0)}, 0.3, Enum.EasingStyle.Back)
        task.wait(0.35)
        Gui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.Position = UDim2.new(1, -58, 0.5, -12)
    MinBtn.BackgroundColor3 = Theme.MinimizeBtn
    MinBtn.Text = "–"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 14
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    -- ========================
    -- FIXED MINIMIZE
    -- ========================
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Sidebar.Visible = false
            TabContainer.Visible = false
            TopDivider.Visible = false
            Tween(MainFrame, {Size = UDim2.new(0, 560, 0, 40)}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 560, 0, 380)}, 0.3, Enum.EasingStyle.Back)
            task.delay(0.25, function()
                Sidebar.Visible = true
                TabContainer.Visible = true
                TopDivider.Visible = true
            end)
        end
    end)

    local TopDivider = Instance.new("Frame")
    TopDivider.Size = UDim2.new(1, 0, 0, 1)
    TopDivider.Position = UDim2.new(0, 0, 0, 36)
    TopDivider.BackgroundColor3 = Theme.Divider
    TopDivider.BorderSizePixel = 0
    TopDivider.Parent = ContentArea

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -42)
    TabContainer.Position = UDim2.new(0, 0, 0, 42)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ClipsDescendants = true
    TabContainer.Parent = ContentArea

    MakeDraggable(MainFrame, LogoFrame)
    MakeDraggable(MainFrame, TopBar)

    Keybinds[ToggleKey] = function()
        Gui.Enabled = not Gui.Enabled
    end

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Tween(MainFrame, {Size = UDim2.new(0, 560, 0, 380)}, 0.4, Enum.EasingStyle.Back)

    local WindowObj = {}
    local Tabs = {}
    local ActiveTab = nil

    local function SetActiveTab(tabObj)
        if ActiveTab == tabObj then return end
        if ActiveTab then
            Tween(ActiveTab.Button, {BackgroundColor3 = Theme.TabInactive}, 0.15)
            ActiveTab.Button.TextColor3 = Theme.TextDark
            ActiveTab.Page.Visible = false
        end
        ActiveTab = tabObj
        Tween(ActiveTab.Button, {BackgroundColor3 = Theme.TabActive}, 0.15)
        ActiveTab.Button.TextColor3 = Theme.Text
        ActiveTab.Page.Visible = true
    end

    -- =========================
    -- CREATE TAB
    -- =========================
    function WindowObj:CreateTab(name, icon)
        local TabObj = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = Theme.TabInactive
        TabBtn.Text = (icon and icon ~= "" and icon .. "  " or "  ") .. name
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.BorderSizePixel = 0
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabList
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local TabPad = Instance.new("UIPadding")
        TabPad.PaddingLeft = UDim.new(0, 10)
        TabPad.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "_Page"
        TabPage.Size = UDim2.new(1, -8, 1, -8)
        TabPage.Position = UDim2.new(0, 4, 0, 4)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.Visible = false
        TabPage.ClipsDescendants = false  -- allow dropdown overlay
        TabPage.Parent = TabContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = TabPage

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 4)
        PagePadding.PaddingRight = UDim.new(0, 4)
        PagePadding.PaddingTop = UDim.new(0, 4)
        PagePadding.Parent = TabPage

        TabObj.Button = TabBtn
        TabObj.Page = TabPage

        TabBtn.MouseButton1Click:Connect(function()
            SetActiveTab(TabObj)
        end)

        TabBtn.MouseEnter:Connect(function()
            if ActiveTab ~= TabObj then
                Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveTab ~= TabObj then
                Tween(TabBtn, {BackgroundColor3 = Theme.TabInactive}, 0.1)
            end
        end)

        table.insert(Tabs, TabObj)
        if #Tabs == 1 then SetActiveTab(TabObj) end

        -- ========================
        -- SECTION
        -- ========================
        function TabObj:CreateSection(title)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 28)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = TabPage

            local SectionLine = Instance.new("Frame")
            SectionLine.Size = UDim2.new(1, 0, 0, 1)
            SectionLine.Position = UDim2.new(0, 0, 0.5, 0)
            SectionLine.BackgroundColor3 = Theme.Divider
            SectionLine.BorderSizePixel = 0
            SectionLine.Parent = SectionFrame

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(0, 0, 1, 0)
            SectionLabel.AutomaticSize = Enum.AutomaticSize.X
            SectionLabel.Position = UDim2.new(0, 8, 0, 0)
            SectionLabel.BackgroundColor3 = Theme.Background
            SectionLabel.BackgroundTransparency = 0
            SectionLabel.Text = "  " .. title .. "  "
            SectionLabel.TextColor3 = Theme.Accent
            SectionLabel.TextSize = 11
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Parent = SectionFrame
        end

        -- ========================
        -- PARAGRAPH
        -- ========================
        function TabObj:CreateParagraph(options)
            local ptitle   = options.Title or ""
            local pcontent = options.Content or ""

            local PFrame = Instance.new("Frame")
            PFrame.Size = UDim2.new(1, 0, 0, 0)
            PFrame.AutomaticSize = Enum.AutomaticSize.Y
            PFrame.BackgroundColor3 = Theme.Secondary
            PFrame.BorderSizePixel = 0
            PFrame.Parent = TabPage
            Instance.new("UICorner", PFrame).CornerRadius = UDim.new(0, 8)

            local PPad = Instance.new("UIPadding")
            PPad.PaddingLeft = UDim.new(0, 12)
            PPad.PaddingRight = UDim.new(0, 12)
            PPad.PaddingTop = UDim.new(0, 10)
            PPad.PaddingBottom = UDim.new(0, 10)
            PPad.Parent = PFrame

            local PLayout = Instance.new("UIListLayout")
            PLayout.SortOrder = Enum.SortOrder.LayoutOrder
            PLayout.Padding = UDim.new(0, 4)
            PLayout.Parent = PFrame

            local PTitleLbl = Instance.new("TextLabel")
            PTitleLbl.Size = UDim2.new(1, 0, 0, 0)
            PTitleLbl.AutomaticSize = Enum.AutomaticSize.Y
            PTitleLbl.BackgroundTransparency = 1
            PTitleLbl.Text = ptitle
            PTitleLbl.TextColor3 = Theme.Text
            PTitleLbl.TextSize = 13
            PTitleLbl.Font = Enum.Font.GothamBold
            PTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            PTitleLbl.TextWrapped = true
            PTitleLbl.Parent = PFrame

            local PContentLbl = Instance.new("TextLabel")
            PContentLbl.Size = UDim2.new(1, 0, 0, 0)
            PContentLbl.AutomaticSize = Enum.AutomaticSize.Y
            PContentLbl.BackgroundTransparency = 1
            PContentLbl.Text = pcontent
            PContentLbl.TextColor3 = Theme.TextDark
            PContentLbl.TextSize = 11
            PContentLbl.Font = Enum.Font.Gotham
            PContentLbl.TextXAlignment = Enum.TextXAlignment.Left
            PContentLbl.TextWrapped = true
            PContentLbl.Parent = PFrame
        end

        -- ========================
        -- BUTTON
        -- ========================
        function TabObj:CreateButton(options)
            local bname    = options.Name or "Button"
            local callback = options.Callback or function() end

            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 38)
            BtnFrame.BackgroundColor3 = Theme.Secondary
            BtnFrame.Text = bname
            BtnFrame.TextColor3 = Theme.Text
            BtnFrame.TextSize = 13
            BtnFrame.Font = Enum.Font.GothamSemibold
            BtnFrame.BorderSizePixel = 0
            BtnFrame.Parent = TabPage
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 8)

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Theme.Divider
            BtnStroke.Thickness = 1
            BtnStroke.Parent = BtnFrame

            BtnFrame.MouseEnter:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.AccentDark}, 0.15)
                Tween(BtnStroke, {Color = Theme.Accent}, 0.15)
            end)
            BtnFrame.MouseLeave:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.Secondary}, 0.15)
                Tween(BtnStroke, {Color = Theme.Divider}, 0.15)
            end)
            BtnFrame.MouseButton1Click:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.wait(0.1)
                Tween(BtnFrame, {BackgroundColor3 = Theme.Secondary}, 0.15)
                callback()
            end)
        end

        -- ========================
        -- TOGGLE
        -- ========================
        function TabObj:CreateToggle(options)
            local tname    = options.Name or "Toggle"
            local default  = options.Default or false
            local flag     = options.Flag
            local callback = options.Callback or function() end

            if flag and SavedConfig[flag] ~= nil then
                default = SavedConfig[flag]
            end

            local toggled = default

            local TFrame = Instance.new("Frame")
            TFrame.Size = UDim2.new(1, 0, 0, 38)
            TFrame.BackgroundColor3 = Theme.Secondary
            TFrame.BorderSizePixel = 0
            TFrame.Parent = TabPage
            Instance.new("UICorner", TFrame).CornerRadius = UDim.new(0, 8)

            local TLabel = Instance.new("TextLabel")
            TLabel.Size = UDim2.new(1, -60, 1, 0)
            TLabel.Position = UDim2.new(0, 12, 0, 0)
            TLabel.BackgroundTransparency = 1
            TLabel.Text = tname
            TLabel.TextColor3 = Theme.Text
            TLabel.TextSize = 13
            TLabel.Font = Enum.Font.GothamSemibold
            TLabel.TextXAlignment = Enum.TextXAlignment.Left
            TLabel.Parent = TFrame

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Size = UDim2.new(0, 40, 0, 20)
            SwitchBG.Position = UDim2.new(1, -52, 0.5, -10)
            SwitchBG.BackgroundColor3 = toggled and Theme.Toggle_ON or Theme.Toggle_OFF
            SwitchBG.BorderSizePixel = 0
            SwitchBG.Parent = TFrame
            Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = SwitchBG
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = ""
            ToggleBtn.Parent = TFrame

            local function UpdateToggle()
                Tween(SwitchBG, {BackgroundColor3 = toggled and Theme.Toggle_ON or Theme.Toggle_OFF}, 0.2)
                Tween(Knob, {Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.2, Enum.EasingStyle.Back)
                if flag then
                    SavedConfig[flag] = toggled
                    SaveConfig(ConfigFolder, ConfigFile, SavedConfig)
                end
                callback(toggled)
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateToggle()
            end)

            if default then
                task.spawn(function() callback(toggled) end)
            end

            local ToggleObj = {}
            function ToggleObj:Set(value) toggled = value UpdateToggle() end
            function ToggleObj:Get() return toggled end
            return ToggleObj
        end

        -- ========================
        -- SLIDER
        -- ========================
        function TabObj:CreateSlider(options)
            local sname    = options.Name or "Slider"
            local min      = options.Min or 0
            local max      = options.Max or 100
            local default  = options.Default or min
            local suffix   = options.Suffix or ""
            local flag     = options.Flag
            local callback = options.Callback or function() end
            local decimals = options.Decimals or 0

            if flag and SavedConfig[flag] ~= nil then default = SavedConfig[flag] end

            local currentValue = default

            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(1, 0, 0, 52)
            SFrame.BackgroundColor3 = Theme.Secondary
            SFrame.BorderSizePixel = 0
            SFrame.Parent = TabPage
            Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 8)

            local SLabel = Instance.new("TextLabel")
            SLabel.Size = UDim2.new(1, -80, 0, 20)
            SLabel.Position = UDim2.new(0, 12, 0, 8)
            SLabel.BackgroundTransparency = 1
            SLabel.Text = sname
            SLabel.TextColor3 = Theme.Text
            SLabel.TextSize = 13
            SLabel.Font = Enum.Font.GothamSemibold
            SLabel.TextXAlignment = Enum.TextXAlignment.Left
            SLabel.Parent = SFrame

            local SValueLbl = Instance.new("TextLabel")
            SValueLbl.Size = UDim2.new(0, 70, 0, 20)
            SValueLbl.Position = UDim2.new(1, -82, 0, 8)
            SValueLbl.BackgroundTransparency = 1
            SValueLbl.Text = tostring(default) .. " " .. suffix
            SValueLbl.TextColor3 = Theme.Accent
            SValueLbl.TextSize = 12
            SValueLbl.Font = Enum.Font.GothamBold
            SValueLbl.TextXAlignment = Enum.TextXAlignment.Right
            SValueLbl.Parent = SFrame

            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -24, 0, 8)
            SliderBG.Position = UDim2.new(0, 12, 0, 34)
            SliderBG.BackgroundColor3 = Theme.SliderBG
            SliderBG.BorderSizePixel = 0
            SliderBG.Parent = SFrame
            Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Slider
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBG
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

            local SliderKnob = Instance.new("Frame")
            SliderKnob.Size = UDim2.new(0, 14, 0, 14)
            SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderKnob.BorderSizePixel = 0
            SliderKnob.ZIndex = 2
            SliderKnob.Parent = SliderBG
            Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

            local sliding = false

            local function UpdateSlider(input)
                local sliderPos  = SliderBG.AbsolutePosition.X
                local sliderSize = SliderBG.AbsoluteSize.X
                local alpha = math.clamp((input.Position.X - sliderPos) / sliderSize, 0, 1)
                local value = min + (max - min) * alpha
                value = decimals == 0 and math.round(value) or math.floor(value * (10^decimals) + 0.5) / (10^decimals)
                currentValue = value
                SValueLbl.Text = tostring(value) .. " " .. suffix
                SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
                SliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
                if flag then SavedConfig[flag] = value SaveConfig(ConfigFolder, ConfigFile, SavedConfig) end
                callback(value)
            end

            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true UpdateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)

            local SliderObj = {}
            function SliderObj:Set(value)
                value = math.clamp(value, min, max)
                currentValue = value
                local alpha = (value - min) / (max - min)
                SValueLbl.Text = tostring(value) .. " " .. suffix
                SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
                SliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
                callback(value)
            end
            function SliderObj:Get() return currentValue end
            return SliderObj
        end

        -- ========================
        -- DROPDOWN (FIXED)
        -- ========================
        function TabObj:CreateDropdown(options)
            local dname    = options.Name or "Dropdown"
            local items    = options.Options or {}
            local default  = options.Default or nil
            local multi    = options.MultiSelect or false
            local flag     = options.Flag
            local callback = options.Callback or function() end

            local selected = multi and {} or nil
            if default then
                if multi then selected = type(default) == "table" and default or {default}
                else selected = default end
            end
            if flag and SavedConfig[flag] ~= nil then selected = SavedConfig[flag] end

            local isOpen = false
            local maxHeight = math.min(#items * 32 + 8, 160)

            -- Header bar (always visible)
            local DFrame = Instance.new("Frame")
            DFrame.Size = UDim2.new(1, 0, 0, 38)
            DFrame.BackgroundColor3 = Theme.Secondary
            DFrame.BorderSizePixel = 0
            DFrame.ClipsDescendants = false
            DFrame.ZIndex = 2
            DFrame.Parent = TabPage
            Instance.new("UICorner", DFrame).CornerRadius = UDim.new(0, 8)

            local DLabel = Instance.new("TextLabel")
            DLabel.Size = UDim2.new(1, -120, 1, 0)
            DLabel.Position = UDim2.new(0, 12, 0, 0)
            DLabel.BackgroundTransparency = 1
            DLabel.Text = dname
            DLabel.TextColor3 = Theme.Text
            DLabel.TextSize = 13
            DLabel.Font = Enum.Font.GothamSemibold
            DLabel.TextXAlignment = Enum.TextXAlignment.Left
            DLabel.ZIndex = 3
            DLabel.Parent = DFrame

            local DArrow = Instance.new("TextLabel")
            DArrow.Size = UDim2.new(0, 20, 1, 0)
            DArrow.Position = UDim2.new(1, -26, 0, 0)
            DArrow.BackgroundTransparency = 1
            DArrow.Text = "▼"
            DArrow.TextColor3 = Theme.Accent
            DArrow.TextSize = 11
            DArrow.Font = Enum.Font.GothamBold
            DArrow.ZIndex = 3
            DArrow.Parent = DFrame

            local DSelectedLbl = Instance.new("TextLabel")
            DSelectedLbl.Size = UDim2.new(0, 90, 1, 0)
            DSelectedLbl.Position = UDim2.new(1, -118, 0, 0)
            DSelectedLbl.BackgroundTransparency = 1
            DSelectedLbl.TextColor3 = Theme.TextDisabled
            DSelectedLbl.TextSize = 11
            DSelectedLbl.Font = Enum.Font.Gotham
            DSelectedLbl.TextXAlignment = Enum.TextXAlignment.Right
            DSelectedLbl.TextTruncate = Enum.TextTruncate.AtEnd
            DSelectedLbl.ZIndex = 3
            DSelectedLbl.Parent = DFrame

            local function UpdateSelectedText()
                if multi then
                    DSelectedLbl.Text = #selected == 0 and "None" or (#selected == 1 and selected[1] or #selected .. " selected")
                else
                    DSelectedLbl.Text = selected or "None"
                end
            end
            UpdateSelectedText()

            -- Dropdown list — parented to DFrame, positioned below it
            local DList = Instance.new("ScrollingFrame")
            DList.Size = UDim2.new(1, 0, 0, 0)
            DList.Position = UDim2.new(0, 0, 1, 6)  -- directly below the header
            DList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            DList.BorderSizePixel = 0
            DList.ClipsDescendants = true
            DList.ZIndex = 50
            DList.Visible = false
            DList.ScrollBarThickness = 3
            DList.ScrollBarImageColor3 = Theme.Accent
            DList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DList.AutomaticCanvasSize = Enum.AutomaticSize.Y
            DList.Parent = DFrame
            Instance.new("UICorner", DList).CornerRadius = UDim.new(0, 8)

            local DListStroke = Instance.new("UIStroke")
            DListStroke.Color = Theme.Accent
            DListStroke.Thickness = 1
            DListStroke.Transparency = 0.6
            DListStroke.Parent = DList

            local DListLayout = Instance.new("UIListLayout")
            DListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DListLayout.Padding = UDim.new(0, 2)
            DListLayout.Parent = DList

            local DListPad = Instance.new("UIPadding")
            DListPad.PaddingTop = UDim.new(0, 4)
            DListPad.PaddingBottom = UDim.new(0, 4)
            DListPad.PaddingLeft = UDim.new(0, 4)
            DListPad.PaddingRight = UDim.new(0, 4)
            DListPad.Parent = DList

            local function isSelected(item)
                if multi then
                    for _, v in ipairs(selected) do if v == item then return true end end
                    return false
                else
                    return selected == item
                end
            end

            local ItemButtons = {}

            for _, item in ipairs(items) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Size = UDim2.new(1, 0, 0, 30)
                ItemBtn.BackgroundColor3 = isSelected(item) and Theme.AccentDark or Color3.fromRGB(32, 32, 32)
                ItemBtn.Text = "  " .. item
                ItemBtn.TextColor3 = isSelected(item) and Theme.Text or Theme.TextDark
                ItemBtn.TextSize = 12
                ItemBtn.Font = Enum.Font.Gotham
                ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                ItemBtn.BorderSizePixel = 0
                ItemBtn.ZIndex = 51
                ItemBtn.Parent = DList
                Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 6)

                ItemButtons[item] = ItemBtn

                ItemBtn.MouseEnter:Connect(function()
                    if not isSelected(item) then Tween(ItemBtn, {BackgroundColor3 = Color3.fromRGB(40,40,40)}, 0.1) end
                end)
                ItemBtn.MouseLeave:Connect(function()
                    if not isSelected(item) then Tween(ItemBtn, {BackgroundColor3 = Color3.fromRGB(32,32,32)}, 0.1) end
                end)

                ItemBtn.MouseButton1Click:Connect(function()
                    if multi then
                        local found = false
                        for i, v in ipairs(selected) do
                            if v == item then table.remove(selected, i) found = true break end
                        end
                        if not found then table.insert(selected, item) end
                        ItemBtn.BackgroundColor3 = isSelected(item) and Theme.AccentDark or Color3.fromRGB(32,32,32)
                        ItemBtn.TextColor3 = isSelected(item) and Theme.Text or Theme.TextDark
                    else
                        selected = item
                        for k, btn in pairs(ItemButtons) do
                            btn.BackgroundColor3 = Color3.fromRGB(32,32,32)
                            btn.TextColor3 = Theme.TextDark
                        end
                        ItemBtn.BackgroundColor3 = Theme.AccentDark
                        ItemBtn.TextColor3 = Theme.Text
                        -- auto close on single select
                        isOpen = false
                        Tween(DList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        Tween(DArrow, {Rotation = 0}, 0.15)
                        DFrame.Size = UDim2.new(1, 0, 0, 38)
                        task.delay(0.15, function() DList.Visible = false end)
                    end
                    UpdateSelectedText()
                    if flag then SavedConfig[flag] = selected SaveConfig(ConfigFolder, ConfigFile, SavedConfig) end
                    callback(selected)
                end)
            end

            local DBtn = Instance.new("TextButton")
            DBtn.Size = UDim2.new(1, 0, 1, 0)
            DBtn.BackgroundTransparency = 1
            DBtn.Text = ""
            DBtn.ZIndex = 4
            DBtn.Parent = DFrame

            DBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    DList.Visible = true
                    DList.Size = UDim2.new(1, 0, 0, 0)
                    Tween(DList, {Size = UDim2.new(1, 0, 0, maxHeight)}, 0.2, Enum.EasingStyle.Back)
                    Tween(DArrow, {Rotation = 180}, 0.2)
                    DFrame.Size = UDim2.new(1, 0, 0, 38 + maxHeight + 6)
                else
                    Tween(DList, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                    Tween(DArrow, {Rotation = 0}, 0.15)
                    DFrame.Size = UDim2.new(1, 0, 0, 38)
                    task.delay(0.15, function() DList.Visible = false end)
                end
            end)

            local DropObj = {}
            function DropObj:Set(value)
                selected = multi and (type(value) == "table" and value or {value}) or value
                for k, btn in pairs(ItemButtons) do
                    btn.BackgroundColor3 = isSelected(k) and Theme.AccentDark or Color3.fromRGB(32,32,32)
                    btn.TextColor3 = isSelected(k) and Theme.Text or Theme.TextDark
                end
                UpdateSelectedText()
                callback(selected)
            end
            function DropObj:Get() return selected end
            return DropObj
        end

        -- ========================
        -- INPUT
        -- ========================
        function TabObj:CreateInput(options)
            local iname       = options.Name or "Input"
            local placeholder = options.Placeholder or "Type here..."
            local flag        = options.Flag
            local callback    = options.Callback or function() end
            local clearOnFocus = options.ClearOnFocus ~= false

            local IFrame = Instance.new("Frame")
            IFrame.Size = UDim2.new(1, 0, 0, 52)
            IFrame.BackgroundColor3 = Theme.Secondary
            IFrame.BorderSizePixel = 0
            IFrame.Parent = TabPage
            Instance.new("UICorner", IFrame).CornerRadius = UDim.new(0, 8)

            local ILabel = Instance.new("TextLabel")
            ILabel.Size = UDim2.new(1, -12, 0, 18)
            ILabel.Position = UDim2.new(0, 12, 0, 8)
            ILabel.BackgroundTransparency = 1
            ILabel.Text = iname
            ILabel.TextColor3 = Theme.Text
            ILabel.TextSize = 12
            ILabel.Font = Enum.Font.GothamSemibold
            ILabel.TextXAlignment = Enum.TextXAlignment.Left
            ILabel.Parent = IFrame

            local IBox = Instance.new("TextBox")
            IBox.Size = UDim2.new(1, -24, 0, 22)
            IBox.Position = UDim2.new(0, 12, 0, 26)
            IBox.BackgroundColor3 = Theme.Input
            IBox.TextColor3 = Theme.Text
            IBox.PlaceholderText = placeholder
            IBox.PlaceholderColor3 = Theme.TextDisabled
            IBox.Text = ""
            IBox.TextSize = 12
            IBox.Font = Enum.Font.Gotham
            IBox.BorderSizePixel = 0
            IBox.ClearTextOnFocus = clearOnFocus
            IBox.Parent = IFrame
            Instance.new("UICorner", IBox).CornerRadius = UDim.new(0, 6)

            local IBoxPad = Instance.new("UIPadding")
            IBoxPad.PaddingLeft = UDim.new(0, 8)
            IBoxPad.Parent = IBox

            local IStroke = Instance.new("UIStroke")
            IStroke.Color = Theme.Divider
            IStroke.Thickness = 1
            IStroke.Parent = IBox

            IBox.Focused:Connect(function() Tween(IStroke, {Color = Theme.Accent}, 0.15) end)
            IBox.FocusLost:Connect(function(enterPressed)
                Tween(IStroke, {Color = Theme.Divider}, 0.15)
                if flag then SavedConfig[flag] = IBox.Text SaveConfig(ConfigFolder, ConfigFile, SavedConfig) end
                callback(IBox.Text, enterPressed)
            end)

            if flag and SavedConfig[flag] then IBox.Text = SavedConfig[flag] end

            local InputObj = {}
            function InputObj:Set(value) IBox.Text = value callback(value, false) end
            function InputObj:Get() return IBox.Text end
            return InputObj
        end

        -- ========================
        -- KEYBIND
        -- ========================
        function TabObj:CreateKeybind(options)
            local kname    = options.Name or "Keybind"
            local default  = options.Default or Enum.KeyCode.F
            local flag     = options.Flag
            local callback = options.Callback or function() end

            local currentKey = default
            local listening = false

            if flag and SavedConfig[flag] then
                pcall(function() currentKey = Enum.KeyCode[SavedConfig[flag]] end)
            end

            local KFrame = Instance.new("Frame")
            KFrame.Size = UDim2.new(1, 0, 0, 38)
            KFrame.BackgroundColor3 = Theme.Secondary
            KFrame.BorderSizePixel = 0
            KFrame.Parent = TabPage
            Instance.new("UICorner", KFrame).CornerRadius = UDim.new(0, 8)

            local KLabel = Instance.new("TextLabel")
            KLabel.Size = UDim2.new(1, -110, 1, 0)
            KLabel.Position = UDim2.new(0, 12, 0, 0)
            KLabel.BackgroundTransparency = 1
            KLabel.Text = kname
            KLabel.TextColor3 = Theme.Text
            KLabel.TextSize = 13
            KLabel.Font = Enum.Font.GothamSemibold
            KLabel.TextXAlignment = Enum.TextXAlignment.Left
            KLabel.Parent = KFrame

            local KBtn = Instance.new("TextButton")
            KBtn.Size = UDim2.new(0, 90, 0, 26)
            KBtn.Position = UDim2.new(1, -100, 0.5, -13)
            KBtn.BackgroundColor3 = Theme.Input
            KBtn.Text = tostring(currentKey.Name)
            KBtn.TextColor3 = Theme.Accent
            KBtn.TextSize = 12
            KBtn.Font = Enum.Font.GothamBold
            KBtn.BorderSizePixel = 0
            KBtn.Parent = KFrame
            Instance.new("UICorner", KBtn).CornerRadius = UDim.new(0, 6)

            Keybinds[currentKey] = callback

            KBtn.MouseButton1Click:Connect(function()
                listening = true
                KBtn.Text = "..."
                KBtn.TextColor3 = Theme.TextDark
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    Keybinds[currentKey] = nil
                    currentKey = input.KeyCode
                    Keybinds[currentKey] = callback
                    KBtn.Text = input.KeyCode.Name
                    KBtn.TextColor3 = Theme.Accent
                    if flag then SavedConfig[flag] = input.KeyCode.Name SaveConfig(ConfigFolder, ConfigFile, SavedConfig) end
                end
            end)
        end

        -- ========================
        -- COLOR PICKER
        -- ========================
        function TabObj:CreateColorPicker(options)
            local cpname   = options.Name or "Color Picker"
            local default  = options.Default or Color3.fromRGB(255, 0, 0)
            local flag     = options.Flag
            local callback = options.Callback or function() end

            local currentColor = default
            if flag and SavedConfig[flag] then
                pcall(function()
                    local c = SavedConfig[flag]
                    currentColor = Color3.fromRGB(c.R, c.G, c.B)
                end)
            end

            local CPFrame = Instance.new("Frame")
            CPFrame.Size = UDim2.new(1, 0, 0, 38)
            CPFrame.BackgroundColor3 = Theme.Secondary
            CPFrame.BorderSizePixel = 0
            CPFrame.Parent = TabPage
            Instance.new("UICorner", CPFrame).CornerRadius = UDim.new(0, 8)

            local CPLabel = Instance.new("TextLabel")
            CPLabel.Size = UDim2.new(1, -60, 1, 0)
            CPLabel.Position = UDim2.new(0, 12, 0, 0)
            CPLabel.BackgroundTransparency = 1
            CPLabel.Text = cpname
            CPLabel.TextColor3 = Theme.Text
            CPLabel.TextSize = 13
            CPLabel.Font = Enum.Font.GothamSemibold
            CPLabel.TextXAlignment = Enum.TextXAlignment.Left
            CPLabel.Parent = CPFrame

            local ColorPreview = Instance.new("TextButton")
            ColorPreview.Size = UDim2.new(0, 36, 0, 24)
            ColorPreview.Position = UDim2.new(1, -46, 0.5, -12)
            ColorPreview.BackgroundColor3 = currentColor
            ColorPreview.Text = ""
            ColorPreview.BorderSizePixel = 0
            ColorPreview.Parent = CPFrame
            Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", ColorPreview).Color = Theme.Divider

            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size = UDim2.new(1, 0, 0, 0)
            PickerFrame.Position = UDim2.new(0, 0, 1, 4)
            PickerFrame.BackgroundColor3 = Theme.Secondary
            PickerFrame.BorderSizePixel = 0
            PickerFrame.ClipsDescendants = true
            PickerFrame.ZIndex = 8
            PickerFrame.Visible = false
            PickerFrame.Parent = CPFrame
            Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 8)

            local pickerOpen = false
            local r, g, b = math.round(currentColor.R*255), math.round(currentColor.G*255), math.round(currentColor.B*255)

            local function MakeRGBSlider(label, initVal, yPos, onchange)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0, 16, 0, 16)
                lbl.Position = UDim2.new(0, 10, 0, yPos + 4)
                lbl.BackgroundTransparency = 1
                lbl.Text = label
                lbl.TextColor3 = Theme.TextDark
                lbl.TextSize = 11
                lbl.Font = Enum.Font.GothamBold
                lbl.ZIndex = 9
                lbl.Parent = PickerFrame

                local sldBG = Instance.new("Frame")
                sldBG.Size = UDim2.new(1, -80, 0, 8)
                sldBG.Position = UDim2.new(0, 30, 0, yPos + 8)
                sldBG.BackgroundColor3 = Theme.SliderBG
                sldBG.BorderSizePixel = 0
                sldBG.ZIndex = 9
                sldBG.Parent = PickerFrame
                Instance.new("UICorner", sldBG).CornerRadius = UDim.new(1, 0)

                local sldFill = Instance.new("Frame")
                sldFill.Size = UDim2.new(initVal/255, 0, 1, 0)
                sldFill.BackgroundColor3 = Theme.Accent
                sldFill.BorderSizePixel = 0
                sldFill.ZIndex = 10
                sldFill.Parent = sldBG
                Instance.new("UICorner", sldFill).CornerRadius = UDim.new(1, 0)

                local sldKnob = Instance.new("Frame")
                sldKnob.Size = UDim2.new(0, 12, 0, 12)
                sldKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                sldKnob.Position = UDim2.new(initVal/255, 0, 0.5, 0)
                sldKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                sldKnob.BorderSizePixel = 0
                sldKnob.ZIndex = 11
                sldKnob.Parent = sldBG
                Instance.new("UICorner", sldKnob).CornerRadius = UDim.new(1, 0)

                local valLbl = Instance.new("TextLabel")
                valLbl.Size = UDim2.new(0, 36, 0, 16)
                valLbl.Position = UDim2.new(1, -44, 0, yPos + 4)
                valLbl.BackgroundTransparency = 1
                valLbl.Text = tostring(initVal)
                valLbl.TextColor3 = Theme.Accent
                valLbl.TextSize = 11
                valLbl.Font = Enum.Font.GothamBold
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.ZIndex = 9
                valLbl.Parent = PickerFrame

                local sliding2 = false
                sldBG.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = true end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliding2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local alpha = math.clamp((inp.Position.X - sldBG.AbsolutePosition.X) / sldBG.AbsoluteSize.X, 0, 1)
                        local val = math.round(alpha * 255)
                        sldFill.Size = UDim2.new(alpha, 0, 1, 0)
                        sldKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
                        valLbl.Text = tostring(val)
                        onchange(val)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = false end
                end)
            end

            local function UpdateColor()
                currentColor = Color3.fromRGB(r, g, b)
                ColorPreview.BackgroundColor3 = currentColor
                if flag then SavedConfig[flag] = {R=r, G=g, B=b} SaveConfig(ConfigFolder, ConfigFile, SavedConfig) end
                callback(currentColor)
            end

            MakeRGBSlider("R", r, 8,  function(val) r = val UpdateColor() end)
            MakeRGBSlider("G", g, 36, function(val) g = val UpdateColor() end)
            MakeRGBSlider("B", b, 64, function(val) b = val UpdateColor() end)

            ColorPreview.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                PickerFrame.Visible = pickerOpen
                if pickerOpen then
                    Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 100)}, 0.2, Enum.EasingStyle.Back)
                    CPFrame.Size = UDim2.new(1, 0, 0, 38 + 104)
                else
                    Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                    CPFrame.Size = UDim2.new(1, 0, 0, 38)
                end
            end)

            local CPObj = {}
            function CPObj:Set(color)
                currentColor = color
                r, g, b = math.round(color.R*255), math.round(color.G*255), math.round(color.B*255)
                ColorPreview.BackgroundColor3 = color
                callback(color)
            end
            function CPObj:Get() return currentColor end
            return CPObj
        end

        return TabObj
    end

    function WindowObj:Notify(options)
        BrixLib:Notify(options)
    end

    return WindowObj
end

return BrixLib
