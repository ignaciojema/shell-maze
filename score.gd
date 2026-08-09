extends Label

@onready var player: CharacterBody3D = $"../../Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.text = str(player.score)
