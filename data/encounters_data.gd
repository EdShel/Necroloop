extends Node
class_name EncountersData

static var encounters: Array[EncounterMetadata] = [
	EncounterMetadata.new({
		"enemy_id": "duck",
		"enemy_name": "Sapwing",
		"health": 300,
		"cards": [],
		"reward_cards": ["loop"],
	}),
	EncounterMetadata.new({
		"enemy_id": "ladybug",
		"enemy_name": "Ladylook",
		"health": 500,
		"cards": ["regen", "regen"],
	}),
	EncounterMetadata.new({
		"enemy_id": "ladybug2",
		"enemy_name": "Sirlook",
		"health": 500,
		"cards": ["", "multi", "multi", "regen", "regen", "regen", ""],
		"reward_cards": ["multi"],
	}),
	EncounterMetadata.new({
		"enemy_id": "rat",
		"enemy_name": "Loongy Goo",
		"health": 700,
		"cards": ["attack", "regen", "regen", "regen", "regen", "regen", "multi"],
	}),
	EncounterMetadata.new({
		"enemy_id": "mimic",
		"enemy_name": "Mimic",
		"health": 500,
		"cards": ["reverse", "reverse", "reverse", "reverse", "reverse", "", ""],
	}),
	EncounterMetadata.new({
		"enemy_id": "cycloop",
		"enemy_name": "Cycloop",
		"health": 800,
		"cards": ["attack", "reverse", "attack", "", "reverse", "multi", "attack"],
		"reward_cards": ["reverse"],
	}),
	EncounterMetadata.new({
		"enemy_id": "bee",
		"enemy_name": "Bee-Beep",
		"health": 1000,
		"cards": ["multi", "attack", "loop", "", "", "", ""],
	}),
	EncounterMetadata.new({
		"enemy_id": "lich",
		"enemy_name": "Necro Deck",
		"health": 1000,
		"cards": ["wildcard", "wildcard", "wildcard", "wildcard", "wildcard", "wildcard", "wildcard"],
	}),
]

static func get_data(index: int) -> EncounterMetadata:
	if index >= encounters.size():
		return null
	return encounters[index]

class EncounterMetadata:
	var enemy_id: String
	var enemy_name: String
	var health: int
	var cards: Array[String]
	var reward_cards: Array[String]
	
	func _init(d: Dictionary) -> void:
		self.enemy_id = d["enemy_id"]
		self.enemy_name = d["enemy_name"]
		self.health = d["health"]
		self.cards = _untyped_array_to_string_array(d["cards"])
		if d.has("reward_cards"):
			self.reward_cards = _untyped_array_to_string_array(d["reward_cards"])
		else:
			self.reward_cards = []
	
	static func _untyped_array_to_string_array(ar: Array) -> Array[String]:
		var result: Array[String] = []
		for x in ar:
			result.push_back(x)
		return result
