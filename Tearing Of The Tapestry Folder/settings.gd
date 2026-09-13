extends Node

# Settings

## UI Settings
### UI Visibility
enum boss_hp_bar {VISIBLE, HIDDEN}
enum dungeon_map {VISIBLE, HIDDEN}

var show_boss_hp_bar = boss_hp_bar.VISIBLE
var show_dungeon_map = dungeon_map.VISIBLE

### UI Positions
enum health_bar_locations {BOTTOM, SIDE}
enum dungeon_map_location {T_R, T_L, B_R, B_L} # top-right, top-left, bottom-right, bottom-left

var health_bar_loc = health_bar_locations.BOTTOM
var dungeon_map_loc = dungeon_map_location.B_R
