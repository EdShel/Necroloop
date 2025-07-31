extends Node
class_name CardsData

static var cards: Array[CardMetadata] = [
	CardMetadata.new(
		"attack",
		"Attack",
		"Reduce opponent's health by 100 when played"
	),
	CardMetadata.new(
		"regen",
		"Regenerate",
		"Increase caster's health by 100 when played"
	),
	CardMetadata.new(
		"loop",
		"Loop",
		"Play all cards again. Cards to the right won't be played"
	),
]

static func get_data(card_id: String) -> CardMetadata:
	for card in cards:
		if card.id == card_id:
			return card
	assert(false, "Card wasn't found: " + card_id)
	return null

class CardMetadata:
	var id: String
	var name: String
	var text: String
	
	func _init(
		id: String,
		name: String,
		text: String
	) -> void:
		self.id = id
		self.name = name
		self.text = text
