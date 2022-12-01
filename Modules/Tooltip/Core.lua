local addonName, ns = ...
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

local covenantMap = {
	[1] = "Kyrian",
	[2] = "Venthyr",
	[3] = "NightFae",
	[4] = "Necrolord",
}

function T:GetCovenantIcon(covenantID, size)
	local covenant = covenantMap[covenantID]
	if covenant then
		return format("|TInterface\\Addons\\"..addonName.."\\Media\\Texture\\Covenants\\%s:%d|t", covenant, size)
	end

	return ""
end

local covenantIDToName = {}
function T:GetCovenantName(covenantID)
	if not covenantIDToName[covenantID] then
		local covenantData = C_Covenants.GetCovenantData(covenantID)

		covenantIDToName[covenantID] = covenantData and covenantData.name
	end

	return covenantIDToName[covenantID] or covenantMap[covenantID]
end

function T:OnLogin()
	T.myGUID = UnitGUID("player")
	T.myFaction = UnitFactionGroup("player")

	T:HideCreatedString()
	T:Progression()
	T:AlreadyUsed()
end