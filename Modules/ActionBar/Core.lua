local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:RegisterModule("ActionBar")
local Bar = B:GetModule("Actionbar")

local margin, padding = C.Bars.margin, C.Bars.padding

function AB:UpdateActionSize(name, cfg)
	local frame = _G["NDui_Action"..name]
	if not frame then return end

	local size = cfg.size or C.db["Actionbar"][name.."Size"]
	local fontSize = cfg.fontSize or C.db["Actionbar"][name.."Font"]
	local num = cfg.num or C.db["Actionbar"][name.."Num"]
	local perRow = cfg.perRow or C.db["Actionbar"][name.."PerRow"]

	if num == 0 then return end

	for i = 1, num do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, padding, -padding)
		elseif mod(i-1, perRow) ==  0 then
			button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		end
		button:SetAttribute("statehidden", false)
		button:Show()
		Bar:UpdateFontSize(button, fontSize)
	end

	for i = num+1, 12 do
		local button = frame.buttons[i]
		if not button then break end
		button:SetAttribute("statehidden", true)
		button:Hide()
	end

	local column = min(num, perRow)
	local rows = ceil(num/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*padding)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
	frame.mover:SetSize(frame:GetSize())
	if frame.mover2 then frame.mover2.isDisable = true end
end

function AB:OnLogin()
	AB:GlobalFade()
	AB:ComboGlow()
end