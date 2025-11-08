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

function S:Hemlock()
	local Hemlock = _G.Hemlock
	if not Hemlock then return end

	local frame = _G.HemlockFrame
	if frame then
		B.StripTextures(frame)
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", _G.MerchantFrame, "RIGHT", -2, 0)
	end

	if Hemlock.InitFrames then
		hooksecurefunc(Hemlock, "InitFrames", function(self)
			for _, button in ipairs(self.frames) do
				if not button.styled then
					B.ReskinIcon(button:GetNormalTexture(), true)
					button:GetNormalTexture():SetInside()
					button:SetHighlightTexture(DB.bdTex)
					button:GetHighlightTexture():SetVertexColor(1, 1, 1,.25)
					button:GetHighlightTexture():SetInside()
					button.styled = true
				end
			end
		end)
	end
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

function S:Restocker()
	local RS = _G.RS_ADDON
	if not RS or not RS.MainFrame then return end

	local frame = RS.MainFrame
	B.StripTextures(frame)
	B.SetBD(frame)
	S:Proxy("ReskinClose", frame.CloseButton)
	S:Proxy("StripTextures", frame.listInset)
	S:Proxy("ReskinScroll", frame.scrollFrame.ScrollBar)
	S:Proxy("Reskin", frame.addBtn)
	S:Proxy("ReskinInput", frame.editBox)
	P.ReskinDropDown(frame.profileDropDownMenu)
	UIDropDownMenu_SetWidth(frame.profileDropDownMenu, 120)

	for _, child in pairs({frame:GetChildren()}) do
		if child.GetText and child:GetText() == "Settings" then
			B.Reskin(child)
			break
		end
	end

	local function reskinItem(item)
		local prev
		for _, key in ipairs({"delBtn", "buyBtn", "toBankBtn", "fromBankBtn", "amountBox"}) do
			local bu = item[key]
			if bu then
				if key == "delBtn" then
					B.ReskinClose(bu)
				elseif key ~= "amountBox" then
					B.Reskin(bu)
					bu:SetHeight(20)
				end
				bu:ClearAllPoints()
				if not prev then
					bu:SetPoint("RIGHT")
				else
					bu:SetPoint("RIGHT", prev, "LEFT", -1, 0)
				end
				prev = bu
			end
		end
		S:Proxy("ReskinInput", item.amountBox)
		S:Proxy("ReskinInput", item.reactionBox)
	end

	for _, item in ipairs(RS.framepool) do
		reskinItem(item)
	end

	hooksecurefunc(RS, "CreateRestockListRow", function()
		reskinItem(RS.framepool[#RS.framepool])
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

function S:OmniCD_HandleIcon(barFrame, iconIndex)
	local icon = barFrame.icons[iconIndex]
	if not icon.__shadow then
		icon.__shadow = B.CreateSD(icon)
	end
	icon.icon:SetTexCoord(unpack(DB.TexCoord))
end

function S:OmniCD()
	local OmniCD = _G.OmniCD
	if not OmniCD then return end

	local Party = OmniCD[1].Party
	if Party.AcquireIcon then
		hooksecurefunc(Party, "AcquireIcon", S.OmniCD_HandleIcon)
	end
end

local function reskinExtraTip(self, tooltip)
	local reg = self.tooltipRegistry[tooltip]
	if reg and reg.extraTip then
		P.ReskinTooltip(reg.extraTip)
		reg.extraTip.bg:SetFrameLevel(0)
	end
end

function S:LibExtraTip()
	local LibExtraTip = _G.LibStub and _G.LibStub("LibExtraTip-1", true)
	if not LibExtraTip then return end

	hooksecurefunc(LibExtraTip, "AddLine", reskinExtraTip)
	hooksecurefunc(LibExtraTip, "AddDoubleLine", reskinExtraTip)
end

function S:Hekili()
	local Hekili = _G.Hekili
	if not Hekili then return end

	if Hekili.CreateButton then
		local CreateButton = Hekili.CreateButton
		Hekili.CreateButton = function(...)
			local button = CreateButton(...)
			if button and not button.styled then
				B.CreateSD(button)
				button.styled = true
			end
			return button
		end
	end
end

S:RegisterSkin("HandyNotes_NPCs (Classic)", S.HandyNotes_NPCs)
S:RegisterSkin("HandyNotes_NPCs (Burning Crusade Classic)", S.HandyNotes_NPCs)
S:RegisterSkin("BattleInfo", S.BattleInfo)
S:RegisterSkin("Accountant_Classic", S.Accountant)
S:RegisterSkin("FeatureFrame", S.FeatureFrame)
S:RegisterSkin("BuffomatClassicTBC", S.buffOmat)
S:RegisterSkin("BuyEmAllClassic", S.BuyEmAllClassic)
S:RegisterSkin("Hemlock", S.Hemlock)
S:RegisterSkin("TotemTimers", S.TotemTimers)
S:RegisterSkin("BigWigs_Options", S.BigWigs_Options)
S:RegisterSkin("Restocker", S.Restocker)
S:RegisterSkin("RaidLedger", S.RaidLedger)
S:RegisterSkin("LibQTip")
S:RegisterSkin("OmniCD", S.OmniCD)
S:RegisterSkin("LibExtraTip")
S:RegisterSkin("Hekili", S.Hekili, true)

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