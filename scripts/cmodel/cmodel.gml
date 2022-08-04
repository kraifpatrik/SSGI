vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
global.__vertexFormat = vertex_format_end();

/// @func CMaterial()
///
/// @desc
function CMaterial() constructor
{
	/// @var {Pointer.Texture}
	Texture = -1;

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function () {
		return undefined;
	};
}

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

/// @func CModel()
///
/// @desc Basic 3D model with shitty OBJ file loading.
function CModel() constructor
{
	/// @var {Bool}
	IsLoaded = false;

	/// @var {Array<Struct.CMesh>}
	Meshes = [];

	/// @var {Id.DsMap, Undefined}
	Materials = undefined;

	/// @var {Id.DsMap, Undefined}
	Sprites = undefined;

	static __LoadMaterials = function (_path) {
		var _file = file_text_open_read(_path);
		if (_file == -1)
		{
			throw "Unable to open file " + _path + "!";
		}

		var _materials = ds_map_create();
		var _material = undefined;
		var _split = [];

		while (!file_text_eof(_file))
		{
			var _line = file_text_read_string(_file);
			StringExplode(_line, " ", _split);

			switch (_split[0])
			{
			// New material
			case "newmtl":
				_material = new CMaterial();
				_materials[? _split[1]] = _material;
				break;

			// Diffuse texture
			case "map_Kd":
				var _spritePath = filename_path(_path) + _split[1];
				if (Sprites == undefined)
				{
					Sprites = ds_map_create();
				}
				if (!ds_map_exists(Sprites, _spritePath))
				{
					if (!file_exists(_spritePath))
					{
						throw "File " + _spritePath + " does not exist!";
					}
					Sprites[? _spritePath] = sprite_add(_spritePath, 1, false, false, 0, 0);
				}
				_material.Texture = sprite_get_texture(Sprites[? _spritePath], 0);
				break;
			}

			file_text_readln(_file);
		}
		file_text_close(_file);

		Materials = _materials;
	};

	/// @func FromOBJ(_path)
	///
	/// @desc Imports a model from an OBJ file. The model must be triangulated
	/// and must have normals and texture coordinates.
	///
	/// @return {Struct.CModel} Returns `self`.
	///
	/// @throws {String} If an error occurs.
	static FromOBJ = function (_path) {
		if (IsLoaded)
		{
			throw "Already loaded!";
		}

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
		var _mesh = undefined;
		var _vertexBuffer = undefined;
		var _split = [];
		var _face = [];

		while (!file_text_eof(_file))
		{
			var _line = file_text_read_string(_file);
			StringExplode(_line, " ", _split);

			switch (_split[0])
			{
			// Materials
			case "mtllib":
				__LoadMaterials(filename_path(_path) + _split[1]);
				break;

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

			// Use material
			case "usemtl":
				if (_mesh)
				{
					vertex_end(_vertexBuffer);
				}

				_vertexBuffer = vertex_create_buffer();
				vertex_begin(_vertexBuffer, global.__vertexFormat);

				_mesh = new CMesh(self);
				_mesh.VertexBuffer = _vertexBuffer;
				_mesh.Material = _split[1];
				array_push(Meshes, _mesh);
				break;

			// Face
			case "f":
				if (_mesh == undefined)
				{
					_vertexBuffer = vertex_create_buffer();
					vertex_begin(_vertexBuffer, global.__vertexFormat);

					_mesh = new CMesh(self);
					_mesh.VertexBuffer = _vertexBuffer;
					array_push(Meshes, _mesh);
				}
	
				for (var i = 1; i < 4; ++i)
				{
					StringExplode(_split[i], "/", _face);

					var _vertexIndex = (real(_face[0]) - 1) * 3;
					var _uvIndex     = (real(_face[1]) - 1) * 2;
					var _normalIndex = (real(_face[2]) - 1) * 3;

					vertex_position_3d(
						_vertexBuffer,
						_vertices[| _vertexIndex],
						_vertices[| _vertexIndex + 2] * -1.0,
						_vertices[| _vertexIndex + 1]);

					vertex_normal(
						_vertexBuffer,
						_normals[| _normalIndex],
						_normals[| _normalIndex + 2] * -1.0,
						_normals[| _normalIndex + 1]);

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

		if (_mesh != undefined)
		{
			vertex_end(_vertexBuffer);
		}

		ds_list_destroy(_vertices);
		ds_list_destroy(_normals);
		ds_list_destroy(_textureCoords);

		IsLoaded = true;

		return self;
	};

	/// @func Freeze()
	///
	/// @desc
	///
	/// @return {Struct.CModel} Returns `self`.
	static Freeze = function () {
		for (var i = array_length(Meshes) - 1; i >= 0; --i)
		{
			Meshes[i].Freeze();
		}
		return self;
	};

	/// @func Submit()
	///
	/// @desc
	///
	/// @return {Struct.CModel} Returns `self`.
	static Submit = function () {
		for (var i = array_length(Meshes) - 1; i >= 0; --i)
		{
			Meshes[i].Submit();
		}
		return self;
	};

	/// @func Destroy()
	///
	/// @return {Undefined}
	static Destroy = function () {
		// Free meshes
		for (var i = array_length(Meshes) - 1; i >= 0; --i)
		{
			Meshes[i].Destroy();
		}
		Meshes = undefined;

		// Free materials
		if (Materials != undefined)
		{
			var _name = ds_map_find_first(Materials);
			repeat (ds_map_size(Materials))
			{
				Materials[? _name].Destroy();
				_name = ds_map_find_next(Materials, _name);
			}
			ds_map_destroy(Materials);
		}

		// Free sprites
		if (Sprites != undefined)
		{
			var _path = ds_map_find_first(Sprites);
			repeat (ds_map_size(Sprites))
			{
				sprite_delete(Sprites[? _path]);
				_path = ds_map_find_next(Sprites, _path);
			}
			ds_map_destroy(Sprites);
		}

		return undefined;
	};
}
