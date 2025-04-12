# GdUnit generated TestSuite
class_name PicklerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/picklegd/pickler.gd'


var _pickler:Pickler = Pickler.new()
var _data = {
		"one": CustomClassOne.new(),
		"two": CustomClassTwo.new(),
		"3": CustomClassTwo.new(),
		"json_things": ["str", 42, {"foo":"bar"}, [1,2,3], true, false, null],
		"native": Vector3(0,1,2),
		"nativeobj": Node2D.new(),
	}
	

var _builtins = {
	"builtins": [
		# refer to @GlobalScope.Variant.Type enum in Godot 4.4
		null,
		true,
		2,
		3.0,
		"four",
		Vector2(5.0,5.0),
		Vector2i(6,6),
		Rect2(7.0, 7.0, 7.0, 7.0),
		Rect2i(8,8,8,8),
		Vector3(9.0,9.0,9.0),
		Vector3i(10,10,10),
		Transform2D(),
		Vector4(12.0,12.0,12.0,12.0),
		Vector4i(13,13,13,13),
		Plane(),
		Quaternion(),
		AABB(),
		Basis(),
		Transform3D(),
		Projection(),
		Color(0.5, 0.5, 0.5, 0.5),
		StringName("twenty_one"),
		NodePath(),
		#RID(), # type 23 rejected type because it's an internal ID
		#Object.new(), # type 24 is the entire point of the Pickler!
		#Callable(), # type 25 rejected type because it's code-over-the-wire
		#Signal(), # type 26 rejected type because it's code-over-the-wire
		Dictionary(),
		Array(),
		PackedByteArray([29,29,29,29]),
		PackedInt32Array([30,30,30,30]),
		PackedInt64Array([31,31,31,31]),
		PackedFloat32Array([32.0,32.0,32.0,32.0]),
		PackedFloat64Array([33.0,33.0,33.0,33.0]),
		PackedStringArray(["thirty", "four"]),
		PackedVector2Array([Vector2(35,35),Vector2(35,35)]),
		PackedVector3Array([Vector3(36,36,36),Vector3(36,36,36)]),
		PackedColorArray([Color(0.3,0.7,0.0),Color(0.3,0.7,0.0)]),
		PackedVector4Array([Vector4(38.0,38.0,38.0,38.0),Vector4(38.0,38.0,38.0,38.0)]),
	]
}
var _resources = {
	"resource": Resource.new(),
	"circle": CircleShape2D.new(),
	"image": Image.load_from_file("res://icon.svg"),
	#"material": load("res://test/picklegd/test_mat.tres")
}
var _customs = {
	"one": CustomClassOne.new(),
	"unsafe": TestFormUnsafe.new(),
}
var _misc = {
	"json_things": ["str", 42, {"foo":"bar"}, [1,2,3], true, false, null],
	"json_things_2": {"foo":"bar", "baz":123},
	"nativeobj": Node2D.new(),
}

class InlineObject extends Object:
	@export var foo: int = 1
	@export var bar: float = 2.0


## recursive check for equality thru dictionaries and arrays.
func check_are_equal(left, right):
	assert_int(typeof(left)).is_equal(typeof(right))
	match typeof(left):
		TYPE_DICTIONARY:
			assert_dict(left).contains_same_keys(right.keys())
			for k in left.keys():
				check_are_equal(left[k], right[k])
		TYPE_ARRAY:
			assert_array(left).has_size(len(right))
			for i in range(len(left)):
				check_are_equal(left[i], right[i])
		TYPE_OBJECT:
			assert_str(left.get_class()).is_equal(right.get_class())
			assert_that(left).is_equal(right)
		_:
			assert_that(left).is_equal(right)


func roundtrip(dict: Dictionary):
	var p = _pickler.pickle(dict)
	var u = _pickler.unpickle(p)
	check_are_equal(dict, u)
	
	for key in u:
		if u[key] is Node:
			u[key].queue_free()
			
	var ps = _pickler.pickle_str(dict)
	var us = _pickler.unpickle_str(ps)
	check_are_equal(dict, us)
	
	for key in us:
		if us[key] is Node:
			us[key].queue_free()


func before():
	_data["one"].foo = 2.0
	_data["two"].qux = "r"
	_customs["one"].foo = 2.0
	#_customs["two"].qux = "r"
	_resources["circle"].radius = 5.0


func before_test():
	_pickler.class_registry.clear()


func test_register_custom_class() -> void:
	_pickler.register_custom_class(CustomClassOne)
	assert_that(_pickler.has_custom_class(CustomClassOne))


func test_register_native_class() -> void:
	_pickler.register_native_class("Node2D")
	assert_that(_pickler.has_native_class("Node2D"))


func test_roundtrip_builtins() -> void:
	roundtrip(_builtins)


func test_roundtrip_resources() -> void:
	_pickler.register_native_class("Resource")
	_pickler.register_native_class("CircleShape2D")
	_pickler.register_native_class("Image")
	assert_that(_pickler.class_registry.has_by_name("Resource"))
	assert_that(_pickler.class_registry.has_by_name("CircleShape2D"))
	assert_that(_pickler.class_registry.has_by_name("Image"))
	roundtrip(_resources)


func test_roundtrip_customs() -> void:
	_pickler.register_custom_class(CustomClassOne)
	_pickler.register_custom_class(TestFormUnsafe)
	assert_that(_pickler.class_registry.has_by_name("CustomClassOne"))
	assert_that(_pickler.class_registry.has_by_name("TestFormUnsafe"))
	roundtrip(_customs)
	
	
func test_roundtrip_misc() -> void:
	_pickler.register_native_class("Node2D")
	assert_that(_pickler.class_registry.has_by_name("Node2D"))
	roundtrip(_misc)


	
func test_pickle_getstate_setstate():
	_pickler.register_custom_class(CustomClassTwo)
	assert_that(_pickler.has_custom_class(CustomClassTwo))
	var two = CustomClassTwo.new()
	var p = _pickler.pickle(two)
	assert_int(two.volatile_int).is_equal(-1)
	var u = _pickler.unpickle(p)
	assert_int(u.volatile_int).is_equal(99)
		
func test_pickle_str():
	_pickler.register_custom_class(CustomClassOne)
	_pickler.register_custom_class(CustomClassTwo)
	_pickler.register_native_class("Node2D")
	var j = _pickler.pickle_str(_data)
	var u = _pickler.unpickle_str(j)
	u["nativeobj"].queue_free()
	
func test_pickle_filtering():
	var j = _pickler.pre_pickle(_data)
	assert_that(j["one"]).is_null()
	assert_that(j["two"]).is_null()
	assert_that(j["3"]).is_null()
	assert_array(j["json_things"]).contains_exactly(_data["json_things"])
	assert_that(j["native"]).is_equal(Vector3(0,1,2))
	assert_that(j["nativeobj"]).is_null()
	
	j["bad_obj"] = {
		Pickler.CLASS_KEY: 99
	}
	
	var u = _pickler.post_unpickle(j)
	assert_that(u["bad_obj"]).is_null()

	#assert_error(_pickler.pre_pickle.bind(Node2D.new()))\
	#.is_push_error('Missing object type in picked data: Node2D')

# TODO: this should be a set of tests for a Registry
func test_pickle_load_associations() -> void:
	_pickler.register_custom_class(CustomClassOne)
	_pickler.register_custom_class(CustomClassTwo)
	_pickler.register_native_class("Node2D")
	assert_that(_pickler.has_custom_class(CustomClassOne))
	assert_that(_pickler.has_custom_class(CustomClassTwo))
	assert_that(_pickler.has_native_class("Node2D"))
	
	var p2: Pickler = Pickler.new()

	var assoc = _pickler.class_registry.get_associations()
	p2.class_registry.add_name_to_id_associations(assoc)
	p2.register_native_class("Node2D")
	p2.register_custom_class(CustomClassTwo)
	p2.register_custom_class(CustomClassOne)
	assert_that(p2.has_custom_class(CustomClassOne))
	assert_that(p2.has_custom_class(CustomClassTwo))
	assert_that(p2.has_native_class("Node2D"))

	for cls_name in _pickler.class_registry.by_name:
		var cls1 = _pickler.class_registry.get_by_name(cls_name)
		var cls2 = p2.class_registry.get_by_name(cls_name)
		assert_str(cls1.name).is_equal(cls2.name)
		assert_int(cls1.id).is_equal(cls2.id)


func test_newargs():
	_pickler.register_custom_class(CustomClassNewargs)
	var data := CustomClassNewargs.new("constructor_arg!")
	var s = _pickler.pickle_str(data)
	print(s)
	var u = _pickler.unpickle_str(s)
	print(u.foo)
	assert_object(u).is_equal(data)
	
func test_registered_getstate_setstate_newargs():
	var reg := _pickler.register_custom_class(CustomClassNewargs)
	reg.__getnewargs__ = func(obj): return ["lambda_newarg!"]
	reg.__getstate__ = func(obj): return {"baz": obj.baz}
	reg.__setstate__ = func(obj, state): obj.baz = state["baz"]
	var data = CustomClassNewargs.new("constructor_arg!")
	data.qux = "just a whatever string this won't show up in the output."
	var s = _pickler.pickle_str(data)
	print(s)
	var u = _pickler.unpickle_str(s)
	print(u.qux)
	assert_str(u.foo).is_not_equal(data.foo)
	assert_float(u.baz).is_equal(data.baz)
	assert_str(u.qux).is_not_equal(data.qux)

func test_instantiate_newargs_nativeobj():
	var reg = _pickler.register_native_class("Node2D")
	reg.__getnewargs__ = func(obj): return [Vector2(1,1)]
	var n = Node2D.new()
	var s = _pickler.pickle_str(n)
	print(s)
	var u = _pickler.unpickle_str(s)
	print(u)
	assert_object(u).is_equal(n)
	n.queue_free()
	u.queue_free()
	

## You can't pickle an instance of an inline class. 
## It doesn't have a global name.
func test_base_pickle_inline_object():
	var s = _pickler.pickle_str(InlineObject.new())
	assert_str(s).is_equal('null')
	var cls_name = _pickler.get_object_class_name(InlineObject.new())
	assert_str(cls_name).is_empty()
	

func test_base_pickle_inject_script_change():
	_pickler.register_custom_class(TestForm)
	
	var t = TestForm.new()
	var s = _pickler.pickle_str(t)
	s = s.replace("TestForm", "TestFormUnsafe")
	print(s)
	var u = _pickler.unpickle_str(s)
	print(u)
	assert_object(u).is_instanceof(TestForm)


	
## A pickled script shouldn't have any source code. Sorry.
func test_base_pickle_a_script():
	_pickler.register_native_class("GDScript")
	_pickler.register_native_class("Script")
	var s = _pickler.pickle_str(TestFormUnsafe)
	var u = _pickler.unpickle_str(s)
	assert_object(TestFormUnsafe).is_not_equal(u)
	var scr = GDScript.new()
	scr.source_code = \
"""
class_name Blah extends Refcounted

func _init():
	print("blah blah blah")

"""
	
	s = _pickler.pickle_str(scr)
	print(s)
	u = _pickler.unpickle_str(s)
	assert_object(scr).is_not_equal(u)
