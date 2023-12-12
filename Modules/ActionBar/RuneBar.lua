local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local margin, padding = C.Bars.margin, C.Bars.padding

AB.RuneSlotButtons = {}

function AB:RuneButton_Update(info)
	self.icon:SetTexture(info.iconTexture)
	self.skillLineAbilityID = info.skillLineAbilityID
	self.slotID = info.equipmentSlot
end

local function buttonOnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	if self.skillLineAbilityID then
		GameTooltip:SetEngravingRune(self.skillLineAbilityID)
	elseif self.name then
		GameTooltip:AddLine(self.name)
	end
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

function AB:RuneBar_CreateButton(name, parent)
	local button = CreateFrame("Button", name, parent, "ActionButtonTemplate")
	button:SetHitRectInsets(-margin / 2, -margin / 2, -margin / 2, -margin / 2)
	button:RegisterForClicks("AnyUp")
	AB:StyleActionButton(button, AB.BarConfig)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", buttonOnLeave)

	return button
end

local function ClearTimers(object)
	if object.delayTimer then
		P:CancelTimer(object.delayTimer)
		object.delayTimer = nil
	end
end

function AB:RuneButton_OnEnter()
	ClearTimers(self.popupBar)
	self.popupBar:Show()
end

function AB:RuneButton_OnLeave()
	ClearTimers(self.popupBar)
	self.popupBar.delayTimer = P:ScheduleTimer(self.popupBar.Hide, .5, self.popupBar)
end

function AB:RuneButton_OnClick()
	if InCombatLockdown() then P:Error(ERR_NOT_IN_COMBAT) return end

	if self.skillLineAbilityID then
		C_Engraving.CastRune(self.skillLineAbilityID)
		PickupInventoryItem(self.slotID)
		ClearCursor()
		local _, dialog = StaticPopup_Visible("REPLACE_ENCHANT")
		if dialog then
			dialog.button1:Click()
		end
	end

	self.popupBar:Hide()
end

function AB:RuneBar_Update()
	C_Engraving.RefreshRunesList()
	local categories = C_Engraving.GetRuneCategories(false, true)
	for _, category in ipairs(categories) do
		local buttonName = "NDuiPlus_RuneBarSlot" .. category
		local slot = _G[buttonName]
		if not slot then
			slot = AB:RuneBar_CreateButton(buttonName, AB.RuneBar)
			slot:HookScript("OnEnter", AB.RuneButton_OnEnter)
			slot:HookScript("OnLeave", AB.RuneButton_OnLeave)
			slot.name = GetItemInventorySlotInfo(category)
			slot.popupList = {}

			slot.popupBar = CreateFrame("Frame", buttonName .. "PopupBar", slot)
			slot.popupBar:SetFrameStrata("DIALOG")
			slot.popupBar:Hide()

			AB.RuneSlotButtons[category] = slot
		end

		local equippedInfo = C_Engraving.GetRuneForEquipmentSlot(category)
		if equippedInfo then
			AB.RuneButton_Update(slot, equippedInfo)
		else
			slot.icon:SetTexture(nil)
			slot.skillLineAbilityID = nil
		end

		local index = 1
		local prevButton
		local runes = C_Engraving.GetRunesForCategory(category, true)
		for _, info in ipairs(runes) do
			if info.skillLineAbilityID ~= slot.skillLineAbilityID then
				local button = slot.popupList[index]
				if not button then
					button = AB:RuneBar_CreateButton(buttonName .. "Button" .. index, slot.popupBar)
					button.popupBar = slot.popupBar
					button:HookScript("OnEnter", AB.RuneButton_OnEnter)
					button:HookScript("OnLeave", AB.RuneButton_OnLeave)
					button:HookScript("OnClick", AB.RuneButton_OnClick)
					slot.popupList[index] = button
				end
				AB.RuneButton_Update(button, info)
				button:ClearAllPoints()
				button:Show()

				if AB.db["RuneBarVertical"] then
					if not prevButton then
						button:SetPoint("RIGHT", -margin, 0)
					else
						button:SetPoint("RIGHT", prevButton, "LEFT", -margin, 0)
					end
				else
					if not prevButton then
						button:SetPoint("BOTTOM", 0, margin)
					else
						button:SetPoint("BOTTOM", prevButton, "TOP", 0, margin)
					end
				end

				prevButton = button
				index = index + 1
			end
		end

		for i = index, #slot.popupList do
			slot.popupList[i]:Hide()
		end


		local size = AB.db["RuneBarSize"]
		local num = index - 1
		local width, height = num * size + (num + 1) * margin, size + 2 * margin

		slot.popupBar:ClearAllPoints()
		if AB.db["RuneBarVertical"] then
			slot.popupBar:SetSize(width, height)
			slot.popupBar:SetPoint("RIGHT", slot, "LEFT")
		else
			slot.popupBar:SetSize(height, width)
			slot.popupBar:SetPoint("BOTTOM", slot, "TOP")
		end
	end

	local prevButton
	for _, category in ipairs(categories) do
		local button = AB.RuneSlotButtons[category]
		button:ClearAllPoints()
		if not prevButton then
			button:SetPoint("TOPLEFT", padding, -padding)
		else
			if AB.db["RuneBarVertical"] then
				button:SetPoint("TOP", prevButton, "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", prevButton, "RIGHT", margin, 0)
			end
		end

		prevButton = button
	end

	AB.RuneBar_NumSlots = #categories
	AB:RuneBar_UpdateSize()
end

function AB:RuneBar_UpdateSize()
	if not AB.RuneBar then return end

	local size = AB.db["RuneBarSize"]
	local num = AB.RuneBar_NumSlots or 1
	local width, height = num * size + (num - 1) * margin + 2 * padding, size + 2 * padding

	if AB.db["RuneBarVertical"] then
		AB.RuneBar:SetSize(height, width)
		AB.RuneBar.mover:SetSize(height, width)
	else
		AB.RuneBar:SetSize(width, height)
		AB.RuneBar.mover:SetSize(width, height)
	end

	for _, slot in pairs(AB.RuneSlotButtons) do
		slot:SetSize(size, size)
		for _, button in ipairs(slot.popupList) do
			button:SetSize(size, size)
		end
	end
end

function AB:RuneBar_OnEquipmentChanged(slotID)
	if C_Engraving.IsEquipmentSlotEngravable(slotID) then
		AB:RuneBar_Update()
	end
end

function AB:RuneBar_Toggle()
	if not AB.RuneBar then return end

	if AB.db["RuneBar"] then
		AB:RuneBar_Update()
		B:RegisterEvent("NEW_RECIPE_LEARNED", AB.RuneBar_Update)
		B:RegisterEvent("RUNE_UPDATED", AB.RuneBar_Update)
		B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", AB.RuneBar_OnEquipmentChanged)
		AB.RuneBar:Show()
	else
		B:UnregisterEvent("NEW_RECIPE_LEARNED", AB.RuneBar_Update)
		B:UnregisterEvent("RUNE_UPDATED", AB.RuneBar_Update)
		B:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", AB.RuneBar_OnEquipmentChanged)
		AB.RuneBar:Hide()
	end
end

function AB:RuneBar()
	AB.RuneBar = CreateFrame("Frame", "NDuiPlus_RuneBar", UIParent)
	AB.RuneBar.mover = B.Mover(AB.RuneBar, L["RuneBar"], "RuneBar", { "BOTTOMRIGHT", -480, 24 })
	AB:RuneBar_Toggle()
end