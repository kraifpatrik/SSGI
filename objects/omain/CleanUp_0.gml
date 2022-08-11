camera_destroy(camera);

model.Destroy();

if (surface_exists(surShadowmap))
{
	surface_free(surShadowmap);
}
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
if (surface_exists(surWork))
{
	surface_free(surWork);
}
if (surface_exists(surWork2))
{
	surface_free(surWork2);
}
if (surface_exists(surWork3))
{
	surface_free(surWork3);
}
if (surface_exists(surSSAO))
{
	surface_free(surSSAO);
}
if (surface_exists(surSSGI))
{
	surface_free(surSSGI);
}

ssgi.Destroy();
