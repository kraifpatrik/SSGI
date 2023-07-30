/// @func CMaterial()
///
/// @desc
function CMaterial() constructor
{
	/// @var {Pointer.Texture}
	BaseColor = -1;

	// @var {Pointer.Texture}
	MetallicRoughness = -1;

	// @var {Pointer.Texture}
	Normal = -1;

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function ()
	{
		return undefined;
	};
}
