/// @macro {Real}
#macro SSGI_KERNEL_SIZE 8

/// @func SSGI_GetKernelTexture()
///
/// @desc
///
/// @return {Pointer.Texture}
function SSGI_GetKernelTexture()
{
	static _texture = undefined;
	//if (_texture == undefined)
	//{
		var _size = SSGI_KERNEL_SIZE;
		var _indices = ds_list_create();
		for (var i = 0; i < _size * _size; ++i)
		{
			ds_list_add(_indices, i);
		}
		ds_list_shuffle(_indices);
		//var _dest = array_create(2);
		var _surface = surface_create(_size, _size);
		surface_set_target(_surface);
		draw_clear(c_black);
		var k = 0;
		for (var i = 0; i < _size; ++i)
		{
			for (var j = 0; j < _size; ++j)
			{
				//SSGI_Hammersley2D(_indices[| k++], _size * _size, _dest);
				draw_point_color(i, j, make_color_rgb(_indices[| k++], 0, 0));
			}
		}
		surface_reset_target();
		ds_list_destroy(_indices);
		var _sprite = sprite_create_from_surface(
			_surface, 0, 0, _size, _size, false, false, 0, 0);
		_texture = sprite_get_texture(_sprite, 0);
	//}
	return _texture;
}
