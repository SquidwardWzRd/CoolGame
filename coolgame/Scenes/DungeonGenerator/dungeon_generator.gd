extends Node2D

# Refrence Article
# https://www.gamedeveloper.com/programming/procedural-dungeon-generation-algorithm
# Another Helpful Post
# https://www.reddit.com/r/roguelikedev/comments/18qnyx1/how_to_separate_sort_rooms/


@export var radius = 200.0
@export var amount = 20
var tile_size = 16

@onready var rb_script = load("res://Scenes/DungeonGenerator/room.gd")
@onready var dungeon_tile_scene = load("res://Scenes/DungeonGenerator/dungeon_tile.tscn")

func _ready() -> void:
	generateRooms(amount)

func _process(delta: float) -> void:
	pass

func getRandomPointInCircle(radius:float) -> Vector2:
	var t = 2 * PI * randf()
	var u = randf() + randf()
	var r = null
	
	if u > 1 : r = 2-u
	else : r = u
	var x = radius*r*cos(t)
	var y = radius*r*sin(t)
	return snapped(Vector2(x, y), Vector2(16,16))


func generateRooms(amount: int) -> void:
	var rooms: Array[Rect2] = []
	
	var max = 30
	for i in range(amount):
		var pos = getRandomPointInCircle(radius)
		var w = randi_range(10,max) * tile_size
		var h = randi_range(10,max) * tile_size
		var room: Rect2 = Rect2(pos, Vector2(w,h))
		rooms.append(room)
	
	# Fix Overlaps
	rooms = resolveOverlaps(rooms)
	
	# Build MST
	var mst: Array[Dictionary] = MST(rooms)
	# Draw The Graph
	var graph_scene = load("res://Scenes/DungeonGenerator/mst_graph.tscn")
	var graph = graph_scene.instantiate()
	graph.mst = mst
	graph.mainrooms = rooms
	add_child(graph)
	graph.queue_redraw()
	
	# Draw the Rooms
	for room in rooms:
		DrawRoom(room)

func MST(rooms: Array[Rect2]) -> Array[Dictionary]:
	# Get the Centerpoints
	var centerpoints: Array[Vector2] = []
	for room in rooms:
		centerpoints.append(room.get_center())
	# Build the Edges
	var edges: Array[Dictionary] = []
	for i in range(len(centerpoints)):
		# Offset J by one so they arent the same
		for j in range(i+1, len(centerpoints)):
			var a = centerpoints[i]
			var b = centerpoints[j]
			var distance = a.distance_to(b)
			edges.append({"from":i,"to":j,"weight":distance})
	
	# Now we have an edge weight for every room connection
	# We need to sort it short to long
	edges.sort_custom(func(a,b): return a["weight"] < b["weight"])
	
	# Union-Find setup
	var parent = []
	var rank = []
	for i in range(centerpoints.size()):
		parent.append(i)
		rank.append(0)
	
	# Build MST
	var mst: Array[Dictionary] = []
	for edge in edges:
		var x = mst_find(parent, edge["from"])
		var y = mst_find(parent, edge["to"])
		if x != y:
			mst.append(edge)
			mst_union(parent, rank, x, y)
	
	return mst

# Find the root of the group
func mst_find(parent: Array, i: int) -> int:
	if parent[i] != i:
		parent[i] = mst_find(parent, parent[i])  # Path compression
	return parent[i]

# Union two groups
func mst_union(parent: Array, rank: Array, x: int, y: int) -> void:
	var xroot = mst_find(parent, x)
	var yroot = mst_find(parent, y)

	if rank[xroot] < rank[yroot]:
		parent[xroot] = yroot
	elif rank[xroot] > rank[yroot]:
		parent[yroot] = xroot
	else:
		parent[yroot] = xroot
		rank[xroot] += 1

func resolveOverlaps(rooms: Array[Rect2], count = 0) -> Array[Rect2]:
	var length: int = len(rooms)
	for i in range(length):
		for j in range(length):
			if i == j:
				continue
			if rooms[i].intersects(rooms[j]):
				#Push Apart
				var newPositions = pushApart(rooms[i], rooms[j])
				rooms[i].position = newPositions[0]
				rooms[j].position = newPositions[1]
				if count >= 1000:
					print("Overflow")
					return rooms
				return resolveOverlaps(rooms, count + 1)
	print("Recursive Count: ", count)
	return rooms

# I want to adjust this and make it take Rect2 as arguments
func pushApart(a: Rect2, b: Rect2) -> Array:
	var pos1: Vector2 = a.position
	var pos2: Vector2 = b.position
	
	var strength = ((a.size.x + b.size.x) + (a.size.y + b.size.y)) / 2
	
	# Vector from rect2 to rect1
	var d = pos1.direction_to(pos2)
	
	# Move the Rooms
	var move = Vector2(d.x * strength, d.y * strength)
	
	var newPos1 = Vector2(pos1.x + move.x, pos1.y + move.y)
	var newPos2 = Vector2(pos2.x - move.x, pos2.y - move.y)
	return [snapped(newPos1, Vector2(16,16)), snapped(newPos2, Vector2(16,16))]


func DrawRoom(room: Rect2) -> void:
	var dungeon_tile = dungeon_tile_scene
	var tiles: Array[Node2D] = []

	for x in range(room.size.x / 16):
		for y in range(room.size.y / 16):
			var tile = dungeon_tile.instantiate()
			tile.position = room.position + Vector2(x * 16, y * 16)
			add_child(tile)
			tiles.append(tile)
	for tile in tiles:
		tile.auto_detect()
	
	#var col = CollisionShape2D.new()
	#var shape = RectangleShape2D.new()
	#shape.size = room.size
	#col.shape = shape
	#col.position = room.get_center()  # keep centered
	#add_child(col)
