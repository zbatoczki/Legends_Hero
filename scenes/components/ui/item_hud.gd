class_name ItemHUD extends HBoxContainer

@onready var _coin_label: Label = %CoinLabel
@onready var _arrow_label: Label = %ArrowLabel
@onready var _bomb_label: Label = %BombLabel
@onready var _key_label: Label = %KeyLabel
@onready var _boss_key_label: Label = %BossKeyLabel


func _ready() -> void:
	_coin_label.text = "000"
	_arrow_label.text = "00"
	_bomb_label.text = "00"
	_key_label.text = "0"
	_boss_key_label.text = "0"


func update_label(item: String, value: String) -> void:
	if item.contains("coin"): _coin_label.text = value.pad_zeros(3)
	elif item == "arrow": _arrow_label.text = value.pad_zeros(2)
	elif item == "bomb": _bomb_label.text = value.pad_zeros(2)
	elif item == "key": _key_label.text = value
	elif item == "boss_key": _boss_key_label.text = value
