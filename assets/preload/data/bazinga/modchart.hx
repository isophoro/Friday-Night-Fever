function onCreatePost()
{
	game.disableCamera = true;
	snapCamera(BF_CAM_POS);
	game.camFollow.y += 120;
	camGame.zoom = 0.97;
}
