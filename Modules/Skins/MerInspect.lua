local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function ReskinListPanel(frame)
	frame:SetBackdrop(nil)
	frame.SetBackdrop = B.Dummy
	frame:SetBackdropColor(0, 0, 0, 0)
	frame.SetBackdropColor = B.Dummy
	frame:SetBackdropBorderColor(0, 0, 0, 0)
	frame.SetBackdropBorderColor = B.Dummy
	frame.GetBackdrop = function(self)
		return self.backdrop
	end

	frame.bg = B.SetBD(frame, nil, 0, C.mult, 0, -C.mult)
end

local function ReskinPortraitFrame(self, unit)
	self:SetScale(.85)
	B.StripTextures(self)
	SetPortraitTexture(self.Portrait, unit)
	self.PortraitRingQuality:SetTexture("Interface\\Masks\\CircleMaskScalable")
	self.PortraitRingQuality:SetSize(50, 50)
	self.PortraitRingQuality:SetDrawLayer("BACKGROUND")
	self.PortraitRingQuality:ClearAllPoints()
	self.PortraitRingQuality:SetPoint("CENTER", self.Portrait)
end

function S:MerInspect()
	if not S.db["MerInspect"] then return end

	if not _G.ShowInspectItemListFrame then return end

	hooksecurefunc("ShowInspectItemListFrame", function(unit, parent)
		local frame = parent.inspectFrame
		if not frame then return end

		if not frame.styled then
			ReskinListPanel(frame)
			ReskinPortraitFrame(frame.portrait, unit)

			local specicon = frame.specicon
			specicon:SetSize(41, 41)
			specicon:ClearAllPoints()
			specicon:SetPoint("TOPRIGHT", -14, -14)
			specicon:SetAlpha(1)
			specicon:SetMask("Interface\\Masks\\CircleMaskScalable")
			local spectext = frame.spectext
			B.SetFontSize(spectext, 12)
			spectext:SetAlpha(1)

			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child and child.itemString then
					child.itemString:SetFont(child.itemString:GetFont(), 13, "OUTLINE") -- 装备字体描边
				end
			end

			if frame == _G.PaperDollFrame.inspectFrame then
				frame:SetHeight(422)
			end

			frame.styled = true
		end

		local frameName = parent:GetName()
		local p1, rel, p2, x, y = frame:GetPoint()
		if frameName == "InspectFrame" then
			frame:SetPoint(p1, rel, p2, x + 2, y)
		elseif not frameName then
			frame:SetPoint(p1, rel, p2, x + C.mult, y)
		end
	end)

	if not _G.ClassicStatsFrameTemplate_OnShow then return end

	hooksecurefunc("ClassicStatsFrameTemplate_OnShow", function(frame)
		local unit = frame.data.unit or "player"
		if not frame.styled then
			B.StripTextures(frame)
			ReskinListPanel(frame)
			ReskinPortraitFrame(frame.PortraitFrame, unit)

			for _, key in pairs({"AttributesCategory", "ResistanceCategory", "EnhancementsCategory", "SuitCategory"}) do
				local category = frame[key]
				if category then
					B.StripTextures(category)
					local line = category:CreateTexture(nil, "ARTWORK")
					line:SetSize(180, C.mult)
					line:SetPoint("BOTTOM", 0, 5)
					line:SetColorTexture(1, 1, 1, .25)
				end
			end

			if unit == "player" then
				hooksecurefunc(frame, "SetPoint", function(_, _, rel)
					frame:SetHeight((rel == PaperDollFrame or rel == PaperDollFrame.inspectFrame) and 422 or 424)
				end)
			end

			frame.styled = true
		end

		if unit == "player" and frame:GetHeight() <= 424 then
			frame:SetHeight(422)
		end
	end)
end

S:RegisterSkin("MerInspect", S.MerInspect)