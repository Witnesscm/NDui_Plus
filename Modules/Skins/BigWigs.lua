local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:BigWigs()
	P.ReskinTooltip(_G.BigWigsTooltip)
	S:BigWigs_Keystone()
end

function S:BigWigs_Keystone()
	local Locale = _G.BigWigsAPI and _G.BigWigsAPI:GetLocale("BigWigs")
	local keystoneTitle = Locale and Locale.keystoneTitle
	if not keystoneTitle then return end

	for _, child in pairs {_G.UIParent:GetChildren()} do
		if child and child.GetTitleText and child.Tabs then
			local text = child:GetTitleText():GetText()
			if text and text == keystoneTitle then
				B.ReskinPortraitFrame(child)

				for i, tab in ipairs(child.Tabs) do
					B.ReskinTab(tab)
					tab:SetHeight(28)
					tab.Text.SetPoint = B.Dummy
					if i ~= 1 then
						tab:ClearAllPoints()
						tab:SetPoint("TOPLEFT", child.Tabs[i - 1], "TOPRIGHT", -15, 0)
					end
				end

				for _, subChild in pairs {child:GetChildren()} do
					if subChild.ScrollBar then
						B.ReskinTrimScroll(subChild.ScrollBar)
						break
					end
				end

				break
			end
		end
	end
end

function S:BigWigs_Options()
	P.ReskinTooltip(_G.BigWigsOptionsTooltip)

	local AceGUI = LibStub("AceGUI-3.0", true)
	if type(AceGUI.Create) == "function" then
		local Create = AceGUI.Create
		AceGUI.Create = function(self, widgetType)
			local widget = Create(self, widgetType)
			if widgetType == "BossDropdownGroup" and widget and not widget.styled then
				S:Proxy("Reskin", widget.exportInstanceBtn)

				widget.styled = true
			end

			return widget
		end
	end
end

S:RegisterSkin("BigWigs", S.BigWigs, true)
S:RegisterSkin("BigWigs_Options", S.BigWigs_Options)
S:RegisterAceGUIWidget("BigWigsSharedDropdown", S.Ace3_Dropdown)
