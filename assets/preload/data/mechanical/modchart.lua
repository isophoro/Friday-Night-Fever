function start (song)
setCamZoom(1)

end

function update (elapsed)
if curStep == 48 or curStep == 52 or curStep == 54 or curStep == 56 or curStep == 912 or curStep == 916 or curStep == 918 or curStep == 920 then
	--setCamZoom(0.73)
	setHudZoom(1.03)
end

if curStep >= 0 and curStep < 2 then
	local currentBeat = (songPos / 1000)*(bpm/120)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 1000 * math.sin((currentBeat + i*50) * math.pi), i)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 450 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end
	end

if curStep >= 60 and curStep < 66 then
	local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + -500 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end

if curStep == 66 then
	strumLine1Visible = false
end

if curStep >= 60 and curStep < 65 then
	local currentBeat = (songPos / 1000)*(bpm/120)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + -838 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end

if curStep == 128 then
local currentBeat = (songPos / 1000)*(bpm/30)
		for i=0,7 do
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.1, 'setDefault')
		tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.1, 'setDefault')
		strumLine1Visible = true
	end
	end
	end

function beatHit(beat)
if curStep >= 48 and curStep < 384 or curStep >= 510 and curStep < 635 or curStep >= 766 and curStep < 894 or curStep >= 926 and curStep < 1278 or curStep >= 1282 and curStep < 1646 then
	--setCamZoom(0.73)
	setHudZoom(1.03)
end

if curStep >= 384 and curStep < 506 or curStep >= 638 and curStep < 762 or curStep >= 1646 and curStep < 1656 then
	--setCamZoom(0.71)
	setHudZoom(1.01)
end

if curStep >= 128 and curStep < 384 or curStep >= 512 and curStep < 624 or curStep >= 768 and curStep < 896 or curStep >= 928 and curStep < 1648 then
	local currentBeat = (songPos / 1000)*(bpm/120)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 25 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end
	end

function stepHit (step) -- do nothing

end