package;

import flixel.ui.FlxBar;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxCamera;

#if windows
import Discord.DiscordClient;
#end

typedef JukeboxSong = {
    var display:String;
    var ?song:String;
    var cover:String;
    var bpm:Float;
    var ?special:Bool;
}

@:enum abstract Playback(Int) to Int from Int
{
    var DUAL = 0;
    var INST = 1;
    var VOCALS = 2;

    public static function getString(pb:Playback):String
    {
        switch(pb)
        {
            case DUAL: return 'Normal';
            case INST: return 'Inst';
            case VOCALS: return 'Vocals';
        }
    }
}

class JukeboxState extends MusicBeatState
{
    var vocals:FlxSound = new FlxSound();
    var loaded:Bool = false;

    var screenbg:FlxSprite = new FlxSprite(0,0).makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), FlxColor.BLACK);
    var overlay:FlxSprite;
    var songText:AlphabetQuick;
    var lengthText:AlphabetQuick;
    var playText:AlphabetQuick;

    var playbackText:AlphabetQuick;
    var playback:Playback = DUAL;

    var songs:Array<JukeboxSong> = [
        {display:"Milk Tea", cover:"tea", bpm:100},
        {display:"Metamorphosis", cover:"peakek", bpm:160},
        {display:"Void", cover:"peakek", bpm:140},
        {display:"Down Bad", cover:"peakek", bpm:180},
        {display:"Star Baby", cover:"wee", bpm:180},
        {display:"Last Meow", cover:"wee", bpm:195},
        {display:"Bazinga", cover:"taki", bpm:190},
        {display:"Crucify", cover:"taki", bpm:200},
        {display:'Prayer', cover:'taki-update', bpm:140},
        {display:'Bad Nun', cover:'taki-update', bpm:140},
        {display:"Mako", cover:"mako", bpm:160},
        {display:"VIM", cover:"mako", bpm:170},
        {display:"Farmed", cover:"mako", bpm:160},
        {display:"Honey", cover:"hunni", bpm:130},
        {display:"Bunnii", cover:"hunni", bpm:165},
        {display:"Throw It Back", cover:"hunni", bpm:160},
        {display:'Mild', cover:'pepper', bpm:100},
        {display:'Spice', cover:'pepper', bpm:150},
        {display:'Party Crasher', cover:'pepper', bpm:159},
        {display:'Ur Girl', cover:'mega', bpm:144},
        {display:'Chicken Sandwich', cover:'mega', bpm:150},
        {display:'Funkin God', cover:'flippy', bpm:190},
        {display:'Hallow', cover:'hallow', bpm:130},
        {display:'Portrait', cover:'hallow', bpm:140},
        {display:'Soul', cover:'hallow', bpm:165},
        {display:'Hardships', cover:'tea-bat', bpm:120},
        {display:'Space Demons', cover:'extras', bpm:170},
        {display:'Beta VIP', song:'VIP', cover:'extras', bpm:155, special:true}
    ];

    var curSelected:Int = 0;
    private var screen:FlxCamera;
	private var cam:FlxCamera;
    var cover:JukeboxImage = new JukeboxImage(0, 155);

    override function create()
    {
        super.create();

        addC354R();

        FlxG.mouse.visible = true;
        FlxG.autoPause = false;
        #if windows
        DiscordClient.changePresence("In the Jukebox Menu, Listening to music", null);
        #end

        screen = new FlxCamera();
		cam = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.reset(screen);
		FlxG.cameras.add(cam);
		FlxCamera.defaultCameras = [cam];

        FlxG.sound.list.add(vocals);

        persistentUpdate = true;

        screenbg = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width),  Std.int(FlxG.height), [FlxColor.fromString('#58FFC7'), FlxColor.fromString('#C2FF8C')]);
        add(screenbg);
        screenbg.cameras = [screen];

        cover.cameras = [screen];
        add(cover);

        var text:AlphabetQuick = new AlphabetQuick(0, cover.y - 55, 'Jukebox', {bold:true,size:0.6,spacing:4,screenCenterX:true});
        text.cameras = [screen];
        add(text);

        songText = new AlphabetQuick(0, Std.int(FlxG.height * 0.65), songs[0].display, {bold:true,size:0.6,spacing:4,screenCenterX:true});
        songText.cameras = [screen];
        add(songText);

        lengthText = new AlphabetQuick(0, Std.int(FlxG.height * 0.73), '',{bold:false,size:0.5,spacing:3,screenCenterX:true});
        lengthText.cameras = [screen];
        add(lengthText);

        playText = new AlphabetQuick(0, Std.int(FlxG.height * 0.82), 'Press SPACE to play',{bold:false,size:0.5,spacing:3,screenCenterX:true});
        playText.cameras = [screen];
        add(playText);

        playbackText = new AlphabetQuick(0, Std.int(FlxG.height * 0.88), 'Playback Mode: ' + Playback.getString(playback), {bold:false,size:0.5,spacing:3,screenCenterX:true});
        playbackText.cameras = [screen];
        add(playbackText);

        songText.cameras = [screen];

        var scanlines:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Scanlines'));
        scanlines.antialiasing = true;
        scanlines.alpha = 0.45;
        add(scanlines);

        overlay = new FlxSprite(0,0).loadGraphic(Paths.image('LMAO'));
        overlay.antialiasing = true;
        add(overlay);

        changeSong();
    }

    var elapsedTimer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        screen.zoom = FlxMath.lerp(0.9, screen.zoom, 0.95);

        if(loaded && controls.LEFT_P || loaded && controls.RIGHT_P)
            changeSong(controls.LEFT_P ? -1 : 1);

        if(controls.UP_P || controls.DOWN_P)
            changePlayback(controls.UP_P ? -1 : 1);

        if(controls.BACK)
        {
            FlxG.autoPause = true;
            FlxG.switchState(new MainMenuState());
        }

        if(FlxG.sound.music != null)
        {
            Conductor.songPosition = FlxG.sound.music.time;

            if(loaded)
            {
                switch(playback)
                {
                    case DUAL:
                        FlxG.sound.music.volume = 1;
                        vocals.volume = 1;
                    case INST:
                        FlxG.sound.music.volume = 1;
                        vocals.volume = 0;  
                    case VOCALS:
                        FlxG.sound.music.volume = 0;
                        vocals.volume = 1;
                }

                if(controls.ACCEPT)
                {
                    if(!FlxG.sound.music.playing)
                    {
                        playText.text = 'Press SPACE to pause';
                        FlxG.sound.music.play();
    
                        if(!songs[curSelected].special)
                        {
                            vocals.play();
                            vocals.time = FlxG.sound.music.time;
                        }
                    }
                    else
                    {
                        playText.text = 'Press SPACE to play';
                        FlxG.sound.music.pause();
                        if(!songs[curSelected].special)
                            vocals.pause();
                    }
                }
            }

            if(FlxG.sound.music.playing)
            {
                elapsedTimer += elapsed;
                if(elapsedTimer >= 1)
                {
                    var seconds:String = '' + Std.int(FlxG.sound.music.time / 1000) % 60;
    
                    if(seconds.length == 1)
                        seconds = '0' + seconds;
            
                    lengthText.text = 'Playing : ${Std.int(FlxG.sound.music.time / 1000 / 60)}:$seconds';
                    elapsedTimer = 0;
                }
            }
        }
    }

    static var loadedSongs:Array<String> = [];
    function changeSong(change:Int = 0)
    {
        if(FlxG.sound.music != null)
            FlxG.sound.music.stop();

        curSelected += change;
        if(curSelected >= songs.length)
            curSelected = 0;
        else if(curSelected < 0)
            curSelected = songs.length - 1;

        cover.animation.play(songs[curSelected].cover);
        cover.screenCenter(X);

        songText.text = '< ${songs[curSelected].display} >';
        Conductor.changeBPM(songs[curSelected].bpm);
       
        var songName:String = songs[curSelected].special ? songs[curSelected].song : StringTools.replace(songs[curSelected].display.toLowerCase(), ' ', '-');
        trace('Loading Song: $songName');

        var isSys:Bool = false;
        #if sys
        isSys = true;
        #end

        if(loadedSongs.contains(songName) || !isSys)
        {
            loadSong(songName);
        }
        else
        {
            #if sys
            sys.thread.Thread.create(() -> {
                loadSong(songName);
            });
            #end
        }
    }

    override function beatHit()
    {
        screen.zoom += 0.015;
    }

    function loadSong(songName:String)
    {
        loaded = false;
        if(FlxG.sound.music != null)
        {
            FlxG.sound.music.stop();

            if(vocals.playing)
                vocals.stop();
        }

        lengthText.text = "Loading song...";
        playText.text = 'Press SPACE to play';
        playback = DUAL;
        playbackText.text = 'Playback Mode: ' + Playback.getString(playback);
        
        FlxG.sound.music.loadEmbedded(songs[curSelected].special ? Paths.music(songName) : Paths.inst(songName));
        elapsedTimer = 1;

        if(!songs[curSelected].special)
            vocals.loadEmbedded(Paths.voices(songName));

        loaded = true;

        var seconds:String = '' + Std.int(FlxG.sound.music.length / 1000) % 60;

        if(seconds.length == 1)
            seconds = '0' + seconds;

        lengthText.text = 'Length : ${Std.int(FlxG.sound.music.length / 1000 / 60)}:$seconds';
        loadedSongs.push(songName);
    }

    function changePlayback(change:Int)
    {
        var curp:Int = playback;
        curp += change;

        if(curp > 2)
            curp = 0;
        else if (curp < 0)
            curp = 2;

        playback = curp;
        playbackText.text = 'Playback Mode: ' + Playback.getString(playback);
    }
    
    function addC354R()
    {
        for(i in 0...CoolUtil.difficultyArray.length)
        {
            if(Highscore.getScore('C354R', i) > 0)
            {
                var c354r:JukeboxSong = {display:"C354R",bpm:150, cover:"C354R"};
                if(!songs.contains(c354r))
                    songs.push(c354r);
                break;
            }
        }
    }
}

class JukeboxImage extends FlxSprite
{
    public function new(X:Float, Y:Float)
    {
        super(X,Y);
        loadGraphic(Paths.image('jukebox_covers', 'preload'), true, 420, 285);
        antialiasing = true;

        var anims:Array<String> = [
            'tea', 'peakek', 'wee', 'taki', 'taki-update',
            'mako', 'hunni', 'pepper', 'mega', 'flippy',
            'hallow', 'tea-bat', 'C354R', 'extras'
        ];
        
        for(i in 0...anims.length)
            animation.add(anims[i], [i], 0, false);

        animation.play('tea');
    }
}