local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:MountJournalEnhanced()
	if not C_AddOns.IsAddOnLoaded("MountJournalEnhanced") then return end

	P:Delay(.1, function()
		for _, child in pairs({_G.MountJournal:GetChildren()}) do
			local objType = child:GetObjectType()
			if objType == "Frame" then
				if child.staticText and child.uniqueCount then
					B.StripTextures(child)
					B.CreateBDFrame(child, .25)
				end
			elseif objType == "Button" then
				if child.BlackCover and child.LockIcon then
					child:DisableDrawLayer("OVERLAY")
					child:SetPushedTexture(DB.pushedTex)
					child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					B.ReskinIcon(child.texture)
				elseif child:GetFrameLevel() == 510 then
					child:DisableDrawLayer("BACKGROUND")
				elseif child:GetText() == "!" then
					B.Reskin(child)
				end
			end
		end

		P.ReskinTooltip(_G.MJEMountSpecialButtonToolTip)
		P.ReskinTooltip(_G.MJEStatisticsHelpToolTip)
		P.ReskinTooltip(_G.MJEMountSpecialButtonToolTip)

		hooksecurefunc("MountJournal_InitMountButton", function(button)
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
		end)
	end)
end

P:AddCallbackForAddon("Blizzard_Collections", S.MountJournalEnhanced)