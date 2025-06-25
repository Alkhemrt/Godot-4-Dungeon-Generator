extends Node

enum Tiles { EMPTY, SOLID }

class Room:
	var position: Vector2
	var dimensions: Vector2
	var centerpoint: Vector2
	
	func intersects(other: Room) -> bool:
		return (position.x < other.position.x + other.dimensions.x and
				position.x + dimensions.x > other.position.x and
				position.y < other.position.y + other.dimensions.y and
				position.y + dimensions.y > other.position.y)

var dugRooms = []
var rng = RandomNumberGenerator.new()
var mapWidth
var mapHeight

func _ready():
	rng.randomize()

func generate(map: TileMap, w: int, h: int, minRoomSize: int, maxRoomSize: int, maxRooms: int = 30):
	mapWidth = w
	mapHeight = h
	dugRooms.clear()

	# Fill map with solid tiles
	for r in range(-1, h + 1):
		for c in range(-1, w + 1):
			map.set_cell(0, Vector2i(c, r), 0, Vector2i(Tiles.SOLID, 0))

	var attempts = 0
	var maxAttempts = maxRooms * 5

	while dugRooms.size() < maxRooms and attempts < maxAttempts:
		attempts += 1

		var room = Room.new()
		room.dimensions = Vector2(
			rng.randi_range(minRoomSize, maxRoomSize),
			rng.randi_range(minRoomSize, maxRoomSize)
		)

		room.position = Vector2(
			rng.randi_range(1, w - int(room.dimensions.x) - 1),
			rng.randi_range(1, h - int(room.dimensions.y) - 1)
		)

		room.centerpoint = room.position + room.dimensions / 2

		var overlaps = false
		for existing in dugRooms:
			if room.intersects(existing):
				overlaps = true
				break

		if overlaps:
			continue

		dugRooms.append(room)
		digRoom(map, room)

		if dugRooms.size() > 1:
			connectRooms(map, dugRooms[-2], room)

func connectRooms(map, roomA: Room, roomB: Room):
	var start = roomA.centerpoint.floor()
	var end = roomB.centerpoint.floor()

	# L-shaped corridor: horizontal then vertical or vice versa
	if rng.randf() < 0.5:
		digLine(map, start, Vector2(end.x, start.y))
		digLine(map, Vector2(end.x, start.y), end)
	else:
		digLine(map, start, Vector2(start.x, end.y))
		digLine(map, Vector2(start.x, end.y), end)

func digLine(map, from: Vector2, to: Vector2):
	var dx = int(sign(to.x - from.x))
	var dy = int(sign(to.y - from.y))

	var pos = from
	while pos != to:
		digCell(map, pos)
		if pos.x != to.x:
			pos.x += dx
		elif pos.y != to.y:
			pos.y += dy
	digCell(map, to)

func digRoom(map, room: Room):
	for x in range(int(room.position.x), int(room.position.x + room.dimensions.x)):
		for y in range(int(room.position.y), int(room.position.y + room.dimensions.y)):
			digCell(map, Vector2(x, y))

func digCell(map, pos: Vector2):
	if pos.x >= 0 and pos.x < mapWidth and pos.y >= 0 and pos.y < mapHeight:
		map.set_cell(0, Vector2i(pos.x, pos.y), 0, Vector2i(Tiles.EMPTY, 0))
