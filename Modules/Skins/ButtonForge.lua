local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local Bar = B:GetModule("Actionbar")

local _G = getfenv(0)

local function reskinButton(self)
	local bu = self.Widget
	local icon = self.WIcon

	Bar:StyleActionButton(bu, P.BarConfig)
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.SetTexCoord = B.Dummy
end

local function reskinBar(self)
	B.StripTextures(self.Background)
	B.CreateBDFrame(self.Background, .25)
	B.StripTextures(self.LabelFrame)
end

function S:ButtonForge()
	if not S.db["ButtonForge"] then return end

	local BFUtil = _G.BFUtil
	local BFButton = _G.BFButton
	local BFBar = _G.BFBar

	for _, button in pairs(BFUtil.ActiveButtons) do
		reskinButton(button)
	end

	local origNewButton = BFButton.New
	BFButton.New = function(...)
		local button = origNewButton(...)
		reskinButton(button)

		return button
	end

	for _, bar in pairs(BFUtil.ActiveBars) do
		reskinBar(bar)
		bar:SetButtonGap(2)
	end

	local origNewBar = BFBar.New
	BFBar.New = function(...)
		local bar = origNewBar(...)
		reskinBar(bar)

		return bar
	end

	hooksecurefunc(BFBar, "Configure", function(self)
		self:SetButtonGap(2)
	end)

	local configButtons = {
		"BFToolbarCreateBar",
		"BFToolbarCreateBonusBar",
		"BFToolbarDestroyBar",
		"BFToolbarAdvanced",
		"BFToolbarConfigureAction",
		"BFToolbarRightClickSelfCast"
	}

	for _, key in pairs(configButtons) do
		local bu = _G[key]
		if bu then
			Bar:StyleActionButton(bu, P.BarConfig)
		end
	end

	local BFToolbar = _G.BFToolbar
	if BFToolbar then
		B.StripTextures(BFToolbar)
		B.SetBD(BFToolbar)
		B.ReskinClose(_G.BFToolbarToggle)
	end

	local BFBindingDialog = _G.BFBindingDialog
	if BFBindingDialog then
		B.StripTextures(BFBindingDialog)
		B.SetBD(BFBindingDialog)
		B.ReskinClose(BFBindingDialog.Toggle)
	end

	for _, key in pairs({"BFBindingDialogBinding", "BFBindingDialogUnbind", "BFConfigPageToolbarToggle"}) do
		local bu = _G[key]
		if bu then
			B.Reskin(bu)
		end
	end

	local BFInputLine = _G.BFInputLine
	if BFInputLine then
		B.ReskinInput(BFInputLine)
	end
end

S:RegisterSkin("ButtonForge", S.ButtonForge)