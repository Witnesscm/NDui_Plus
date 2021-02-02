local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local TM = P:RegisterModule("TalentManager")
------------------------------------
-- Credit: ElvUI_WindTools, Talented
------------------------------------
local MAX_SETS = 14

function TM:SaveSet(setName)
	if not self.db.sets[self.specID] then
		self.db.sets[self.specID] = {}
	end

	for key, data in pairs(self.db.sets[self.specID]) do
		if data.setName == setName then
			UIErrorsFrame:AddMessage(DB.InfoColor..format(L["Already have a set named %s."], setName))
			return
		end
	end

	if #self.db.sets[self.specID] == MAX_SETS then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["Too many sets here, please delete one of them and try again."])
		return
	end

	local talentString = TM:ProcessPvEIgnore(self.SaveFrame.TalentString, self.SaveFrame.PveIgnore)
	local pvpTalentTable = TM:ProcessPvPIgnore(self.SaveFrame.PvpTalentTable, self.SaveFrame.PvpIgnore)

	tinsert(self.db.sets[self.specID], {
		setName = setName,
		talentString = talentString,
		pvpTalentTable = pvpTalentTable
	})
	self:UpdateSetButtons()
	self.SaveFrame:Hide()
end

function TM:SetTalent(talentString, pvpTalentTable)
	if talentString and talentString ~= "" then
		local talentTable = {}
		gsub(talentString, "[0-9]", function(char)
			tinsert(talentTable, char)
		end)

		local talentIDs = {}
		for tier = 1, MAX_TALENT_TIERS do
			local isAvilable, column = GetTalentTierInfo(tier, 1)
			if isAvilable and talentTable[tier] and talentTable[tier] ~= 0 and talentTable[tier] ~= column then
				local talentID = GetTalentInfo(tier, talentTable[tier], 1)
				tinsert(talentIDs, talentID)
			end
		end

		if #talentIDs > 1 then
			LearnTalents(unpack(talentIDs))
		end
	end

	for i = 1, 3 do
		local talentID = pvpTalentTable[i]
		if talentID then
			local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i)
			if slotInfo.enabled and talentID ~= 0 and slotInfo.selectedTalentID ~= talentID then
				LearnPvpTalent(talentID, i)
			end
		end
	end
end

function TM:NewSet()
	local frame = TM.SaveFrame
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", TM.SetFrame, "TOPRIGHT", 20, 0)
	frame:Show()
	TM:UpdateSaveFrame()

	frame.EditBox:SetText("")
	frame.EditBox:SetFocus()
	frame.Editing = nil
	frame.Title:SetText(NEW)
end

function TM:EditSet(index, setName)
	for key, data in pairs(self.db.sets[self.specID]) do
		if key ~= index and data.setName == setName then
			UIErrorsFrame:AddMessage(DB.InfoColor..format(L["Already have a set named %s."], setName))
			return
		end
	end

	local talentString = TM:ProcessPvEIgnore(self.SaveFrame.TalentString, self.SaveFrame.PveIgnore)
	local pvpTalentTable = TM:ProcessPvPIgnore(self.SaveFrame.PvpTalentTable, self.SaveFrame.PvpIgnore)

	local data = self.db.sets[self.specID][index]
	if data then
		data.setName = setName
		data.talentString = talentString
		data.pvpTalentTable = pvpTalentTable
	end

	self:UpdateSetButtons()
	self.SaveFrame:Hide()
end

function TM:UpdateSet(index, setName)
	local frame = TM.SaveFrame
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", TM.SetFrame, "TOPRIGHT", 20, 0)
	frame:Show()
	TM:UpdateSaveFrame()

	frame.EditBox:SetText(setName)
	frame.EditBox:SetFocus()
	frame.EditBox:HighlightText()
	frame.Editing = index
	frame.Title:SetText(EDIT)
end

function TM:DeleteSet(specID, setName)
	if not self.db.sets[specID] then return end

	for key, data in pairs(self.db.sets[specID]) do
		if data.setName == setName then
			tremove(self.db.sets[specID], key)
			self:UpdateSetButtons()
			return
		end
	end
end

function TM:ShowContextText(button)
	local menu = {
		{
			text = button.setName,
			isTitle = true,
			notCheckable = true
		},
		{
			text = EDIT,
			func = function()
				TM:UpdateSet(button.index, button.setName)
			end,
			notCheckable = true
		},
		{
			text = DELETE,
			func = function()
				TM:DeleteSet(button.specID, button.setName)
			end,
			notCheckable = true
		}
	}

	EasyMenu(menu, P.EasyMenu, "cursor", 0, 0, "MENU")
end

function TM:GetTalentString()
	local talentString = ""
	for tier = 1, MAX_TALENT_TIERS do
		local isAvilable, column = GetTalentTierInfo(tier, 1)
		talentString = talentString .. (isAvilable and column or 0)
	end
	return talentString
end

function TM:GetPvPTalentTable()
	return C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
end

function TM:ProcessPvEIgnore(build, ignore)
	local talentString = ""
	for i = 1, #ignore do
		if ignore[i] then
			talentString = talentString.."0"
		else
			talentString = talentString..build:sub(i,i)
		end
	end
	return talentString
end

function TM:ProcessPvPIgnore(build, ignore)
	for i=1, #ignore do
		if ignore[i] then
			build[i] = 0
		end
	end
	return build
end

local iconString = "|T%s:0:0:0:0:64:64:5:59:5:59|t %s"

function TM:GetTalentName(tier, column)
	if column == 0 then
		return format(iconString, 134400, L["Not set"])
	else
		local _, name, icon = GetTalentInfo(tier, column, 1)
		return format(iconString, icon, name)
	end
end

function TM:GetPvPTalentName(id)
	if not id or id == 0 then
		return format(iconString, 134400, L["Not set"])
	else
		local _, name, icon = GetPvpTalentInfoByID(id)
		return format(iconString, icon, name)
	end
end

function TM:SetButtonTooltip(button)
	local talentTable = {}
	gsub(button.talentString, "[0-9]", function(char)
		tinsert(talentTable, tonumber(char))
	end)
	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMRIGHT", 12, 20)
	GameTooltip:SetText(button.setName)

	GameTooltip:AddLine("PvE", 1, 1, 1)
	for tier = 1, MAX_TALENT_TIERS do
		GameTooltip:AddLine(TM:GetTalentName(tier, talentTable[tier]), 1, 1, 1)
	end

	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddLine("PvP", 1, 1, 1)
	for i = 1, 3 do
		GameTooltip:AddLine(TM:GetPvPTalentName(button.pvpTalentTable and button.pvpTalentTable[i]), 1, 1, 1)
	end

	GameTooltip:Show()
end

function TM:UpdateSaveFrame()
	local frame = TM.SaveFrame
	if not frame or not frame:IsShown() then return end

	for i = 1, #frame.PveIgnore do
		frame.PveIgnore[i] = false
	end

	for i = 1, #frame.PvpIgnore do
		frame.PvpIgnore[i] = false
	end

	frame.TalentString = TM:GetTalentString()
	for tier, bu in ipairs(frame.PveButtons) do
		local column = tonumber(frame.TalentString:sub(tier, tier))
		bu.TalentName = TM:GetTalentName(tier, column)
		bu:SetText(bu.TalentName)
	end

	frame.PvpTalentTable = TM:GetPvPTalentTable()
	for i, bu in ipairs(frame.PvpButtons) do
		bu.TalentName = TM:GetPvPTalentName(frame.PvpTalentTable[i])
		bu:SetText(bu.TalentName)
	end
end

local function CreateHeader(parent, title, width, height)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(width, height)
	frame.Title = B.CreateFS(frame, 14, title, true, "CENTER", 0, 0)

	local line = frame:CreateTexture(nil, "ARTWORK")
	line:SetSize(frame:GetWidth(), C.mult)
	line:SetPoint("BOTTOM", 0, 0)
	line:SetColorTexture(1, 1, 1, .25)

	return frame
end

function TM:CreateSaveFrame()
	local frame = CreateFrame("Frame", "NDuiPlusTMSaveFrame", UIParent)
	frame:SetPoint("TOPLEFT", TM.SetFrame, "TOPRIGHT", 60, 0)
	frame:SetFrameStrata("HIGH")
	B.CreateMF(frame)
	B.SetBD(frame)
	frame:SetWidth(180)
	frame:SetHeight(TM.SetFrame:GetHeight())
	frame:Hide()
	tinsert(UISpecialFrames, "NDuiPlusTMSaveFrame")

	local close = B.CreateButton(frame, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function() frame:Hide() end)

	frame.Title = B.CreateFS(frame, 14, "", true, "TOP", 0, -8)

	local label = B.CreateFS(frame, 14, L["Set Name"].." :", true, "TOPLEFT", 10, -32)
	local editBox = B.CreateEditBox(frame, 160, 22)
	editBox.bg:SetBackdropColor(0, 0, 0, 0)
	editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
	frame.EditBox = editBox

	frame.PveHeader = CreateHeader(frame, "PvE", 160, 22)
	frame.PveHeader:SetPoint("TOP", frame.EditBox, "BOTTOM", 0, -10)

	frame.PveButtons = {}
	frame.PveIgnore = {}
	for i = 1, MAX_TALENT_TIERS do
		frame.PveIgnore[i] = false

		local bu = P.CreateButton(frame, 160, 22, nil, true)
		if i == 1 then
			bu:SetPoint("TOP", frame.PveHeader, "BOTTOM", 0, -10)
		else
			bu:SetPoint("TOPLEFT", frame.PveButtons[i - 1], "TOPLEFT", 0, -24)
		end
		bu:SetScript("OnClick", function(self)
			frame.PveIgnore[i] = not frame.PveIgnore[i]
			if frame.PveIgnore[i] then
				bu:SetText(format("Tier %d ", i)..L["Ignored"])
			else
				bu:SetText(self.TalentName)
			end
		end)

		tinsert(frame.PveButtons, bu)
	end
	
	frame.PvpHeader = CreateHeader(frame, "PvP", 160, 22)
	frame.PvpHeader:SetPoint("TOP", frame.PveButtons[#frame.PveButtons], "BOTTOM", 0, -10)

	frame.PvpButtons = {}
	frame.PvpIgnore = {}
	for i = 1, 3 do
		frame.PvpIgnore[i] = false

		local bu = P.CreateButton(frame, 160, 22, nil, true)
		if i == 1 then
			bu:SetPoint("TOP", frame.PvpHeader, "BOTTOM", 0, -10)
		else
			bu:SetPoint("TOPLEFT", frame.PvpButtons[i - 1], "TOPLEFT", 0, -24)
		end
		bu:SetScript("OnClick", function(self)
			frame.PvpIgnore[i] = not frame.PvpIgnore[i]
			if frame.PvpIgnore[i] then
				bu:SetText(format("Slot %d ", i)..L["Ignored"])
			else
				bu:SetText(self.TalentName)
			end
		end)

		tinsert(frame.PvpButtons, bu)
	end

	local save = P.CreateButton(frame, 160, 22, SAVE)
	save:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
	save:SetScript("OnClick", function()
		local setName = frame.EditBox:GetText()
		if setName and setName ~= "" then
			if frame.Editing then
				TM:EditSet(frame.Editing, setName)
			else
				TM:SaveSet(setName)
			end
		else
			UIErrorsFrame:AddMessage(DB.InfoColor..L["You must enter a set name."])
		end
	end)
	frame.SaveButton = save

	TM.SaveFrame = frame
end

function TM:CreateSetFrame()
	local frame = CreateFrame("Frame", "NDuiPlusTMSetFrame", PlayerTalentFrameTalents)
	frame:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 3, 0)
	frame:SetPoint("BOTTOMRIGHT", PlayerTalentFrame, "BOTTOMRIGHT", 153, 0)
	B.SetBD(frame)
	frame:EnableMouse(true)
	frame:Hide()

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(TM.specIcon)
	tex:SetSize(24, 24)
	tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
	B.ReskinIcon(tex)
	frame.SpecIcon = tex

	local header = CreateHeader(frame, L["Talent Set"], 130, 22)
	header:SetPoint("TOP", 0, -20)
	header.Title:SetPoint("CENTER", 0, 4)
	frame.Header = header

	local newButton = P.CreateButton(frame, 130, 22, NEW)
	newButton:SetPoint("BOTTOM", frame, 0, 10)
	newButton:SetScript("OnClick", function()
		TM:NewSet()
	end)

	frame.SetButtons = {}
	for i = 1, MAX_SETS do
		local button = P.CreateButton(frame, 130, 22, "", true)
		if i == 1 then
			button:SetPoint("TOP", header, "BOTTOM", 0, -10)
		else
			button:SetPoint("TOP", frame.SetButtons[i - 1], "BOTTOM", 0, -4)
		end
		button.index = i
		button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		button:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				TM:SetTalent(self.talentString, self.pvpTalentTable)
			elseif button == "RightButton" then
				TM:ShowContextText(self)
			end
		end)

		button:HookScript("OnEnter", function(self)
			TM:SetButtonTooltip(self)
		end)
		button:HookScript("OnLeave", B.HideTooltip)

		button:Hide()
		frame.SetButtons[i] = button
	end

	local toggle = P.CreateButton(PlayerTalentFrameTalents, 100, 22, L["Talent Manager"])
	toggle:SetPoint("BOTTOMRIGHT", -16, -16)
	toggle:SetScript("OnClick", function()
		B:TogglePanel(frame)
	end)

	TM.SetFrame = frame
	TM:UpdateSetButtons()
end

function TM:UpdateSetButtons()
	if not self.SetFrame or not self.specID then return end

	local db = self.db.sets[self.specID]
	local numSets = db and #db or 0

	for i = 1, numSets do
		local button = self.SetFrame.SetButtons[i]
		button:SetText(db[i].setName)
		button.setName = db[i].setName
		button.specID = self.specID
		button.talentString = db[i].talentString
		button.pvpTalentTable = db[i].pvpTalentTable
		button:Show()
	end

	if numSets == MAX_SETS then return end

	for i = numSets + 1, MAX_SETS do
		local button = self.SetFrame.SetButtons[i]
		button.setName = nil
		button.specID = nil
		button.talentString = nil
		button.pvpTalentTable = nil
		button:Hide()
	end
end

function TM:UpdatePlayerInfo()
	local specID, _, _, specIcon = GetSpecializationInfo(GetSpecialization())
	self.specID = specID
	self.specIcon = specIcon

	if self.SetFrame then
		self.SetFrame.SpecIcon:SetTexture(self.specIcon)
	end
end

function TM:TweakWarmode()
	local PvpTalentFrame = _G.PlayerTalentFrameTalents.PvpTalentFrame
	PvpTalentFrame.InvisibleWarmodeButton:SetAllPoints(PvpTalentFrame.Swords)
end

function TM:TalentUI_Load(addon)
	if addon == "Blizzard_TalentUI" then
		TM:CreateSetFrame()
		TM:CreateSaveFrame()
		TM:TweakWarmode()
		B:UnregisterEvent(self, TM.TalentUI_Load)
	end
end

function TM:SetupCache()
	TM.db = NDuiPlusCharDB["TalentManager"]
	TM.db.sets = TM.db.sets or {}
end

function TM:OnLogin()
	if not NDuiPlusDB["Misc"]["TalentManager"] then return end

	TM:SetupCache()

	if IsAddOnLoaded("Blizzard_TalentUI") then
		TM:CreateSetFrame()
		TM:CreateSaveFrame()
		TM:TweakWarmode()
	else
		B:RegisterEvent("ADDON_LOADED", TM.TalentUI_Load)
	end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		TM:UpdatePlayerInfo()
		TM:UpdateSetButtons()
	end)

	B:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function(_, unit)
		if unit and UnitIsUnit("player", unit) then
			TM:UpdatePlayerInfo()
			TM:UpdateSetButtons()
		end
	end)

	B:RegisterEvent("PLAYER_TALENT_UPDATE", TM.UpdateSaveFrame)
end