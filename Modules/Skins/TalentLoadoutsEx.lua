local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function ReskinChildButton(self)
	if not self then
		P.Developer_ThrowError("object is nil")
		return
	end

	for _, child in pairs {self:GetChildren()} do
		if child:GetObjectType() == "Button" and child.Left and child.Middle and child.Right and child.Text then
			B.Reskin(child)
		end
	end
end

local function SkinListButton(self)
	if not self.styled then
		self:DisableDrawLayer("BACKGROUND")
		self.Check:SetAtlas("checkmark-minimal")
		S:Proxy("ReskinIcon", self.Icon)
		S:Proxy("ReskinCollapse", self.ToggleButton)
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

local function ReskinPopupFrame(self)
	if not self then
		P.Developer_ThrowError("object is nil")
		return
	end

	S:Proxy("StripTextures", self.Border)
	S:Proxy("StripTextures", self.Header)
	S:Proxy("StripTextures", self.Main)
	B.SetBD(self)
end

function S:TalentLoadoutsEx()
	P.WaitFor(function()
		return not not _G.TalentLoadoutExMainFrame
	end, function()
		local frame = _G.TalentLoadoutExMainFrame
		B.StripTextures(frame)
		B.SetBD(frame, nil, 0, 0, 0, 0)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", _G.PlayerSpellsFrame, "TOPRIGHT", 1, 0)
		frame:SetPoint("BOTTOMLEFT", _G.PlayerSpellsFrame, "BOTTOMRIGHT", 1, 0)
		S:Proxy("ReskinTrimScroll", frame.ScrollBar)
		ReskinChildButton(frame)

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

			local textFrame = popupFrame.TalentTextFrame
			if textFrame then
				B.StripTextures(textFrame)
				B.SetBD(textFrame):SetInside()
				textFrame:ClearAllPoints()
				textFrame:SetPoint("BOTTOMLEFT", popupFrame, "TOPLEFT")
				textFrame:SetPoint("BOTTOMRIGHT", popupFrame, "TOPRIGHT")
				S:Proxy("StripTextures", textFrame.Main)

				local editBox = textFrame.Main and textFrame.Main.EditBox
				if editBox then
					B.ReskinInput(editBox)
					editBox:ClearAllPoints()
					editBox:SetPoint("TOPLEFT", 2, -2)
					editBox:SetPoint("BOTTOMRIGHT", -2, 2)
				end
			end
		end

		local textPopup = frame.TextPopupFrame and frame.TextPopupFrame.Main
		if textPopup then
			ReskinPopupFrame(frame.TextPopupFrame)
			S:Proxy("StripTextures", textPopup.ScrollFrame)
			S:Proxy("CreateBDFrame", textPopup.ScrollFrame, .25)
			S:Proxy("ReskinScroll", textPopup.ScrollFrame and textPopup.ScrollFrame.ScrollBar)
			ReskinChildButton(textPopup)
		end

		local presetPopup = frame.PresetPopupFrame and frame.PresetPopupFrame.Main
		if presetPopup then
			ReskinPopupFrame(frame.PresetPopupFrame)
			S:Proxy("ReskinDropDown", presetPopup.AddonDropDownMenu)

			local configFrame = presetPopup.AddonConfigFrame1
			if configFrame then
				S:Proxy("ReskinDropDown", configFrame.ModeOptionFrame and configFrame.ModeOptionFrame.DropDownMenu)
				S:Proxy("ReskinCheck", configFrame.CombineOptionFrame and configFrame.CombineOptionFrame.CheckButton)
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