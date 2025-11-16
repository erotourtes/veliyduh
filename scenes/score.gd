extends Label

@onready var scoreNode: Label = $"."


func _on_enemies_score(score: int) -> void:
	scoreNode.text = str(score)
