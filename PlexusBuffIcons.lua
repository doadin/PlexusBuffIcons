local function IsRetailWow()
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

local UnitAura, UnitGUID, pairs = _G.UnitAura, _G.UnitGUID, _G.pairs

local MAX_BUFFS = 6

local L = setmetatable(PlexusBuffIconsLocale or {}, {__index = function(t, k) t[k] = k return k end})

local PlexusRoster = _G.Plexus:GetModule("PlexusRoster")
local PlexusFrame = _G.Plexus:GetModule("PlexusFrame")
local PlexusBuffIcons = _G.Plexus:NewModule("PlexusBuffIcons", "AceBucket-3.0")

local function WithAllPlexusFrames(func)
    for _, frame in pairs(PlexusFrame.registeredFrames) do
        func(frame)
    end
end

local GetAuraDataByAuraInstanceID
local ForEachAura

if IsRetailWow() then
    GetAuraDataByAuraInstanceID = _G.C_UnitAuras.GetAuraDataByAuraInstanceID
    ForEachAura = _G.AuraUtil.ForEachAura
end

PlexusBuffIcons.menuName = L["Buff Icons"]

PlexusBuffIcons.defaultDB = {
    enabled = true,
    iconsize = 9,
    offsetx = -1,
    offsety = -1,
    alpha = 0.9,
    iconnum = 4,
    iconperrow = 2,
    showbuff = nil,
    buffmine = nil,
    bufffilter = true,
    showcooldown = true,
    showcdtext = false,
    namefilter = nil,
    nameforce = nil,
    orientation = "VERTICAL",
    anchor = "TOPRIGHT",
    color = { r = 0, g = 0.5, b = 1.0, a = 1.0 },
    ecolor = { r = 1, g = 1, b = 0, a = 1.0 },
    rcolor = { r = 1, g = 0, b = 0, a = 1.0 },
    unit_buff_icons = {
        color = { r=1, g=1, b=1, a=1 },
        text = "BuffIcons",
        enable = true,
        priority = 30,
        range = false
    }
}

local options = {
    type = "group",
    inline = PlexusFrame.options.args.bar.inline,
    name = L["Buff Icons"],
    desc = L["Buff Icons"],
    order = 1200,
    get = function(info)
        local k = info[#info]
        return PlexusBuffIcons.db.profile[k]
    end,
    set = function(info, v)
        local k = info[#info]
        PlexusBuffIcons.db.profile[k] = v
        PlexusBuffIcons:UpdateAllUnitsBuffs()
    end,
    args = {
        enabled = {
            order = 40, width = "double",
            type = "toggle",
            name = L["Enable"],
            desc = L["Enabling/disabling the module will display all buff or debuff icons."],
            get = function()
                return PlexusBuffIcons.db.profile.enabled
            end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.enabled = v
                if v and not PlexusBuffIcons.enabled then
                    PlexusBuffIcons:OnEnable()
                elseif not v and PlexusBuffIcons.enabled then
                    PlexusBuffIcons:OnDisable()
                end
            end,
        },
        showbuff = {
            order = 50, width = "single",
            type = "toggle",
            name = L["Show Buff instead of Debuff"],
            desc = L["If selected, the icons will present unit buffs instead of debuffs."],
        },
        buffmine = {
            order = 51, width = "single",
            type = "toggle",
            name = L["Only Mine"],
            disabled = function(info) return not PlexusBuffIcons.db.profile.showbuff end, --luacheck: ignore 212
        },
        bufffilter = {
            order = 52, width = "double",
            type = "toggle",
            name = L["Only castable/removable"],
            desc = L["If selected, only shows the buffs you can cast or the debuffs you can remove."],
        },
        showcooldown = {
            order = 53,
            type = "toggle",
            name = L["Show cooldown on icon"],
        },
        showcdtext = {
            order = 54,
            type = "toggle",
            name = L["Show Cooldown text"],
            desc = L["If disabled, OmniCC will not add texts on the icons."],
        },
        iconsize = {
            order = 55, width = "double",
            type = "range",
            name = L["Icons Size"],
            desc = L["Size for each buff icon"],
            max = 16,
            min = 5,
            step = 1,
            get = function () return PlexusBuffIcons.db.profile.iconsize end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.iconsize = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconSize(f) end)
            end
        },
        alpha = {
            order = 70, width = "double",
            type = "range",
            name = L["Alpha"],
            desc = L["Alpha value for each buff icon"],
            max = 1,
            min = 0.1,
            step = 0.1,
            get = function () return PlexusBuffIcons.db.profile.alpha end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.alpha = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconAlpha(f) end)
            end
        },
        offsetx = {
            order = 60, width = "double",
            type = "range",
            name = L["Offset X"],
            desc = L["X-axis offset from the selected anchor point, minus value to move inside."],
            max = 20,
            min = -20,
            step = 1,
            get = function () return PlexusBuffIcons.db.profile.offsetx end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.offsetx = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconPos(f) end)
            end
        },
        offsety = {
            order = 65, width = "double",
            type = "range",
            name = L["Offset Y"],
            desc = L["Y-axis offset from the selected anchor point, minus value to move inside."],
            max = 20,
            min = -20,
            step = 1,
            get = function () return PlexusBuffIcons.db.profile.offsety end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.offsety = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconPos(f) end)
            end
        },
        iconnum = {
            order = 75, width = "double",
            type = "range",
            name = L["Icon Numbers"],
            desc = L["Max icons to show."],
            max = MAX_BUFFS,
            min = 1,
            step = 1,
        },
        iconperrow = {
            order = 76, width = "double",
            type = "range",
            name = L["Icons Per Row"],
            desc = L["Sperate icons in several rows."],
            max = MAX_BUFFS,
            min = 0,
            step = 1,
            get = function()
                return PlexusBuffIcons.db.profile.iconperrow
            end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.iconperrow = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconPos(f) end)
            end,
        },
        orientation = {
            order = 80,  width = "double",
            type = "select",
            name = L["Orientation of Icon"],
            desc = L["Set icons list orientation."],
            get = function ()
                return PlexusBuffIcons.db.profile.orientation
            end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.orientation = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconPos(f) end)
            end,
            values ={["HORIZONTAL"] = L["HORIZONTAL"], ["VERTICAL"] = L["VERTICAL"]}
        },
        anchor = {
            order = 90,  width = "double",
            type = "select",
            name = L["Anchor Point"],
            desc = L["Anchor point of the first icon."],
            get = function ()
                return PlexusBuffIcons.db.profile.anchor
            end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.anchor = v
                WithAllPlexusFrames(function (f) PlexusBuffIcons.ResetBuffIconPos(f) end)
            end,
            values ={["TOPRIGHT"] = L["TOPRIGHT"], ["TOPLEFT"] = L["TOPLEFT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"]}
        },
        namefilter = {
            order = 200, width = "full",
            type = "input",
            multiline = 3,
            name =  L["Buffs/Debuffs Never Shown"],
            desc =  L["Buff or Debuff names never to show, seperated by ','"],
            get = function()
                return PlexusBuffIcons.db.profile.namefilter
            end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.namefilter = v
                PlexusBuffIcons:SetNameFilter(true)
                PlexusBuffIcons:UpdateAllUnitsBuffs()
            end,
        },
        --[[ --8.0 removed because performance problem
        nameforce = {
            order = 201, width = "full",
            type = "input",
            multiline = 3,
            name =  L["Buffs/Debuffs Always Shown"],
            desc =  L["Buff or Debuff names which will always be shown if applied, seperated by ','"],
            get = function()
                return PlexusBuffIcons.db.profile.nameforce
            end,
            set = function(_, v)
                PlexusBuffIcons.db.profile.nameforce = v
                PlexusBuffIcons:SetNameFilter(false)
                PlexusBuffIcons:UpdateAllUnitsBuffs()
            end,
        },
        --]]
    }
}

_G.Plexus.options.args.PlexusBuffIcons = options

function PlexusBuffIcons.InitializeFrame(_, f) --luacheck: ignore 212
    if not f.BuffIcons then
        f.BuffIcons = {}
        for i=1, MAX_BUFFS do
            local bar = f.Bar or f.indicators.bar
            local bg = CreateFrame("Frame", "$parentPlexusBuffIcon"..i, bar)
            bg:SetFrameLevel(bar:GetFrameLevel() + 3)
            bg.icon = bg:CreateTexture("$parentTex", "OVERLAY")
            bg.icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)
            bg.icon:SetAllPoints(bg)
            bg.cd = CreateFrame("Cooldown", "$parentCD", bg, "CooldownFrameTemplate")
            bg.cd:SetAllPoints(bg.icon)
            bg.cd:SetReverse(true)
            bg.cd:SetDrawBling(false)
            bg.cd:SetDrawEdge(false)
            bg.cd:SetSwipeColor(0, 0, 0, 0.6)  --will be overrided by omnicc
            bg.cdtext = bg:CreateFontString("Cdtext", "OVERLAY")
            bg.cdtext:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            bg.cdtext:ClearAllPoints()
            bg.cdtext:SetPoint("TOPRIGHT", bg.icon, 1, 1)
            bg.stack = bg:CreateFontString("Stack", "OVERLAY")
            bg.stack:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
            bg.stack:ClearAllPoints()
            bg.stack:SetPoint("BOTTOMRIGHT", bg.icon, 1, -1)
        f.BuffIcons[i] = bg
        end

        PlexusBuffIcons.ResetBuffIconSize(f)
        PlexusBuffIcons.ResetBuffIconPos(f)
        PlexusBuffIcons.ResetBuffIconAlpha(f)
    end
end

function PlexusBuffIcons.ResetBuffIconSize(f)
    if(f.BuffIcons) then
        for _,v in pairs(f.BuffIcons) do
            v:SetWidth(PlexusBuffIcons.db.profile.iconsize)
            v:SetHeight(PlexusBuffIcons.db.profile.iconsize)
        end
    end
end

function PlexusBuffIcons.ResetBuffIconPos(f)
    local icons = f.BuffIcons
    local xadjust = 1
    local yadjust = 1
    local p = PlexusBuffIcons.db.profile
    if(string.find(p.anchor, "BOTTOM")) then yadjust = -1 end
    if(string.find(p.anchor, "LEFT")) then xadjust = -1 end
    if(icons) then
        for k,v in pairs(icons) do
            v:ClearAllPoints()
            if(k==1) then
                v:SetPoint(p.anchor, f, p.anchor, xadjust * p.offsetx, yadjust * p.offsety)
            elseif(p.iconperrow and p.iconperrow>0 and (k-1)%p.iconperrow==0) then
                if(p.orientation == "VERTICAL") then
                    if(string.find(p.anchor, "RIGHT")) then
                        if(p.offsetx<=0) then
                            v:SetPoint("RIGHT", icons[k-p.iconperrow], "LEFT", -1, 0) --向内侧(左)
                        else
                            v:SetPoint("LEFT", icons[k-p.iconperrow], "RIGHT", 1, 0)  --向外侧(右)
                        end
                    elseif(string.find(p.anchor, "LEFT")) then
                        if(p.offsetx<=0) then
                            v:SetPoint("LEFT", icons[k-p.iconperrow], "RIGHT", 1, 0)  --向内侧(右)
                        else
                            v:SetPoint("RIGHT", icons[k-p.iconperrow], "LEFT", -1, 0)
                        end
                    end
                else
                    if(string.find(p.anchor, "TOP")) then
                        if(p.offsety<=0) then
                            v:SetPoint("TOP", icons[k-p.iconperrow], "BOTTOM", 0, -1)  --向内侧(下)
                        else
                            v:SetPoint("BOTTOM", icons[k-p.iconperrow], "TOP", 0, 1)  --向内侧(上)
                        end
                    elseif(string.find(p.anchor, "BOTTOM")) then
                        if(p.offsety<=0) then
                            v:SetPoint("BOTTOM", icons[k-p.iconperrow], "TOP", 0, 1)
                        else
                            v:SetPoint("TOP", icons[k-p.iconperrow], "BOTTOM", 0, -1)
                        end
                    end
                end
            else
                if(p.orientation == "VERTICAL") then
                    if(string.find(p.anchor, "BOTTOM")) then
                        v:SetPoint("BOTTOM", icons[k-1], "TOP", 0, 1)  --向上增长
                    else
                        v:SetPoint("TOP", icons[k-1], "BOTTOM", 0, -1) --向下增长
                    end
                else
                    if(string.find(p.anchor, "LEFT")) then
                        v:SetPoint("LEFT", icons[k-1], "RIGHT", 1, 0)  --向右增长
                    else
                        v:SetPoint("RIGHT", icons[k-1], "LEFT", -1, 0)  --向左增长
                    end
                end
            end
        end
    end
end

function PlexusBuffIcons.ResetBuffIconAlpha(f)
    if(f.BuffIcons) then
        for _,v in pairs(f.BuffIcons) do
            v:SetAlpha( PlexusBuffIcons.db.profile.alpha )
        end
    end
end

function PlexusBuffIcons:OnInitialize()
    self.super.OnInitialize(self)
    WithAllPlexusFrames(function(f) PlexusBuffIcons.InitializeFrame(nil, f) end)
    hooksecurefunc(PlexusFrame, "InitializeFrame", self.InitializeFrame)
end

function PlexusBuffIcons:OnEnable()
    if not PlexusBuffIcons.db.profile.enabled then return end
    self.enabled = true
    self:RegisterEvent("UNIT_AURA")
    if(not self.bucket) then
        self:Debug("registering bucket")
        self.bucket = self:RegisterBucketMessage("Plexus_UpdateLayoutSize", 1, "UpdateAllUnitsBuffs")
    end
    self:SetNameFilter(true)
    self:SetNameFilter(false)

    self:UpdateAllUnitsBuffs()
end

function PlexusBuffIcons:OnDisable()
    self.enabled = nil
    self:UnregisterEvent("UNIT_AURA")
    if(self.bucket) then
        self:Debug("unregistering bucket")
        self:UnregisterBucket(self.bucket)
        self.bucket = nil
    end
    for _,v in pairs(PlexusFrame.registeredFrames) do
        if(v.BuffIcons) then
            for i=1, MAX_BUFFS do v.BuffIcons[i]:Hide() end
        end
    end
end

function PlexusBuffIcons:SetNameFilter(filterOrForce)
    local setting, temp
    if filterOrForce then
        setting = PlexusBuffIcons.db.profile.namefilter
        self.namefilter = self.namefilter or {}
        temp = self.namefilter
    else
        setting = PlexusBuffIcons.db.profile.nameforce
        self.nameforce = self.nameforce or {}
        temp = self.nameforce
    end
    local str = string.gsub(setting or "", "，", ",")
    wipe(temp)
    for _, v in ipairs({strsplit(",\n", str)}) do
        temp[v:trim()] = true
    end
end

function PlexusBuffIcons:Reset()
    self.super.Reset(self)
    self:SetNameFilter(true)
    self:SetNameFilter(false)
end

local function showBuffIcon(v, n, setting, icon, count, expires, duration)
    v.BuffIcons[n]:Show()
    v.BuffIcons[n].icon:SetTexture(icon)
    if count > 1 then
        v.BuffIcons[n].stack:SetText(count)
        v.BuffIcons[n].stack:Show()
    else
        v.BuffIcons[n].stack:Hide()
    end
    if (setting.showcooldown) then
        v.BuffIcons[n].cdtext:SetText("")
        v.BuffIcons[n].cd.noCooldownCount = not setting.showcdtext
        v.BuffIcons[n].cd:SetDrawEdge(v.BuffIcons[n].cd.noCooldownCount)
        v.BuffIcons[n].cd:SetCooldown(expires - duration, duration)
    else
        if (setting.showcdtext) then
            local timeElapsed = 0
            v.BuffIcons[n].expires = expires
            if not v.BuffIcons[n].hooked then
                v.BuffIcons[n]:HookScript("OnUpdate", function(self, elapsed)
                    if self.expires == 0 then
                        self.cdtext:SetText("")
                        return
                    end
                    timeElapsed = timeElapsed + elapsed
                    if timeElapsed > 0.1 then
                        self.cdtext:SetText("")
                        local timeLeft = self.expires - GetTime()
                        if timeLeft < 0 then
                            self:Hide()
                            return
                        end
                        local timetext = "|cFFFFFFFF%d|r"
                        if timeLeft <= 1 then
                            timetext = "|cFFFF0000%d|r"
                        elseif timeLeft <= 4 then
                            timetext = "|cFFFF0000%d|r"
                        elseif timeLeft <= 10 then
                            timetext = "|cFFFFFF00%d|r"
                        end
                        if timeLeft < 60 then
                            self.cdtext:SetText(format(timetext, timeLeft))
                        end
                        timeElapsed = 0
                    end
                end)
                v.BuffIcons[n].hooked = true
            end
        else
            if self and self.cdtext then
                self.cdtext:SetText("")
            end
        end
        v.BuffIcons[n].cd:SetCooldown(0, 0)
    end
end
local function updateFrame(v)
    local i = 1
    local n = 1
    local setting = PlexusBuffIcons.db.profile
    local showbuff = setting.showbuff

    --[[ --8.0 removed because of performance problem
    for name, _ in pairs(PlexusBuffIcons.nameforce) do
        local name, rank, icon, count, debuffType, duration, expires, caster, isStealable, _, spellID = UnitAura(v.unit, name)
        if name then
            showBuffIcon(v, n, setting, icon, expires, duration)
            n=n+1
        end
    end
    --]]
    local filter = setting.bufffilter
    if showbuff then
        filter = filter and (setting.buffmine and "HELPFUL|RAID|PLAYER" or "HELPFUL|RAID") or (setting.buffmine and "HELPFUL|PLAYER" or "HELPFUL")
    else
        filter = filter and "HARMFUL|RAID" or "HARMFUL"
    end
    while(n <= setting.iconnum and i<40) do
        local name, icon, count, _, duration, expires, _, _, _, _ = UnitAura(v.unit, i, filter)
        if (name) then
            if not showbuff or (duration and duration > 0 or setting.bufffilter) then  --ignore mount, world buff etc
                if not PlexusBuffIcons.namefilter[name] and not PlexusBuffIcons.nameforce[name] then
                    showBuffIcon(v, n, setting, icon, count, expires, duration)
                    n=n+1
                end
            end
        else
            break
        end
        i=i+1
    end
    for i=n, MAX_BUFFS do --luacheck: ignore
        v.BuffIcons[i]:Hide()
    end
end

local UnitAuraInstanceID
local function updateFrame_df(v)
    local n = 1
    local setting = PlexusBuffIcons.db.profile
    local showbuff = setting.showbuff

    for i=n, MAX_BUFFS do --luacheck: ignore
        v.BuffIcons[i]:Hide()
    end

    local filter = setting.bufffilter

    if v.unit and UnitAuraInstanceID[v.unitGUID] then
        local numAuras = 0
        for instanceID, aura in pairs(UnitAuraInstanceID[v.unitGUID]) do
            if n > setting.iconnum then
                break
            end
            if not aura.sourceUnit then
                local aurainfo = GetAuraDataByAuraInstanceID(v.unit, instanceID)
                aura.sourceUnit = aurainfo and aurainfo.sourceUnit
            end
            if aura then
                numAuras = numAuras + 1
                local name, icon, count, duration, expires, caster = aura.name, aura.icon, aura.applications, aura.duration, aura.expirationTime, aura.sourceUnit
                if filter and not aura.isRaid then
                    return
                end
                if setting.buffmine and caster ~= "player" then
                    return
                end
                if not showbuff or (duration and duration > 0 or setting.bufffilter) then  --ignore mount, world buff etc
                    if not PlexusBuffIcons.namefilter[name] and not PlexusBuffIcons.nameforce[name] then
                        showBuffIcon(v, n, setting, icon, count, expires, duration)
                        n=n+1
                    end
                end
            end
            if numAuras == 0 then
                UnitAuraInstanceID[v.unitGUID] = nil
            end
        end
    end
end


function PlexusBuffIcons:UNIT_AURA(_, unitid, updatedAuras)
    if not self.enabled then return end
    if not unitid then return end
    local guid = UnitGUID(unitid)
    if not guid then return end

    if not UnitAuraInstanceID then
        UnitAuraInstanceID = {}
    end
    if not UnitAuraInstanceID[guid] then
        UnitAuraInstanceID[guid] = {}
    end

    if not PlexusRoster:IsGUIDInRaid(guid) then return end

    if IsRetailWow() then
        local showbuff = PlexusBuffIcons.db.profile.showbuff

        if updatedAuras and updatedAuras.isFullUpdate then
            local unitauraInfo = {}
            if showbuff then
                ForEachAura(unitid, "HELPFUL", nil,
                    function(aura)
                        if aura and aura.auraInstanceID then
                            unitauraInfo[aura.auraInstanceID] = aura
                        end
                    end,
                true)
            else
                ForEachAura(unitid, "HARMFUL", nil,
                    function(aura)
                        if aura and aura.auraInstanceID then
                            unitauraInfo[aura.auraInstanceID] = aura
                        end
                    end,
                true)
            end

            UnitAuraInstanceID[guid] = {}
            for _, v in pairs(unitauraInfo) do
                UnitAuraInstanceID[guid][v.auraInstanceID] = v
            end
        end

        if updatedAuras and updatedAuras.addedAuras then
            for _, addedAuraInfo in pairs(updatedAuras.addedAuras) do
                if showbuff and addedAuraInfo.isHelpful then
                    UnitAuraInstanceID[guid][addedAuraInfo.auraInstanceID] = addedAuraInfo
                elseif not showbuff and addedAuraInfo.isHarmful then
                   UnitAuraInstanceID[guid][addedAuraInfo.auraInstanceID] = addedAuraInfo
               end
            end
        end


        if updatedAuras and updatedAuras.updatedAuraInstanceIDs then
            for _, auraInstanceID in ipairs(updatedAuras.updatedAuraInstanceIDs) do
                if UnitAuraInstanceID[guid][auraInstanceID] then
                    local newAura = GetAuraDataByAuraInstanceID(unitid, auraInstanceID)
                    if showbuff and newAura and newAura.isHelpful then
                        UnitAuraInstanceID[guid][newAura.auraInstanceID] = newAura
                    elseif not showbuff and newAura and newAura.isHarmful then
                        UnitAuraInstanceID[guid][newAura.auraInstanceID] = newAura
                    end
                end
            end
        end

        if updatedAuras and updatedAuras.removedAuraInstanceIDs then
            for _, auraInstanceID in ipairs(updatedAuras.removedAuraInstanceIDs) do
                if UnitAuraInstanceID[guid] and UnitAuraInstanceID[guid][auraInstanceID] then
                    local aura = UnitAuraInstanceID[guid][auraInstanceID]
                    if showbuff and aura and aura.isHelpful then
                        UnitAuraInstanceID[guid][auraInstanceID] = nil
                    elseif not showbuff and aura and aura.isHarmful then
                        UnitAuraInstanceID[guid][auraInstanceID] = nil
                    end
                end
            end
        end

        for _,v in pairs(PlexusFrame.registeredFrames) do
            if v.unitGUID == guid then updateFrame_df(v) end
        end
    else
        for _,v in pairs(PlexusFrame.registeredFrames) do
            if v.unitGUID == guid then updateFrame(v) end
        end
    end
    -- end

end

function PlexusBuffIcons:UpdateAllUnitsBuffs()
    for _, unitid in PlexusRoster:IterateRoster() do
        self:UNIT_AURA("UpdateAllUnitsBuffs", unitid)
    end
end
