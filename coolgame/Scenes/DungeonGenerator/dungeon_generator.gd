extends Node2D

# Refrence Article
# https://www.gamedeveloper.com/programming/procedural-dungeon-generation-algorithm
# Another Helpful Post
# https://www.reddit.com/r/roguelikedev/comments/18qnyx1/how_to_separate_sort_rooms/


@export var radius = 200.0
@export var amount = 20
var tile_size = 16

@onready var rb_script = load("res://Scenes/DungeonGenerator/room.gd")
@onready var sewer_scene = load("res://Scenes/DungeonGenerator/SewerParts/sewer_floor.tscn")

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

func rectangles_overlap(pos1, size1, pos2, size2) -> bool:
	var left1 = pos1.x - size1.x / 2
	var right1 = pos1.x + size1.x / 2
	var top1 = pos1.y + size1.y / 2
	var bottom1 = pos1.y - size1.y / 2
	
	var left2 = pos2.x - size2.x / 2
	var right2 = pos2.x + size2.x / 2
	var top2 = pos2.y + size2.y / 2
	var bottom2 = pos2.y - size2.y / 2
	
	var separated = right1 <= left2 or right2 <= left1 or top1 <= bottom2 or top2 <= bottom1
	
	return not separated

func generateRooms(amount: int) -> void:
	var rooms = []
	
	var max = 30
	for i in range(amount):
		var point = getRandomPointInCircle(radius)
		var w = randi_range(10,max)
		var h = randi_range(10,max)
		rooms.append([point, snapped(Vector2(w*tile_size,h*tile_size), Vector2(16,16))])
	
	# Fix Overlaps
	rooms = resolveOverlaps(rooms)
	
	# Build MST
	var mst = MST(rooms)
	# Draw The Graph
	var graph_scene = load("res://Scenes/DungeonGenerator/mst_graph.tscn")
	var graph = graph_scene.instantiate()
	graph.mst = mst
	graph.mainrooms = rooms
	add_child(graph)
	graph.queue_redraw()
	
	# Draw the Rooms
	for room in rooms:
		DrawRoom(room[0], room[1].x, room[1].y)

func MST(mainrooms: Array) -> Array:
	# Get the Centerpoints
	var centerpoints = []
	for room in mainrooms:
		centerpoints.append(room[0])
	# Build the Edges
	var edges = []
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
	var mst = []
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

func resolveOverlaps(rooms: Array, count = 0) -> Array:
	for i in rooms:
		for j in rooms:
			if i[0] == j[0]:
				continue
			if rectangles_overlap(i[0], i[1], j[0], j[1]):
				#Push Apart
				var newPositions = pushApart(i[0], i[1], j[0], j[1])
				i[0] = newPositions[0]
				j[0] = newPositions[1]
				#if count >= 2000:
					#return rooms
				return resolveOverlaps(rooms, count + 1)
	print("Recursive Count: ", count)
	return rooms

func pushApart(pos1, size1, pos2, size2) -> Array:
	var strength = (tile_size ** 2) / 2
	
	# Vector from rect2 to rect1
	var d = Vector2(pos1.x - pos2.x, pos1.y - pos2.y)
	
	# Avoid Division by 0
	if d.x == 0 and d.y == 0:
		d = Vector2(1,0)
	
	# Normalize the Vector
	var dist = (d.x ** 2 + d.y ** 2) ** 0.5
	d.x /= dist
	d.y /= dist
	
	# Move the Rooms
	var move = Vector2(d.x * strength, d.y * strength)
	
	var newPos1 = Vector2(pos1.x + move.x, pos1.y + move.y)
	var newPos2 = Vector2(pos2.x - move.x, pos2.y - move.y)
	return [snapped(newPos1, Vector2(16,16)), snapped(newPos2, Vector2(16,16))]


func DrawRoom(pos:Vector2, width: int, height: int, main: bool = false) -> void:
	var sewer = sewer_scene
	var origin = pos - Vector2(width, height) / 2  # shift from center to top-left

	for x in range(width / 16):
		for y in range(height / 16):
			var block = sewer.instantiate()
			block.position = origin + Vector2(x, y) * tile_size + Vector2(tile_size / 2, tile_size / 2)
			add_child(block)
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	col.position = pos  # keep centered
	if main:
		col.debug_color = Color("bd292e6b")
	
	add_child(col)
