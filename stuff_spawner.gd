extends Node

@onready var objs1 = $"../Part1/Objects"
@onready var tl1 = $"../Part1/TL".position
@onready var tr1 = $"../Part1/TR".position
@onready var br1 = $"../Part1/BR".position
@onready var bl1 = $"../Part1/BL".position

@onready var objs2 = $"../Part2/Objects"
@onready var tl2 = $"../Part2/TL".position
@onready var tr2 = $"../Part2/TR".position
@onready var br2 = $"../Part2/BR".position
@onready var bl2 = $"../Part2/BL".position

@onready var path = $"../PathMaker/CollisionPolygon2D"

const TREE_SCENE = preload("res://tree_short.tscn")
const SNOWMAN_SCENE = preload("res://snowman.tscn")

var matrix = []
var available_positions = []

var turn = 1

func reload(part:int):
	turn += 1;
	createMatrix()
	if part == 1:
		for child in objs1.get_children():
			child.queue_free()
	else:
		for child in objs2.get_children():
			child.queue_free()
	
	spawnStuff(part)
	clearPath(part)

func createMatrix():
	var distance_x = tr1.x - tl1.x
	var distance_y = abs(tl1.y - bl1.y)
	
	var rows = int(distance_y / 16)
	var columns = int(distance_x / 16)
	
	matrix = []
	available_positions.clear()

	for i in range(rows):
		var row = []
		for j in range(columns):
			var x_pos = tl1.x + j * (distance_x / columns) + 8
			var y_pos = tl1.y + i * (distance_y / rows)
			var pos = Vector2(x_pos, y_pos)
			row.append(pos)
			available_positions.append(pos)
		matrix.append(row)

func spawnObject(scene: PackedScene, part: int):
	if available_positions.size() == 0:
		return
	
	var random_index = randi_range(0, available_positions.size() - 1)
	var pos = available_positions[random_index]
	available_positions.remove_at(random_index)
	
	var instance = scene.instantiate()
	instance.position = pos
	
	if part == 1:
		objs1.add_child(instance)
	else:
		objs2.add_child(instance)

func clearPath(p):
	var random_x = randi_range(int(tl1.x), int(tr1.x) -16)
	var points = path.polygon
	
	points[0].x = points[3].x
	points[1].x = points[2].x
	points[2].x = random_x + 16
	points[3].x = random_x - 16
	
	path.polygon = points
	
	$"../PathMaker/Timer".wait_time = 0.1
	$"../PathMaker/Timer".start()
	path.disabled = false

func spawnStuff(part):
	for i in range(randi_range((10 + turn), (15 + turn) )):
		spawnObject(TREE_SCENE, part)
	for i in range(turn):
		spawnObject(SNOWMAN_SCENE, part)
