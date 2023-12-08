local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

if not P.IsWrath() then return end

local LSP = LibStub("LibShowUIPanel-1.0")
local ShowUIPanel = LSP.ShowUIPanel
local HideUIPanel = LSP.HideUIPanel

local MAX_NUM_TALENT_TIERS = _G.MAX_NUM_TALENT_TIERS
local NUM_TALENT_COLUMNS = _G.NUM_TALENT_COLUMNS
local MAX_NUM_TALENTS = _G.MAX_NUM_TALENTS
local PLAYER_TALENTS_PER_TIER = _G.PLAYER_TALENTS_PER_TIER
local PET_TALENTS_PER_TIER = _G.PET_TALENTS_PER_TIER
local DEFAULT_TALENT_SPEC = _G.DEFAULT_TALENT_SPEC

local TALENT_TIERS_WRATH = 11
local TALENT_COLUMNS_WRATH = 4
local TALENT_TIERS_PET_WRATH = 6

local talentButtonSize = 32
local initialOffsetX = 36
local initialOffsetY = 16
local buttonSpacingX = 63
local buttonSpacingY = 63

local petOffsetX = 0
local petOffsetY = 16

local specsIndex = {
	[1] = "spec1",
	[2] = "spec2",
	[3] = "petspec1",
}

local specs = {
	["spec1"] = {
		name = TALENT_SPEC_PRIMARY,
		talentGroup = 1,
		unit = "player",
		pet = false,
		tooltip = TALENT_SPEC_PRIMARY,
		portraitUnit = "player",
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
		glyphName = TALENT_SPEC_PRIMARY_GLYPH,
	},
	["spec2"] = {
		name = TALENT_SPEC_SECONDARY,
		talentGroup = 2,
		unit = "player",
		pet = false,
		tooltip = TALENT_SPEC_SECONDARY,
		portraitUnit = "player",
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
		hasGlyphs = true,
		glyphName = TALENT_SPEC_SECONDARY_GLYPH,
	},
	["petspec1"] = {
		name = TALENT_SPEC_PET_PRIMARY,
		talentGroup = 1,
		unit = "pet",
		tooltip = TALENT_SPEC_PET_PRIMARY,
		pet = true,
		portraitUnit = "pet",
		defaultSpecTexture = nil,
		hasGlyphs = false,
		glyphName = nil,
	},
}

local specTabs = {}
local selectedSpec
local activeSpec

local talentSpecInfoCache = {}
for _, spec in ipairs(specsIndex) do
	talentSpecInfoCache[spec] = {}
end

StaticPopupDialogs["NDUIPLUS_CONFIRM_LEARN_PREVIEW_TALENTS"] = {
	text = CONFIRM_LEARN_PREVIEW_TALENTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		LearnPreviewTalents(M.TalentUI.pet)
		PlaySound(1455)
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

local TALENT_BRANCH_TEXTURECOORDS = {
	up = {
		[1] = {0.12890625, 0.25390625, 0 , 0.484375},
		[-1] = {0.12890625, 0.25390625, 0.515625 , 1.0}
	},
	down = {
		[1] = {0, 0.125, 0, 0.484375},
		[-1] = {0, 0.125, 0.515625, 1.0}
	},
	left = {
		[1] = {0.2578125, 0.3828125, 0, 0.5},
		[-1] = {0.2578125, 0.3828125, 0.5, 1.0}
	},
	right = {
		[1] = {0.2578125, 0.3828125, 0, 0.5},
		[-1] = {0.2578125, 0.3828125, 0.5, 1.0}
	},
	topright = {
		[1] = {0.515625, 0.640625, 0, 0.5},
		[-1] = {0.515625, 0.640625, 0.5, 1.0}
	},
	topleft = {
		[1] = {0.640625, 0.515625, 0, 0.5},
		[-1] = {0.640625, 0.515625, 0.5, 1.0}
	},
	bottomright = {
		[1] = {0.38671875, 0.51171875, 0, 0.5},
		[-1] = {0.38671875, 0.51171875, 0.5, 1.0}
	},
	bottomleft = {
		[1] = {0.51171875, 0.38671875, 0, 0.5},
		[-1] = {0.51171875, 0.38671875, 0.5, 1.0}
	},
	tdown = {
		[1] = {0.64453125, 0.76953125, 0, 0.5},
		[-1] = {0.64453125, 0.76953125, 0.5, 1.0}
	},
	tup = {
		[1] = {0.7734375, 0.8984375, 0, 0.5},
		[-1] = {0.7734375, 0.8984375, 0.5, 1.0}
	},
}

local TALENT_ARROW_TEXTURECOORDS = {
	top = {
		[1] = {0, 0.5, 0, 0.5},
		[-1] = {0, 0.5, 0.5, 1.0}
	},
	right = {
		[1] = {1.0, 0.5, 0, 0.5},
		[-1] = {1.0, 0.5, 0.5, 1.0}
	},
	left = {
		[1] = {0.5, 1.0, 0, 0.5},
		[-1] = {0.5, 1.0, 0.5, 1.0}
	},
}

function M:TalentUI_CreatePanel(i)
	local frame = CreateFrame("Frame", nil, self)
	local isPet = i > 3
	local tiers = isPet and TALENT_TIERS_PET_WRATH or TALENT_TIERS_WRATH
	local offsetX = isPet and petOffsetX or 0
	local offsetY = isPet and petOffsetY or 0
	frame:SetSize(initialOffsetX * 2 + TALENT_COLUMNS_WRATH * buttonSpacingX - 26 + offsetX, initialOffsetY * 2 + tiers * buttonSpacingX - 26 + offsetY)
	B.CreateBDFrame(frame, .2)
	frame.__owner = self

	frame.branches = {}
	frame.buttons = {}
	frame.brancheTextures = {}
	frame.arrowTextures = {}
	frame.talentTree = isPet and 1 or i

	local TopBG = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	TopBG:SetPoint("TOPLEFT")
	TopBG:SetPoint("TOPRIGHT")
	TopBG:SetHeight(.775 * frame:GetHeight())

	local BottomBG = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	BottomBG:SetPoint("TOPLEFT", TopBG, "BOTTOMLEFT")
	BottomBG:SetPoint("TOPRIGHT", TopBG, "BOTTOMRIGHT")
	BottomBG:SetPoint("BOTTOMLEFT")
	BottomBG:SetPoint("BOTTOMRIGHT")
	BottomBG:SetTexCoord(0, 1, 0, 74 / 128)

	local ArrowFrame = CreateFrame("Frame", nil, frame)
	ArrowFrame:SetAllPoints()
	ArrowFrame:SetFrameLevel(frame:GetFrameLevel() + 2)

	local Label = frame:CreateFontString(nil, "OVERLAY")
	Label:SetFont(DB.Font[1], 16, DB.Font[3])
	Label:SetTextColor(1, .8, 0)
	Label:SetPoint("BOTTOM", frame, "TOP", 0, 10)

	frame.TopBG = TopBG
	frame.BottomBG = BottomBG
	frame.ArrowFrame = ArrowFrame
	frame.Label = Label

	for i = 1, MAX_NUM_TALENT_TIERS do
		frame.branches[i] = {}
		for j = 1, NUM_TALENT_COLUMNS do
			frame.branches[i][j] = {
				id = nil,
				up = 0,
				left = 0,
				right = 0,
				down = 0,
				leftArrow = 0,
				rightArrow = 0,
				topArrow = 0,
			}
		end
	end

	return frame
end

local currentSpecTab

local function SelectRole(self)
	if InCombatLockdown() then P:Error(ERR_NOT_IN_COMBAT) return end

	if currentSpecTab then
		SetTalentGroupRole(currentSpecTab, self.value)
	end
end

local function IsRoleChecked(self)
	local currentRole = currentSpecTab and GetTalentGroupRole(currentSpecTab) or "NONE"
	return currentRole == self.value
end

local roleList = {
	{text = P.TextureString(B.GetRoleTex("TANK"), ":16:16")..TANK, func = SelectRole, classicChecks = true, value = "TANK", checked = IsRoleChecked},
	{text = P.TextureString(B.GetRoleTex("HEALER"), ":16:16")..HEALER, func = SelectRole, classicChecks = true, value = "HEALER", checked = IsRoleChecked},
	{text = P.TextureString(B.GetRoleTex("DAMAGER"), ":16:16")..DAMAGER, func = SelectRole, classicChecks = true, value = "DAMAGER", checked = IsRoleChecked},
}

local RoleDropDown

local function TalentSpecTab_OnClick(self, btn)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)

	local specIndex = self.specIndex
	local spec = specs[specIndex]

	if btn == "RightButton" then
		self:SetChecked(not self:GetChecked())

		if not spec.pet then
			currentSpecTab = spec.talentGroup

			if not RoleDropDown then
				RoleDropDown = CreateFrame("Frame", "NDuiPlus_RoleDropMenu", UIParent, "UIDropDownMenuTemplate")
				RoleDropDown.displayMode = "MENU"
				RoleDropDown.initialize = EasyMenu_Initialize
			end

			ToggleDropDownMenu(1, nil, RoleDropDown, "cursor", 10, -10, roleList)
		end

		return
	end

	for _, frame in next, specTabs do
		frame:SetChecked(nil)
	end

	self:SetChecked(true)
	selectedSpec = specIndex

	M.TalentUI.pet = spec.pet
	M.TalentUI.unit = spec.unit
	M.TalentUI.talentGroup = spec.talentGroup

	M:TalentUI_Refresh()
end

local function TalentSpecTab_OnDoubleClick(self)
	local specIndex = self.specIndex
	local spec = specs[specIndex]
	local numTalentGroups = GetNumTalentGroups(false, false)
	if not spec.pet and numTalentGroups > 1 and specIndex ~= activeSpec then
		SetActiveTalentGroup(spec.talentGroup)
	end
end

local function TalentSpecTab_OnEnter(self)
	local specIndex = self.specIndex
	local spec = specs[specIndex]
	local role = GetTalentGroupRole(spec.talentGroup)
	if spec.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local numTalentGroups, numPetTalentGroups = GetNumTalentGroups(false, false), GetNumTalentGroups(false, true)

		if numPetTalentGroups <= 1 and numTalentGroups <= 1 then
			if not spec.pet then
				GameTooltip:AddDoubleLine(UnitName(spec.unit), P.TextureString(B.GetRoleTex(role), ":16:16"), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
				GameTooltip:AddLine(" ")
			else
				GameTooltip:AddLine(UnitName(spec.unit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			end
		else
			if not spec.pet then
				GameTooltip:AddDoubleLine(spec.tooltip, P.TextureString(B.GetRoleTex(role), ":16:16"))
				GameTooltip:AddLine(" ")
			else
				GameTooltip:AddLine(spec.tooltip)
			end
			if self.specIndex == activeSpec then
				GameTooltip:AddLine(TALENT_ACTIVE_SPEC_STATUS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			end
		end

		local pointsColor
		for index, info in ipairs(talentSpecInfoCache[specIndex]) do
			if info.name then
				if talentSpecInfoCache[specIndex].primaryTabIndex == index then
					pointsColor = GREEN_FONT_COLOR
				else
					pointsColor = HIGHLIGHT_FONT_COLOR
				end
				GameTooltip:AddDoubleLine(
					info.name,
					info.pointsSpent,
					HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
					pointsColor.r, pointsColor.g, pointsColor.b,
					1
				)
			end
		end

		if not spec.pet then
			GameTooltip:AddLine(" ")
			if numTalentGroups > 1 and specIndex ~= activeSpec then
				GameTooltip:AddLine(P.LeftButtonTip(L["QuickChangeTalents"]), .6, .8, 1)
			end
			GameTooltip:AddLine(P.RightButtonTip(SET_ROLE_TOOLTIP), .6, .8, 1)
		end

		GameTooltip:Show()
	end
end

local function TalentSpecTab_OnEvent(self)
	if GameTooltip:IsOwned(self) then
		TalentSpecTab_OnEnter(self)
	end
end

function M:TalentUI_CreateTab()
	local tab = CreateFrame("CheckButton", nil, self)
	tab:SetSize(32, 32)
	tab:SetNormalTexture(0)
	tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
	tab:SetHighlightTexture(0)
	tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	tab:SetCheckedTexture(DB.pushedTex)
	B.CreateBDFrame(tab)
	tab:Hide()

	return tab
end

function M:TalentUI_CreateSpecTab(i, specIndex)
	local tab = M.TalentUI_CreateTab(self)
	tab:SetID(i)
	tab.specIndex = specIndex
	specTabs[specIndex] = tab
	tab:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	tab:RegisterEvent("TALENT_GROUP_ROLE_CHANGED")
	tab:SetScript("OnClick", TalentSpecTab_OnClick)
	tab:SetScript("OnDoubleClick", TalentSpecTab_OnDoubleClick)
	tab:SetScript("OnEnter", TalentSpecTab_OnEnter)
	tab:SetScript("OnLeave", B.HideTooltip)
	tab:SetScript("OnEvent", TalentSpecTab_OnEvent)

	local activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, false), GetNumTalentGroups(false, false)
	local activePetTalentGroup, numPetTalentGroups = GetActiveTalentGroup(false, true), GetNumTalentGroups(false, true)
	M.TalentUI_UpdateSpecTab(tab, activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups)

	return tab
end

function M:TalentUI_UpdateSpecTab(activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups)
	local specIndex = self.specIndex
	local spec = specs[specIndex]

	local canShow
	if spec.pet then
		canShow = spec.talentGroup <= numPetTalentGroups
	else
		canShow = spec.talentGroup <= numTalentGroups
	end
	if not canShow then
		self:Hide()
		return false
	end

	M.TalentUI_UpdateSpecInfoCache(talentSpecInfoCache[specIndex], false, spec.pet, spec.talentGroup)

	local normalTexture = self:GetNormalTexture()
	local hasMultipleTalentGroups = numTalentGroups > 1
	self.usingPortraitTexture = false
	if hasMultipleTalentGroups then
		local specInfoCache = talentSpecInfoCache[specIndex]
		local primaryTabIndex = specInfoCache.primaryTabIndex
		if primaryTabIndex > 0 then
			normalTexture:SetTexture(specInfoCache[primaryTabIndex].icon)
		else
			if specInfoCache.numTabs > 1 and specInfoCache.totalPointsSpent > 0 then
				normalTexture:SetTexture(TALENT_HYBRID_ICON)
			else
				if spec.defaultSpecTexture then
					normalTexture:SetTexture(spec.defaultSpecTexture)
				elseif spec.portraitUnit  then
					SetPortraitTexture(normalTexture, spec.portraitUnit)
					self.usingPortraitTexture = true
				end
			end
		end
	else
		if spec.portraitUnit then
			SetPortraitTexture(normalTexture, spec.portraitUnit)
			self.usingPortraitTexture = true
		end
	end

	self:Show()
	return true
end

local sortedTabPointsSpentBuf = {}
function M.TalentUI_UpdateSpecInfoCache(cache, inspect, pet, talentGroup)
	cache.primaryTabIndex = 0
	cache.totalPointsSpent = 0

	local highPointsSpent = 0
	local highPointsSpentIndex
	local lowPointsSpent = math.huge
	local lowPointsSpentIndex

	local numTabs = GetNumTalentTabs(inspect, pet)
	cache.numTabs = numTabs
	for i = 1, MAX_TALENT_TABS do
		cache[i] = cache[i] or {}
		if i <= numTabs then
			local name, icon, pointsSpent, _, previewPointsSpent = GetTalentTabInfo(i, inspect, pet, talentGroup)
			local displayPointsSpent = pointsSpent + previewPointsSpent

			cache[i].name = name
			cache[i].pointsSpent = displayPointsSpent
			cache[i].icon = icon
			cache.totalPointsSpent = cache.totalPointsSpent + displayPointsSpent

			if displayPointsSpent > highPointsSpent then
				highPointsSpent = displayPointsSpent
				highPointsSpentIndex = i
			end
			if displayPointsSpent < lowPointsSpent then
				lowPointsSpent = displayPointsSpent
				lowPointsSpentIndex = i
			end

			sortedTabPointsSpentBuf[i] = 0

			local insertIndex = i
			for j = 1, i, 1 do
				local currPointsSpent = sortedTabPointsSpentBuf[j]
				if currPointsSpent > displayPointsSpent then
					insertIndex = j
					break
				end
			end
			for j = i, insertIndex + 1, -1 do
				sortedTabPointsSpentBuf[j] = sortedTabPointsSpentBuf[j - 1]
			end
			sortedTabPointsSpentBuf[insertIndex] = displayPointsSpent
		else
			cache[i].name = nil
		end
	end

	if highPointsSpentIndex and lowPointsSpentIndex then
		local midPointsSpentIndex = bit.rshift(numTabs, 1) + 1
		local midPointsSpent = sortedTabPointsSpentBuf[midPointsSpentIndex]

		if 3*(midPointsSpent-lowPointsSpent) < 2*(highPointsSpent-lowPointsSpent)then
			cache.primaryTabIndex = highPointsSpentIndex
		end
	end
end

local function TalentButton_OnClick(self, button)
	if IsModifiedClick("CHATLINK") then
		local link = GetTalentLink(self.__owner.talentTree, self:GetID(), false, M.TalentUI.pet, M.TalentUI.talentGroup, GetCVarBool("previewTalents"))
		if link then
			ChatEdit_InsertLink(link)
		end
	elseif selectedSpec and (activeSpec == selectedSpec or specs[selectedSpec].pet) then
		if button == "LeftButton" then
			if GetCVarBool("previewTalents") then
				AddPreviewTalentPoints(self.__owner.talentTree, self:GetID(), 1, M.TalentUI.pet, M.TalentUI.talentGroup)
			else
				LearnTalent(self.__owner.talentTree, self:GetID(), M.TalentUI.pet, M.TalentUI.talentGroup)
			end
		elseif button == "RightButton" then
			if GetCVarBool("previewTalents") then
				AddPreviewTalentPoints(self.__owner.talentTree, self:GetID(), -1, M.TalentUI.pet, M.TalentUI.talentGroup)
			end
		end
	end
end

local function TalentButton_OnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetTalent(self.__owner.talentTree, self:GetID(), false, M.TalentUI.pet, M.TalentUI.talentGroup, GetCVarBool("previewTalents"))
end

local function TalentButton_OnEvent(self, event, ...)
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetTalent(self.__owner.talentTree, self:GetID(), false, M.TalentUI.pet, M.TalentUI.talentGroup, GetCVarBool("previewTalents"))
	end
end

function M:TalentUI_GetButton(i)
	if not self.buttons[i] then
		local button = CreateFrame("Button", nil, self, "ItemButtonTemplate")
		button:SetID(i)
		button.__owner = self

		button:RegisterEvent("CHARACTER_POINTS_CHANGED")
		button:SetScript("OnClick", TalentButton_OnClick)
		button:SetScript("OnEvent", TalentButton_OnEvent)
		button:SetScript("OnEnter", TalentButton_OnEnter)
		button:SetScript("OnLeave", B.HideTooltip)

		local Slot = button:CreateTexture(nil, "BACKGROUND")
		Slot:SetSize(64, 64)
		Slot:SetPoint("CENTER", 0, -1)
		Slot:SetTexture([[Interface\Buttons\UI-EmptySlot-White]])

		local RankBorder = button:CreateTexture(nil, "OVERLAY")
		RankBorder:SetSize(32, 32)
		RankBorder:SetPoint("CENTER", button, "BOTTOMRIGHT")
		RankBorder:SetTexture([[Interface\TalentFrame\TalentFrame-RankBorder]])

		local Rank = button:CreateFontString(nil, "OVERLAY")
		Rank:SetFont(DB.Font[1], 15, DB.Font[3])
		Rank:SetPoint("CENTER", RankBorder, "CENTER")

		B.StripTextures(button)
		button.icon:SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(button.icon)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)

		button.Slot = Slot
		button.RankBorder = RankBorder
		button.Rank = Rank
		button.UpdateTooltip = TalentButton_OnEnter

		self.buttons[i] = button
	end
	return self.buttons[i]
end

function M:TalentUI_SetArrowTexture(tier, column, texCoords, xOffset, yOffset)
	local arrowTexture = M.TalentUI_GetArrowTexture(self)
	arrowTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
	arrowTexture:SetPoint("TOPLEFT", arrowTexture:GetParent(), "TOPLEFT", xOffset, yOffset)
end

function M:TalentUI_GetArrowTexture()
	local texture = self.arrowTextures[self.arrowIndex]
	if not texture then
		texture = self.ArrowFrame:CreateTexture(nil, "BACKGROUND")
		texture:SetSize(32, 32)
		texture:SetTexture([[Interface\TalentFrame\UI-TalentArrows]])
		self.arrowTextures[self.arrowIndex] = texture
	end
	self.arrowIndex = self.arrowIndex + 1
	texture:Show()

	return texture
end

function M:TalentUI_SetBranchTexture(tier, column, texCoords, xOffset, yOffset)
	local branchTexture = M.TalentUI_GetBranchTexture(self)
	branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
	branchTexture:SetPoint("TOPLEFT", branchTexture:GetParent(), "TOPLEFT", xOffset, yOffset)
end

function M:TalentUI_GetBranchTexture()
	local texture = self.brancheTextures[self.textureIndex]
	if not texture then
		texture = self:CreateTexture(nil, "ARTWORK")
		texture:SetSize(32, 32)
		texture:SetTexture([[Interface\TalentFrame\UI-TalentBranches]])
		self.brancheTextures[self.textureIndex] = texture
	end
	self.textureIndex = self.textureIndex + 1
	texture:Show()

	return texture
end

function M:TalentUI_ResetArrowTextureCount()
	self.arrowIndex = 1
end

function M:TalentUI_ResetBranchTextureCount()
	self.textureIndex = 1
end

function M:TalentUI_GetArrowTextureCount()
	return self.arrowIndex
end

function M:TalentUI_GetBranchTextureCount()
	return self.textureIndex
end

function M:TalentUI_SetPrereqs(buttonTier, buttonColumn, forceDesaturated, tierUnlocked, preview, ...)
	local tier, column, isLearnable, isPreviewLearnable
	local requirementsMet = tierUnlocked and not forceDesaturated

	for i=1, select("#", ...), 4 do
		tier, column, isLearnable, isPreviewLearnable = select(i, ...)
		if ( forceDesaturated or (preview and not isPreviewLearnable) or (not preview and not isLearnable) ) then
			requirementsMet = nil
		end
		M.TalentUI_DrawLines(self, buttonTier, buttonColumn, tier, column, requirementsMet)
	end

	return requirementsMet
end

function M:TalentUI_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet)
	if requirementsMet then
		requirementsMet = 1
	else
		requirementsMet = -1
	end

	if buttonColumn == column then
		if buttonTier - tier > 1 then
			for i = tier + 1, buttonTier - 1 do
				if self.branches[i][buttonColumn].id then
					P:Print("Error this layout is blocked vertically " .. self.branches[buttonTier][i].id)
					return
				end
			end
		end

		for i = tier, buttonTier - 1 do
			self.branches[i][buttonColumn].down = requirementsMet
			if i + 1 <= buttonTier - 1 then
				self.branches[i + 1][buttonColumn].up = requirementsMet
			end
		end

		self.branches[buttonTier][buttonColumn].topArrow = requirementsMet
		return
	end

	if buttonTier == tier then
		local left = min(buttonColumn, column)
		local right = max(buttonColumn, column)

		if right - left > 1 then
			for i = left + 1, right - 1 do
				if self.branches[tier][i].id then
					P:Print("there\"s a blocker " .. tier .. " " .. i)
					return
				end
			end
		end

		for i = left, right - 1 do
			self.branches[tier][i].right = requirementsMet
			self.branches[tier][i + 1].left = requirementsMet
		end

		if buttonColumn < column then
			self.branches[buttonTier][buttonColumn].rightArrow = requirementsMet
		else
			self.branches[buttonTier][buttonColumn].leftArrow = requirementsMet
		end
		return
	end

	local left = min(buttonColumn, column)
	local right = max(buttonColumn, column)

	if left == column then
		left = left + 1
	else
		right = right - 1
	end

	local blocked = nil
	for i = left, right do
		if self.branches[tier][i].id then
			blocked = 1
		end
	end
	left = min(buttonColumn, column)
	right = max(buttonColumn, column)
	if not blocked then
		self.branches[tier][buttonColumn].down = requirementsMet
		self.branches[buttonTier][buttonColumn].up = requirementsMet

		for i = tier, buttonTier - 1 do
			self.branches[i][buttonColumn].down = requirementsMet
			self.branches[i + 1][buttonColumn].up = requirementsMet
		end

		for i = left, right - 1 do
			self.branches[tier][i].right = requirementsMet
			self.branches[tier][i + 1].left = requirementsMet
		end

		self.branches[buttonTier][buttonColumn].topArrow = requirementsMet
		return
	end

	if left == buttonColumn then
		left = left + 1
	else
		right = right - 1
	end

	for i = left, right do
		if self.branches[buttonTier][i].id then
			P:Print("Error, this layout is undrawable " .. self.branches[buttonTier][i].id)
			return
		end
	end

	left = min(buttonColumn, column)
	right = max(buttonColumn, column)

	for i = tier, buttonTier - 1 do
		self.branches[i][column].up = requirementsMet
		self.branches[i + 1][column].down = requirementsMet
	end

	if buttonColumn < column then
		self.branches[buttonTier][buttonColumn].rightArrow = requirementsMet
	else
		self.branches[buttonTier][buttonColumn].leftArrow = requirementsMet
	end
end

function M:TalentUI_SetButtonLocation(tier, column, initialOffsetX, initialOffsetY, buttonSpacingX, buttonSpacingY)
	column = (column - 1) * buttonSpacingX + initialOffsetX
	tier = -(tier - 1) * buttonSpacingY - initialOffsetY
	self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", column, tier)
end

function M:TalentUI_ResetBranches()
	local node
	for i = 1, MAX_NUM_TALENT_TIERS do
		for j = 1, NUM_TALENT_COLUMNS do
			node = self.branches[i][j]
			node.id = nil
			node.up = 0
			node.down = 0
			node.left = 0
			node.right = 0
			node.rightArrow = 0
			node.leftArrow = 0
			node.topArrow = 0
		end
	end
end

function M:TalentUI_UpdateTalentPoints()
	local talentPoints = GetUnspentTalentPoints(false, M.TalentUI.pet, M.TalentUI.talentGroup)
	local unspentPoints = talentPoints - GetGroupPreviewTalentPointsSpent(M.TalentUI.pet, M.TalentUI.talentGroup)
	M.TalentUI.Points:SetText(format(CHARACTER_POINTS1_COLON..HIGHLIGHT_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE, unspentPoints))

	return unspentPoints
end

function M:TalentUI_Update()
	local preview = GetCVarBool("previewTalents")
	local isActiveTalentGroup = M.TalentUI.talentGroup == GetActiveTalentGroup(false, M.TalentUI.pet)

	local base
	local name, _, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(self.talentTree, false, M.TalentUI.pet, M.TalentUI.talentGroup)
	if name then
		base = "Interface\\TalentFrame\\"..background.."-"
	else
		base = "Interface\\TalentFrame\\MageFire-"
	end

	self.TopBG:SetTexture(base .. "TopLeft")
	self.TopBG:SetDesaturated(not isActiveTalentGroup)
	self.BottomBG:SetTexture(base .. "BottomLeft")
	self.BottomBG:SetDesaturated(not isActiveTalentGroup)

	local numTalents = GetNumTalents(self.talentTree, false, M.TalentUI.pet)
	if numTalents > MAX_NUM_TALENTS then
		P:Print("Too many talents in talent frame!")
	end

	local unspentPoints = M:TalentUI_UpdateTalentPoints()
	local tabPointsSpent
	if pointsSpent and previewPointsSpent then
		tabPointsSpent = pointsSpent + previewPointsSpent
	else
		tabPointsSpent = 0
	end

	self.Label:SetText(format("%s: "..HIGHLIGHT_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE, name, tabPointsSpent))

	M.TalentUI_ResetBranches(self)
	local forceDesaturated, tierUnlocked
	for i = 1, MAX_NUM_TALENTS do
		local button = M.TalentUI_GetButton(self, i)
		if i <= numTalents then
			local name, iconTexture, tier, column, rank, maxRank, _, meetsPrereq, previewRank, meetsPreviewPrereq = GetTalentInfo(self.talentTree, i, false, M.TalentUI.pet, M.TalentUI.talentGroup)
			if name then
				local displayRank
				if preview then
					displayRank = previewRank
				else
					displayRank = rank
				end

				button.Rank:SetText(displayRank)
				M.TalentUI_SetButtonLocation(button, tier, column, initialOffsetX, initialOffsetY, buttonSpacingX, buttonSpacingY)
				self.branches[tier][column].id = button:GetID()

				if (unspentPoints <= 0 or not isActiveTalentGroup) and displayRank == 0 then
					forceDesaturated = 1
				else
					forceDesaturated = nil
				end

				if (tier - 1) * (M.TalentUI.pet and PET_TALENTS_PER_TIER or PLAYER_TALENTS_PER_TIER) <= tabPointsSpent then
					tierUnlocked = 1
				else
					tierUnlocked = nil
				end

				SetItemButtonTexture(button, iconTexture)

				local prereqsSet = M.TalentUI_SetPrereqs(self, tier, column, forceDesaturated, tierUnlocked, preview, GetTalentPrereqs(self.talentTree, i, false, M.TalentUI.pet, M.TalentUI.talentGroup))
				if prereqsSet and ((preview and meetsPreviewPrereq) or (not preview and meetsPrereq)) then
					SetItemButtonDesaturated(button, nil)

					if displayRank < maxRank then
						button.Rank:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
						button.Slot:SetVertexColor(0.1, 1.0, 0.1)
					else
						button.Slot:SetVertexColor(1.0, 0.82, 0)
						button.Rank:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
					end
					button.RankBorder:Show()
					button.Rank:Show()
				else
					SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65)
					button.Slot:SetVertexColor(0.5, 0.5, 0.5)
					if rank == 0 then
						button.RankBorder:Hide()
						button.Rank:Hide()
					else
						button.RankBorder:SetVertexColor(0.5, 0.5, 0.5)
						button.Rank:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
					end
				end
				button:Show()
			else
				button:Hide()
			end
		else
			button:Hide()
		end
	end

	local node
	local xOffset, yOffset
	local ignoreUp
	local tempNode

	M.TalentUI_ResetBranchTextureCount(self)
	M.TalentUI_ResetArrowTextureCount(self)

	for i = 1, MAX_NUM_TALENT_TIERS do
		for j = 1, NUM_TALENT_COLUMNS do
			node = self.branches[i][j]

			xOffset = ((j - 1) * buttonSpacingX) + initialOffsetX + 2
			yOffset = -((i - 1) * buttonSpacingY) - initialOffsetY - 2

			if node.id then
				if node.up ~= 0 then
					if not ignoreUp then
						M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset + talentButtonSize)
					else
						ignoreUp = nil
					end
				end
				if node.down ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - talentButtonSize + 1)
				end
				if node.left ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset - talentButtonSize, yOffset)
				end
				if node.right ~= 0 then
					tempNode = self.branches[i][j+1]
					if tempNode.left ~= 0 and tempNode.down < 0 then
						M.TalentUI_SetBranchTexture(self, i, j-1, TALENT_BRANCH_TEXTURECOORDS["right"][tempNode.down], xOffset + talentButtonSize, yOffset)
					else
						M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + talentButtonSize + 1, yOffset)
					end
				end

				if node.rightArrow ~= 0 then
					M.TalentUI_SetArrowTexture(self, i, j, TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + talentButtonSize / 2 + 5, yOffset)
				end
				if node.leftArrow ~= 0 then
					M.TalentUI_SetArrowTexture(self, i, j, TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - talentButtonSize / 2 - 5, yOffset)
				end
				if node.topArrow ~= 0 then
					M.TalentUI_SetArrowTexture(self, i, j, TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + talentButtonSize / 2 + 5)
				end
			else
				if node.up ~= 0 and node.left ~= 0 and node.right ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset, yOffset)
				elseif node.down ~= 0 and node.left ~= 0 and node.right ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset, yOffset)
				elseif node.left ~= 0 and node.down ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset, yOffset)
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32)
				elseif node.left ~= 0 and node.up ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset, yOffset)
				elseif node.left ~= 0 and node.right ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + talentButtonSize, yOffset)
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset + 1, yOffset)
				elseif node.right ~= 0 and node.down ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset, yOffset)
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32)
				elseif node.right ~= 0 and node.up ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset, yOffset)
				elseif node.up ~= 0 and node.down ~= 0 then
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset)
					M.TalentUI_SetBranchTexture(self, i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32)
					ignoreUp = 1
				end
			end
		end
	end

	for i = M.TalentUI_GetBranchTextureCount(self), #self.brancheTextures do
		self.brancheTextures[i]:Hide()
	end

	for i = M.TalentUI_GetArrowTextureCount(self), #self.arrowTextures do
		self.arrowTextures[i]:Hide()
	end
end

function M.TalentUI_UpdateActiveSpec(activeTalentGroup)
	activeSpec = DEFAULT_TALENT_SPEC
	for index, spec in next, specs do
		if not spec.pet and spec.talentGroup == activeTalentGroup then
			activeSpec = index
			break
		end
	end
end

function M.TalentUI_UpdateSpecs(activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups)
	local firstShownTab, lastShownTab
	local numShown = 0

	for _, specIndex in ipairs(specsIndex) do
		local frame = specTabs[specIndex]
		local spec = specs[specIndex]
		if M.TalentUI_UpdateSpecTab(frame, activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups) then
			firstShownTab = firstShownTab or frame
			numShown = numShown + 1
			frame:ClearAllPoints()

			if numShown == 1 then
				frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPRIGHT", 2*C.mult, -38)
			else
				if spec.pet ~= specs[lastShownTab.specIndex].pet then
					frame:SetPoint("TOPLEFT", lastShownTab, "BOTTOMLEFT", 0, -39)
				else
					frame:SetPoint("TOPLEFT", lastShownTab, "BOTTOMLEFT", 0, -22)
				end
			end
			lastShownTab = frame
		else
			if specIndex == selectedSpec then
				selectedSpec = nil
			end
		end
	end

	if not selectedSpec then
		if firstShownTab then
			TalentSpecTab_OnClick(firstShownTab)
		end
		return false
	end

	if numShown == 1 and lastShownTab then
		--lastShownTab:Hide()
	end

	return true
end

function M.TalentUI_UpdateControls()
	local spec = selectedSpec and specs[selectedSpec]
	local isActiveSpec = selectedSpec == activeSpec
	local preview = GetCVarBool("previewTalents")

	local talentPoints = GetUnspentTalentPoints(false, spec.pet, spec.talentGroup)
	if (spec.pet or isActiveSpec) and talentPoints > 0 then
		if preview then
			M.TalentUI.PreviewBar:Show()
			M.TalentUI.PreviewButton:Hide()
			if GetGroupPreviewTalentPointsSpent(spec.pet, spec.talentGroup) > 0 then
				M.TalentUI.Learn:Enable()
				M.TalentUI.Reset:Enable()
			else
				M.TalentUI.Learn:Disable()
				M.TalentUI.Reset:Disable()
			end
		else
			M.TalentUI.PreviewBar:Hide()
			M.TalentUI.PreviewButton:Show()
		end
	else
		M.TalentUI.PreviewBar:Hide()
		M.TalentUI.PreviewButton:Hide()
	end
end

function M.TalentUI_UpdatePlayer()
	local activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, false), GetNumTalentGroups(false, false)
	local activePetTalentGroup, numPetTalentGroups = GetActiveTalentGroup(false, true), GetNumTalentGroups(false, true)

	if not M.TalentUI_UpdateSpecs(activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups) then
		return
	end

	M.TalentUI_UpdateActiveSpec(activeTalentGroup)
	M.TalentUI_UpdateControls()
end

function M:TalentUI_UpdateVisibility()
	local frame = M.TalentUI
	if frame.pet then
		frame:SetSize(frame.petWidth, frame.petHeight)
		frame.Points:ClearAllPoints()
		frame.Points:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 8)
		if M.GlyphUI:IsShown() then M.GlyphUI:Hide() end
	else
		frame:SetSize(frame.playerWidth, frame.playerHeight)
		frame.Points:ClearAllPoints()
		frame.Points:SetPoint("BOTTOM", frame, "BOTTOM", 0, 8)
	end

	for i = 1, 3 do
		frame.panels[i]:SetShown(not frame.pet)
	end
	frame.panels[4]:SetShown(frame.pet)
	frame.ContainerBar:SetShown(not frame.pet)
end

function M:TalentUI_Refresh()
	if not M.TalentUI or not M.TalentUI:IsShown() then return end

	M.TalentUI_UpdatePlayer()
	M:TalentUI_UpdateVisibility()

	if M.TalentUI.pet then
		M.TalentUI_Update(M.TalentUI.panels[4])
	else
		for i = 1, 3 do
			M.TalentUI_Update(M.TalentUI.panels[i])
		end
	end

	if M.GlyphUI:IsShown() then
		M:GlyphUI_Update()
	end
end

function M.TalentUI_PreUpdate(event)
	if event == "PREVIEW_TALENT_POINTS_CHANGED" then
		if selectedSpec and not specs[selectedSpec].pet then
			M:TalentUI_Refresh()
		end
	elseif event == "PREVIEW_PET_TALENT_POINTS_CHANGED" then
		if selectedSpec and specs[selectedSpec].pet then
			M:TalentUI_Refresh()
		end
	end
end

function M:TalentUI_UpdatePet(summoner)
	if summoner == "player" then
		if selectedSpec and specs[selectedSpec].pet then
			local numTalentGroups = GetNumTalentGroups(false, true)
			if numTalentGroups == 0 then
				TalentSpecTab_OnClick(activeSpec and specTabs[activeSpec] or specTabs[DEFAULT_TALENT_SPEC])
				return
			end
		end
		M:TalentUI_Refresh()
	end
end

function M:TalentUI_UpdatePortrait(unit)
	for _, frame in next, specTabs do
		if frame.usingPortraitTexture then
			local spec = specs[frame.specIndex]
			if unit == spec.unit and spec.portraitUnit then
				SetPortraitTexture(frame:GetNormalTexture(), unit)
			end
		end
	end
end

function M:TalentUI_Toggle(expand)
	if not IsAddOnLoaded("Blizzard_TalentUI") then TalentFrame_LoadUI() end

	if expand then
		M.TalentUI:Show()
		HideUIPanel(PlayerTalentFrame)
	else
		M.TalentUI:Hide()
		ShowUIPanel(PlayerTalentFrame)
	end

	M.db["TalentExpand"] = expand
end

function M:TalentUI_Init()
	local frame = CreateFrame("Frame", "NDuiPlusTalentFrame", UIParent)
	tinsert(UISpecialFrames, "NDuiPlusTalentFrame")
	frame.playerWidth = (initialOffsetX * 2 + TALENT_COLUMNS_WRATH * buttonSpacingX - 26)* 3 + 34
	frame.playerHeight = initialOffsetY * 2 + TALENT_TIERS_WRATH * buttonSpacingX - 26 + 68
	frame.petWidth = (initialOffsetX * 2 + TALENT_COLUMNS_WRATH * buttonSpacingX - 26)* 1 + 34 + petOffsetX
	frame.petHeight = initialOffsetY * 2 + TALENT_TIERS_PET_WRATH * buttonSpacingX - 26 + 68 + petOffsetY
	frame:SetSize(frame.playerWidth, frame.playerHeight)
	frame:SetPoint("CENTER")
	frame:SetFrameLevel(10)
	B.SetBD(frame)
	B.CreateMF(frame)
	frame:Hide()
	frame:SetScript("OnShow", function()
		PlaySound(SOUNDKIT.TALENT_SCREEN_OPEN)
		TalentSpecTab_OnClick(activeSpec and specTabs[activeSpec] or specTabs[DEFAULT_TALENT_SPEC])
	end)
	frame:SetScript("OnHide", function()
		PlaySound(SOUNDKIT.TALENT_SCREEN_CLOSE)
		for _, info in next, talentSpecInfoCache do
			wipe(info)
		end
	end)

	local Close = CreateFrame("Button", nil, frame)
	B.ReskinClose(Close)
	Close:SetScript("OnClick", function()
		frame:Hide()
	end)
	frame.Close = Close

	local Expand = CreateFrame("Button", nil, frame)
	Expand:SetPoint("RIGHT", Close, "LEFT", -3, 0)
	B.ReskinArrow(Expand, "down")
	Expand:SetScript("OnClick", function()
		M:TalentUI_Toggle(false)
	end)
	frame.Expand = Expand

	local Points = frame:CreateFontString(nil, "OVERLAY")
	Points:SetFont(DB.Font[1], 16, DB.Font[3])
	Points:SetTextColor(1, .8, 0)
	Points:SetPoint("BOTTOM", frame, "BOTTOM", 0, 8)
	frame.Points = Points

	frame.panels = {}
	for i = 1, 4 do
		frame.panels[i] = M.TalentUI_CreatePanel(frame, i)
		if i == 1 or i == 4 then
			frame.panels[i]:SetPoint("TOPLEFT", 16, -36)
		else
			frame.panels[i]:SetPoint("TOPLEFT", frame.panels[i-1], "TOPRIGHT", C.mult, 0)
		end
	end

	frame.tabs = {}
	for i, spec in ipairs(specsIndex) do
		frame.tabs[i] = M.TalentUI_CreateSpecTab(frame, i, spec)
	end

	local PreviewButton = P.CreateButton(frame, 80, 20, PREVIEW)
	PreviewButton:SetPoint("BOTTOMRIGHT", -16, 6)
	PreviewButton:SetScript("OnClick", function()
		SetCVar("previewTalents", 1)
		M.TalentUI_UpdateControls()
	end)
	P.AddTooltip(PreviewButton, "ANCHOR_RIGHT", OPTION_PREVIEW_TALENT_CHANGES_DESCRIPTION, "info")
	frame.PreviewButton = PreviewButton

	local PreviewBar = CreateFrame("Frame", nil, frame)
	PreviewBar:SetSize(200, 32)
	PreviewBar:SetPoint("BOTTOMRIGHT")
	frame.PreviewBar = PreviewBar

	local Reset = P.CreateButton(PreviewBar, 70, 20, RESET)
	Reset:SetPoint("BOTTOMRIGHT", -16, 6)
	Reset:SetScript("OnClick", function()
		ResetGroupPreviewTalentPoints(M.TalentUI.pet, M.TalentUI.talentGroup)
	end)
	P.AddTooltip(Reset, "ANCHOR_RIGHT", TALENT_TOOLTIP_RESETTALENTGROUP, "info")
	frame.Reset = Reset

	local Learn = P.CreateButton(PreviewBar, 70, 20, LEARN)
	Learn:SetPoint("RIGHT", Reset, "LEFT", -4, 0)
	Learn:SetScript("OnClick", function()
		StaticPopup_Show("NDUIPLUS_CONFIRM_LEARN_PREVIEW_TALENTS")
	end)
	P.AddTooltip(Learn, "ANCHOR_RIGHT", TALENT_TOOLTIP_LEARNTALENTGROUP, "info")
	frame.Learn = Learn

	local ContainerBar = CreateFrame("Frame", nil, frame)
	ContainerBar:SetSize(200, 32)
	ContainerBar:SetPoint("BOTTOMLEFT")
	frame.ContainerBar = ContainerBar

	local Glyph = P.CreateButton(ContainerBar, 70, 20, GLYPHS)
	Glyph:SetPoint("BOTTOMLEFT", 16, 6)
	Glyph:SetScript("OnClick", function()
		if M.GlyphUI then
			B:TogglePanel(M.GlyphUI)
		end
	end)
	frame.Glyph = Glyph

	frame.unit = "player"
	frame.pet = false
	frame.talentGroup = 1

	local activeTalentGroup = GetActiveTalentGroup()
	M.TalentUI_UpdateActiveSpec(activeTalentGroup)

	M.TalentUI = frame

	local alaEmu = _G.__ala_meta__ and _G.__ala_meta__.emu
	if alaEmu and alaEmu.MT then
		local CalcButton = P.CreateButton(ContainerBar, 70, 20, L["TalentEmu"])
		CalcButton:SetPoint("LEFT", Glyph, "RIGHT", 4, 0)
		CalcButton:SetScript("OnClick", function() alaEmu.MT.CreateEmulator() end)
		frame.CalcButton = CalcButton
	end
end

function M.TalentUI_Wipe(_, arg1, arg2)
	HideUIPanel(GossipFrame)
	StaticPopupDialogs["CONFIRM_TALENT_WIPE"].text = _G["CONFIRM_TALENT_WIPE_"..arg2]
	local dialog = StaticPopup_Show("CONFIRM_TALENT_WIPE")
	if dialog then
		MoneyFrame_Update(dialog:GetName().."MoneyFrame", arg1)
		M.TalentUI:Show()
		local talentGroup = GetActiveTalentGroup()
		for index, spec in next, specs do
			if spec.pet == false and spec.talentGroup == talentGroup then
				TalentSpecTab_OnClick(specTabs[index])
				break
			end
		end
	end
end

function M:TalentUI_Load()
	P:Delay(.5,function()
		for i = 1, MAX_NUM_TALENTS do
			local talent = _G["PlayerTalentFrameTalent"..i]
			if talent then
				local hl = talent:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
			end
		end
	end)

	if M.db["ExtTalentUI"] then
		local bu = CreateFrame("Button", nil, PlayerTalentFrame)
		bu:SetPoint("RIGHT", PlayerTalentFrameCloseButton, "LEFT", -3, 0)
		B.ReskinArrow(bu, "right")
		bu:SetScript("OnClick", function()
			M:TalentUI_Toggle(true)
		end)
	end
end
P:AddCallbackForAddon("Blizzard_TalentUI", M.TalentUI_Load)

function M:ExtTalentUI()
	if not M.db["ExtTalentUI"] then return end

	_G.ToggleTalentFrame = function()
		if M.db["TalentExpand"] then
			B:TogglePanel(M.TalentUI)
		else
			if not IsAddOnLoaded("Blizzard_TalentUI") then TalentFrame_LoadUI() end
			if not IsAddOnLoaded("Blizzard_GlyphUI") then GlyphFrame_LoadUI() end

			if PlayerTalentFrame:IsShown() then
				HideUIPanel(PlayerTalentFrame)
			else
				ShowUIPanel(PlayerTalentFrame)
			end
		end
	end

	M:TalentUI_Init()
	M:GlyphUI_Init()
	_G.UIParent:UnregisterEvent("CONFIRM_TALENT_WIPE")
	B:RegisterEvent("CONFIRM_TALENT_WIPE", M.TalentUI_Wipe)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", M.TalentUI_Refresh)
	B:RegisterEvent("PET_TALENT_UPDATE", M.TalentUI_Refresh)
	B:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED", M.TalentUI_PreUpdate)
	B:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED", M.TalentUI_PreUpdate)
	B:RegisterEvent("UNIT_PET", M.TalentUI_UpdatePet)
	B:RegisterEvent("UNIT_PORTRAIT_UPDATE", M.TalentUI_UpdatePortrait)
	B:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", function() PlaySound(SOUNDKIT.GLYPH_MAJOR_CREATE) end)
end

M:RegisterMisc("ExtTalentUI", M.ExtTalentUI)