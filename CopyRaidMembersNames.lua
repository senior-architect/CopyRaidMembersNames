SLASH_CRMN1 = "/crmn"

-- Инициализация глобальной таблицы
CopyRaidMembersNames = CopyRaidMembersNames or {}

function GetNames()
    local unit, numMembers, names

    if IsInRaid() then
        unit = "raid"
        numMembers = GetNumRaidMembers()
        names = ""
    elseif IsInGroup() then
        unit = "party"
        numMembers = GetNumPartyMembers()
        names = UnitName("player") .. "\n"
    else
        print("Вы не состоите в группе или рейде")
        return
    end
    
    for i = 1, numMembers do
        local memberName = UnitName(unit .. i)
        names = names .. memberName .. "\n"
    end
    return string.gsub(names, "\n$", "")
end

function ShowNamesFrame()
    local raidMembersNames = GetNames()

    if backdrop then
        rcbf.Text:SetText(raidMembersNames)
    end
    
    backdrop = {
        bgFile = "Interface/BUTTONS/WHITE8X8",
        edgeFile = "Interface/GLUES/Common/Glue-Tooltip-Border",
        tile = true,
        edgeSize = 8,
        tileSize = 8,
        insets = {
            left = 5,
            right = 5,
            top = 5,
            bottom = 5,
        },
    }
     
    rcbf = CreateFrame("Frame", "MyScrollMessageTextFrame", UIParent)
    rcbf:SetSize(150, 150)
    rcbf:SetPoint("CENTER")
    rcbf:SetFrameStrata("BACKGROUND")
    rcbf:SetBackdrop(backdrop)
    rcbf:SetBackdropColor(0, 0, 0)
    rcbf.Close = CreateFrame("Button", "$parentClose", rcbf)
    rcbf.Close:SetSize(24, 24)
    rcbf.Close:SetPoint("TOPRIGHT")
    rcbf.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    rcbf.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    rcbf.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
    rcbf.Close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)

    rcbf.Select = CreateFrame("Button", "$parentSelect", rcbf, "UIPanelButtonTemplate")
    rcbf.Select:SetSize(14, 14)
    rcbf.Select:SetPoint("RIGHT", rcbf.Close, "LEFT")
    rcbf.Select:SetText("Se")
    rcbf.Select:SetScript("OnClick", function(self)
        self:GetParent().Text:HighlightText()
        self:GetParent().Text:SetFocus()
    end)
    
    rcbf.Export = CreateFrame("Button", "$parentSelect", rcbf, "UIPanelButtonTemplate")
    rcbf.Export:SetSize(72, 14)
    rcbf.Export:SetPoint("TOPLEFT", rcbf, "TOPLEFT", 10, -5)
    rcbf.Export:SetText("Save to file")
    rcbf.Export:SetScript("OnClick", function(self)
        local logName = UnitName("player") .. "__" .. date("%Y_%m_%d__%H_%M_%S")
        local logText = string.gsub(raidMembersNames, "\n", " ")
        CopyRaidMembersNames = CopyRaidMembersNames or {}
        CopyRaidMembersNames[logName] = {}
        table.insert(CopyRaidMembersNames[logName], logText)
        
        print("Сохраняем список участников рейда в файл \\WoWNozdor\\WTF\\Account\\%ИМЯ_ТВОЕГО_АККАУНТА%\\SavedVariables\\CopyRaidMembersNames.lua")
        print("Не забудь сделать логаут или /reload")
    end)
     
    rcbf.SF = CreateFrame("ScrollFrame", "$parent_DF", rcbf, "UIPanelScrollFrameTemplate")
    rcbf.SF:SetPoint("TOPLEFT", rcbf, 12, -30)
    rcbf.SF:SetPoint("BOTTOMRIGHT", rcbf, -30, 10)
    rcbf.Text = CreateFrame("EditBox", nil, rcbf)
    rcbf.Text:SetMultiLine(true)
    rcbf.Text:SetSize(180, 170)
    rcbf.Text:SetPoint("TOPLEFT", rcbf.SF)
    rcbf.Text:SetPoint("BOTTOMRIGHT", rcbf.SF)
    rcbf.Text:SetMaxLetters(99999)
    rcbf.Text:SetFontObject(GameFontNormal)
    rcbf.Text:SetAutoFocus(false)
    rcbf.Text:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 
    rcbf.SF:SetScrollChild(rcbf.Text)
     
    rcbf.Text:SetText(raidMembersNames)
end

SlashCmdList["CRMN"] = function(msg)
    if not IsInRaid() and not IsInGroup() then
        print("Вы не состоите в группе или рейде")
    elseif rcbf and rcbf:IsVisible() then
        rcbf:Hide()
    else
        ShowNamesFrame()
    end
end


---

-- Create minimap button
 
local minibtn = CreateFrame("Button", nil, Minimap)
minibtn:SetFrameLevel(8)
minibtn:SetSize(32,32)
minibtn:SetMovable(true)
 
-- minibtn:SetNormalTexture("Interface/AddOns/AutoSell/Leatrix_Plus_Up.blp")
-- minibtn:SetPushedTexture("Interface/AddOns/AutoSell/Leatrix_Plus_Up.blp")
-- minibtn:SetHighlightTexture("Interface/AddOns/AutoSell/Leatrix_Plus_Up.blp")
 
minibtn:SetNormalTexture("Interface/COMMON/Indicator-Yellow.png")
minibtn:SetPushedTexture("Interface/COMMON/Indicator-Yellow.png")
minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Yellow.png")
 
 
local myIconPos = 0
 
-- Control movement
local function UpdateMapBtn()
    local Xpoa, Ypoa = GetCursorPosition()
    local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
    Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
    Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
    myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
    minibtn:ClearAllPoints()
    minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
end
 
minibtn:RegisterForDrag("LeftButton")
minibtn:SetScript("OnDragStart", function()
    minibtn:StartMoving()
    minibtn:SetScript("OnUpdate", UpdateMapBtn)
end)
 
minibtn:SetScript("OnDragStop", function()
    minibtn:StopMovingOrSizing();
    minibtn:SetScript("OnUpdate", nil)
    UpdateMapBtn();
end)
 
-- Set position
minibtn:ClearAllPoints();
minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)),(80 * sin(myIconPos)) - 52)
 
-- Control clicks
minibtn:SetScript("OnClick", function()
    ShowNamesFrame()
end)
