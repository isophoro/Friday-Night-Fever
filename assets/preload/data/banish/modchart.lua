function start (song) -- do nothing

end

function update (elapsed)
if curStep >= 384 and curStep < 640 or curStep >= 1296 and curStep < 1552 then
local currentBeat = (songPos / 1000)*(bpm/8)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*50) * math.pi), i)
end
end

if curStep == 640 or curStep == 1552 then
local currentBeat = (songPos / 1000)*(bpm/30)
	for i=0, 7 do
	tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.6, 'setDefault')
	tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.6, 'setDefault')
end
end


	if curStep == 380 or curStep == 1292 then
	showOnlyStrums = true
end

	if curStep == 640 or curStep == 1552 then
	showOnlyStrums = false
end

	if curStep == 1280 then
	strumLine1Visible = false
	strumLine2Visible = false
end

	if curStep == 1296 then
	strumLine1Visible = true
	strumLine2Visible = true
end


if curStep >= 1292 and curStep < 1296 or curStep >= 380 and curStep < 384 then
	setCamZoom(0.6)
end


if curStep == 1152 or curStep == 1158 or curStep == 1164 or curStep == 1168 or curStep == 1174 or curStep == 1180 or curStep == 1184 or curStep == 1190 or curStep == 1196 or curStep == 1200 or curStep == 1206 or curStep == 1212 then
	setCamZoom(0.4050)
	setHudZoom(1.01)
end

if curStep == 1216 or curStep == 1222 or curStep == 1228 or curStep == 1232 or curStep == 1238 or curStep == 1244 or curStep == 1248 or curStep == 1254 or curStep == 1260 or curStep == 1264 or curStep == 1270 or curStep == 1276 then
	setCamZoom(0.4050)
	setHudZoom(1.01)
end
end


function beatHit (beat)
if curStep >= 126 and curStep < 378 or curStep >= 638 and curStep < 888 then
	setCamZoom(0.4025)
	setHudZoom(1.01)
end

if curStep >= 382 and curStep < 638 or curStep >= 894 and curStep < 1150 or curStep >= 1294 and curStep < 1552 then
	setCamZoom(0.41)
	setHudZoom(1.01)
end
end