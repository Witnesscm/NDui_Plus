local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function SkinListButton(self)
	if not self.styled then
		self:DisableDrawLayer("BACKGROUND")
		self.Check:SetAtlas("checkmark-minimal")
		B.ReskinIcon(self.icon)
		B.ReskinCollapse(self.ToggleButton)
		self.ToggleButton:GetPushedTexture():SetAlpha(0)

		self.bg = B.CreateBDFrame(self, .25)
		self.bg:SetAllPoints()
		self.SelectedBar:SetColorTexture(DB.r, DB.g, DB.b, .25)
		self.SelectedBar:SetInside(self.bg)
		local hl = self:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(self.bg)

		self.styled = true
	end

	self.bg:SetShown(not not (self.data and not self.data.text))
end

function S:TalentLoadoutsEx()
	P:Delay(.1, function()
		local frame = _G.TalentLoadoutExMainFrame
		if not frame then return end

		B.StripTextures(frame)
		B.SetBD(frame, nil, 0, 0, 0, 0)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", _G.PlayerSpellsFrame, "TOPRIGHT", 1, 0)
		frame:SetPoint("BOTTOMLEFT", _G.PlayerSpellsFrame, "BOTTOMRIGHT", 1, 0)
		S:Proxy("ReskinTrimScroll", frame.ScrollBar)

		for _, key in ipairs({"ImportButton", "ExportButton", "LoadButton", "SaveButton", "EditButton", "DeleteButton", "UpButton", "DownButton"}) do
			S:Proxy("Reskin", frame[key])
		end

		for _, button in frame.ScrollBox:EnumerateFrames() do
			SkinListButton(button)
		end

		hooksecurefunc(frame.ScrollBox, "Update", function(self)
			self:ForEachFrame(SkinListButton)
		end)

		local popupFrame = frame.EditPopupFrame
		if popupFrame then
			B.ReskinIconSelector(popupFrame)

			local listFrame = popupFrame.IconListFrame
			if listFrame then
				B.StripTextures(listFrame)
				B.SetBD(listFrame):SetInside()
				listFrame:ClearAllPoints()
				listFrame:SetPoint("TOPLEFT", popupFrame, "BOTTOMLEFT")
				listFrame:SetPoint("TOPRIGHT", popupFrame, "BOTTOMRIGHT")

				for _, child in pairs {listFrame:GetChildren()} do
					if child.icon and child.name then
						local hl = child:GetHighlightTexture()
						hl:SetColorTexture(1, 1, 1, .25)
						hl:SetAllPoints(child.texture)
						B.ReskinIcon(child.texture)
					end
				end
			end
		end

		local pvpFrame = frame.PvpFrame
		if pvpFrame then
			B.StripTextures(pvpFrame)
			S:Proxy("ReskinCheck", pvpFrame.CheckButton)
		end
	end)
end

P:AddCallbackForAddon("Blizzard_PlayerSpells", S.TalentLoadoutsEx)