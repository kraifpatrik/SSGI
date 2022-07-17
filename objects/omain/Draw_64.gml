if (!debug)
{
	exit;
}

var _x = 0;
var _y = 0;
var _width = window_get_width() / 4;
var _height = window_get_height() / 4;

if (surface_exists(surDepth))
{
	draw_surface_stretched(surDepth, _x, _y, _width, _height);
}
_x += _width;

if (surface_exists(surNormal))
{
	draw_surface_stretched(surNormal, _x, _y, _width, _height);
}
_x += _width;
