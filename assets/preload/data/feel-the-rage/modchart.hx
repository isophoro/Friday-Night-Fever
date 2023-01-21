function onOpponentNoteHit(note)
{
	if (curBeat >= 32 && curBeat < 63 || curBeat >= 224 && curBeat < 240)
		game.defaultCamZoom += 0.01;
}

function onPlayerNoteHit(note)
{
	if (curStep == 1548 || curStep == 1597 || curStep == 1660 || curStep == 1661 || curStep == 1704 || curStep == 1708 || curStep == 1788 || curStep == 1789)
	{
		note.properties.singAnim = "scared";
	}
}

function onBeatHit(curBeat:Int)
{
	if (curBeat >= 48 && curBeat < 48 || curBeat >= 240 && curBeat < 256)
		game.defaultCamZoom += 0.01;

	game.camZooming = true;
	if (curBeat % 4 == 0)
	{
		camHUD.zoom += 0.009;
	}

	switch (curBeat)
	{
		case 64:
			game.defaultCamZoom = 0.55;
			game.useDirectionalCamera = true;
		case 32:
			BF_CAM_OFFSET.x = 100;
		case 128:
			BF_CAM_OFFSET.x = 0;
			game.defaultCamZoom = 0.4;
			game.useDirectionalCamera = false;
		case 240:
			// HSCRIPT NEEDS OR STATEMENTS GRRRRRRRRR
			BF_CAM_OFFSET.x = 100;
		case 256:
			BF_CAM_OFFSET.x = 0;
			game.defaultCamZoom = 0.55;
			game.useDirectionalCamera = true;
	}
}
