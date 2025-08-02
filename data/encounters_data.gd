extends Node
class_name EncountersData

static var encounters: Array[EncounterMetadata] = [
	EncounterMetadata.new({
		"enemy_id": "duck",
		"enemy_name": "Sapwing",
		"health": 300,
		"cards": [],
		"reward_cards": ["loop"],
		"hint": "Try dragging some cards into the highlighted areas",
		"solution_cards": ["attack", "attack", "attack"],
	}),
	EncounterMetadata.new({
		"enemy_id": "ladybug",
		"enemy_name": "Ladylook",
		"health": 500,
		"cards": ["regen", "regen"],
		"hint": "The enemy outheals all your attacks!\nTry placing the card 'Loop' after your other cards.",
		"solution_cards": ["attack", "attack", "attack", "loop"],
	}),
	EncounterMetadata.new({
		"enemy_id": "ladybug2",
		"enemy_name": "Sirlook",
		"health": 500,
		"cards": ["", "multi", "multi", "regen", "regen", "regen", ""],
		"reward_cards": ["multi"],
		"hint": "This enemy will regenerate more than any of your attacks can outdamage!\nLook carefully at the second property of the 'Loop' card.",
		"solution_cards": ["attack", "attack", "loop", "", "", "", ""],
	}),
	EncounterMetadata.new({
		"enemy_id": "rat",
		"enemy_name": "Loongy Goo",
		"health": 700,
		"cards": ["attack", "regen", "regen", "regen", "regen", "regen", "multi"],
		"reward_cards": ["regen"],
		"hint": "This time you need more damage than all your raw 'Attack' cards provide.\nTry using 'Tallying' you just got.\n'Loop' card is not an attack card, so to speak",
		"solution_cards": ["multi", "attack", "attack", "attack", "loop", "", ""],
	}),
	EncounterMetadata.new({
		"enemy_id": "mimic",
		"enemy_name": "Mimic",
		"health": 500,
		"cards": ["reverse", "reverse", "reverse", "reverse", "reverse", "", ""],
		"reward_cards": ["reverse"],
		"hint": "Put your damaging card at the end of the loop.\nNeed to somehow neutralize their last 'Reverse' card though",
		"solution_cards": ["", "", "", "", "multi", "attack", "loop"],
	}),
	EncounterMetadata.new({
		"enemy_id": "bee",
		"enemy_name": "Bee-Beep",
		"health": 1000,
		"cards": ["multi", "attack", "loop", "", "", "", ""],
		"hint": "Check out the new slick 'Reverse' card you just got.\nWhat if it's placed before the enemy attacks?",
		"solution_cards": ["reverse", "", "", "", "", "", ""],
	}),
	EncounterMetadata.new({
		"enemy_id": "cycloop",
		"enemy_name": "Cycloop",
		"health": 800,
		"cards": ["attack", "reverse", "attack", "", "reverse", "multi", "attack"],
		"hint": "If you don't put any card after the enemy's reverse,\nthen that card will be neutralized by their own card.",
		"solution_cards": ["multi", "", "attack", "loop", "", "", ""],
	}),
	EncounterMetadata.new({
		"enemy_id": "lich",
		"enemy_name": "Necro Deck",
		"health": 1000,
		"cards": ["wildcard", "wildcard", "wildcard", "wildcard", "wildcard", "wildcard", "wildcard"],
		"hint": "Their weakness is 'Reverse'.",
		"solution_cards": ["reverse", "loop", "", "", "", "", ""],
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
