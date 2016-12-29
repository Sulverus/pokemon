## Pokemon
Tarantool based Pokemon game engine PoC

This example shows how to create realtime geolocation game engine in tarantool

### Stack
1. Tarantool
2. Avro schema (tarantool module)
3. GIS (tarantool module)

### Example
Initial state:

1. 2 players in different locations
2. Initial set of monsters
3. Each player try to catch a monster

```
local pokemon = require('pokemon')
local yaml = require('yaml')
-- init
box.cfg{}
pokemon:start()

-- players descr
local player1 = {
    name="Player1",
    id=1,
    location = {
        x=1.0001,
        y=2.0003
    }
}
local player2 = {
    name="Player2",
    id=2,
    location = {
        x=30.123,
        y=40.456
    }
}

-- add a monster to game
pokemon:add_pokemon({
    name="Pikachu",
    chance=99.1,
    id=1,
    status="active",
    location = {
        x=1,
        y=2
    }
})
-- list of monsters (1 monster is available)
print(yaml.encode(pokemon:map()))
-- Player 1 can catch it
print(pokemon:catch(1, player1)) -- true
-- Player 2 can't
print(pokemon:catch(1, player2)) -- false
-- Monser map is empty
print(yaml.encode(pokemon:map()))

```

```
2016-12-29 17:01:27.854 [14134] main/101/game.lua C> version 1.7.3-2-g2062354
2016-12-29 17:01:27.854 [14134] main/101/game.lua C> log level 5
2016-12-29 17:01:27.854 [14134] main/101/game.lua I> mapping 1073741824 bytes for tuple arena...
2016-12-29 17:01:27.888 [14134] main/101/game.lua I> initializing an empty data directory
2016-12-29 17:01:27.897 [14134] snapshot/101/main I> saving snapshot `./00000000000000000000.snap.inprogress'
2016-12-29 17:01:27.897 [14134] snapshot/101/main I> done
2016-12-29 17:01:27.949 [14134] main/101/game.lua I> ready to accept requests
2016-12-29 17:01:28.032 [14134] main/101/game.lua I> Started
---
- {'id': 1, 'status': 'active', 'location': {'y': 2, 'x': 1}, 'name': 'Pikachu', 'chance': 99.1}
...

2016-12-29 17:01:28.033 [14134] main/101/game.lua I> Player 'Player1' catched 'Pikachu'
true
false
--- []
...

2016-12-29 17:01:28.034 [14134] main C> entering the event loop
```
