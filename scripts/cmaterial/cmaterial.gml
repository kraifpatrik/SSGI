/// @func CMaterial()
///
/// @desc
function CMaterial() constructor
{
	/// @var {Pointer.Texture}
	BaseColor = pointer_null;

	// @var {Pointer.Texture}
	MetallicRoughness = pointer_null;

	// @var {Pointer.Texture}
	Normal = pointer_null;

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
