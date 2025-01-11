local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

if C_CVar.GetCVar("portal") ~= "test" then return end -- PTR/Beta

-- One-click learning all profession specializations
do
	local function PurchaseRank(configID, nodeID)
		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
		if nodeInfo then
			for i = nodeInfo.ranksPurchased, nodeInfo.maxRanks do
				C_Traits.PurchaseRank(configID, nodeID)
			end

			for _, edgeInfo in ipairs(nodeInfo.visibleEdges) do
				PurchaseRank(configID, edgeInfo.targetNode)
			end
		end
	end

	local function OnClick(self)
		local specPage = self:GetParent()
		local professionID = specPage:GetProfessionID()
		local configID = C_ProfSpecs.GetConfigIDForSkillLine(professionID)
		local treeIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(professionID)

		for _, treeID in ipairs(treeIDs) do
			local tabInfo = C_ProfSpecs.GetTabInfo(treeID)
			if tabInfo then
				PurchaseRank(configID, tabInfo.rootNodeID)
			end
		end

		specPage.TreePreview:Hide()
	end

	function M:ProfessionSpecHelper()
		local button = CreateFrame("Button", nil, _G.ProfessionsFrame.SpecPage, "MagicButtonTemplate")
		button:SetSize(160, 36)
		button:SetPoint("TOPRIGHT", -10, -40)
		button:SetText(L["Learn All Specialization"])
		button:SetScript("OnClick", OnClick)

		if C.db["Skins"]["BlizzardSkins"] then B.Reskin(button) end
	end

	P:AddCallbackForAddon("Blizzard_Professions", M.ProfessionSpecHelper)
end