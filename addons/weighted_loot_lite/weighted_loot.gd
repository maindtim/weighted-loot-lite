class_name WeightedLoot
extends RefCounted
## Weighted random picking for loot tables, spawn tables and drop rates.
## Plain RefCounted: no Node or scene required. Seedable for reproducible runs.

var _items: Array = []
var _weights: Array[float] = []
var _rng := RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()


## Adds an item with a weight. Weight <= 0 is ignored. Adding an existing
## item again replaces its weight.
func add(item, weight: float) -> void:
	if weight <= 0.0:
		return
	var i := _items.find(item)
	if i >= 0:
		_weights[i] = weight
	else:
		_items.append(item)
		_weights.append(weight)


func remove(item) -> void:
	var i := _items.find(item)
	if i >= 0:
		_items.remove_at(i)
		_weights.remove_at(i)


func clear() -> void:
	_items.clear()
	_weights.clear()


func size() -> int:
	return _items.size()


func is_empty() -> bool:
	return _items.is_empty()


func total_weight() -> float:
	var t := 0.0
	for w in _weights:
		t += w
	return t


## Probability (0..1) of picking `item` on a single roll. 0 if not present.
func chance_of(item) -> float:
	var i := _items.find(item)
	if i < 0:
		return 0.0
	return _weights[i] / total_weight()


## One weighted roll. Returns null if the table is empty.
func pick():
	if _items.is_empty():
		return null
	var roll := _rng.randf() * total_weight()
	var acc := 0.0
	for i in _items.size():
		acc += _weights[i]
		if roll < acc:
			return _items[i]
	return _items[_items.size() - 1]


## `count` independent rolls (duplicates allowed).
func pick_many(count: int) -> Array:
	var out := []
	for n in maxi(count, 0):
		out.append(pick())
	return out


## `count` distinct items, weighted, without repeats. Returns fewer if the
## table has fewer items.
func pick_unique(count: int) -> Array:
	var items := _items.duplicate()
	var weights := _weights.duplicate()
	var out := []
	while out.size() < count and not items.is_empty():
		var total := 0.0
		for w in weights:
			total += w
		var roll := _rng.randf() * total
		var acc := 0.0
		var chosen := items.size() - 1
		for i in items.size():
			acc += weights[i]
			if roll < acc:
				chosen = i
				break
		out.append(items[chosen])
		items.remove_at(chosen)
		weights.remove_at(chosen)
	return out
