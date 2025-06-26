extends MeshInstance3D

@export var radius: float = 141600.0
@export var segments: int = 10000
@export var line_color: Color = Color.WHITE

func _ready():
	var mesh := ArrayMesh.new()
	var st := SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in range(segments + 1):  # Close the circle
		var angle = TAU * i / segments
		var pos = Vector3(radius * cos(angle), 0, radius * sin(angle))
		st.set_color(line_color)
		st.add_vertex(pos)
	st.commit(mesh)

	self.mesh = mesh
	self.material_override = create_line_material()

func create_line_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = line_color
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_transparent = true
	return mat
