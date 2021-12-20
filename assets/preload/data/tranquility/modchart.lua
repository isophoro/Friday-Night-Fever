function start (song) -- do nothing

end


function update (elapsed)
if curStep >= 0 then
local currentBeat = (songPos / 1000)*(bpm/240)
for i=0,7 do
	setActorX(_G['defaultStrum'..i..'X'] + 5 * math.sin((currentBeat + i*0.25) * math.pi), i)
	setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.cos((currentBeat + i*0.25) * math.pi), i)
end
end
end

function stepHit (step) -- do nothing

end