local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local ipairs, tinsert, tremove, sort  = ipairs, table.insert, table.remove, table.sort
local CooldownFrame_Set = CooldownFrame_Set
local GetMouseFocus = GetMouseFocus
local GetSpellInfo, GetSpellCount, GetSpellCooldown, IsUsableSpell = GetSpellInfo, GetSpellCount, GetSpellCooldown, IsUsableSpell

local margin, padding = C.Bars.margin, C.Bars.padding

local mageSpellData = {
	[1] = {
		name = "Teleport",
		spell = {3561, 3562, 3567, 3563, 3565, 3566, 32271, 32272, 49359, 49358, 33690, 35715, 53140}
	},
	[2] = {
		name = "Portal",
		spell = {10059, 11416, 11417, 11418, 11419, 11420, 32266, 32267, 49360, 49361, 33691, 35717, 53142}
	},
	[3] = {
		name = "Food",
		spell = {587, 597, 990, 6129, 10144, 10145, 28612, 33717, 42955, 42956}
	},
	[4] = {
		name = "Water",
		spell = {5504, 5505, 5506, 6127, 10138, 10139, 10140, 37420, 27090, 42955, 42956}
	},
	[5] = {
		name = "Gem",
		spell = {759, 3552, 10053, 10054, 27101, 42985}
	}
}

local mageButtons = {}
local mainButtons = {}

local PopupHandler = CreateFrame("Frame", "NDuiPlus_MageBarHandler", UIParent, "SecureHandlerBaseTemplate")
PopupHandler:Hide()
PopupHandler:Execute([=[
	PopupHandler = self
	BAR_MAP = newtable()
]=])

function AB:MageButton_UpdateSize()
	local size = AB.db["MageBarSize"]
	local scale = size/34

	self:SetSize(size, size)
	self.Name:SetScale(scale)
	self.Count:SetScale(scale)
	self.HotKey:SetScale(scale)
	self.FlyoutArrow:SetScale(scale)
end

function AB:MageButton_UpdateSpell(spellID)
	local texture = GetSpellTexture(spellID)
	self.icon:SetTexture(texture)
	self:SetAttribute("type", "spell")
	self.spellID = spellID

	local spell = Spell:CreateFromSpellID(spellID)
	spell:ContinueOnSpellLoad(function()
		local name = spell:GetSpellName()
		local rank = spell:GetSpellSubtext()
		if rank and strlen(rank) > 0 then
			name = name.."("..rank..")"
		end
		self:SetAttribute("spell", name)
	end)

	AB.MageButton_UpdateCount(self)
	AB.MageButton_UpdateUsable(self)
end

function AB:MageButton_UpdateCount()
	local count = GetSpellCount(self.spellID)
	if count and count > 0 then
		self.Count:SetText(count)
	else
		self.Count:SetText("")
	end
end

function AB:MageButton_UpdateCooldown()
	local start, duration, enabled = GetSpellCooldown(self.spellID)
	if (start and duration and enabled and start > 0 and duration > 0) then
		CooldownFrame_Set(self.cooldown, start, duration, enabled)
		self.cooldown:SetSwipeColor(0, 0, 0);
	else
		CooldownFrame_Set(self.cooldown, 0, 0, 0)
	end

	AB.MageButton_UpdateCount(self)
end

function AB:MageButton_UpdateUsable()
	local isUsable, notEnoughMana = IsUsableSpell(self.spellID)
	if isUsable then
		self.icon:SetVertexColor(1.0, 1.0, 1.0)
	elseif notEnoughMana then
		self.icon:SetVertexColor(0.5, 0.5, 1.0)
	else
		self.icon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function AB:MageButton_UpdateFlyout()
	if not self.FlyoutArrow then return end

	local arrowDistance
	if GetMouseFocus() == self then
		self.FlyoutBorder:Show()
		self.FlyoutBorderShadow:Show()
		arrowDistance = 5
	else
		self.FlyoutBorder:Hide()
		self.FlyoutBorderShadow:Hide()
		arrowDistance = 2
	end

	self.FlyoutArrow:Show()
	self.FlyoutArrow:ClearAllPoints()

	local vertical = AB.db["MageBarVertical"]
	if vertical then
		self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
		SetClampedTextureRotation(self.FlyoutArrow, 270)
	else
		self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance)
		SetClampedTextureRotation(self.FlyoutArrow, 0)
	end
end

function AB:MageBar_UpdateCooldown()
	for _, button in ipairs(mageButtons) do
		AB.MageButton_UpdateCooldown(button)
	end
end

local lastTime = 0
function AB:MageBar_UpdateUsable()
	local thisTime = GetTime()
	if thisTime - lastTime > .5 then
		for _, button in ipairs(mageButtons) do
			AB.MageButton_UpdateUsable(button)
		end

		lastTime = thisTime
	end
end

local function buttonOnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetSpellByID(self.spellID)
	GameTooltip:Show()

	if AB.fadeParent then
		AB.Button_OnEnter(self)
	end
end

local function buttonOnLeave(self)
	GameTooltip:Hide()

	if AB.fadeParent then
		AB.Button_OnLeave(self)
	end
end

function AB:CreateMageButton(name, parent, spellID)
	local button = CreateFrame("Button", name, parent, "ActionButtonTemplate, SecureActionButtonTemplate")
	button:SetHitRectInsets(-margin/2, -margin/2, -margin/2, -margin/2)
	button:RegisterForClicks("AnyUp")
	AB:StyleActionButton(button, AB.BarConfig)

	AB.MageButton_UpdateSpell(button, spellID)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", buttonOnLeave)

	tinsert(mageButtons, button)

	return button
end

function AB:CreateMainButton(info)
	local index = info.index
	local buttonName = "NDuiPlus_MageBarButton"..index
	local button = _G[buttonName]
	if not button then
		button = AB:CreateMageButton(buttonName, AB.MageBar, info.mainSpell)
		button:HookScript("OnEnter", AB.MageButton_UpdateFlyout)
		button:HookScript("OnLeave", AB.MageButton_UpdateFlyout)
		button.popupButtonList = {}

		tinsert(mainButtons, {button, index})
	else
		button:Show()
		AB.MageButton_UpdateSpell(button, info.mainSpell)
	end

	button.Category = info.name
	AB.MageButton_UpdateFlyout(button)

	local popupBar = button.popupBar
	if not popupBar then
		popupBar = CreateFrame("Frame", buttonName.."PopupBar", button, "SecureHandlerBaseTemplate")
		popupBar:SetFrameStrata("DIALOG")
		popupBar:Raise()
		popupBar:Hide()

		PopupHandler:SetFrameRef("popupBar", popupBar)
		PopupHandler:SetFrameRef("mainButton", button)
		PopupHandler:Execute([=[
			local bar = PopupHandler:GetFrameRef("popupBar")
			local button = PopupHandler:GetFrameRef("mainButton")

			BAR_MAP[button] = bar
		]=])
		PopupHandler:WrapScript(button, "OnEnter", [=[
			BAR_MAP[self]:Show()
		]=])
		PopupHandler:WrapScript(button, "OnLeave", [=[
			BAR_MAP[self]:Hide()
		]=])
		PopupHandler:WrapScript(button, "OnClick", [=[
			BAR_MAP[self]:Hide()
		]=])

		button.popupBar = popupBar
	end

	local vertical = AB.db["MageBarVertical"]

	local prevButton
	for i, spellID in ipairs(info.subSpell) do
		local popupButton =  button.popupButtonList[i]
		if not popupButton then
			popupButton = AB:CreateMageButton(buttonName.."Popup"..i, popupBar, spellID)

			PopupHandler:SetFrameRef("popupButton", popupButton)
			PopupHandler:Execute([=[
				local bar = PopupHandler:GetFrameRef("popupBar")
				local button = PopupHandler:GetFrameRef("popupButton")

				BAR_MAP[button] = bar
			]=])
			PopupHandler:WrapScript(popupButton, "OnClick", [=[
				BAR_MAP[self]:Hide()
			]=])
			PopupHandler:WrapScript(popupButton, "OnEnter", [=[
				local popupBar = BAR_MAP[self]
				if popupBar and not popupBar:IsVisible() then 
					popupBar:Show()
					popupBar:UnregisterAutoHide()
					popupBar:RegisterAutoHide(.25)
					popupBar:AddToAutoHide(self)
				end
			]=])

			button.popupButtonList[i] = popupButton
		else
			AB.MageButton_UpdateSpell(popupButton, spellID)
		end

		popupButton:ClearAllPoints()
		if vertical then
			if not prevButton then
				popupButton:SetPoint("RIGHT", -margin, 0)
			else
				popupButton:SetPoint("RIGHT", prevButton, "LEFT", -margin, 0)
			end
		else
			if not prevButton then
				popupButton:SetPoint("BOTTOM", 0, margin)
			else
				popupButton:SetPoint("BOTTOM", prevButton, "TOP", 0, margin)
			end
		end

		prevButton = popupButton
	end

	local size = AB.db["MageBarSize"]
	local num = #button.popupButtonList
	local width, height = num*size + (num+1)*margin, size + 2*margin

	popupBar:ClearAllPoints()
	if vertical then
		popupBar:SetSize(width, height)
		popupBar:SetPoint("RIGHT", button, "LEFT")
	else
		popupBar:SetSize(height, width)
		popupBar:SetPoint("BOTTOM", button, "TOP")
	end
end

local spellList = {}
function AB:MageBar_Update()
	if not AB.MageBar then return end

	wipe(spellList)

	for _, value in ipairs(mainButtons) do
		value[1]:ClearAllPoints()
		value[1]:Hide()
	end

	local node
	for index, info in ipairs(mageSpellData) do
		if AB.db["MageBar"..info.name] then
			node = {name = info.name, index = index, subSpell = {}}

			for _, spellID in ipairs(info.spell) do
				if IsPlayerSpell(spellID) then
					tinsert(node.subSpell, spellID)
					node.mainSpell = spellID
				end
			end

			tinsert(spellList, node)
		end
	end

	for _, info in ipairs(spellList) do
		if info.mainSpell then
			tremove(info.subSpell)
			AB:CreateMainButton(info)
		end
	end

	sort(mainButtons, function(a, b)
		if a and b then
			return a[2] < b[2]
		end
	end)

	local num = 0
	local prevButton
	for _, value in ipairs(mainButtons) do
		local button = value[1]
		if button:IsShown() then
			if not prevButton then
				button:SetPoint("TOPLEFT", padding, -padding)
			else
				if AB.db["MageBarVertical"] then
					button:SetPoint("TOP", prevButton, "BOTTOM", 0, -margin)
				else
					button:SetPoint("LEFT", prevButton, "RIGHT", margin, 0)
				end
			end

			num = num + 1
			prevButton = button
		end
	end

	AB.NumMageButons = num
	AB:MageBar_UpdateSize()
end

function AB:MageBar_UpdateSize()
	if not AB.MageBar then return end

	local size = AB.db["MageBarSize"]
	local num = AB.NumMageButons or 1
	local width, height = num*size + (num-1)*margin + 2*padding, size + 2*padding

	if AB.db["MageBarVertical"] then
		AB.MageBar:SetSize(height, width)
		AB.MageBar.mover:SetSize(height, width)
	else
		AB.MageBar:SetSize(width, height)
		AB.MageBar.mover:SetSize(width, height)
	end

	for _, button in ipairs(mageButtons) do
		AB.MageButton_UpdateSize(button)
	end
end

function AB:MageBar_Toggle()
	if not AB.MageBar then return end

	if AB.db["MageBar"] then
		AB:MageBar_Update()
		B:RegisterEvent("LEARNED_SPELL_IN_TAB", AB.MageBar_Update)
		B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", AB.MageBar_UpdateCooldown)
		B:RegisterEvent("BAG_UPDATE_DELAYED", AB.MageBar_UpdateCooldown)
		B:RegisterEvent("SPELL_UPDATE_USABLE", AB.MageBar_UpdateUsable)
		B:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", AB.MageBar_UpdateUsable)
		AB.MageBar:Show()
	else
		B:UnregisterEvent("LEARNED_SPELL_IN_TAB", AB.MageBar_Update)
		B:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN", AB.MageBar_UpdateCooldown)
		B:UnregisterEvent("BAG_UPDATE_DELAYED", AB.MageBar_UpdateCooldown)
		B:UnregisterEvent("SPELL_UPDATE_USABLE", AB.MageBar_UpdateUsable)
		B:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS", AB.MageBar_UpdateUsable)
		AB.MageBar:Hide()
	end
end

function AB:MageBar_Init()
	if DB.MyClass ~= "MAGE" then return end

	AB.MageBar = CreateFrame("Frame", "NDuiPlus_MageBar", UIParent)
	AB.MageBar.mover = B.Mover(AB.MageBar, L["MageBar"], "MageBar", {"BOTTOMRIGHT", -480, 24})
	AB:MageBar_Toggle()
end