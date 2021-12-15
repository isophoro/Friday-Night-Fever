package sprites;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;

class CharacterTrail extends FlxTrail
{
    var elapsedTimer:Float = 0;
    
    override function update(elapsed:Float)
    {
        // Count the frames
        // now actually cares about the game fps / animation fps!
        elapsedTimer += elapsed;

        // Update the trail in case the intervall and there actually is one.
        if (elapsedTimer >= (delay / 60) && _trailLength >= 1)
        {
            elapsedTimer = 0;

            // Push the current position into the positons array and drop one.
            var spritePosition:FlxPoint = null;
            if (_recentPositions.length == _trailLength)
            {
                spritePosition = _recentPositions.pop();
            }
            else
            {
                spritePosition = FlxPoint.get();
            }

            spritePosition.set(target.x - target.offset.x, target.y - target.offset.y);
            _recentPositions.unshift(spritePosition);

            // Also do the same thing for the Sprites angle if rotationsEnabled
            if (rotationsEnabled)
            {
                cacheValue(_recentAngles, target.angle);
            }

            // Again the same thing for Sprites scales if scalesEnabled
            if (scalesEnabled)
            {
                var spriteScale:FlxPoint = null; // sprite.scale;
                if (_recentScales.length == _trailLength)
                {
                    spriteScale = _recentScales.pop();
                }
                else
                {
                    spriteScale = FlxPoint.get();
                }

                spriteScale.set(target.scale.x, target.scale.y);
                _recentScales.unshift(spriteScale);
            }

            // Again the same thing for Sprites frames if framesEnabled
            if (framesEnabled && _graphic == null)
            {
                cacheValue(_recentFrames, target.animation.frameIndex);
                cacheValue(_recentFlipX, target.flipX);
                cacheValue(_recentFlipY, target.flipY);
                cacheValue(_recentAnimations, target.animation.curAnim);
            }

            // Now we need to update the all the Trailsprites' values
            var trailSprite:FlxSprite;

            for (i in 0..._recentPositions.length)
            {
                trailSprite = members[i];
                trailSprite.x = _recentPositions[i].x;
                trailSprite.y = _recentPositions[i].y;

                // And the angle...
                if (rotationsEnabled)
                {
                    trailSprite.angle = _recentAngles[i];
                    trailSprite.origin.x = _spriteOrigin.x;
                    trailSprite.origin.y = _spriteOrigin.y;
                }

                // the scale...
                if (scalesEnabled)
                {
                    trailSprite.scale.x = _recentScales[i].x;
                    trailSprite.scale.y = _recentScales[i].y;
                }

                // and frame...
                if (framesEnabled && _graphic == null)
                {
                    trailSprite.animation.frameIndex = _recentFrames[i];
                    trailSprite.flipX = _recentFlipX[i];
                    trailSprite.flipY = _recentFlipY[i];

                    trailSprite.animation.curAnim = _recentAnimations[i];
                }

                // Is the trailsprite even visible?
                trailSprite.exists = true;
            }
        }

        //super.update(elapsed);
    }
}