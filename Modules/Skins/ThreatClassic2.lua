local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function DisableBackdrop(self)
	if not self then return end

	self:SetBackdrop(nil)
	self.SetBackdrop = B.Dummy
	DisableBackdrop(self.edgeBackdrop)
end

local function resetAnchor(self, point)
	local bg = self.parent.__bg
	bg:ClearAllPoints()
	if not point then
		bg:SetOutside()
	elseif point == "TOPLEFT" then
		bg:SetPoint("TOPLEFT", -C.mult, C.mult)
		bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", C.mult, -C.mult)
	elseif point == "BOTTOMLEFT" then
		bg:SetPoint("TOPLEFT", self, "TOPLEFT", -C.mult, C.mult)
		bg:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
	end
end

function S:ThreatClassic2()
	if not S.db["ClassicThreatMeter"] then return end

	P:Delay(.5, function()
		local frame = _G.ThreatClassic2BarFrame
		if not frame then return end

		B.StripTextures(frame)
		frame.__bg = B.SetBD(frame)

		if frame.bg then
			frame.bg.SetVertexColor = B.Dummy
		end

		local header = frame.header
		if header then
			DisableBackdrop(header)
			header:SetStatusBarColor(0, 0, 0, 0)
			header.SetStatusBarColor = B.Dummy
			header.SetStatusBarTexture = B.Dummy
			header.text:SetPoint("LEFT", header, 4, 1)
			header.parent = frame
			hooksecurefunc(header, "SetPoint", resetAnchor)
			hooksecurefunc(header, "Hide", resetAnchor)
		end

		for _, child in pairs {frame:GetChildren()} do
			if child:GetObjectType() == "StatusBar" and child.val then
				DisableBackdrop(child)
			end
		end

		-- Initialize the options of bar texture and padding
		local options = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("ThreatClassic2", "cmd", "MyLib-1.0")
		if options then
			local get = options.args.appearance.get
			local set = options.args.appearance.set
			local texturePath = {"appearance", "bar", "texture"}
			local paddingPath = {"appearance", "bar", "padding"}
			local texture = get(texturePath)
			if texture == "TC2 Default" then
				set(texturePath, "normTex")
				set(paddingPath, 2)
			else
				set(texturePath, texture) -- TC2:UpdateFrame()
			end
		end
	end)
end

S:RegisterSkin("ThreatClassic2", S.ThreatClassic2)