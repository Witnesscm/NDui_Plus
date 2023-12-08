local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local AB = P:GetModule("ActionBar")
local NS = B:GetModule("Skins")

local _G = getfenv(0)
local select, pairs, ipairs, strfind = select, pairs, ipairs, string.find

function S:HandyNotes_NPCs()
	P:Delay(.5,function()
		for i = 1, _G.WorldMapFrame:GetNumChildren() do
			local child = select(i, _G.WorldMapFrame:GetChildren())
			if child:GetObjectType() == "Button" and child:GetText() == "NPCs" then
				B.Reskin(child)
			end
		end
	end)
end

function S:BattleInfo()
	local function GetChildFrame(i, frame)
		local child = select(i, frame:GetChildren())
		if child:GetObjectType() == "Frame" and not child:GetName() then
			local backdrop = child:GetBackdrop()
			local edgeFile = backdrop and backdrop.edgeFile
			if edgeFile and strfind(edgeFile, "UI%-DialogBox%-Border") then
				return child
			end
		end
	end

	local HonorFrameStat
	local PVPFrame = _G.HonorFrame or _G.PVPFrame
	for i = 1, PVPFrame:GetNumChildren() do
		local child = GetChildFrame(i, PVPFrame)
		if child then
			B.StripTextures(child)
			local bg = B.SetBD(child)
			bg:SetInside(child, 0, 0)
			HonorFrameStat = child
			break
		end
	end

	if not HonorFrameStat then return end
	for i = 1, HonorFrameStat:GetNumChildren() do
		local child = GetChildFrame(i, HonorFrameStat)
		if child then
			child:DisableDrawLayer("BORDER")
			local bg = B.CreateBDFrame(child, .25)
			bg:SetInside(child, 0 ,6)
		end
	end
end

function S:Accountant()
	B.ReskinPortraitFrame(_G.AccountantClassicFrame)
	B.Reskin(_G.AccountantClassicFrameResetButton)
	B.Reskin(_G.AccountantClassicFrameOptionsButton)
	B.Reskin(_G.AccountantClassicFrameExitButton)

	local row1 = _G.AccountantClassicFrameRow1In
	local vline1 = CreateFrame("Frame", nil, row1, "BackdropTemplate")
	vline1:SetHeight(340)
	vline1:SetWidth(1)
	vline1:SetPoint("TOP", row1, "TOPLEFT", 16, 0)
	B.CreateBD(vline1)
	local vline2 = CreateFrame("Frame", nil, row1, "BackdropTemplate")
	vline2:SetHeight(340)
	vline2:SetWidth(1)
	vline2:SetPoint("TOP", row1, "TOPRIGHT", 16, 0)
	B.CreateBD(vline2)

	for i = 1, 18 do
		local row = _G["AccountantClassicFrameRow"..i]
		local hline = CreateFrame("Frame", nil, row, "BackdropTemplate")
		hline:SetHeight(1)
		hline:SetWidth(640)
		hline:SetPoint("TOP")
		B.CreateBD(hline)
	end

	for i = 1, 11 do
		local tab = _G["AccountantClassicFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end
	end
	_G.AccountantClassicFrameTab1:ClearAllPoints()
	_G.AccountantClassicFrameTab1:SetPoint("BOTTOMLEFT", 5, -30)
	_G.AccountantClassicFrameTab11:ClearAllPoints()
	_G.AccountantClassicFrameTab11:SetPoint("BOTTOMRIGHT", 0, -30)

	B.ReskinDropDown(_G.AccountantClassicFrameServerDropDown)
	B.ReskinDropDown(_G.AccountantClassicFrameFactionDropDown)
	B.ReskinDropDown(_G.AccountantClassicFrameCharacterDropDown)
end

function S:FeatureFrame()
	B.ReskinPortraitFrame(FeatureFrame, 10, -10, -32, 70)
	for i = 1, 7 do
		local tab = _G["FeatureFrameTab"..i]
		B.CreateBDFrame(tab)
		tab:DisableDrawLayer("BACKGROUND")
		tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
		tab:GetCheckedTexture():SetTexture(DB.pushedTex)
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	end

	B.ReskinArrow(FeatureFramePrevPageButton, "left")
	B.ReskinArrow(FeatureFrameNextPageButton, "right")

	for i = 1, 14 do
		local bu = _G["FeatureFrameButton"..i]
		local ic = _G["FeatureFrameButton"..i.."IconTexture"]
		local name = _G["FeatureFrameButton"..i.."OtherName"]

		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.ReskinIcon(ic)
		name:SetTextColor(1, 1, 1)
	end
end

function S:buffOmat()
	local frame = _G.BomC_MainWindow
	if not frame then return end

	for _, tab in ipairs(frame.Tabs) do
		B.ReskinTab(tab)
	end

	for _, key in pairs({"CloseButton", "SettingsButton", "MacroButton"}) do
		local bu = _G["BomC_MainWindow_"..key]
		if bu then
			B.Reskin(bu)
		end
	end

	B.StripTextures(frame)
	B.SetBD(frame)
	B.Reskin(BomC_ListTab_Button)
	B.ReskinScroll(BomC_SpellTab_Scroll.ScrollBar)
	P.ReskinTooltip(BomC_Tooltip)
end

function S:BuyEmAllClassic()
	B.StripTextures(BuyEmAllFrame)
	B.SetBD(BuyEmAllFrame, nil, 10, -10, -10, 10)
	B.Reskin(BuyEmAllOkayButton)
	B.Reskin(BuyEmAllCancelButton)
	B.Reskin(BuyEmAllStackButton)
	B.Reskin(BuyEmAllMaxButton)

	B.CreateMF(BuyEmAllFrame)
end

function S:xCT()
	local styled
	InterfaceOptionsCombatPanel:HookScript("OnShow", function(self)
		if styled then return end

		for i = 1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			if child:GetObjectType() == "Button" and child:GetText() then
				B.Reskin(child)
			end
		end

		styled = true
	end)
end

function S:Elephant()
	local Elephant = _G.Elephant

	B.StripTextures(ElephantFrame)
	B.SetBD(ElephantFrame)
	B.StripTextures(ElephantFrameScrollingMessageTextureFrame)

	local bg = B.CreateBDFrame(ElephantFrameScrollingMessageTextureFrame, .25)
	bg:SetPoint("TOPLEFT", 0, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 0)

	local Buttons = {
		"ElephantFrameDeleteButton",
		"ElephantFrameEnableButton",
		"ElephantFrameEmptyButton",
		"ElephantFrameCopyButton",
		"ElephantFrameCloseButton",
	}

	for _, button in pairs(Buttons) do
		local bu = _G[button]
		if bu then
			B.Reskin(bu)
		end
	end

	hooksecurefunc(Elephant, "ShowCopyWindow", function()
		local frame = _G.ElephantCopyFrame
		if frame and not frame.styled then
			B.StripTextures(frame)
			B.SetBD(frame)
			B.CreateMF(frame)

			B.StripTextures(ElephantCopyFrameScrollTextureFrame)
			local bg = B.CreateBDFrame(ElephantCopyFrameScrollTextureFrame, .25)
			bg:SetPoint("TOPLEFT", 0, -2)
			bg:SetPoint("BOTTOMRIGHT", -2, 0)

			for _, button in pairs({
				"ElephantCopyFrameBackButton",
				"ElephantCopyFrameHideButton",
				"ElephantCopyFrameBBCodeButton",}) do
				local bu = _G[button]
				if bu then
					B.Reskin(bu)
				end
			end

			B.ReskinCheck(ElephantCopyFrameUseTimestampsButton)

			frame.styled = true
		end
	end)
end

function S:Hemlock()
	local Hemlock = _G.Hemlock
	if not Hemlock then return end

	local function reskinButton(button)
		B.ReskinIcon(button:GetNormalTexture())
		button:GetNormalTexture():SetInside()
		button:SetHighlightTexture(DB.bdTex)
		button:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		button:GetHighlightTexture():SetInside()
	end

	B.StripTextures(_G.HemlockFrame)
	_G.HemlockFrame:SetPoint("LEFT", MerchantFrameCloseButton, "RIGHT", 0, 0)
	hooksecurefunc(Hemlock, "MakeFrame", function(self)
		for _, button in ipairs(self.frames) do
			if not button.styled then
				reskinButton(button)
				button.styled = true
			end
		end
	end)

	hooksecurefunc(Hemlock, "MakeScanFrame", function(self)
		local button = _G.HemlockPoisonButtonOpen
		if button and not button.styled then
			reskinButton(button)
			button.styled = true
		end
	end)
end

function S:TotemTimers()
	if DB.MyClass ~= "SHAMAN" then return end

	local TotemTimers = _G.TotemTimers
	local TTActionBars = _G.TTActionBars
	local XiTimers = TotemTimers.timers

	local function hook_SetTexture(self, texture)
		local bg = self:GetParent().icbg
		if not bg then return end

		if texture and texture ~= "" then
			bg:Show()
		else
			bg:Hide()
		end
	end

	local function reskinTotemButton(self)
		AB:StyleActionButton(self, AB.BarConfig)

		local icon = _G[self:GetName().."Icon"]
		if icon then
			icon:SetTexCoord(unpack(DB.TexCoord))
			icon.SetTexCoord = B.Dummy
		end

		local mini = self.miniIconFrame
		if mini then
			mini.icbg = B.ReskinIcon(self.miniIcon)
			mini.icbg:SetBackdropColor(0, 0, 0, 0)
			mini.icbg:Hide()
			mini:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
			hooksecurefunc(self.miniIcon, "SetTexture", hook_SetTexture)
		end
	end

	hooksecurefunc(XiTimers, "new", function(self, ...)
		local timer = XiTimers.timers[#XiTimers.timers]

		reskinTotemButton(timer.button)
		reskinTotemButton(timer.animation.button)

		for i = 1, #timer.timerBars do
			timer.timerBars[i].icon:SetTexCoord(unpack(DB.TexCoord))
		end
	end)

	hooksecurefunc(_G.TTActionBars, "new", function(self, ...)
		local bar = TTActionBars.bars[#TTActionBars.bars]

		for _, button in ipairs(bar.buttons) do
			reskinTotemButton(button)
		end
	end)
end

function S:BigWigs_Options()
	P.ReskinTooltip(_G.BigWigsOptionsTooltip)
end

function S:RestockerTBC()
	local RS = _G.RS_ADDON
	if not RS or not RS.MainFrame then return end

	local frame = RS.MainFrame
	P.ReskinFrame(frame)
	B.StripTextures(frame.listInset)
	B.ReskinScroll(frame.scrollFrame.ScrollBar)
	B.Reskin(frame.addBtn)
	B.ReskinInput(frame.editBox)
	P.ReskinDropDown(frame.profileDropDownMenu)
	UIDropDownMenu_SetWidth(frame.profileDropDownMenu, 120)

	for _, child in pairs({frame:GetChildren()}) do
		if child:GetObjectType() == "CheckButton" then
			B.ReskinCheck(child)
		end
	end

	local function reskinItemFrame(item)
		for _, child in pairs({item:GetChildren()}) do
			local objectType = child:GetObjectType()
			if objectType == "Button" then
				B.ReskinClose(child)
			elseif objectType == "EditBox" then
				P.ReskinInput(child)
				child.bg:SetPoint("BOTTOMRIGHT", -4, 0)
			end
		end
	end

	for _, item in ipairs(RS.framepool) do
		reskinItemFrame(item)
	end

	hooksecurefunc(RS, "addListFrame", function()
		reskinItemFrame(RS.framepool[#RS.framepool])
	end)
end

function S:RaidLedger()
	for _, child in pairs {_G.RaidFrame:GetChildren()} do
		if child:GetObjectType() == "Button" and child:GetText() and child:GetText() ~= "" and not child.__bg then
			B.Reskin(child)
		end
	end
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

S:RegisterSkin("HandyNotes_NPCs (Classic)", S.HandyNotes_NPCs)
S:RegisterSkin("HandyNotes_NPCs (Burning Crusade Classic)", S.HandyNotes_NPCs)
S:RegisterSkin("BattleInfo", S.BattleInfo)
S:RegisterSkin("Accountant_Classic", S.Accountant)
S:RegisterSkin("FeatureFrame", S.FeatureFrame)
S:RegisterSkin("BuffomatClassicTBC", S.buffOmat)
S:RegisterSkin("BuyEmAllClassic", S.BuyEmAllClassic)
S:RegisterSkin("xCT+", S.xCT)
-- S:RegisterSkin("Elephant", S.Elephant)
S:RegisterSkin("Hemlock", S.Hemlock)
S:RegisterSkin("TotemTimers", S.TotemTimers)
S:RegisterSkin("BigWigs_Options", S.BigWigs_Options)
S:RegisterSkin("RestockerTBC", S.RestockerTBC)
S:RegisterSkin("RaidLedger", S.RaidLedger)
S:RegisterSkin("LibQTip")

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

-- Fade NDui stat panel arrow
S.ArrowButtons = {}

function S:UpdateArrowVisible()
	for _, button in ipairs(S.ArrowButtons) do
		if S.db["CategoryArrow"] then
			P:UIFrameFadeOut(button, 0.5, button:GetAlpha(), 0)
			button:SetAlpha(0)
		else
			P:UIFrameFadeIn(button, 0.5, button:GetAlpha(), 1)
			button:SetAlpha(1)
		end
	end
end

function S:StatArrow_Setup()
	local index = 1
	local category = _G["NDuiStatCategory"..index]
	while category do
		for i = 1, category:GetNumChildren() do
			local child = select(i, category:GetChildren())
			if child.__texture and child.__owner then
				child:HookScript("OnEnter", function(self)
					if S.db["CategoryArrow"] then
						P:UIFrameFadeIn(self, 0.3, self:GetAlpha(), 1)
					end
				end)
				child:HookScript("OnLeave", function(self)
					if S.db["CategoryArrow"] then
						P:UIFrameFadeOut(self, 0.3, self:GetAlpha(), 0)
					end
				end)

				tinsert(S.ArrowButtons, child)
			end
		end

		index = index + 1
		category = _G["NDuiStatCategory"..index]
	end

	S:UpdateArrowVisible()

	B:UnregisterEvent("PLAYER_ENTERING_WORLD", S.StatArrow_Setup)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", S.StatArrow_Setup)