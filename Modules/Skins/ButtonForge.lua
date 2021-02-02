local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:ButtonForge()
	if not IsAddOnLoaded("ButtonForge") then return end
	if not NDuiPlusDB["Skins"]["ButtonForge"] then return end

	local Bar = B:GetModule("Actionbar")

	local function callback(_, event, button)
		if event == "BUTTON_ALLOCATED" then
			local bu = _G[button]
			local icon = _G[button.."Icon"]
			Bar:StyleActionButton(bu, S.BarConfig)
			icon:SetTexCoord(unpack(DB.TexCoord))
			icon.SetTexCoord = B.Dummy
		end
	end
	ButtonForge_API1.RegisterCallback(callback)

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
			Bar:StyleActionButton(bu, S.BarConfig)
		end
	end

	B.StripTextures(BFToolbar)
	B.SetBD(BFToolbar)
	B.ReskinClose(BFToolbarToggle)
	B.StripTextures(BFBindingDialog)
	B.SetBD(BFBindingDialog)
	B.Reskin(BFBindingDialogBinding)
	B.Reskin(BFBindingDialogUnbind)
	B.ReskinClose(BFBindingDialog.Toggle)
	B.Reskin(BFConfigPageToolbarToggle)

	hooksecurefunc(BFUtil, "NewBar", function()
		for i = 1, BFConfigureLayer:GetNumChildren() do
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

	hooksecurefunc(BFBar, "Configure", function(self)
		self:SetButtonGap(2)		-- 锁定间隔为2
	end)
end

S:RegisterSkin("ButtonForge", S.ButtonForge)