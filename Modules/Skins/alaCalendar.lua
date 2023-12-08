local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local ipairs = ipairs
local r, g, b = DB.r, DB.g, DB.b

local function expandOnEnter(self)
	if self:IsEnabled() then
		self.bg:SetBackdropColor(r, g, b, .25)
	end
end

local function expandOnLeave(self)
	self.bg:SetBackdropColor(0, 0, 0, .25)
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
	self:SetTexture("")

	local frame = self:GetParent()
	if texture and texture ~= "" then
		texture = strlower(texture)
		if strfind(texture, "plus") or strfind(texture, "closed") or texture == "130838" then
			frame.__texture:DoCollapse(true)
		elseif strfind(texture, "minus") or strfind(texture, "open") or texture == "130821" then
			frame.__texture:DoCollapse(false)
		end
		frame.bg:Show()
	else
		frame.bg:Hide()
	end
	self.settingTexture = nil
end

local function reskinCollapseTex(self)
	self:SetTexture("")
	local frame = self:GetParent()

	local bg = B.CreateBDFrame(self, .25, true)
	bg:ClearAllPoints()
	bg:SetPoint("CENTER", self)
	bg:SetSize(13, 13)
	frame.bg = bg

	frame.__texture = bg:CreateTexture(nil, "OVERLAY")
	frame.__texture:SetPoint("CENTER")
	frame.__texture:SetSize(7, 7)
	frame.__texture:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
	frame.__texture.DoCollapse = updateCollapseTexture

	frame:HookScript("OnEnter", expandOnEnter)
	frame:HookScript("OnLeave", expandOnLeave)

	hooksecurefunc(self, "SetTexture", resetCollapseTexture)

	hooksecurefunc(self, "Show", function()
		self:GetParent().bg:Show()
		self:GetParent().__texture:Show()
	end)

	hooksecurefunc(self, "Hide", function()
		self:GetParent().bg:Hide()
		self:GetParent().__texture:Hide()
	end)
end

local function updateArrowDirection(self, bool)
	if not self.__texture then return end

	if self.__direction == "left" then
		bool = not bool
	end

	B.SetupArrow(self.__texture, bool and "left" or "right")
end

local function reskinArrowButton(self, direction)
	B.ReskinArrow(self, direction)
	self.__direction = direction
	self.Texture = updateArrowDirection
end

local function alaCalendarSkin()
	-- calendar
	local frame = _G.ALA_CALENDAR
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame, nil, 3, C.mult, -3, 3)
		B.ReskinClose(frame.close, nil, -10, -6)
		B.ReskinArrow(frame.prev, "left")
		B.ReskinArrow(frame.next, "right")
		reskinArrowButton(frame.call_board, "right")
		frame.call_board:ClearAllPoints()
		frame.call_board:SetPoint("TOP", frame.close, "BOTTOM", 0, -8)

		for col = 1, 7 do
			local bg = frame.weekTitles[col][1]
			bg:Hide()
		end

		for row, rowcells in ipairs(frame.cells) do
			for col, cell in ipairs(rowcells) do
				cell:DisableDrawLayer("BACKGROUND")
				cell:DisableDrawLayer("OVERLAY")
				cell:SetHighlightTexture(DB.bdTex)
				local hl = cell:GetHighlightTexture()
				hl:SetVertexColor(r, g, b, .25)

				if row == 1 and col < 7 then
					local vline = CreateFrame("Frame", nil, cell, "BackdropTemplate")
					vline:SetHeight(540)
					vline:SetWidth(1)
					vline:SetPoint("TOP", cell, "TOPRIGHT")
					B.CreateBD(vline)
				end

				if col == 1 then
					local hline = CreateFrame("Frame", nil, cell, "BackdropTemplate")
					hline:SetWidth(631)
					hline:SetHeight(1)
					hline:SetPoint("LEFT", cell, "TOPLEFT")
					B.CreateBD(hline)
				end

				cell.todayBD = B.CreateBDFrame(cell)
				cell.todayBD:SetAllPoints()
				cell.todayBD:SetBackdropColor(r, g, b, .25)
				cell.todayBD:SetBackdropBorderColor(r, g, b)
				cell.todayBD:SetFrameLevel(cell:GetFrameLevel() + 5)
				cell.todayBD:Hide()
				hooksecurefunc(cell, "Today", function(self)
					self.todayBD:Show()
				end)

				hooksecurefunc(cell, "NotToday", function(self)
					self.todayBD:Hide()
				end)

				cell.dark = B.CreateBDFrame(cell, .4)
				cell.dark:SetAllPoints()
				cell.dark:SetBackdropBorderColor(0, 0, 0, 0)
				hooksecurefunc(cell, "Bright", function(self)
					self.dark:Hide()
				end)

				hooksecurefunc(cell, "Dark", function(self)
					self.dark:Show()
				end)
			end
		end
	end

	-- board
	local board = _G.ALA_CALENDAR_BOARD
	B.StripTextures(board)
	B.SetBD(board, nil, -C.mult*2, C.mult, C.mult, -27)
	B.ReskinClose(board.close)
	board.close:ClearAllPoints()
	board.close:SetPoint("TOPLEFT", board, "TOPLEFT", 6, -6)

	if board.call_calendar then
		reskinArrowButton(board.call_calendar, "left")
		board.call_calendar:ClearAllPoints()
		board.call_calendar:SetPoint("TOP", board.close, "BOTTOM", 0, -8)
		board.call_calendar.str:SetPoint("LEFT", board.call_calendar, "RIGHT", 4, 0)
	end

	reskinArrowButton(board.call_char_list, "left")
	board.call_char_list.str:SetPoint("LEFT", board.call_char_list, "RIGHT", 4, 0)

	hooksecurefunc(board.scroll, "UpdateButtons", function(self)
		local scrollChild = self:GetScrollChild()
		if scrollChild then
			for _, child in pairs {scrollChild:GetChildren()} do
				if child and child.collapse and child.glow and not child.styled then
					reskinCollapseTex(child.collapse)
					child.glow:SetAlpha(0)

					child.styled = true
				end
			end
		end
	end)

	-- config
	local config = _G.ALA_CALENDAR_CONFIG
	B.StripTextures(config)
	B.SetBD(config)
	B.ReskinClose(config.close)

	for _, object in pairs(config.set_objects) do
		local objectType = object:GetObjectType()
		if objectType == "Button" then
			B.ReskinArrow(object, "down")
		elseif objectType == "CheckButton" then
			B.ReskinCheck(object)
		elseif objectType == "Slider" then
			B.ReskinSlider(object)
		end
	end

	for _, object in pairs(config.inst_objects) do
		B.ReskinCheck(object)
	end

	local charlist = config.char_list
	B.StripTextures(charlist)
	B.SetBD(charlist)

	reskinArrowButton(config.call_char_list, "right")
end

function S:alaCalendar()
	if not S.db["alaCalendar"] then return end

	local alaCal = _G.__ala_meta__ and _G.__ala_meta__.cal
	if not alaCal then return end

	if alaCal.CreateUI then
		hooksecurefunc(alaCal, "CreateUI", alaCalendarSkin)
	end
end

S:RegisterSkin("alaCalendar", S.alaCalendar)