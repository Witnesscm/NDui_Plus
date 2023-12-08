local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local AB = P:GetModule("ActionBar")

local _G = getfenv(0)
local pairs = pairs

local function setBorder(button)
	local border = button.Border
	if not border then return end

	border.__textureFile = DB.pushedTex
	border:SetTexture(DB.pushedTex)
	border:SetAllPoints()
end

function S:ItemRack()
	if not S.db["ItemRack"] then return end

	local ItemRack = _G.ItemRack
	if not ItemRack then return end

	for i = 0, 20 do
		local bu = _G["ItemRackButton"..i]
		if bu then
			AB:StyleActionButton(bu, AB.BarConfig)
		end
	end

	hooksecurefunc(ItemRack, "CreateMenuButton", function(idx)
		local button = _G["ItemRackMenu"..idx]
		if button and not button.styled then
			AB:StyleActionButton(button, AB.BarConfig)
			setBorder(button)
			button.styled = true
		end
	end)

	hooksecurefunc(ItemRack, "ReflectLock", function()
		if _G.ItemRackMenuFrame.SetBackdrop then
			_G.ItemRackMenuFrame:SetBackdrop(nil)
		end
	end)
end

function S:ItemRackOptions()
	if not S.db["ItemRack"] then return end

	B.StripTextures(ItemRackOptFrame)
	B.SetBD(ItemRackOptFrame)
	B.ReskinClose(ItemRackOptClose)
	-- B.ReskinIcon(ItemRackMinimapIcon)
	-- ItemRackMinimapIcon.SetTexCoord = B.Dummy

	for i = 0, 19 do
		local inv = _G["ItemRackOptInv"..i]
		if inv then
			AB:StyleActionButton(inv, AB.BarConfig)
			setBorder(inv)
		end
	end

	for i = 1, 8 do
		local subFrame = _G["ItemRackOptSubFrame"..i]
		if subFrame then
			B.StripTextures(subFrame)
		end
	end

	for i = 1, 4 do
		local tab = _G["ItemRackOptTab"..i]
		if tab then
			B.StripTextures(tab)
		end
	end

	local Buttons = {
		"ItemRackOptEventEdit",
		"ItemRackOptEventDelete",
		"ItemRackOptEventNew",
		"ItemRackOptEventEditSave",
		"ItemRackOptEventEditCancel",
		"ItemRackOptEventEditExpand",
		"ItemRackOptSetsSaveButton",
		"ItemRackOptSetsBindButton",
		"ItemRackOptSetsDeleteButton",
		"ItemRackOptKeyBindings",
		"ItemRackOptResetBar",
		"ItemRackOptResetEvents",
		"ItemRackOptResetEverything",
		"ItemRackOptBindUnbind",
		"ItemRackOptBindCancel",
	}
	for _, button in pairs(Buttons) do
		local bu = _G[button]
		if bu then
			B.Reskin(bu)
		end
	end

	local CheckButtons = {
		"ItemRackOptSetsHideCheckButton",
		"ItemRackOptQueueEnable",
		"ItemRackOptItemStatsPriority",
		"ItemRackOptItemStatsKeepEquipped",
		"ItemRackOptEventEditBuffAnyMount",
		"ItemRackOptEventEditBuffNotInPVP",
		"ItemRackOptEventEditBuffUnequip",
		"ItemRackOptEventEditStanceNotInPVP",
		"ItemRackOptEventEditStanceUnequip",
		"ItemRackOptEventEditZoneUnequip",
	}

	for _, obj in pairs(CheckButtons) do
		local check = _G[obj]
		if check then
			B.ReskinCheck(check)
		end
	end

	local EditBoxs = {
		"ItemRackOptItemStatsDelay",
		"ItemRackOptEventEditNameEdit",
		"ItemRackOptEventEditBuffName",
		"ItemRackOptEventEditStanceName",
		"ItemRackOptEventEditScriptTrigger",
		"ItemRackOptSetsName",
		"ItemRackOptButtonSpacing",
		"ItemRackOptAlpha",
		"ItemRackOptMainScale",
		"ItemRackOptMenuScale",
		"ItemRackOptSetMenuWrapValue",
	}
	for _, obj in pairs(EditBoxs) do
		local editBox = _G[obj]
		if editBox then
			B.StripTextures(editBox)
			B.ReskinInput(editBox)
		end
	end

	local Sliders = {
		"ItemRackOptButtonSpacingSlider",
		"ItemRackOptAlphaSlider",
		"ItemRackOptMainScaleSlider",
		"ItemRackOptMenuScaleSlider",
		"ItemRackOptSetMenuWrapValueSlider",
	}
	for _, obj in pairs(Sliders) do
		local slider = _G[obj]
		if slider then
			P.SetupBackdrop(slider)
			B.ReskinSlider(slider)
		end
	end

	local ScrollBars = {
		"ItemRackOptEventEditScriptEditScrollFrameScrollBar",
		"ItemRackOptEventEditZoneEditScrollFrameScrollBar",
		"ItemRackFloatingEditorScrollFrameScrollBar",
		"ItemRackOptEventListScrollFrameScrollBar",
		"ItemRackOptListScrollFrameScrollBar",
		"ItemRackOptSetsIconScrollFrameScrollBar",
		"ItemRackOptSetListScrollFrameScrollBar",
		"ItemRackOptSortListScrollFrameScrollBar",
	}
	for _, obj in pairs(ScrollBars) do
		local scrollBar = _G[obj]
		if scrollBar then
			B.ReskinScroll(scrollBar)
		end
	end

	local ListFrames = {
		ItemRackOptEventListFrame,
		ItemRackOptEventEditZoneEditBox,
		ItemRackOptEventEditScriptEditBox,
		ItemRackOptSetsIconFrame,
	}

	local childFrames = {
		ItemRackOptSetList1,
		ItemRackOptSortListScrollFrame,
	}

	for _, child in pairs(childFrames) do
		local parent = child:GetParent()
		table.insert(ListFrames, parent)
	end

	for _, frame in pairs(ListFrames) do
		B.StripTextures(frame)
		B.CreateBDFrame(frame, .25)
	end

	for i = 1, 11 do
		local icon = _G["ItemRackOptSortList"..i.."Icon"]
		B.ReskinIcon(icon)
	end
	B.ReskinClose(ItemRackOptSortListClose)

	for i = 1, 9 do
		local check = _G["ItemRackOptEventList"..i.."Enabled"]
		local icon = _G["ItemRackOptEventList"..i.."Icon"]

		B.ReskinCheck(check)
		B.ReskinIcon(icon:GetNormalTexture())
		icon:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end

	local dropdown = _G.ItemRackOptEventEditTypeDrop
	local down = _G.ItemRackOptEventEditTypeDropButton
	B.StripTextures(dropdown)
	down:ClearAllPoints()
	down:SetPoint("RIGHT",1,0)
	B.ReskinArrow(down, "down")
	down:SetSize(22, 22)
	local bg = B.CreateBDFrame(dropdown, 0)
	B.CreateGradient(bg)

	B.StripTextures(ItemRackOptEventEditPickTypeFrame)
	B.SetBD(ItemRackOptEventEditPickTypeFrame)
	B.StripTextures(ItemRackOptEventEditZoneEditBackdrop)
	B.StripTextures(ItemRackOptEventEditScriptEditBackdrop)
	B.StripTextures(ItemRackOptBindFrame)

	ItemRackOptSetsName:SetWidth(158)
	B.ReskinInput(ItemRackOptSetsName)
	B.ReskinArrow(ItemRackOptSetsDropDownButton, "down")
	B.ReskinClose(ItemRackOptSetListClose)

	for i = 1, 25 do
		local button = _G["ItemRackOptSetsIcon"..i]
		local icon = _G["ItemRackOptSetsIcon"..i.."Icon"]
		B.ReskinIcon(icon)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end

	AB:StyleActionButton(ItemRackOptSetsCurrentSet, AB.BarConfig)

	for i = 1, 10 do
		local icon = _G["ItemRackOptSetList"..i.."Icon"]
		B.ReskinIcon(icon)
	end

	for i = 1, 11 do
		local check = _G["ItemRackOptList"..i.."CheckButton"]
		local underline = _G["ItemRackOptList"..i.."Underline"]
		B.ReskinCheck(check)
		underline:Hide()
		underline.Show = B.Dummy
	end
end

S:RegisterSkin("ItemRack", S.ItemRack)
S:RegisterSkin("ItemRackOptions", S.ItemRackOptions)