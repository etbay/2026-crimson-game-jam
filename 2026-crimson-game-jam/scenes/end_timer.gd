extends Label

func _ready() -> void:
	self.text = "Final Time: %f\nHits Taken: %d" % [GlobalStats.time, GlobalStats.hits]
