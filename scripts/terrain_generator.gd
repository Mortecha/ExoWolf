extends StaticBody3D
@tool
@export var generate_mesh: bool :
	get:
		return generate_mesh # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of generate_mesh
@export var size: int = 512
@export var subdivide: int = 64
@export var amplitude: int = 16
@export var falloff_amplitude: int = 8

@export var seed_value: int = 1
@export var octaves: int = 3 # set between 1 and 3 
@export var period: int = 100
@export var persistance: int = 2

func generate_mesh(__):
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size, size)
	plane_mesh.subdivide_depth = subdivide
	plane_mesh.subdivide_width = subdivide
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var data = surface_tool.commit_to_arrays()
	var vertices = data[ArrayMesh.ARRAY_VERTEX]
	
	var noise = OpenSimplexNoise.new()
	noise.seed = seed_value
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistance

	var custom_gradient = CustomGradientTexture.new()
	custom_gradient.gradient = Gradient.new()
	custom_gradient.type = CustomGradientTexture.GradientType.RADIAL
	custom_gradient.size = Vector2(size + 1, size + 1)
	var gradient_data = custom_gradient.get_data()

	false # gradient_data.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

	for i in vertices.size():
		var vertex = vertices[i]
		var gradient_point = gradient_data.get_pixel(vertex.x + size / 2, vertex.z + size / 2)
		var noise_value = noise.get_noise_2d(vertex.x, vertex.z)
		vertices[i].y = noise_value * amplitude - gradient_point.r * falloff_amplitude
		
	data[ArrayMesh.ARRAY_VERTEX] = vertices

	false # gradient_data.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)

	surface_tool.create_from(array_mesh,0)
	surface_tool.generate_normals()

	$MeshInstance3D.mesh = surface_tool.commit()
	$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
