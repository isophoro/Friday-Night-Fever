function start (song)
setCamZoom(1)

end

function update (elapsed)

if curStep >= 248 and curStep < 256 then
	local currentBeat = (songPos / 1000)*(bpm/120)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 200 * math.sin((currentBeat + i*25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 100 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end

if curStep >= 256 and curStep < 272 then
local currentBeat = (songPos / 1000)*(bpm/240)
		for i=0,7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.6, 'setDefault')
			tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.6, 'setDefault')
	end
	end



if curStep >= 520 and curStep < 632 then -- wind thing
	local currentBeat = (songPos / 1000)*(bpm/120)
		for i=0,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + 5 * math.sin((currentBeat + i*50) * math.pi), i)
			setActorX(_G['defaultStrum'..i..'X'] + 20 * math.cos((currentBeat + i*50) * math.pi), i)
	end
	end

if curStep >= 632 and curStep < 640 then -- sonicsonic
	local currentBeat = (songPos / 1000)*(bpm/240)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin((currentBeat + i*25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 50 * math.cos((currentBeat + i*0.25) * math.pi), i)
	end
	end
	
if curStep >= 640 and curStep < 704 then -- return
	local currentBeat = (songPos / 1000)*(bpm/1000)
		for i=0,7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.6, 'setDefault')
			tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.6, 'setDefault')
	end
	end
	end
	

function beatHit(beat) -- do nothing

end


function stepHit (step) -- do nothing

end