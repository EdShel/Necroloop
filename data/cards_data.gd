extends Node
class_name CardsData

static var cards: Array[CardMetadata] = [
	CardMetadata.new(
		"attack",
		"Attack",
		"Reduce opponent's health by 100 when played",
		{ "amount": 100 }
	),
	CardMetadata.new(
		"regen",
		"Regenerate",
		"Increase caster's health by 100 when played",
		{ "amount": 100 }
	),
	CardMetadata.new(
		"multi",
		"Tallying",
		"If caster's previous card wasn't attack, their next card is 4x powerful",
		{ "amount": 4 }
	),
	CardMetadata.new(
		"reverse",
		"Reverse",
		"The next card is played in favor of the caster",
	),
	CardMetadata.new(
		"loop",
		"Loop",
		"Play all cards again. Cards to the right won't be played"
	),
	CardMetadata.new(
		"wildcard",
		"Wildcard",
		"Becomes another card based on opponent's cards"
	),
]

static var cards_ord: Dictionary[String, int] = {}

static func get_data(card_id: String) -> CardMetadata:
	for card in cards:
		if card.id == card_id:
			return card
	assert(false, "Card wasn't found: " + card_id)
	return null

static func get_ord(card_id: String) -> int:
	if cards_ord.is_empty():
		for i in range(cards.size()):
			cards_ord.set(cards[i].id, i)
	return cards_ord[card_id]


class CardMetadata:
	var id: String
	var name: String
	var text: String
	var payload: Dictionary
	
	func _init(
		id: String,
		name: String,
		text: String,
		payload: Dictionary = {}
	) -> void:
		self.id = id
		self.name = name
		self.text = text
		self.payload = payload
	
	func get_amount() -> int:
		return payload["amount"]
