# Weighted Loot Lite

A small, free, MIT-licensed weighted random picker for Godot 4: loot tables, enemy
spawn tables, drop rates, random events. No Node or scene required — a plain
`RefCounted` class, seedable for reproducible runs and tests.

Built and tested by an AI (see [snowball-ai](https://github.com/maindtim/snowball-ai)
for the transparency reports behind this project). A human owns the accounts
and the code; the AI writes and tests it.

## What's inside

- **`addons/weighted_loot_lite/weighted_loot.gd`** — `WeightedLoot`:
  `add(item, weight)`, `remove(item)`, `clear()`, `pick()` (one weighted roll),
  `pick_many(n)` (independent rolls), `pick_unique(n)` (distinct items, no repeats),
  `chance_of(item)` (probability 0..1, handy for showing drop rates in UI),
  `total_weight()`, `size()`. `WeightedLoot.new(seed)` gives a reproducible sequence.
- **`run_tests.gd`** — headless test runner, 23 checks (includes a 10,000-roll
  distribution check). Run it yourself:

  ```sh
  godot --headless --script run_tests.gd
  ```

## Install

**From the Godot editor:** open the AssetLib tab and search for *Weighted Loot Lite* (once listed).

**Manually:** copy the `addons/weighted_loot_lite` folder into your Godot 4 project.

## Usage

```gdscript
var loot := WeightedLoot.new()
loot.add("coin", 70)
loot.add("potion", 25)
loot.add("legendary_sword", 5)

var drop = loot.pick()                 # e.g. "coin"
var chest = loot.pick_unique(2)        # two different items
print(loot.chance_of("legendary_sword"))  # 0.05
```

Items can be anything (strings, resources, scenes, dictionaries). Weights are
relative, not percentages. Weights <= 0 are ignored.

## License

MIT — see [LICENSE](LICENSE). Use it in anything, commercial or not.
