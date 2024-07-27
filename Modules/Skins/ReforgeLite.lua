local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function reskinCollapse(self)
	if not self or not self.button then return end

	P.ReskinCollapse(self.button)
	self.button.SetPushedTexture = B.Dummy
	self.button:UpdateTexture()
end

local function SkinRLWidget(self)
	if not self or self.styled then return end

	local objType = self and self:GetObjectType()
	if objType == "EditBox" then
		B.ReskinInput(self, 20)
	elseif objType == "Frame" and self.Button then
		P.ReskinDropDown(self)
		self.Button:SetPoint("RIGHT", -18, 8)
	elseif objType == "CheckButton" then
		B.ReskinCheck(self)
	end

	self.styled = true
end

local widgetCount = 1

local function SkinAllWidgets()
	while _G["ReforgeLiteWidget"..widgetCount] do
		SkinRLWidget(_G["ReforgeLiteWidget"..widgetCount])
		widgetCount = widgetCount + 1
	end
end

local function SkinMethodCategory(self)
	if self.methodCategory and not self.methodCategory.styled then
		reskinCollapse(self.methodCategory)
		S:Proxy("Reskin", self.methodShow)
		S:Proxy("Reskin", self.methodReset)
		S:Proxy("Reskin", self.importWowSims)

		self.methodCategory.styled = true
	end
end

function S:ReforgeLite()
	local frame = _G.ReforgeLite
	if not frame then return end

	hooksecurefunc(frame, "CreateFrame", function()
		B.StripTextures(frame)
		B.SetBD(frame)
		S:Proxy("ReskinClose", frame.close)
		S:Proxy("ReskinScroll", frame.scrollBar)
		S:Proxy("ReskinArrow", frame.presetsButton, "down")
		S:Proxy("ReskinSlider", frame.quality)

		for _, key in ipairs({"savePresetButton", "deletePresetButton", "exportPresetButton","pawnButton", "computeButton", "storedClear", "storedRestore", "debugButton"}) do
			S:Proxy("Reskin", frame[key])
		end

		for _, key in ipairs({"statWeightsCategory", "storedCategory", "settingsCategory"}) do
			reskinCollapse(frame[key])
		end

		for _, cap in ipairs(frame.statCaps) do
			cap.add:SetDisabledTexture(0)
			S:Proxy("Reskin", cap.add)
			cap.add.text = B.CreateFS(cap.add, 18, "+", false, "CENTER", 2, 0)
		end

		for _, item in ipairs(frame.itemData) do
			S:Proxy("ReskinIcon", item.texture)
		end
	end)

	SkinMethodCategory(frame)
	hooksecurefunc(frame, "UpdateMethodCategory", SkinMethodCategory)

	hooksecurefunc(frame, "ShowMethodWindow", function()
		if frame.methodWindow and not frame.methodWindow.styled then
			B.StripTextures(frame.methodWindow)
			B.SetBD(frame.methodWindow)
			S:Proxy("ReskinClose", frame.methodWindow.close)
			S:Proxy("Reskin", frame.methodWindow.reforge)

			for _, item in ipairs(frame.methodWindow.items) do
				S:Proxy("ReskinIcon", item.texture)
			end

			frame.methodWindow.styled = true
		end
	end)

	-- Widget
	SkinAllWidgets()
	for _, method in ipairs({"AddCapPoint", "UpdateStatWeightList", "CreateOptionList", "FillSettings", "ShowMethodWindow"}) do
		if frame[method] and type(frame[method]) == "function" then
			hooksecurefunc(frame, method, SkinAllWidgets)
		end
	end

	-- ErrorFrame
	if frame.DebugMethod then
		hooksecurefunc(frame, "DebugMethod", function()
			local ErrorFrame = _G.ReforgeLiteExportFrame
			if ErrorFrame and not ErrorFrame.styled then
				B.StripTextures(ErrorFrame)
				B.SetBD(ErrorFrame)
				S:Proxy("ReskinClose", ErrorFrame.close)
				S:Proxy("ReskinScroll", ErrorFrame.scroll.ScrollBar)
				ErrorFrame.styled = true
			end
		end)
	end
end

S:RegisterSkin("ReforgeLite", S.ReforgeLite)