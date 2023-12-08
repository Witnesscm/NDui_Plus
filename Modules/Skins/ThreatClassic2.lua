local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function reskinStatusBar(self)
	self:SetBackdrop(nil)
	self.SetBackdrop = B.Dummy

	local backdrop = self.edgeBackdrop or self.backdrop
	if backdrop then
		backdrop:SetBackdrop(nil)
		backdrop.SetBackdrop = B.Dummy
	end
end

function S:ThreatClassic2()
	if not S.db["ClassicThreatMeter"] then return end

	P:Delay(.5, function()
		local frame = _G.ThreatClassic2BarFrame
		if not frame then return end

		local bg = B.SetBD(frame)
		if frame.header:IsShown() then
			bg:SetPoint("TOPLEFT", -C.mult, 18)
		end

		local frameBg = frame.bg
		if frameBg then
			frameBg:SetColorTexture(0, 0, 0, 0)
			frameBg:SetVertexColor(0, 0, 0, 0)
			frameBg.SetVertexColor = B.Dummy
		end

		local header = frame.header
		if header then
			reskinStatusBar(header)
			header:SetStatusBarColor(0, 0, 0, 0)
			header.SetStatusBarColor = B.Dummy
			header.text:SetPoint("LEFT", header, 4, 0)
		end

		for _, child in pairs {frame:GetChildren()} do
			if child:GetObjectType() == "StatusBar" and child.bg and child.val then
				reskinStatusBar(child)
				child.bg:SetVertexColor(0, 0, 0, 0)
				child.bg.SetVertexColor = B.Dummy
			end
		end
	end)
end

S:RegisterSkin("ThreatClassic2", S.ThreatClassic2)

local function loadStyle(event, addon)
	if addon ~= "ThreatClassic2" then return end

	local charKey = DB.MyName .. " - " .. DB.MyRealm
	ThreatClassic2DB = ThreatClassic2DB or {}
	ThreatClassic2DB["profileKeys"] = ThreatClassic2DB["profileKeys"] or {}
	ThreatClassic2DB["profileKeys"][charKey] = ThreatClassic2DB["profileKeys"][charKey] or charKey
	ThreatClassic2DB["profiles"] = ThreatClassic2DB["profiles"] or {}
	ThreatClassic2DB["profiles"][charKey] = ThreatClassic2DB["profiles"][charKey] or {}

	local profileKey = ThreatClassic2DB["profileKeys"][charKey]
	local profile = profileKey and ThreatClassic2DB["profiles"][profileKey]
	if profile then
		profile.bar = profile.bar or {}
		profile.bar.texture = profile.bar.texture or "normTex"
		profile.bar.padding = 2
	end

	B:UnregisterEvent(event, loadStyle)
end

B:RegisterEvent("ADDON_LOADED", loadStyle)