local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function updateButtonBorder(button)
	if not button.bg then return end

	button.icon:SetShown(button.index ~= nil)

	if button.selectedTexture:IsShown() then
		button.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	else
		button.bg:SetBackdropColor(0, 0, 0, .25)
	end

	if button.DragButton.ActiveTexture:IsShown() then
		button.icon.bg:SetBackdropBorderColor(1, .8, 0)
	else
		button.icon.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function TempPostHook(object, method, hookFunc)
	local orig = object[method]
	if orig then
		object[method] = function(...)
			local results = {orig(...)}
			hookFunc(...)
			object[method] = orig
			return unpack(results)
		end
	end
end

local function HandlePetButton(self)
	if not self.bg then
		self.background:SetAlpha(0)
		self:SetHighlightTexture(0)
		self.iconBorder:SetTexture("")
		self.selectedTexture:SetTexture("")

		self.bg = B.CreateBDFrame(self, .25)
		self.bg:SetPoint("TOPLEFT", 1, -1)
		self.bg:SetPoint("BOTTOMRIGHT", 0, 1)

		local icon = self.icon
		icon:SetSize(25, 25)
		icon.SetSize = B.Dummy
		icon.bg = B.ReskinIcon(icon)
	end

	if self.selectedTexture:IsShown() then
		self.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	else
		self.bg:SetBackdropColor(0, 0, 0, .25)
	end
end

local PetWindow
local function ReskinPetPanel()
	if PetWindow and not PetWindow.styled then
		local frame = PetWindow.frame
		if frame.bg then
			B.CreateBD(frame.bg)
			B.CreateSD(frame.bg)
			B.CreateTex(frame.bg)
			frame.bg:SetPoint("TOPLEFT", 2, 0)
			frame.bg:SetPoint("BOTTOMRIGHT")
		end

		S:Proxy("ReskinInput", frame.SearchBox)
		S:Proxy("ReskinTrimScroll", frame.ScrollBar)

		if frame.ScrollBox then
			hooksecurefunc(frame.ScrollBox, "Update", function(self)
				self:ForEachFrame(HandlePetButton)
			end)
		end

		if PetWindow.InfoButton then
			PetWindow.InfoButton.Ring:Hide()
		end

		PetWindow.styled = true
	end
end

local styled
local function ReskinMJEnhanced()
	if CollectionsJournal.selectedTab == COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS and not styled then
		P.WaitFor(function()
			return _G.MJEMountSpecialButtonToolTip and _G.MJEStatisticsHelpToolTip and _G.MJEDisplayHelpToolTip
		end, function()
			for _, child in pairs({_G.MountJournal:GetChildren()}) do
				local objType = child:GetObjectType()
				if objType == "Frame" then
					if child.staticText and child.uniqueCount then
						B.StripTextures(child)
						B.CreateBDFrame(child, .25)
					end
				elseif objType == "Button" then
					if child.texture and child.NormalTexture then
						child:SetPushedTexture(0)
						child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
						B.ReskinIcon(child.texture)
						child:SetNormalTexture(0)
					elseif child:GetText() == "!" then
						B.Reskin(child)
					elseif child.Icon and child.Icon:GetAtlas() == "QuestLog-icon-setting" then
						child:DisableDrawLayer("BACKGROUND")
					end
				elseif objType == "CheckButton" and child.Icon then
					child:SetPushedTexture(0)
					child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					B.ReskinIcon(child.Icon)
					child:SetNormalTexture(0)
					child:SetCheckedTexture(DB.pushedTex)
					child:HookScript("PreClick", function(self, button)
						if not self.isHooked and button == "LeftButton" then
							if S.aceContainers["Window"] then
								TempPostHook(S.aceContainers, "Window", function(_, widget)
									PetWindow = widget
								end)
							end
							self.isHooked = true
						end
					end)
					child:HookScript("PostClick", function(_, button)
						if button == "LeftButton" then
							ReskinPetPanel()
						end
					end)
				end
			end

			local SlotButton = _G.MountJournal.SlotButton
			if SlotButton then
				local icon = SlotButton.ItemIcon:GetTexture()
				B.StripTextures(SlotButton)
				SlotButton.bg = B.ReskinIcon(SlotButton.ItemIcon)
				SlotButton.bg:SetInside(nil, 2, 2)
				SlotButton.ItemIcon:SetTexture(icon)
				SlotButton.ItemIcon:SetInside(SlotButton.bg)
				SlotButton:SetPushedTexture(0)
				SlotButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				SlotButton:GetHighlightTexture():SetInside(SlotButton.bg)
			end

			hooksecurefunc("MountJournal_InitMountButton", updateButtonBorder)

			P.ReskinTooltip(_G.MJEMountSpecialButtonToolTip)
			P.ReskinTooltip(_G.MJEStatisticsHelpToolTip)
			P.ReskinTooltip(_G.MJEDisplayHelpToolTip)

			local controlFrame = MountJournal.MountDisplay.ModelScene.ControlFrame
			for _, child in pairs({controlFrame:GetChildren()}) do
				if child.NormalTexture then
					child.NormalTexture:SetAlpha(0)
					child.PushedTexture:SetAlpha(0)
				end
			end
		end)

		styled = true
	end
end

function S:MountJournalEnhanced()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C_AddOns.IsAddOnLoaded("MountJournalEnhanced") then return end

	_G.MountJournal:HookScript("OnShow", ReskinMJEnhanced)
end

P:AddCallbackForAddon("Blizzard_Collections", S.MountJournalEnhanced)