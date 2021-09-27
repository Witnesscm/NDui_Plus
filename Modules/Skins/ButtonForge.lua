local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:ButtonForge()
	if not S.db["ButtonForge"] then return end

	local Bar = B:GetModule("Actionbar")

	local function callback(_, event, button)
		if event == "BUTTON_ALLOCATED" then
			local bu = _G[button]
			local icon = _G[button.."Icon"]
			Bar:StyleActionButton(bu, P.BarConfig)
			icon:SetTexCoord(unpack(DB.TexCoord))
			icon.SetTexCoord = B.Dummy
		end
	end
	_G.ButtonForge_API1.RegisterCallback(callback)

	local buttons = {
		"BFToolbarCreateBar",
		"BFToolbarCreateBonusBar",
		"BFToolbarDestroyBar",
		"BFToolbarAdvanced",
		"BFToolbarConfigureAction",
		"BFToolbarRightClickSelfCast"
	}
	for _, button in next, buttons do
		local bu = _G[button]
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

	hooksecurefunc(_G.BFUtil, "NewBar", function()
		for i = 1, _G.BFConfigureLayer:GetNumChildren() do
			local child = select(i, BFConfigureLayer:GetChildren())
			if child:GetObjectType() == "EditBox" and not child.styled then
				B.ReskinInput(child)
				child.styled = true
			end
			if child and child.ParentBar and not child.styled then
				B.StripTextures(child.ParentBar.Background)
				B.CreateBDFrame(child.ParentBar.Background, .25)
				B.StripTextures(child.ParentBar.LabelFrame)
				child.styled = true
			end
		end
	end)

	hooksecurefunc(_G.BFBar, "Configure", function(self)
		self:SetButtonGap(2)		-- 锁定间隔为2
	end)
end

S:RegisterSkin("ButtonForge", S.ButtonForge)