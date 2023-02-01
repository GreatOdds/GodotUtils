extends Node

# Load as an autoload and call functions to draw shapes

const DEFAULT_LINGER_3D := 1 # Frames
const DEFAULT_COLOR_3D := Color.BLUE

var shapes_3d: Array[ShapeInfo] = []
var immi_mesh := ImmediateMesh.new()
var debug_mat := StandardMaterial3D.new()

func _ready() -> void:
	debug_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	debug_mat.set_flag(BaseMaterial3D.FLAG_DISABLE_DEPTH_TEST, true)
	
	var mi := MeshInstance3D.new()
	mi.cast_shadow = false
	mi.mesh = immi_mesh
	add_child(mi)

func _process(_delta: float) -> void:
	_update_mesh()

func line_3d(from: Vector3, to: Vector3,
		color := DEFAULT_COLOR_3D, linger := DEFAULT_LINGER_3D) -> void:
	var new_shape := ShapeInfo.new(Engine.get_frames_drawn(), linger)
	new_shape.material = _get_material(color)
	new_shape.vertices = PackedVector3Array([from, to])
	new_shape.indices = PackedInt32Array([0, 1])
	shapes_3d.append(new_shape)

func vector_3d(origin: Vector3, vector: Vector3,
		color := DEFAULT_COLOR_3D, linger := DEFAULT_LINGER_3D) -> void:
	var new_shape := ShapeInfo.new(Engine.get_frames_drawn(), linger)
	new_shape.material = _get_material(color)
	new_shape.vertices = PackedVector3Array([origin, origin + vector])
	new_shape.indices = PackedInt32Array([0, 1])
	shapes_3d.append(new_shape)

func transform_3d(transform: Transform3D, linger := DEFAULT_LINGER_3D) -> void:
	line_3d(transform.origin, transform.origin + transform.basis.x, Color.RED, linger)
	line_3d(transform.origin, transform.origin + transform.basis.y, Color.GREEN, linger)
	line_3d(transform.origin, transform.origin + transform.basis.z, Color.BLUE, linger)

func box_3d(origin: Vector3, size: Vector3,
		color := DEFAULT_COLOR_3D, linger := DEFAULT_LINGER_3D) -> void:
	var new_shape := ShapeInfo.new(Engine.get_frames_drawn(), linger)
	new_shape.material = _get_material(color)
	var tf := Transform3D.IDENTITY
	tf.scaled(size)
	tf.origin = origin
	new_shape.vertices = PackedVector3Array([
		Vector3(-0.5,-0.5,-0.5),
		Vector3(-0.5,-0.5, 0.5),
		Vector3(-0.5, 0.5,-0.5),
		Vector3(-0.5, 0.5, 0.5),
		Vector3( 0.5,-0.5,-0.5),
		Vector3( 0.5,-0.5, 0.5),
		Vector3( 0.5, 0.5,-0.5),
		Vector3( 0.5, 0.5, 0.5),]) * tf
	new_shape.indices = PackedInt32Array([
		0, 1,
		0, 2,
		0, 4,
		1, 3,
		1, 5,
		2, 3,
		2, 6,
		3, 7,
		4, 5,
		4, 6,
		5, 7,
		6, 7,])
	shapes_3d.append(new_shape)

func sphere_3d(origin: Vector3, radius: float,
		color := DEFAULT_COLOR_3D, linger := DEFAULT_LINGER_3D) -> void:
	pass

func _update_mesh() -> void:
	immi_mesh.clear_surfaces()
	
	var current_frame := Engine.get_frames_drawn()
	
	var expired_shapes: Array[ShapeInfo] = []
	
	for shape in shapes_3d:
		if (current_frame - shape.frame_created >= shape.linger):
			expired_shapes.append(shape)
			continue
		immi_mesh.surface_begin(Mesh.PRIMITIVE_LINES, shape.material)
		for index in shape.indices:
			immi_mesh.surface_add_vertex(shape.vertices[index])
		immi_mesh.surface_end()
		
	
	for shape in expired_shapes:
		shapes_3d.erase(shape)

func _get_material(color := DEFAULT_COLOR_3D) -> StandardMaterial3D:
	var mat := debug_mat.duplicate()
	mat.albedo_color = color
	return mat

class ShapeInfo extends RefCounted:
	var frame_created: int = 0
	var linger: int = 0
	var material: StandardMaterial3D
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	
	func _init(p_frame_created := 0, p_linger := 0) -> void:
		frame_created = p_frame_created
		linger = p_linger
