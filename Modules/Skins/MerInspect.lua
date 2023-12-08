local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local M = B:GetModule("Misc")

local _G = getfenv(0)
local select, pairs = select, pairs

local function reskinInspect(frame)
	frame:SetBackdrop(nil)
	frame.SetBackdrop = B.Dummy
	frame:SetBackdropColor(0, 0, 0, 0)
	frame.SetBackdropColor = B.Dummy
	frame:SetBackdropBorderColor(0, 0, 0, 0)
	frame.SetBackdropBorderColor = B.Dummy
	frame.GetBackdrop = function(self)
		return self.backdrop
	end

	if frame:GetHeight() <= 424 then frame:SetHeight(422) end
	frame.bg = B.SetBD(frame, nil, 0, C.mult, 0, -C.mult)
end

function S:MerInspect()
	if not S.db["MerInspect"] then return end

	if not _G.ShowInspectItemListFrame then return end

	hooksecurefunc("ShowInspectItemListFrame", function(_, parent)
		local frame = parent.inspectFrame
		if not frame then return end

		if not frame.styled then
			reskinInspect(frame)

			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child and child.itemString then
					child.itemString:SetFont(child.itemString:GetFont(), 13, "OUTLINE") -- 装备字体描边
				end
			end

			frame.styled = true
		end

		local frameName = parent:GetName()
		if frameName == "PaperDollFrame" then
			frame.bg:SetPoint("TOPLEFT", -C.mult, C.mult)
		elseif frameName == "InspectFrame" then
			frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", -33, -15-C.mult)
		else
			frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", C.mult, 0)
		end
	end)

	if not _G.ClassicStatsFrameTemplate_OnShow then return end

	hooksecurefunc("ClassicStatsFrameTemplate_OnShow", function(self)
		if self:GetHeight() <= 424 then self:SetHeight(422) end

		if not self.styled then
			B.StripTextures(self)
			reskinInspect(self)

			for _, key in pairs({"AttributesCategory", "ResistanceCategory", "EnhancementsCategory", "SuitCategory"}) do
				local category = self[key]
				if category then
					B.StripTextures(category)
					local line = category:CreateTexture(nil, "ARTWORK")
					line:SetSize(180, C.mult)
					line:SetPoint("BOTTOM", 0, 5)
					line:SetColorTexture(1, 1, 1, .25)
				end
			end

			self.styled = true
		end
	end)
end

S:RegisterSkin("MerInspect", S.MerInspect)