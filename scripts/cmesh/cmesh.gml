/// @func CMesh([_model])
///
/// @desc
///
/// @param {Struct.CModel} [_model]
function CMesh(_model=undefined) constructor
{
	/// @var {Struct.CModel, Undefined}
	Model = _model;

	/// @var {Id.VertexBuffer, Undefined}
	VertexBuffer = undefined;

	/// @var {String, Undefined}
	Material = undefined;

	/// @func Freeze()
	///
	/// @desc
	///
	/// @return {Struct.CMesh} Returns `self`.
	static Freeze = function ()
	{
		if (VertexBuffer != undefined)
		{
			vertex_freeze(VertexBuffer);
		}
		return self;
	};

	/// @func Submit()
	///
	/// @desc
	///
	/// @return {Struct.CMesh} Returns `self`.
	static Submit = function ()
	{
		if (VertexBuffer != undefined)
		{
			var _shader = shader_current();
			var _baseColor = -1;
			var _metallicRoughness = -1;
			var _normal = -1;

			if (Material != undefined)
			{
				_baseColor = Model.Materials[? Material].BaseColor;
				_metallicRoughness = Model.Materials[? Material].MetallicRoughness;
				_normal = Model.Materials[? Material].Normal;
			}

			texture_set_stage(shader_get_sampler_index(_shader, "u_texMetallicRoughness"), _metallicRoughness);
			texture_set_stage(shader_get_sampler_index(_shader, "u_texNormal"), _normal);
			vertex_submit(VertexBuffer, pr_trianglelist, _baseColor);
		}
		return self;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function ()
	{
		if (VertexBuffer != undefined)
		{
			vertex_delete_buffer(VertexBuffer);
		}
		return undefined;
	};
}
