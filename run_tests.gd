extends SceneTree
## Headless test runner. From this folder:
##   godot --headless --script run_tests.gd
## Exit code 0 = all tests passed.

const WeightedLoot = preload("res://addons/weighted_loot_lite/weighted_loot.gd")

var _failures := 0
var _checks := 0


func _init() -> void:
	_test_empty_table()
	_test_single_item_always_picked()
	_test_zero_and_negative_weights_ignored()
	_test_add_existing_replaces_weight()
	_test_remove_and_clear()
	_test_total_weight_and_chance()
	_test_seed_is_reproducible()
	_test_distribution_matches_weights()
	_test_pick_many_count()
	_test_pick_unique_has_no_repeats()
	_test_pick_unique_capped_by_size()
	_test_pick_unique_does_not_mutate_table()
	print("%d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("FAIL: " + label)


func _test_empty_table() -> void:
	var t := WeightedLoot.new(1)
	_check(t.is_empty(), "new table is empty")
	_check(t.pick() == null, "pick on empty table is null")
	_check(t.pick_unique(3).is_empty(), "pick_unique on empty is empty")
	_check(t.total_weight() == 0.0, "empty total weight is 0")


func _test_single_item_always_picked() -> void:
	var t := WeightedLoot.new(1)
	t.add("gold", 5.0)
	var ok := true
	for i in 50:
		if t.pick() != "gold":
			ok = false
	_check(ok, "single item is always picked")
	_check(t.chance_of("gold") == 1.0, "single item chance is 1")


func _test_zero_and_negative_weights_ignored() -> void:
	var t := WeightedLoot.new(1)
	t.add("a", 0.0)
	t.add("b", -3.0)
	_check(t.size() == 0, "zero/negative weights are not added")


func _test_add_existing_replaces_weight() -> void:
	var t := WeightedLoot.new(1)
	t.add("a", 1.0)
	t.add("a", 4.0)
	_check(t.size() == 1, "re-adding does not duplicate")
	_check(t.total_weight() == 4.0, "re-adding replaces weight")


func _test_remove_and_clear() -> void:
	var t := WeightedLoot.new(1)
	t.add("a", 1.0)
	t.add("b", 1.0)
	t.remove("a")
	_check(t.size() == 1 and t.chance_of("a") == 0.0, "remove drops the item")
	t.remove("missing")
	_check(t.size() == 1, "removing a missing item is a no-op")
	t.clear()
	_check(t.is_empty(), "clear empties the table")


func _test_total_weight_and_chance() -> void:
	var t := WeightedLoot.new(1)
	t.add("common", 75.0)
	t.add("rare", 25.0)
	_check(t.total_weight() == 100.0, "total weight sums")
	_check(is_equal_approx(t.chance_of("rare"), 0.25), "chance_of is weight / total")
	_check(t.chance_of("nope") == 0.0, "chance_of unknown is 0")


func _test_seed_is_reproducible() -> void:
	var a := WeightedLoot.new(42)
	var b := WeightedLoot.new(42)
	for t in [a, b]:
		t.add("x", 1.0)
		t.add("y", 2.0)
		t.add("z", 3.0)
	_check(a.pick_many(20) == b.pick_many(20), "same seed gives same sequence")


func _test_distribution_matches_weights() -> void:
	var t := WeightedLoot.new(7)
	t.add("common", 90.0)
	t.add("rare", 10.0)
	var rare := 0
	var n := 10000
	for i in n:
		if t.pick() == "rare":
			rare += 1
	var frac := float(rare) / n
	_check(frac > 0.08 and frac < 0.12, "rare picked ~10%% of the time (got %.3f)" % frac)


func _test_pick_many_count() -> void:
	var t := WeightedLoot.new(1)
	t.add("a", 1.0)
	_check(t.pick_many(5).size() == 5, "pick_many returns count items")
	_check(t.pick_many(0).is_empty(), "pick_many(0) is empty")
	_check(t.pick_many(-2).is_empty(), "pick_many negative is empty")


func _test_pick_unique_has_no_repeats() -> void:
	var t := WeightedLoot.new(3)
	for k in ["a", "b", "c", "d", "e"]:
		t.add(k, 1.0)
	var got := t.pick_unique(4)
	var seen := {}
	for g in got:
		seen[g] = true
	_check(got.size() == 4 and seen.size() == 4, "pick_unique returns distinct items")


func _test_pick_unique_capped_by_size() -> void:
	var t := WeightedLoot.new(3)
	t.add("a", 1.0)
	t.add("b", 1.0)
	_check(t.pick_unique(10).size() == 2, "pick_unique is capped by table size")


func _test_pick_unique_does_not_mutate_table() -> void:
	var t := WeightedLoot.new(3)
	t.add("a", 1.0)
	t.add("b", 1.0)
	t.pick_unique(2)
	_check(t.size() == 2 and t.total_weight() == 2.0, "pick_unique leaves table intact")
