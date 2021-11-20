function start (song)
setHudZoom(2)
showOnlyStrums = true
strumLine1Visible = false
strumLine2Visible = false
			--[[
				makeSprite('captionsmako1','captionsmako1', true)
				makeSprite('captionsmako2','captionsmako2', true)
				makeSprite('captionsmako3','captionsmako3', true)
				makeSprite('captionsmako4','captionsmako4', true)
				makeSprite('captionsmako5','captionsmako5', true)
				makeSprite('captionsmako6','captionsmako6', true)
				makeSprite('captionsmako7','captionsmako7', true)
				makeSprite('captionsmako8','captionsmako8', true)
				setActorX(-350,'captionsmako1')
				setActorY(-450,'captionsmako1')
				setActorX(-350,'captionsmako2')
				setActorY(-450,'captionsmako2')
				setActorX(-350,'captionsmako3')
				setActorY(-450,'captionsmako3')
				setActorX(-350,'captionsmako4')
				setActorY(-450,'captionsmako4')
				setActorX(-350,'captionsmako5')
				setActorY(-450,'captionsmako5')
				setActorX(-350,'captionsmako6')
				setActorY(-450,'captionsmako6')
				setActorX(-350,'captionsmako7')
				setActorY(-450,'captionsmako7')
				setActorX(-350,'captionsmako8')
				setActorY(-450,'captionsmako8')
				setActorScale(0.7,'captionsmako1')
				tweenFadeIn('captionsmako1',0,0.1)
				setActorScale(0.7,'captionsmako2')
				tweenFadeIn('captionsmako2',0,0.1)
				setActorScale(0.7,'captionsmako3')
				tweenFadeIn('captionsmako3',0,0.1)
				setActorScale(0.7,'captionsmako4')
				tweenFadeIn('captionsmako4',0,0.1)
				setActorScale(0.7,'captionsmako5')
				tweenFadeIn('captionsmako5',0,0.1)
				setActorScale(0.7,'captionsmako6')
				tweenFadeIn('captionsmako6',0,0.1)
				setActorScale(0.7,'captionsmako7')
				tweenFadeIn('captionsmako7',0,0.1)
				setActorScale(0.7,'captionsmako8')
				tweenFadeIn('captionsmako8',0,0.1)
		]]--
end

	function update (elapsed)
	--[[
	if curStep >= 88 and curStep < 124 then
	tweenFadeIn('captionsmako1',1,0.3)

	end

	if curStep == 128 then
	tweenFadeOut('captionsmako1',0,0.3)

	end

	if curStep >= 620 and curStep < 645 then
	tweenFadeIn('captionsmako2',1,0.3)

	end

	if curStep == 650 then
	tweenFadeOut('captionsmako2',0,0.3)

	end

	if curStep >= 752 and curStep < 764 then
	tweenFadeIn('captionsmako3',1,0.3)

	end

	if curStep == 764 then
	tweenFadeOut('captionsmako3',0,0.3)

	end

	if curStep >= 880 and curStep < 892 then
	tweenFadeIn('captionsmako4',1,0.3)

	end

	if curStep == 894 then
	tweenFadeOut('captionsmako4',0,0.3)

	end

	if curStep >= 1110 and curStep < 1146 then
	tweenFadeIn('captionsmako5',1,0.3)

	end

	if curStep == 1148 then
	tweenFadeOut('captionsmako5',0,0.3)

	end

	if curStep >= 1260 and curStep < 1276 then
	tweenFadeIn('captionsmako6',1,0.3)

	end

	if curStep == 1278 then
	tweenFadeOut('captionsmako6',0,0.3)

	end

	if curStep >= 1374 and curStep < 1400 then
	tweenFadeIn('captionsmako7',1,0.3)

	end

	if curStep == 1402 then
	tweenFadeOut('captionsmako7',0,0.3)

	end

	if curStep >= 1408 and curStep < 1434 then
	tweenFadeIn('captionsmako8',1,0.3)

	end

	if curStep == 1436 then
	tweenFadeOut('captionsmako8',0,0.3)

	end

	]]--

	if curStep == 1 then
	setCamZoom(1)
	setHudZoom(1)

		end


	if curStep >= 0 and curStep < 1376 then
		local currentBeat = (songPos / 1000)*(bpm/45)
		for i=0,3 do
			setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.cos((currentBeat + i*50) * math.pi), i)
		end
		end


	if curStep >= 129 and curStep < 255 then
		local currentBeat = (songPos / 1000)*(bpm/120)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 5 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
		end

	if curStep >= 256 and curStep < 376 then
		local currentBeat = (songPos / 1000)*(bpm/120)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 10 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
		end

	if curStep >= 384 and curStep < 616 then
		local currentBeat = (songPos / 1000)*(bpm/60)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 10 * math.sin((currentBeat + i*50) * math.pi), i)
		end
		end

	if curStep >= 640 and curStep < 752 or curStep >= 768 and curStep < 880 or curStep >= 896 and curStep < 1112 then
		local currentBeat = (songPos / 1000)*(bpm/60)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 15 * math.sin((currentBeat + i*0.25) * math.pi), i)
		end
		end

	if curStep >= 1152 and curStep < 1256 then
		local currentBeat = (songPos / 1000)*(bpm/60)
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 25 * math.sin((currentBeat + i*0.25) * math.pi), i)
		end
		end


if curStep == 376 or curStep == 616 or curStep == 752 or curStep == 880 or curStep == 1112 or curStep == 1256 then
local currentBeat = (songPos / 1000)*(bpm/30)
		for i=4,7 do
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.3, 'setDefault')
		tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.3, 'setDefault')
end
end

if curStep == 1376 then
local currentBeat = (songPos / 1000)*(bpm/30)
		for i=0,3 do
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.3, 'setDefault')
		tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.3, 'setDefault')
end
end


	if curStep >= 129 and curStep < 130 then
	setCamZoom(1.1)
	strumLine1Visible = true
	strumLine2Visible = true
		end

	if curStep >= 128 and curStep < 255 then
	showOnlyStrums = false
		end


	if curStep == 752 then
	strumLine1Visible = false
	end

	if curStep == 768 then
	strumLine1Visible = true
	end


	if curStep == 880 then
	strumLine1Visible = false
	end

	if curStep == 896 then
	strumLine1Visible = true
	end


	if curStep == 1104 then
	strumLine1Visible = false
	end

	if curStep == 1152 then
	strumLine1Visible = true
	end


	if curStep == 1260 then
	strumLine1Visible = false
	end

	if curStep == 1280 then
	strumLine1Visible = true
	end



	if curStep == 624 then
	showOnlyStrums = true
	setCamZoom(1.1)
	strumLine1Visible = false
	strumLine2Visible = false
		end

	if curStep == 640 then
	showOnlyStrums = false
	setCamZoom(1.1)
	strumLine1Visible = true
	strumLine2Visible = true
		end


	if curStep == 1376 then
	setCamZoom(1.1)
	strumLine1Visible = false
	strumLine2Visible = false
		end

	if curStep == 1408 then
	showOnlyStrums = true
		end
		end


function beatHit(beat)
	if curStep >= 382 and curStep < 622 or curStep >= 1278 and curStep < 1406 then
	setCamZoom(0.92)
	setHudZoom(1.02)
		end

	if curStep >= 638 and curStep < 752 or curStep >= 766 and curStep < 882 or curStep >= 894 and curStep < 1118 or curStep >= 1150 and curStep < 1262 then
	setCamZoom(0.93)
	setHudZoom(1.03)
		end
		end