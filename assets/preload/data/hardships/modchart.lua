function start (song)
makeSprite('captions2','captions2', true)
	setActorX(1000,'captions2')
	setActorY(-150,'captions2')
	setActorScale(1.6,'captions2')
	tweenFadeIn('captions2',0,0.3)
end

function update (elapsed)
	if curStep >= 628 and curStep < 638 then
	tweenFadeIn('captions2',1,0.3)
end

	if curStep == 638 then
	tweenFadeIn('captions2',0,0.6)
end
end
	