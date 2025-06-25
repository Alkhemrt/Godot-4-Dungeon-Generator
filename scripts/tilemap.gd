extends TileMap

@export var mapWidth = 21
@export var mapHeight = 11

@export var minRoomSize = 3
@export var maxRoomSize = 5

func _ready():
	DungeonGenerator.generate(self, mapWidth, mapHeight, minRoomSize, maxRoomSize)


func _on_button_pressed():
	DungeonGenerator.generate(self, mapWidth, mapHeight, minRoomSize, maxRoomSize)
