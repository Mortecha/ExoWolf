extends StaticBody
tool
export(bool) var generate_mesh setget generate_mesh
export(int) var size = 512
export(int) var subdivide = 64
export(int) var amplitude = 16
export(int) var falloff_amplitude = 8

export(int) var seed_value = 1
export(int) var octaves = 3 # set between 1 and 3 
export(int) var period = 100
export(int) var persistance = 2

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

	gradient_data.lock()

	for i in vertices.size():
		var vertex = vertices[i]
		var gradient_point = gradient_data.get_pixel(vertex.x + size / 2, vertex.z + size / 2)
		var noise_value = noise.get_noise_2d(vertex.x, vertex.z)
		vertices[i].y = noise_value * amplitude - gradient_point.r * falloff_amplitude
		
	data[ArrayMesh.ARRAY_VERTEX] = vertices

	gradient_data.unlock()

	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)

	surface_tool.create_from(array_mesh,0)
	surface_tool.generate_normals()

	$MeshInstance.mesh = surface_tool.commit()
	$CollisionShape.shape = array_mesh.create_trimesh_shape()
