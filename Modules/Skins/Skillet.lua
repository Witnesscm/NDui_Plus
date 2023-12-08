local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local cr, cg, cb = DB.r, DB.g, DB.b

local function reskinDropDown(self)
	P.ReskinDropDown(self)
	self:SetWidth(165)
end

local function reskinIcon(bu)
	bu:SetNormalTexture(135349)
	local icon = bu:GetNormalTexture()
	B.ReskinIcon(icon)
end

local function reskinTradeButton(bu)
	bu:SetHighlightTexture(DB.bdTex)
	bu:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	bu:GetHighlightTexture():SetInside()

	if bu.SetPushedTexture then bu:SetPushedTexture(0) end
	if bu.SetCheckedTexture then bu:SetCheckedTexture(DB.pushedTex) end

	local icon = _G[bu:GetName().."Icon"]
	icon:SetInside()
	B.ReskinIcon(icon)
end

function S:SkilletClassic()
	if not S.db["Skillet"] then return end

	local Buttons = {
		"SkilletPluginButton",
		"SkilletRecipeNotesButton",
		"SkilletQueueManagementButton",
		"SkilletIgnoredMatsButton",
		"SkilletAuctionatorButton",
		"SkilletQueueAllButton",
		"SkilletEnchantButton",
		"SkilletCreateAllButton",
		"SkilletQueueButton",
		"SkilletCreateButton",
		"SkilletStartQueueButton",
		"SkilletEmptyQueueButton",
		"SkilletShoppingListButton",
		"SkilletQueueOnlyButton",
		"SkilletQueueLoadButton",
		"SkilletQueueDeleteButton",
		"SkilletQueueSaveButton",
		"SkilletMerchantBuyFrameButton",
		"SkilletIgnoreListButton",
	}

	local Parents = {
		"SkilletSkillListParent",
		"SkilletReagentParent",
		"SkilletQueueManagementParent",
		"SkilletQueueParent",
		"SkilletIgnoreListParent",
		"SkilletShoppingListParent",
	}

	local Frames = {
		"SkilletFrame",
		"SkilletIgnoreList",
		"SkilletShoppingList",
		"SkilletStandaloneQueue",
	}

	local ScrollFrames = {
		"SkilletSkillList",
		"SkilletViewCraftersScrollFrame",
		"SkilletQueueList",
		"SkilletIgnoreListList",
		"SkilletNotesList",
		"SkilletQueueOnlyButton",
	}

	local FilterButtons = {
		"SkilletExpandAllButton",
		"SkilletCollapseAllButton",
		"SkilletRecipeDifficultyButton",
		"SkilletHideUncraftableRecipes",
		"SkilletInventoryFilterOwned",
		"SkilletInventoryFilterBag",
		"SkilletInventoryFilterCraft",
		"SkilletInventoryFilterVendor",
		"SkilletInventoryFilterAlts",
	}

	local function reskinFunc()
		for _, v in pairs(Buttons) do
			local bu = _G[v]
			if bu then
				B.Reskin(bu)
			end
		end

		for _, v in pairs(Parents) do
			local frame = _G[v]
			if frame then
				P.SetupBackdrop(frame)
				frame.SetBackdrop = B.Dummy
				B.StripTextures(frame)
				local bg = B.CreateBDFrame(frame, .25)
				bg:SetInside()
			end
		end

		for _, v in pairs(Frames) do
			local frame = _G[v]
			if frame then
				P.SetupBackdrop(frame)
				frame.SetBackdrop = B.Dummy
				P.ReskinFrame(frame)
				frame:DisableDrawLayer("BACKGROUND")
			end
		end

		for _, v in pairs(ScrollFrames) do
			local scrollBar = _G[v.."ScrollBar"]
			if scrollBar then
				B.ReskinScroll(scrollBar)
			end
		end

		for _, v in pairs(FilterButtons) do
			local bu = _G[v]
			if bu then
				B.ReskinIcon(bu:GetNormalTexture())
				bu:SetHighlightTexture(DB.bdTex)
				local hl = bu:GetHighlightTexture()
				hl:SetVertexColor(cr, cg, cb, .25)
				hl:SetAllPoints()

				if bu.SetCheckedTexture then
					bu:SetCheckedTexture(DB.pushedTex)
				end
			end
		end

		local option = SkilletShowOptionsButton
		B.Reskin(option)
		option:SetSize(16,16)
		option:SetPoint("RIGHT", SkilletFrameCloseButton,"LEFT", -2, 0)
		option.text = B.CreateFS(option, 14, "?")

		reskinDropDown(SkilletRecipeGroupDropdown)
		reskinDropDown(SkilletSortDropdown)
		reskinDropDown(SkilletFilterDropdown)

		B.ReskinArrow(SkilletRecipeGroupOperations, "right")
		SkilletRecipeGroupOperations:SetPoint("LEFT", SkilletRecipeGroupDropdownButton, "RIGHT", 2, 0)

		B.ReskinInput(SkilletSearchBox)
		SkilletSearchBox.bg:SetPoint("TOPLEFT", -8, 0)
		SkilletSearchBox.bg:SetPoint("BOTTOMRIGHT", -1, 1)
		--B.ReskinClose(SkilletSearchClear, "LEFT", SkilletSearchBox, "RIGHT", 0, 0)

		B.ReskinArrow(SkilletSortAscButton, "up")
		SkilletSortAscButton:SetPoint("LEFT", SkilletSortDropdownButton, "RIGHT", 2, 0)
		B.ReskinArrow(SkilletSortDescButton, "down")
		SkilletSortDescButton:SetPoint("LEFT", SkilletSortDropdownButton, "RIGHT", 2, 0)

		B.StripTextures(SkilletRankFrame)
		SkilletRankFrame:SetStatusBarTexture(DB.bdTex)
		B.CreateBDFrame(SkilletRankFrame, .25)
		B.ReskinArrow(SkilletPreviousItemButton, "left")

		B.ReskinInput(SkilletItemCountInputBox)
		--B.ReskinClose(SkilletClearNumButton, "LEFT", SkilletItemCountInputBox, "RIGHT", 2, 0)
		P.ReskinDropDown(SkilletQueueLoadDropdown)
		SkilletQueueLoadDropdown.Button:SetPoint("RIGHT", 105, 2)
		B.ReskinInput(SkilletQueueSaveEditBox)
		SkilletQueueSaveEditBox:SetPoint("TOPLEFT", SkilletQueueLoadDropdown, "BOTTOMLEFT", 18, -2)
		SkilletQueueSaveButton:SetPoint("LEFT", SkilletQueueSaveEditBox, "RIGHT", 6, 0)

		-- Icon
		reskinIcon(SkilletSkillIcon)

		for i = 1, 8 do
			local icon = _G["SkilletReagent"..i.."Icon"]
			reskinIcon(icon)
		end

		for i = 1, 7 do
			local icon = _G["SkilletNotesButton"..i.."Icon"]
			reskinIcon(icon)
		end

		-- Notes
		B.StripTextures(SkilletRecipeNotesFrame)
		local noteBG = B.SetBD(SkilletRecipeNotesFrame)
		noteBG:SetInside()
		B.ReskinClose(SkilletNotesCloseButton)

		-- Tooltip
		P.ReskinTooltip(SkilletSkillTooltip)
		P.ReskinTooltip(SkilletTradeskillTooltip)
	end
	hooksecurefunc(_G.Skillet, "CreateTradeSkillWindow", reskinFunc)

	local function reskinQueueButton()
		local i = 1
		local button = _G["SkilletQueueButton"..i]
		while button do
			if not button.styled then
				B.Reskin(_G[button:GetName().."DeleteButton"])
				button.styled = true
			end
			i = i + 1
			button = _G["SkilletQueueButton"..i]
		end
	end
	hooksecurefunc(_G.Skillet, "UpdateQueueWindow", reskinQueueButton)

	local function reskinTradeButtons(self, player)
		local tradeSkillList = self.tradeSkillList
		local additionalButtonsList = self.AdditionalButtonsList

		for _, tradeID in ipairs(tradeSkillList) do
			local button = _G["SkilletFrameTradeButton-"..player.."-"..tradeID]
			if button and not button.styled then
				reskinTradeButton(button)

				button.styled = true
			end
		end

		for _, spellTable in ipairs(additionalButtonsList) do
			local spellName = spellTable[2]
			local button = _G["SkilletDo"..spellName]
			if button and not button.styled then
				reskinTradeButton(button)

				button.styled = true
			end
		end
	end
	hooksecurefunc(_G.Skillet, "UpdateTradeButtons", reskinTradeButtons)
end

S:RegisterSkin("Skillet-Classic", S.SkilletClassic)