local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:RegisterModule("Tooltip")

T.ItemTooltips = {
	["GameTooltip"] = true,
	["ItemRefTooltip"] = true,
	["ShoppingTooltip1"] = true,
	["EmbeddedItemTooltip"] = true,
}

local createdString = gsub(ITEM_CREATED_BY, "%%s", ".+")

function T:HideCreatedString()
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self)
		if not T.db["HideCreator"] then return end

		local name = self:GetName()
		if not T.ItemTooltips[name] then return end

		for i = 2, self:NumLines() do
			local line = _G[self:GetName().."TextLeft"..i]
			local text = line and line:GetText()
			if text and text ~= "" and strmatch(text, createdString) then
				line:SetText("")
				break
			end
		end
	end)
end

function T:OnLogin()
	T.myGUID = UnitGUID("player")
	T.myFaction = UnitFactionGroup("player")

	T:HideCreatedString()
	T:Progression()
	T:Covenant()
	T:AlreadyUsed()
end