function start (song)
setCamZoom(1)

end

function update (elapsed)

if curStep >= 0 and curStep < 8 or curStep >= 16 and curStep < 20 or curStep >= 64 and curStep < 72 or curStep >= 80 and curStep < 84 or curStep >= 128 and curStep < 136 or curStep >= 144 and curStep < 148 or curStep >= 192 and curStep < 200 or curStep >= 208 and curStep < 212 or curStep >= 512 and curStep < 520 or curStep >= 528 and curStep < 532 or curStep >= 896 and curStep < 904 or curStep >= 912 and curStep < 916 or curStep >= 960 and curStep < 968 or curStep >= 976 and curStep < 980 or curStep >= 1152 and curStep < 1160 or curStep >= 1168 and curStep < 1172 or curStep >= 1216 and curStep < 1222 or curStep >= 1232 and curStep < 1236 or curStep >= 1024 and curStep < 1032 or curStep >= 1040 and curStep < 1044 or curStep >= 1088 and curStep < 1096 or curStep >= 1104 and curStep < 1108 or curStep >= 512 and curStep < 520 or curStep >= 528 and curStep < 532 or curStep >= 576 and curStep < 584 or curStep >= 592 and curStep < 596 then
	local currentBeat = (songPos / 1000)*(bpm/5)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 10 * math.sin((currentBeat + i*50) * math.pi), i)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + -10 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end
	end

if curStep >= 32 and curStep < 36 or curStep >= 96 and curStep < 100 or curStep >= 160 and curStep < 164 or curStep >= 224 and curStep < 228 or curStep >= 544 and curStep < 548 or curStep >= 608 and curStep < 612 or curStep >= 928 and curStep < 932 or curStep >= 992 and curStep < 996 or curStep >= 1056 and curStep < 1060 or curStep >= 1120 and curStep < 1124 or curStep >= 1184 and curStep < 1188 or curStep >= 1248 and curStep < 1252 then
	local currentBeat = (songPos / 1000)*(bpm/30)
		for i=0,3 do
			setActorY(_G['defaultStrum'..i..'Y'] + 50 * math.sin((currentBeat + i*25) * math.pi), i)
		for i=4,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + -50 * math.sin((currentBeat + i*25) * math.pi), i)
	end
	end
	end

if curStep >= 28 and curStep < 32 or curStep >= 36 and curStep < 40 or curStep >= 92 and curStep < 96 or curStep >= 100 and curStep < 104 or curStep >= 156 and curStep < 160 or curStep >= 164 and curStep < 168 or curStep >= 220 and curStep < 224 or curStep >= 228 and curStep < 232 or curStep >= 540 and curStep < 544 or curStep >= 548 and curStep < 552 or curStep >= 604 and curStep < 608 or curStep >= 612 and curStep < 616 or curStep >= 924 and curStep < 928 or curStep >= 932 and curStep < 936 or curStep >= 988 and curStep < 992 or curStep >= 996 and curStep < 1000 or curStep >= 1052 and curStep < 1056 or curStep >= 1060 and curStep < 1064 or curStep >= 1116 and curStep < 1120 or curStep >= 1124 and curStep < 1128 or curStep >= 1180 and curStep < 1184 or curStep >= 1188 and curStep < 1192 or curStep >= 1244 and curStep < 1248 or curStep >= 1252 and curStep < 1256 then
	local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,3 do
			setActorY(_G['defaultStrum'..i..'Y'] + -50 * math.sin((currentBeat + i*25) * math.pi), i)
		for i=4,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + 50 * math.sin((currentBeat + i*25) * math.pi), i)
	end
	end
	end

if curStep >= 48 and curStep < 64 or curStep >= 112 and curStep < 128 or curStep >= 176 and curStep < 192 or curStep >= 240 and curStep < 256 or curStep >= 560 and curStep < 576 or curStep >= 944 and curStep < 960 or curStep >= 1008 and curStep < 1024 or curStep >= 1072 and curStep < 1088 or curStep >= 1136 and curStep < 1152 or curStep >= 1200 and curStep < 1216 or curStep >= 1264 then
	local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + -50 * math.sin((currentBeat + i*50) * math.pi), i)
		for i=4,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + 50 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end
	end

if curStep >= 48 and curStep < 64 or curStep >= 112 and curStep < 128 or curStep >= 176 and curStep < 192 or curStep >= 240 and curStep < 256 or curStep >= 560 and curStep < 576 or curStep >= 944 and curStep < 960 or curStep >= 1008 and curStep < 1024 or curStep >= 1072 and curStep < 1088 or curStep >= 1136 and curStep < 1152 or curStep >= 1200 and curStep < 1216 or curStep >= 1264 then
	local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,3 do
			setActorY(_G['defaultStrum'..i..'Y'] + -50 * math.sin((currentBeat + i*50) * math.pi), i)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 50 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end
	end


if curStep >= 176 and curStep < 180 or curStep >= 184 and curStep < 188 or curStep >= 240 and curStep < 244 or curStep >= 248 and curStep < 252 or curStep >= 560 and curStep < 564 or curStep >= 568 and curStep < 572 or curStep >= 1072 and curStep < 1076 or curStep >= 1080 and curStep < 1084 or curStep >= 1136 and curStep < 1140 or curStep >= 1144 and curStep < 1148 then
	local currentBeat = (songPos / 1000)*(bpm/30)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + -50 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end

if curStep >= 48 and curStep < 64 or curStep >= 112 and curStep < 128 or curStep >= 944 and curStep < 960 or curStep >= 1008 and curStep < 1024 or curStep >= 1200 and curStep < 1216 or curStep >= 1264 then
	local currentBeat = (songPos / 1000)*(bpm/120)
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + -50 * math.sin((currentBeat + i*50) * math.pi), i)
	end
	end


if curStep >= 128 and curStep < 136 or curStep >= 192 and curStep < 200 or curStep >= 512 and curStep < 520 or curStep >= 576 and curStep < 584 then
	camHudAngle = camHudAngle + 0.2
end

if curStep >= 144 and curStep < 148 or curStep >= 208 and curStep < 212 or curStep >= 528 and curStep < 532 or curStep >= 592 and curStep < 596 then
	camHudAngle = camHudAngle + -0.5
end

if curStep >= 156 and curStep < 158 or curStep >= 220 and curStep < 222 or curStep >= 540 and curStep < 542 or curStep >= 604 and curStep < 606 then
	camHudAngle = camHudAngle + 0.2
end

if curStep == 161 or curStep == 224 or curStep == 545 or curStep == 608 then
	camHudAngle = 0
end

if curStep == 136 or curStep == 138 or curStep == 140 or curStep == 142 or curStep == 148 or curStep == 150 or curStep == 152 or curStep == 154 or curStep == 168 or curStep == 170 or curStep == 172 or curStep == 174 or curStep == 200 or curStep == 202 or curStep == 204 or curStep == 206 or curStep == 212 or curStep == 214 or curStep == 216 or curStep == 218 or curStep == 232 or curStep == 234 or curStep == 236 or curStep == 238 or curStep == 520 or curStep == 522 or curStep == 524 or curStep == 526 or curStep == 532 or curStep == 534 or curStep == 536 or curStep == 538 or curStep == 552 or curStep == 554 or curStep == 556 or curStep == 558 or curStep == 584 or curStep == 586 or curStep == 588 or curStep == 590 or curStep == 596 or curStep == 598 or curStep == 600 or curStep == 602 or curStep == 616 or curStep == 618 or curStep == 620 or curStep == 622 or curStep == 1032 or curStep == 1034 or curStep == 1036 or curStep == 1038 or curStep == 1044 or curStep == 1046 or curStep == 1047 or curStep == 1048 or curStep == 1050 or curStep == 1064 or curStep == 1066 or curStep == 1068 or curStep == 1069 or curStep == 1070 then
	setCamZoom(1)
		end


if curStep == 1024 or curStep == 1088 then
	setCamZoom(1.05)
		end


if curStep >= 1072 and curStep < 1074 or curStep >= 1136 and curStep < 1138 then
	setCamZoom(1)
		end

if curStep >= 1074 and curStep < 1076 or curStep >= 1138 and curStep < 1140 then
	setCamZoom(1.02)
		end

if curStep >= 1076 and curStep < 1080 or curStep >= 1140 and curStep < 1144 then
	setCamZoom(1.04)
		end

if curStep >= 1080 and curStep < 1082 or curStep >= 1144 and curStep < 1146 then
	setCamZoom(1.06)
		end

if curStep >= 1082 and curStep < 1084 or curStep >= 1146 and curStep < 1148 then
	setCamZoom(1.08)	
		end

if curStep >= 1084 and curStep < 1088 or curStep >= 1148 and curStep < 1152 then
	setCamZoom(1.1)
		end


if curStep == 128 or curStep == 134 or curStep == 136 or curStep == 138 or curStep == 141 or curStep == 143 or curStep == 145 or curStep == 147 or curStep == 149 or curStep == 151 or curStep == 155 or curStep == 161 or curStep == 163 or curStep == 169 or curStep == 171 or curStep == 173 or curStep == 175 or curStep == 177 or curStep == 179 or curStep == 183 or curStep == 187 or curStep == 191 or curStep == 624 then
local currentBeat = (songPos / 1000)*(bpm/2)
		for i=0,7 do
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.1, 'setDefault')
		tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.1, 'setDefault')
		strumLine1Visible = true
	end
	end
	end


function beatHit(beat)

if curStep >= 382 and curStep < 510 or curStep >= 638 and curStep < 894 then
	setCamZoom(0.92)
	setHudZoom(1.02)
end
end


function stepHit (step) -- do nothing

end