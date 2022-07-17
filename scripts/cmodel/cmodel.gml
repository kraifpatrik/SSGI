/// @func CModel()
///
/// @desc Basic 3D model with shitty OBJ file loading.
function CModel() constructor
{
	/// @var {Id.VertexFormat}
	static VertexFormat = undefined;

	if (VertexFormat == undefined)
	{
		vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_normal();
		vertex_format_add_texcoord();
		VertexFormat = vertex_format_end();
	}

	/// @var {Id.VertexBuffer}
	VertexBuffer = undefined;

	/// @var {Bool}
	IsLoaded = false;

	/// @var {Pointer.Texture}
	Texture = -1;

	/// @func FromOBJ(_path)
	///
	/// @desc Imports a model from an OBJ file. The model must be triangulated
	/// and must have normals and texture coordinates.
	///
	/// @return {Struct.CModel} Returns `self`.
	///
	/// @throws {String} If an error occurs.
	static FromOBJ = function (_path) {
		var _file = file_text_open_read(_path);
		if (_file == -1)
		{
			throw "Unable to open file " + _path + "!";
		}

		// Prepare lists for loaded data
		var _vertices = ds_list_create();
		var _normals = ds_list_create();
		var _textureCoords = ds_list_create();

		// Load data
		var _split = [];
		var _face = [];

		var _vertexBuffer = vertex_create_buffer();
		vertex_begin(_vertexBuffer, VertexFormat);

		while (!file_text_eof(_file))
		{
			var _line = file_text_read_string(_file);
			StringExplode(_line, " ", _split);

			switch (_split[0])
			{
			// Vertex
			case "v":
				ds_list_add(_vertices,
					real(_split[1]), real(_split[2]), real(_split[3]));
				break;

			// Vertex normal
			case "vn":
				ds_list_add(_normals,
					real(_split[1]), real(_split[2]), real(_split[3]));
				break;

			// Vertex texture coordinate
			case "vt":
				ds_list_add(_textureCoords,
					real(_split[1]), real(_split[2]));
				break;

			// Face
			case "f":
				for (var i = 1; i < 4; ++i)
				{
					StringExplode(_split[i], "/", _face);

					var _vertexIndex = (real(_face[0]) - 1) * 3;
					var _uvIndex     = (real(_face[1]) - 1) * 2;
					var _normalIndex = (real(_face[2]) - 1) * 3;

					vertex_position_3d(
						_vertexBuffer,
						_vertices[| _vertexIndex],
						_vertices[| _vertexIndex + 1] * -1.0,
						_vertices[| _vertexIndex + 2]);

					vertex_normal(
						_vertexBuffer,
						_normals[| _normalIndex],
						_normals[| _normalIndex + 1],
						_normals[| _normalIndex + 2]);

					vertex_texcoord(
						_vertexBuffer,
						_textureCoords[| _uvIndex],
						1.0 - _textureCoords[| _uvIndex + 1]);
				}
				break;
			}

			file_text_readln(_file);
		}
		file_text_close(_file);

		ds_list_destroy(_vertices);
		ds_list_destroy(_normals);
		ds_list_destroy(_textureCoords);

		vertex_end(_vertexBuffer);
		if (VertexBuffer != undefined)
		{
			vertex_delete_buffer(VertexBuffer);
		}
		VertexBuffer = _vertexBuffer;

		IsLoaded = true;

		return self;
	};

	/// @func Freeze()
	///
	/// @desc
	///
	/// @return {Struct.CModel} Returns `self`.
	static Freeze = function () {
		gml_pragma("forceinline");
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
	/// @return {Struct.CModel} Returns `self`.
	static Submit = function () {
		gml_pragma("forceinline");
		if (VertexBuffer != undefined)
		{
			vertex_submit(VertexBuffer, pr_trianglelist, Texture);
		}
		return self;
	};

	/// @func Destroy()
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
