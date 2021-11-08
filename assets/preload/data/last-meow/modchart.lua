function start (song)

end

function update (elapsed)
	if curStep >= 0 then
		local currentBeat = (songPos / 1000)*(bpm/240)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*10) * math.pi), i)
		end
		end

	if curStep >= 0 then
		local currentBeat = (songPos / 1000)*(bpm/15)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*10) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 5 * math.sin((currentBeat + i*15) * math.pi), i)
		end
		end


	if curStep >= 1200 and curStep < 1204 then
	setCamZoom(0.64)
		end
	
	if curStep >= 1204 and curStep < 1208 then
	setCamZoom(0.66)
		end

	if curStep >= 1208 and curStep < 1211 then
	setCamZoom(0.68)
		end

	if curStep >= 1211 and curStep < 1214 then
	setCamZoom(0.70)
		end

	if curStep >= 1214 and curStep < 1216 then
	setCamZoom(0.72)
		end
		end


function beatHit(beat)
	if curStep >= 0 and curStep < 126 or curStep >= 1102 and curStep < 1150 or curStep >= 1214 and curStep < 1246 then
	setCamZoom(0.61)
	setHudZoom(1.00)
		end

	if curStep >= 126 and curStep < 632 or curStep >= 734 and curStep < 766 or curStep >= 798 and curStep < 830 or curStep >= 862 and curStep < 894 or curStep >= 926 and curStep < 958 or curStep >= 990 and curStep < 1102 or curStep >= 1150 and curStep < 1198 or curStep >= 1246 and curStep < 1278 or curStep >= 1374 and curStep < 1406 or curStep >= 1438 and curStep < 1470 then
	setCamZoom(0.62)
	setHudZoom(1.01)
		end

	if curStep >= 638 and curStep < 734 or curStep >= 1278 and curStep < 1374 then
	setCamZoom(0.6350)
	setHudZoom(1.02)
		end
		end