local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function reskinConditionContent(self)
	for _, child in pairs {self:GetChildren()} do
		if not child.styled then
			B.ReskinCheck(child.CheckButton)
			P.ReskinDropDown(child.DropDown)
			B.StripTextures(child.DetailFrame)
			B.CreateBDFrame(child.DetailFrame, .25)

			local items = child.DetailFrame.items
			if items then
				for _, check in pairs(items) do
					B.ReskinCheck(check)
				end
			end

			child.styled = true
		end
	end
end

local function reskinSwitchDialog(self)
	local buttons = self.List.Content.buttons
	if buttons then
		for _, button in pairs(buttons) do
			if not button.__bg then
				B.StripTextures(button)
				B.Reskin(button)
			end

			button.__bg:SetBackdropColor(0, 0, 0, 0)
		end
	end
end

function S:ImprovedAddonList()
	if _G.ImprovedAddonListDropDown then
		P.ReskinDropDown(_G.ImprovedAddonListDropDown)
	end

	local inputDialog = _G.ImprovedAddonListInputDialog
	if inputDialog then
		B.StripTextures(inputDialog)
		B.SetBD(inputDialog)
		B.ReskinClose(inputDialog.CloseButton)
		B.ReskinInput(inputDialog.EditBox)
		B.Reskin(inputDialog.OkayButton)

		for _, key in pairs({"SaveToGlobal", "ShowStaticPop", "AutoDismiss"}) do
			local check = inputDialog[key]
			if check then
				B.ReskinCheck(check)
			end
		end

		local conditionContainer = inputDialog.ConditionContainer
		if conditionContainer then
			B.StripTextures(conditionContainer)
			B.CreateBDFrame(conditionContainer, .25)
			B.ReskinScroll(conditionContainer.ScrollBar)
		end
	end

	local conditionContent = _G.ImprovedAddonListConditionContent
	if conditionContent then
		conditionContent:HookScript("OnShow", reskinConditionContent)
	end

	local remarkDialog = _G.ImprovedAddonListInputRemarkDialog
	if remarkDialog then
		B.StripTextures(remarkDialog)
		B.SetBD(remarkDialog)
		B.ReskinClose(remarkDialog.CloseButton)
		B.ReskinInput(remarkDialog.EditBox)
	end

	local switchDialog = _G.ImprovedAddonListSwitchConfigurationPromptDialog
	if switchDialog then
		B.StripTextures(switchDialog)
		B.SetBD(switchDialog)
		B.ReskinClose(switchDialog.CloseButton)

		local list = switchDialog.List
		if list then
			B.StripTextures(list)
			B.ReskinScroll(list.ScrollBar)
		end

		switchDialog:HookScript("OnShow", reskinSwitchDialog)
		switchDialog:HookScript("OnEnter", reskinSwitchDialog)
	end
end

S:RegisterSkin("ImprovedAddonList", S.ImprovedAddonList)