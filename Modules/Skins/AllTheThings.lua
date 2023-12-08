local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function reanchorSkillFrame(self)
	if _G.SkilletFrame then
		self:SetPoint("TOPLEFT", _G.SkilletFrame, "TOPRIGHT", 4, 0)
		self:SetPoint("BOTTOMLEFT", _G.SkilletFrame, "BOTTOMRIGHT", 4, 0)
	elseif _G.CraftFrame and _G.CraftFrame:IsVisible() then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", _G.CraftFrame, "TOPRIGHT", -27, -11)
		self:SetPoint("BOTTOMLEFT", _G.CraftFrame, "BOTTOMRIGHT", -27, 71)
	elseif _G.TradeSkillFrame and _G.TradeSkillFrame:IsVisible() then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", _G.TradeSkillFrame, "TOPRIGHT", -27, -11)
		self:SetPoint("BOTTOMLEFT", _G.TradeSkillFrame, "BOTTOMRIGHT", -27, 71)
	end
end

local function reskinATTFrame(frame, suffix)
	B.StripTextures(frame)
	frame.bg = B.SetBD(frame)
	B.ReskinClose(frame.CloseButton, nil, -4, -4)
	B.ReskinScroll(frame.ScrollBar)

	frame.ScrollBar:SetPoint("TOP", frame.CloseButton, "BOTTOM", 0, -22)
	frame.Container:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -26)
	frame.Container:SetPoint("RIGHT", frame.ScrollBar, "LEFT", -4, 0)
	frame.Container:SetPoint("BOTTOM", frame, "BOTTOM", 0, 6)

	if suffix == "Tradeskills" and frame.UpdateDefaultFrameVisibility then
		hooksecurefunc(frame, "UpdateDefaultFrameVisibility", reanchorSkillFrame)
	end
end

function S:AllTheThings()
	local ATTC = _G.ATTC
	if not ATTC then return end

	for suffix, frame in pairs(ATTC.Windows) do
		reskinATTFrame(frame, suffix)
		frame.styled = true
	end

	hooksecurefunc(ATTC, "GetWindow", function(self, suffix, ...)
		local frame = self.Windows[suffix]
		if frame and not frame.styled then
			reskinATTFrame(frame, suffix)
			frame.styled = true
		end
	end)

	local model = _G.ATTGameTooltipModel
	B.StripTextures(model)
	model.bg = B.SetBD(model, .7)
	model.bg:SetInside()
end

S:RegisterSkin("ATT-Classic", S.AllTheThings)