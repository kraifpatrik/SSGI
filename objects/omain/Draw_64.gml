var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

draw_surface_stretched(surSSGI, 0, 0, _windowWidth, _windowHeight);

////////////////////////////////////////////////////////////////////////////////
// Debug
if (!debug)
{
	exit;
}

var _x = 0;
var _y = 0;
var _width = _windowWidth / 8;
var _height = _windowHeight / 8;

draw_surface_stretched(application_surface, _x, _y, _width, _height);
_x += _width;

draw_surface_stretched(surDepth, _x, _y, _width, _height);
_x += _width;

draw_surface_stretched(surNormal, _x, _y, _width, _height);
_x += _width;
