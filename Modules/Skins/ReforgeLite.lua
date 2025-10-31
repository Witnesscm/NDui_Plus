local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function ReskinCollapse(self)
	if not self then
		P.Developer_ThrowError("ReforgeLite object is nil")
		return
	end

	P.ReskinCollapse(self)
	self.SetPushedTexture = B.Dummy
	self:UpdateTexture()
end

local function ReskinHelpButton(self)
	if not self then
		P.Developer_ThrowError("ReforgeLite object is nil")
		return
	end

	if self.Ring then
		self.Ring:SetAlpha(0)
	end
end

local function ReskinItemButton(self)
	if not self or not self.texture or not self.quality then
		P.Developer_ThrowError("ReforgeLite object is nil")
		return
	end

	self.texture:SetInside()
	self.bg = B.ReskinIcon(self.texture)
	B.ReskinIconBorder(self.quality, true)
end

local function ReskinDropDown(self)
	B.StripTextures(self)
	if self.Arrow then self.Arrow:SetAlpha(0) end
	if self.Background then self.Background:SetAlpha(0) end

	local bg = B.CreateBDFrame(self, 0, true)
	bg:SetAllPoints()
	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetPoint("RIGHT", bg, -3, 0)
	tex:SetSize(18, 18)
	B.SetupArrow(tex, "down")
	self.__texture = tex

	self:HookScript("OnEnter", B.Texture_OnEnter)
	self:HookScript("OnLeave", B.Texture_OnLeave)
end

local function SkinRLWidget(self)
	if not self or self.styled then return end

	local objType = self and self:GetObjectType()
	if objType == "EditBox" then
		B.ReskinInput(self, 20)
	elseif objType == "Button" and self.Left and self.Middle and self.Right and self.Text then
		B.Reskin(self)
	elseif objType == "Button" and self.Arrow and self.Text then
		ReskinDropDown(self)
	elseif objType == "Button" and self.ResetButton and self.Text then
		B.ReskinFilterButton(self)
	elseif objType == "CheckButton" then
		B.ReskinCheck(self)
	elseif objType == "Slider" then
		B.ReskinSlider(self)
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

function S:ReforgeLite()
	local ReforgeLite = _G.ReforgeLite
	if not ReforgeLite then return end

	-- Main Frame
	hooksecurefunc(ReforgeLite, "CreateFrame", function(self)
		B.StripTextures(self)
		B.SetBD(self)
		S:Proxy("ReskinClose", self.close)
		S:Proxy("ReskinScroll", self.scrollBar)

		for _, cap in ipairs(self.statCaps) do
			cap.add:SetDisabledTexture(0)
			S:Proxy("Reskin", cap.add)
			cap.add.text = B.CreateFS(cap.add, 18, "+", false, "CENTER", 2, 0)
		end

		for _, item in ipairs(self.itemData) do
			ReskinItemButton(item)
		end

		for _, key in ipairs({"itemLockHelpButton", "statWeightsHelpButton", "statCapsHelpButton"}) do
			local helpBtn = self[key]
			if helpBtn then
				ReskinHelpButton(helpBtn)
			end
		end
	end)

	local CreateCategory = ReforgeLite.CreateCategory
	ReforgeLite.CreateCategory = function(...)
		local category = CreateCategory(...)
		ReskinCollapse(category.button)
		return category
	end

	hooksecurefunc(ReforgeLite, "UpdateMethodCategory", function(self)
		local frame = self.methodCategory
		if frame and not frame.styled then
			ReskinHelpButton(self.methodHelpButton)
			ReskinHelpButton(self.expertiseToHitHelpButton)

			frame.styled = true
		end
	end)

	-- Method Window
	hooksecurefunc(ReforgeLite, "CreateMethodWindow", function(self)
		local frame = self.methodWindow
		if frame and not frame.styled then
			B.StripTextures(frame)
			B.SetBD(frame)
			S:Proxy("ReskinClose", frame.close)
			ReskinHelpButton(frame.helpButton)

			for _, item in ipairs(frame.items) do
				ReskinItemButton(item)
			end

			frame.styled = true
		end
	end)

	-- All Widgets
	SkinAllWidgets()
	for _, method in ipairs({"AddCapPoint", "UpdateStatWeightList", "CreateOptionList", "FillSettings", "ShowMethodWindow"}) do
		if ReforgeLite[method] and type(ReforgeLite[method]) == "function" then
			hooksecurefunc(ReforgeLite, method, SkinAllWidgets)
		end
	end

	-- Import Button
	hooksecurefunc(ReforgeLite, "CreateImportButton", function(self)
		local button = self.importButton
		if button and not button.styled then
			B.Reskin(button)
			button.styled = true
		end
	end)
end

S:RegisterSkin("ReforgeLite", S.ReforgeLite)