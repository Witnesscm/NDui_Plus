local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local NS = B:GetModule("Skins")

local _G = getfenv(0)
local select, pairs, type, strfind = select, pairs, type, string.find

function S:PremadeGroupsFilter()
	local button = _G.UsePFGButton or _G.UsePGFButton
	if button then
		button:SetSize(32, 32)
		button:ClearAllPoints()
		button:SetPoint("RIGHT", _G.LFGListFrame.SearchPanel.RefreshButton, "LEFT", -55, 0)
		button.text:SetText(FILTER)
		button.text:SetWidth(button.text:GetStringWidth())
	end
end

function S:WorldQuestsList()
	local frame = _G["WorldQuestsListFrame"]
	B.StripTextures(frame)
	local bg = B.CreateBDFrame(frame, .8)
	B.CreateSD(bg)
	for i = 1, _G.WorldMapFrame:GetNumChildren() do
		local child = select(i, _G.WorldMapFrame:GetChildren())
		if child:GetObjectType() == "CheckButton" and child.text then
			B.ReskinCheck(child)
		end
	end
end

function S:MogPartialSets()
	if _G.MogPartialSets_FilterButton then
		B.ReskinFilterButton(_G.MogPartialSets_FilterButton)
	end

	local filter = _G.MogPartialSets_Filter
	if filter then
		B.StripTextures(filter)
		B.SetBD(filter, .7)
		filter:SetScale(NDuiADB["UIScale"])

		for _, key in ipairs({"ShowExtraSetsToggle", "OnlyFavoriteToggle", "FavoriteVariantsToggle", "UseHiddenIfMissingToggle"}) do
			local frame = filter[key]
			local child = frame and frame:GetChildren()
			if child and child:GetObjectType() == "CheckButton" then
				B.ReskinCheck(child)
			end
		end

		for _, key in ipairs({"HeadSlot", "ShoulderSlot", "CloakSlot", "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot"}) do
			local slot = filter[key]
			if slot then
				B.ReskinCheck(slot.Ignored)
				B.ReskinCheck(slot.Hidden)
			end
		end

		for _, key in ipairs({"OkButton", "RefreshButton"}) do
			local bu = filter[key]
			if bu then
				B.Reskin(bu)
			end
		end

		local editbox = _G.MogPartialSets_FilterMaxMissingPiecesEditBox
		if editbox then
			B.ReskinInput(editbox, 20, 15)
			editbox:ClearAllPoints()
			editbox:SetPoint("TOPLEFT", 6, 0)
		end
	end
end

function S:BigWigs_Options()
	P.ReskinTooltip(_G.BigWigsOptionsTooltip)
end

function S:LibQTip()
	local LibQTip = _G.LibStub and _G.LibStub("LibQTip-1.0", true)
	if not LibQTip then return end

	local origAcquire = LibQTip.Acquire
	LibQTip.Acquire = function(...)
		local tooltip = origAcquire(...)
		P.ReskinTooltip(tooltip)

		return tooltip
	end
end

function S:SavedInstances()
	local SI = _G.SavedInstances and _G.SavedInstances[1]
	if not SI then return end

	local Tooltip = SI:GetModule("Tooltip")
	if Tooltip and Tooltip.ShowDetached then
		hooksecurefunc(Tooltip, "ShowDetached", function()
			local frame = _G.SavedInstancesDetachHeader
			if frame and not frame.styled then
				B.StripTextures(frame)
				B.SetBD(frame)
				B.ReskinClose(frame.CloseButton, nil, -2, -2)
				frame.CloseButton:SetAlpha(1)

				frame.styled = true
			end
		end)
	end
end

function S:HandyNotes_Dragonflight()
	local Krowi_WMB = _G.LibStub and _G.LibStub("Krowi_WorldMapButtons-1.4", true)
	if not Krowi_WMB then return end

	for _, button in ipairs(Krowi_WMB.Buttons) do
		if button.AlphaOption and button.ScaleOption then
			S:Proxy("ReskinSlider", button.AlphaOption.Slider)
			S:Proxy("ReskinSlider", button.ScaleOption.Slider)
			if button.Background then button.Background:SetAlpha(0) end
			if button.Border then button.Border:SetAlpha(0) end

			break
		end
	end
end

function S:BuyEmAll()
	B.StripTextures(_G.BuyEmAllFrame)
	B.SetBD(_G.BuyEmAllFrame, nil, 10, -10, -10, 10)
	B.Reskin(_G.BuyEmAllOkayButton)
	B.Reskin(_G.BuyEmAllCancelButton)
	B.Reskin(_G.BuyEmAllStackButton)
	B.Reskin(_G.BuyEmAllMaxButton)

	B.CreateMF(_G.BuyEmAllFrame)
end

S:RegisterSkin("WorldQuestsList", S.WorldQuestsList)
S:RegisterSkin("PremadeGroupsFilter", S.PremadeGroupsFilter)
S:RegisterSkin("MogPartialSets", S.MogPartialSets)
S:RegisterSkin("BigWigs_Options", S.BigWigs_Options)
S:RegisterSkin("LibQTip")
S:RegisterSkin("SavedInstances", S.SavedInstances)
S:RegisterSkin("HandyNotes_Dragonflight", S.HandyNotes_Dragonflight)
S:RegisterSkin("BuyEmAll", S.BuyEmAll)

-- Hide Toggle Button
S.ToggleFrames = {}

do
	hooksecurefunc(NS, "CreateToggle", function(self, frame)
		local close = frame.closeButton
		local open = frame.openButton

		S:SetupToggle(close)
		S:SetupToggle(open)

		close:HookScript("OnClick", function() -- fix
			open:Hide()
			open:Show()
		end)

		tinsert(S.ToggleFrames, frame)
		S:UpdateToggleVisible()
	end)
end

function S:SetupToggle(bu)
	bu:HookScript("OnEnter", function(self)
		if S.db["HideToggle"] then
			P:UIFrameFadeIn(self, 0.5, self:GetAlpha(), 1)
		end
	end)
	bu:HookScript("OnLeave", function(self)
		if S.db["HideToggle"] then
			P:UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0)
		end
	end)
end

function S:UpdateToggleVisible()
	for _, frame in pairs(S.ToggleFrames) do
		local close = frame.closeButton
		local open = frame.openButton

		if S.db["HideToggle"] then
			P:UIFrameFadeOut(close, 0.5, close:GetAlpha(), 0)
			open:SetAlpha(0)
		else
			P:UIFrameFadeIn(close, 0.5, close:GetAlpha(), 1)
			open:SetAlpha(1)
		end
	end
end