local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local _G = getfenv(0)
local select, pairs, type = select, pairs, type

-- Math
do
	-- AceTimer
	_G.LibStub("AceTimer-3.0"):Embed(P)

	function P:WaitFunc(elapse)
		local i = 1
		while i <= #P.WaitTable do
			local data = P.WaitTable[i]
			if data[1] > elapse then
				data[1], i = data[1] - elapse, i + 1
			else
				tremove(P.WaitTable, i)
				data[2](unpack(data[3]))

				if #P.WaitTable == 0 then
					P.WaitFrame:Hide()
				end
			end
		end
	end

	P.WaitTable = {}
	P.WaitFrame = CreateFrame("Frame", "NDuiPlus_WaitFrame", _G.UIParent)
	P.WaitFrame:SetScript("OnUpdate", P.WaitFunc)

	function P:Delay(delay, func, ...)
		if type(delay) ~= "number" or type(func) ~= "function" then
			return false
		end

		if delay < 0.01 then delay = 0.01 end

		if select("#", ...) <= 0 then
			C_Timer.After(delay, func)
		else
			tinsert(P.WaitTable,{delay,func,{...}})
			P.WaitFrame:Show()
		end

		return true
	end

	function P.WaitFor(condition, callback, interval, leftTimes)
		leftTimes = (leftTimes or 10) - 1
		interval = interval or 0.1

		if condition() then
			callback()
			return
		end

		if leftTimes and leftTimes <= 0 then
			return
		end

		P:Delay(interval, P.WaitFor, condition, callback, interval, leftTimes)
	end
end

-- UI widgets
do
	P.EasyMenu = CreateFrame("Frame", "NDuiPlus_EasyMenu", UIParent, "UIDropDownMenuTemplate")

	function P:SetupBackdrop()
		Mixin(self, BackdropTemplateMixin)
		self:OnBackdropLoaded()
		self:HookScript("OnSizeChanged", self.OnBackdropSizeChanged)
	end

	function P:CreateButton(width, height, text, discolor, fontSize)
		local bu = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		bu:SetSize(width, height)
		bu.Text:SetFont(DB.Font[1], fontSize or 14, DB.Font[3])
		bu.Text:SetWidth(width - 20)
		bu.Text:SetWordWrap(false)
		if discolor and type(discolor) == "boolean" then
			bu.Text:SetTextColor(1, 1, 1)
		else
			bu.Text:SetTextColor(DB.r, DB.g, DB.b)
		end
		if text then
			bu:SetText(text)
		end
		bu:SetScript("OnEnable", function()
			if discolor and type(discolor) == "boolean" then
				bu.Text:SetTextColor(1, 1, 1)
			else
				bu.Text:SetTextColor(DB.r, DB.g, DB.b)
			end
		end)
		bu:SetScript("OnDisable", function()
			bu.Text:SetTextColor(.5, .5, .5)
		end)
		B.Reskin(bu)

		return bu
	end
end

-- UI skins
do
	local blizzRegions = {
		"Left",
		"Middle",
		"Right",
		"Mid",
		"LeftDisabled",
		"MiddleDisabled",
		"RightDisabled",
		"TopLeft",
		"TopRight",
		"BottomLeft",
		"BottomRight",
		"TopMiddle",
		"MiddleLeft",
		"MiddleRight",
		"BottomMiddle",
		"MiddleMiddle",
		"TabSpacer",
		"TabSpacer1",
		"TabSpacer2",
		"_RightSeparator",
		"_LeftSeparator",
		"Cover",
		"Border",
		"Background",
		"TopTex",
		"TopLeftTex",
		"TopRightTex",
		"LeftTex",
		"BottomTex",
		"BottomLeftTex",
		"BottomRightTex",
		"RightTex",
		"MiddleTex",
	}

	function P:ReskinInput(height, width)
		if not self then
			P.Developer_ThrowError("input is nil")
			return
		end

		local frameName = self.GetName and self:GetName()
		for _, region in pairs(blizzRegions) do
			region = frameName and _G[frameName..region] or self[region]
			if region then
				region:SetAlpha(0)
			end
		end

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", -2, 0)
		bg:SetPoint("BOTTOMRIGHT")
		self.bg = bg

		if height then self:SetHeight(height) end
		if width then self:SetWidth(width) end
	end

	local function updateCollapseTexture(texture, collapsed)
		if collapsed then
			texture:SetTexCoord(0, .4375, 0, .4375)
		else
			texture:SetTexCoord(.5625, 1, 0, .4375)
		end
	end

	local function resetCollapseTexture(self, texture)
		if self.settingTexture then return end
		self.settingTexture = true
		self:SetNormalTexture(0)

		if texture and texture ~= "" then
			if strfind(texture, "Plus") or strfind(texture, "Closed") or texture == 130838 then
				self.__texture:DoCollapse(true)
			elseif strfind(texture, "Minus") or strfind(texture, "Open") or texture == 130821 then
				self.__texture:DoCollapse(false)
			end
			self.bg:Show()
		else
			self.bg:Hide()
		end
		self.settingTexture = nil
	end

	function P:ReskinCollapse(isAtlas)
		if not self then
			P.Developer_ThrowError("collapse is nil")
			return
		end

		self:SetHighlightTexture(0)
		self:SetPushedTexture(0)
		self:SetDisabledTexture(0)

		local bg = B.CreateBDFrame(self, .25, true)
		bg:ClearAllPoints()
		bg:SetSize(13, 13)
		bg:SetPoint("TOPLEFT", self:GetNormalTexture())
		self.bg = bg

		self.__texture = bg:CreateTexture(nil, "OVERLAY")
		self.__texture:SetPoint("CENTER")
		self.__texture:SetSize(7, 7)
		self.__texture:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self.__texture.DoCollapse = updateCollapseTexture

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
		if isAtlas then
			hooksecurefunc(self, "SetNormalAtlas", resetCollapseTexture)
		else
			hooksecurefunc(self, "SetNormalTexture", resetCollapseTexture)
		end

		hooksecurefunc(self, "Enable", function()
			self.__texture:SetDesaturated(false)
		end)
		hooksecurefunc(self, "Disable", function()
			self.__texture:SetDesaturated(true)
		end)
	end

	function P:ReskinFrame()
		if not self then
			P.Developer_ThrowError("frame is nil")
			return
		end

		B.StripTextures(self)
		local bg = B.SetBD(self)

		local frameName = self.GetName and self:GetName()
		for _, key in pairs({"Header", "header"}) do
			local frameHeader = self[key] or (frameName and _G[frameName..key])
			if frameHeader then
				B.StripTextures(frameHeader, 0)

				frameHeader:ClearAllPoints()
				frameHeader:SetPoint("TOP", bg, "TOP", 0, 5)
			end
		end
		for _, key in pairs({"Portrait", "portrait"}) do
			local framePortrait = self[key] or (frameName and _G[frameName..key])
			if framePortrait then framePortrait:SetAlpha(0) end
		end

		local closeButton = self.CloseButton or (frameName and _G[frameName.."CloseButton"]) or self.Close
		if closeButton then B.ReskinClose(closeButton) end

		return bg
	end

	function P:ReskinDropDown()
		if not self then
			P.Developer_ThrowError("dropdown is nil")
			return
		end

		B.StripTextures(self)

		local frameName = self.GetName and self:GetName()
		local down = self.Button or frameName and (_G[frameName.."Button"] or _G[frameName.."_Button"])
		if not down then
			P.Developer_ThrowError("dropdown button is nil")
			return
		end

		down:ClearAllPoints()
		down:SetPoint("RIGHT", -18, 2)
		B.ReskinArrow(down, "down")
		down:SetSize(18, 18)

		local bg = B.CreateBDFrame(self, 0)
		bg:ClearAllPoints()
		bg:SetPoint("LEFT", 16, 0)
		bg:SetPoint("TOPRIGHT", down, "TOPRIGHT")
		bg:SetPoint("BOTTOMRIGHT", down, "BOTTOMRIGHT")
		B.CreateGradient(bg)
		self.bg = bg
	end

	function P.ReskinFont(font, size)
		if not font then
			P.Developer_ThrowError("font is nil")
			return
		end

		local oldSize = select(2, font:GetFont())
		size = size or oldSize
		local fontSize = size*C.db["Skins"]["FontScale"]
		font:SetFont(DB.Font[1], fontSize, DB.Font[3])
		font:SetShadowColor(0, 0, 0, 0)
	end

	function P:ReskinTab(offset)
		if not self then
			P.Developer_ThrowError("tab is nil")
			return
		end

		offset = offset or 0

		self:DisableDrawLayer("BACKGROUND")

		local bg = B.CreateBDFrame(self)
		bg:SetPoint("TOPLEFT", 8 - offset, -3)
		bg:SetPoint("BOTTOMRIGHT", -8 + offset, 0)

		self:SetHighlightTexture(DB.bdTex)
		local hl = self:GetHighlightTexture()
		hl:ClearAllPoints()
		hl:SetInside(bg)
		hl:SetVertexColor(cr, cg, cb, .25)
	end

	function P:ReskinTooltip()
		if not self then
			P.Developer_ThrowError("tooltip is nil")
			return
		end

		if self:IsForbidden() then return end

		if not self.tipStyled then
			self:HideBackdrop()
			self:DisableDrawLayer("BACKGROUND")
			self.bg = B.SetBD(self, .7)
			self.bg:SetInside(self)

			self.tipStyled = true
		end
	end

	function P:Button_OnEnter()
		if not self:IsEnabled() then return end

		if C.db["Skins"]["FlatMode"] then
			self.__gradient:SetVertexColor(cr / 4, cg / 4, cb / 4)
		else
			self.__bg:SetBackdropColor(cr, cg, cb, .25)
		end
		self.__bg:SetBackdropBorderColor(cr, cg, cb)
	end

	function P:Button_OnLeave()
		if C.db["Skins"]["FlatMode"] then
			self.__gradient:SetVertexColor(.3, .3, .3, .25)
		else
			self.__bg:SetBackdropColor(0, 0, 0, 0)
		end
		self.__bg:SetBackdropBorderColor(0, 0, 0)
	end

	function P:RemoveBD()
		for _, child in pairs {self:GetChildren()} do
			if child.backdropInfo and (child.backdropInfo.bgFile == DB.bdTex and child.backdropInfo.edgeSize == C.mult) then
				child:Hide()
				child:SetAlpha(0)
				break
			end
		end
	end

	-- Temporary fix
	do
		hooksecurefunc(B, "ReskinPortraitFrame", function(self)
			if self.PortraitContainer then
				self.PortraitContainer:SetAlpha(0)
			end
			if self.portrait then
				self.portrait:SetAlpha(0)
			end
		end)
	end
end

-- Misc
do
	local function Tooltip_OnEnter(self)
		GameTooltip:SetOwner(self, self.anchor)
		GameTooltip:ClearLines()
		if self.title then
			GameTooltip:AddLine(self.title)
		end
		if tonumber(self.text) then
			GameTooltip:SetSpellByID(self.text)
		elseif self.text then
			local r, g, b = 1, 1, 1
			if self.color == "class" then
				r, g, b = cr, cg, cb
			elseif self.color == "system" then
				r, g, b = 1, .8, 0
			elseif self.color == "info" then
				r, g, b = .6, .8, 1
			end
			GameTooltip:AddLine(self.text, r, g, b, 1)
		end
		GameTooltip:Show()
	end

	function P:AddTooltip(anchor, text, color, showTips)
		self.anchor = anchor
		self.text = text
		self.color = color
		if showTips then self.title = L["Tips"] end
		self:HookScript("OnEnter", Tooltip_OnEnter)
		self:HookScript("OnLeave", B.HideTooltip)
	end

	function P:AnchorTooltip()
		if self:GetRight() >= (GetScreenWidth() / 2) then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		end
	end

	function P.NameGenerator(name)
		local index = 0
		return function()
			index = index + 1
			return name .. index
		end
	end

	function P.LeftButtonTip(text)
		return P.LEFT_MOUSE_BUTTON .. text
	end

	function P.RightButtonTip(text)
		return P.RIGHT_MOUSE_BUTTON .. text
	end

	function P.TextureString(texture, data)
		return format("|T%s:%s|t", texture, data or "16")
	end

	function P.AtlasString(atlas, data)
		return format("|A:%s:%s|a", atlas, data or "16:16")
	end

	function P.CopyTable(tbl)
		local copy = {}
		for k, v in pairs(tbl) do
			if type(v) == "table" then
				copy[k] = P.CopyTable(v)
			else
				copy[k] = v
			end
		end
		return copy
	end

	function P.Memorize(func)
		local cache = {}

		return function(k, ...)
			if not k then
				return
			end
			if not cache[k] then
				cache[k] = func(k, ...)
			end
			return cache[k]
		end
	end

	function P:SecureHook(object, method, handler)
		if not handler then
			method, handler, object = object, method, nil
		end

		if object and type(object) == "string" then
			object = _G[object]
		end

		if object then
			if object[method] then
				hooksecurefunc(object, method, handler)
			else
				P.Developer_ThrowError(format("Attempting to hook a non existing function %s", method))
			end
		else
			if _G[method] then
				hooksecurefunc(method, handler)
			else
				P.Developer_ThrowError(format("Attempting to hook a non existing function %s", method))
			end
		end
	end
end