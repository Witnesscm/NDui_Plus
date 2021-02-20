local _, ns = ...
local B, C, L, DB, P = unpack(ns)
-------------------
-- ElvUI Animation
-------------------
P.AnimShake = {{-9,7,-7,12}, {-5,9,-9,5}, {-5,7,-7,5}, {-9,9,-9,9}, {-5,7,-7,5}, {-9,7,-9,5}}
P.AnimShakeH = {-5,5,-2,5,-2,5}

function P:FlashLoopFinished(requested)
	if not requested then self:Play() end
end

function P:RandomAnimShake(index)
	local s = P.AnimShake[index]
	return random(s[1], s[2]), random(s[3], s[4])
end

function P:SetUpAnimGroup(obj, Type, ...)
	if not Type then Type = "Flash" end

	if strsub(Type, 1, 5) == "Flash" then
		obj.anim = obj:CreateAnimationGroup("Flash")
		obj.anim.fadein = obj.anim:CreateAnimation("ALPHA", "FadeIn")
		obj.anim.fadein:SetFromAlpha(0)
		obj.anim.fadein:SetToAlpha(1)
		obj.anim.fadein:SetOrder(2)

		obj.anim.fadeout = obj.anim:CreateAnimation("ALPHA", "FadeOut")
		obj.anim.fadeout:SetFromAlpha(1)
		obj.anim.fadeout:SetToAlpha(0)
		obj.anim.fadeout:SetOrder(1)

		if Type == "FlashLoop" then
			obj.anim:SetScript("OnFinished", P.FlashLoopFinished)
		end
	elseif strsub(Type, 1, 5) == "Shake" then
		local shake = obj:CreateAnimationGroup(Type)
		shake:SetLooping("REPEAT")
		shake.path = shake:CreateAnimation("Path")

		if Type == "Shake" then
			shake.path:SetDuration(0.7)
			obj.shake = shake
		elseif Type == "ShakeH" then
			shake.path:SetDuration(2)
			obj.shakeh = shake
		end

		for i = 1, 6 do
			shake.path[i] = shake.path:CreateControlPoint()
			shake.path[i]:SetOrder(i)

			if Type == "Shake" then
				shake.path[i]:SetOffset(P:RandomAnimShake(i))
			else
				shake.path[i]:SetOffset(P.AnimShakeH[i], 0)
			end
		end
	else
		local x, y, duration, customName = ...
		if not customName then customName = "anim" end

		local anim = obj:CreateAnimationGroup("Move_In")
		obj[customName] = anim

		anim.in1 = anim:CreateAnimation("Translation")
		anim.in1:SetDuration(0)
		anim.in1:SetOrder(1)
		anim.in1:SetOffset(x, y)

		anim.in2 = anim:CreateAnimation("Translation")
		anim.in2:SetDuration(duration)
		anim.in2:SetOrder(2)
		anim.in2:SetSmoothing("OUT")
		anim.in2:SetOffset(-x, -y)

		anim.out1 = obj:CreateAnimationGroup("Move_Out")
		anim.out1:SetScript("OnFinished", function() obj:Hide() end)

		anim.out2 = anim.out1:CreateAnimation("Translation")
		anim.out2:SetDuration(duration)
		anim.out2:SetOrder(1)
		anim.out2:SetSmoothing("IN")
		anim.out2:SetOffset(x, y)
	end
end

function P:Shake(obj)
	if not obj.shake then
		P:SetUpAnimGroup(obj, "Shake")
	end

	obj.shake:Play()
end

function P:StopShake(obj)
	if obj.shake then
		obj.shake:Finish()
	end
end

function P:ShakeHorizontal(obj)
	if not obj.shakeh then
		P:SetUpAnimGroup(obj, "ShakeH")
	end

	obj.shakeh:Play()
end

function P:StopShakeHorizontal(obj)
	if obj.shakeh then
		obj.shakeh:Finish()
	end
end

function P:Flash(obj, duration, loop)
	if not obj.anim then
		P:SetUpAnimGroup(obj, loop and "FlashLoop" or "Flash")
	end

	if not obj.anim:IsPlaying() then
		obj.anim.fadein:SetDuration(duration)
		obj.anim.fadeout:SetDuration(duration)
		obj.anim:Play()
	end
end

function P:StopFlash(obj)
	if obj.anim and obj.anim:IsPlaying() then
		obj.anim:Stop()
	end
end

function P:SlideIn(obj, customName)
	if not customName then customName = "anim" end
	if not obj[customName] then return end

	obj[customName].out1:Stop()
	obj[customName]:Play()
	obj:Show()
end

function P:SlideOut(obj, customName)
	if not customName then customName = "anim" end
	if not obj[customName] then return end

	obj[customName]:Finish()
	obj[customName]:Stop()
	obj[customName].out1:Play()
end

local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")
FADEMANAGER.delay = 0.025

function P:UIFrameFade_OnUpdate(elapsed)
	FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

	if FADEMANAGER.timer > FADEMANAGER.delay then
		FADEMANAGER.timer = 0

		for frame, info in next, FADEFRAMES do
			-- Reset the timer if there isn"t one, this is just an internal counter
			if frame:IsVisible() then
				info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
			else
				info.fadeTimer = info.timeToFade + 1
			end

			-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
			if info.fadeTimer < info.timeToFade then
				if info.mode == "IN" then
					frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
				else
					frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
				end
			else
				frame:SetAlpha(info.endAlpha)

				-- If there is a fadeHoldTime then wait until its passed to continue on
				if info.fadeHoldTime and info.fadeHoldTime > 0  then
					info.fadeHoldTime = info.fadeHoldTime - elapsed
				else
					-- Complete the fade and call the finished function if there is one
					P:UIFrameFadeRemoveFrame(frame)

					if info.finishedFunc then
						if info.finishedArgs then
							info.finishedFunc(unpack(info.finishedArgs))
						else -- optional method
							info.finishedFunc(info.finishedArg1, info.finishedArg2, info.finishedArg3, info.finishedArg4, info.finishedArg5)
						end

						if not info.finishedFuncKeep then
							info.finishedFunc = nil
						end
					end
				end
			end
		end

		if not next(FADEFRAMES) then
			FADEMANAGER:SetScript("OnUpdate", nil)
		end
	end
end

-- Generic fade function
function P:UIFrameFade(frame, info)
	if not frame or frame:IsForbidden() then return end

	frame.fadeInfo = info

	if not info.mode then
		info.mode = "IN"
	end

	if info.mode == "IN" then
		if not info.startAlpha then info.startAlpha = 0 end
		if not info.endAlpha then info.endAlpha = 1 end
		if not info.diffAlpha then info.diffAlpha = info.endAlpha - info.startAlpha end
	else
		if not info.startAlpha then info.startAlpha = 1 end
		if not info.endAlpha then info.endAlpha = 0 end
		if not info.diffAlpha then info.diffAlpha = info.startAlpha - info.endAlpha end
	end

	frame:SetAlpha(info.startAlpha)

	if not frame:IsProtected() then
		frame:Show()
	end

	if not FADEFRAMES[frame] then
		FADEFRAMES[frame] = info -- read below comment
		FADEMANAGER:SetScript("OnUpdate", P.UIFrameFade_OnUpdate)
	else
		FADEFRAMES[frame] = info -- keep these both, we need this updated in the event its changed to another ref from a plugin or sth, don"t move it up!
	end
end

-- Convenience function to do a simple fade in
function P:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	if not frame or frame:IsForbidden() then return end

	if frame.FadeObject then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = "IN"
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = endAlpha - startAlpha

	P:UIFrameFade(frame, frame.FadeObject)
end

-- Convenience function to do a simple fade out
function P:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	if not frame or frame:IsForbidden() then return end

	if frame.FadeObject then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = "OUT"
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = startAlpha - endAlpha

	P:UIFrameFade(frame, frame.FadeObject)
end

function P:UIFrameFadeRemoveFrame(frame)
	if frame and FADEFRAMES[frame] then
		if frame.FadeObject then
			frame.FadeObject.fadeTimer = nil
		end

		FADEFRAMES[frame] = nil
	end
end

-------------------
-- RayUI Animation
-------------------
local function smooth(mode, x, y, z)
	return mode == true and 1 or max((10 + abs(x - y)) / (88.88888 * z), .2) * 1.1
end

function P.Simple_Move(self, t)
	self.pos = self.pos + t * self.speed * smooth(self.smode, self.limit, self.pos, .5)
	self:SetPoint(self.point_1, self.parent, self.point_2, self.hor and self.pos or self.alt or 0, not (self.hor) and self.pos or self.alt or 0)
	if self.pos * self.mod >= self.limit * self.mod then
		self:SetPoint(self.point_1, self.parent, self.point_2, self.hor and self.limit or self.alt or 0, not (self.hor) and self.limit or self.alt or 0)
		self.pos = self.limit
		self:SetScript("OnUpdate", nil)
		if self.finish_hide then
			self:Hide()
		end
		if self.finish_function then
			self:finish_function()
		end
	end
end

function P:Slide(frame, direction, length, speed)
	local p1, rel, p2, x, y = frame:GetPoint()
	frame.mod = (direction == "LEFT" or direction == "DOWN") and -1 or 1
	frame.hor = (direction == "LEFT" or direction == "RIGHT") and true or false
	frame.pos = frame.hor and x or y
	frame.alt = frame.hor and y or x
	frame.limit = (frame.hor and x or y) + frame.mod * length
	frame.speed = frame.mod * speed
	frame.point_1 = p1
	frame.point_2 = p2
	frame:SetScript("OnUpdate", P.Simple_Move)
end