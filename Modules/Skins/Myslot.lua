local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
--------------------------
-- Credit: ElvUI_WindTools
--------------------------
function S:Myslot()
	if not IsAddOnLoaded("Myslot") then return end

	local Myslot = LibStub("Myslot-5.0", true)
	if not Myslot then return end

	local frame = Myslot.MainFrame
	B.StripTextures(frame)
	B.SetBD(frame)

	for _, child in pairs {frame:GetChildren()} do
		local objType = child:GetObjectType()
		if objType == "Button" and child.Text then
			B.Reskin(child)
		elseif objType == "CheckButton" then
			B.ReskinCheck(child)
		elseif objType == "Frame" then
			if floor(child:GetWidth() - 600) == 0 and floor(child:GetHeight() - 400) == 0 then
				child:SetBackdrop(nil)
				local bg = B.CreateBDFrame(child, 0)
				bg:SetInside()
				for _, subChild in pairs {child:GetChildren()} do
					if subChild:GetObjectType() == "ScrollFrame" then
						B.ReskinScroll(subChild.ScrollBar)
						break
					end
				end
			elseif child.initialize and child.Icon and child.Button then
				P.ReskinDropDown(child)
				child.Button:SetSize(20, 20)
			end
		end
	end
end

S:RegisterSkin("Myslot", S.Myslot)