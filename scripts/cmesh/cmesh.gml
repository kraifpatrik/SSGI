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
	static Freeze = function () {
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
	static Submit = function () {
		if (VertexBuffer != undefined)
		{
			var _texture = (Material != undefined)
				? Model.Materials[? Material].Texture
				: -1;
			vertex_submit(VertexBuffer, pr_trianglelist, _texture);
		}
		return self;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function () {
		if (VertexBuffer != undefined)
		{
			vertex_delete_buffer(VertexBuffer);
		}
		return undefined;
	};
}
