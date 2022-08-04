camera_destroy(camera);

model.Destroy();

if (surface_exists(surDepth))
{
	surface_free(surDepth);
}
if (surface_exists(surNormal))
{
	surface_free(surNormal);
}
if (surface_exists(surLight))
{
	surface_free(surLight);
}

ssgi.Destroy();
