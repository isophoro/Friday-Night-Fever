function start (song) -- do nothing

end

function update (elapsed)
if curStep >= 0 and curStep < 1792 then -- down bad wave!!!
	local currentBeat = (songPos / 1000)*(bpm/30)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*50) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.cos((currentBeat + i*0.25) * math.pi), i)
	end
	end

if curStep >= 1792 and curStep < 1800 then -- move out move ou
	local currentBeat = (songPos / 1000)*(bpm/240)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + -600 * math.sin((currentBeat + i*50) * math.pi), i)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 600 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end
	end

if curStep == 128 or curStep == 136 or curStep == 144 or curStep == 152 or curStep == 160 or curStep == 168 or curStep == 176 or curStep == 184 or curStep == 192 or curStep == 200 or curStep == 208 or curStep == 216 or curStep == 224 or curStep == 232 or curStep == 240 or curStep == 248 or curStep == 1024 or curStep == 1032 or curStep == 1040 or curStep == 1048 or curStep == 1056 or curStep == 1064 or curStep == 1072 or curStep == 1080 or curStep == 1088 or curStep == 1096 or curStep == 1104 or curStep == 1112 or curStep == 1120 or curStep == 1128 or curStep == 1136 or curStep == 1144 then
		setHudZoom(1.01)
		setCamZoom(0.93)
	end
	end

function beatHit(beat) 
if curStep >= 382 and curStep < 638 or curStep >= 650 and curStep < 886 or curStep >= 1278 and curStep < 1534 or curStep >= 1544 and curStep < 1782 then
setHudZoom(1.02)
setCamZoom(0.95)

end
end

function stepHit (step) -- do nothing

end