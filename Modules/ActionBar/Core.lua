local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:RegisterModule("ActionBar")
local Bar = B:GetModule("Actionbar")

-- local margin, padding = C.Bars.margin, C.Bars.padding

-- local NDui_ActionBar = {
	-- "NDui_ActionBar1",
	-- "NDui_ActionBar2",
	-- "NDui_ActionBar3",
	-- "NDui_ActionBar4",
	-- "NDui_ActionBar5",
-- }

-- local defaultSettings = {
	-- Fader = false,
	-- ButtonSize = 34,
	-- NumButtons = 12,
	-- NumPerRow = 12,
-- }

-- function AB:UpdateActionBar()
	-- local frame = self
	-- if not frame then return end

	-- frame.buttons = frame.buttons or frame.buttonList

	-- local size = C.db["Actionbar"]["CustomBarButtonSize"]
	-- local scale = size/34
	-- local num = C.db["Actionbar"]["CustomBarNumButtons"]
	-- local perRow = C.db["Actionbar"]["CustomBarNumPerRow"]
	-- for i = 1, num do
		-- local button = frame.buttons[i]
		-- button:SetSize(size, size)
		-- button.Name:SetScale(scale)
		-- button.Count:SetScale(scale)
		-- button.HotKey:SetScale(scale)
		-- button:ClearAllPoints()
		-- if i == 1 then
			-- button:SetPoint("TOPLEFT", frame, padding, -padding)
		-- elseif mod(i-1, perRow) ==  0 then
			-- button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		-- else
			-- button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		-- end
		-- button:SetAttribute("statehidden", false)
		-- button:Show()
	-- end

	-- for i = num+1, 12 do
		-- local button = frame.buttons[i]
		-- button:SetAttribute("statehidden", true)
		-- button:Hide()
	-- end

	-- local column = min(num, perRow)
	-- local rows = ceil(num/perRow)
	-- frame:SetWidth(column*size + (column-1)*margin + 2*padding)
	-- frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
	-- frame.mover:SetSize(frame:GetSize())
-- end

function AB:OnLogin()
	AB:GlobalFade()
	AB:ComboGlow()
end