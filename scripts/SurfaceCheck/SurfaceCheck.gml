/// @func SurfaceCheck(_surface, _width, _height)
///
/// @desc
///
/// @param {Id.Surface} _surface
/// @param {Real} _width
/// @param {Real} _height
///
/// @return {Id.Surface}
function SurfaceCheck(_surface, _width, _height)
{
	_width = max(_width, 1);
	_height = max(_height, 1);
	if (!surface_exists(_surface))
	{
		_surface = surface_create(_width, _height);
	}
	else if (surface_get_width(_surface) != _width
		|| surface_get_height(_surface) != _height)
	{
		surface_resize(_surface, _width, _height);
	}
	return _surface;
}
