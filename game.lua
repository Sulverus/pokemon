local pokemon = require('pokemon')
local yaml = require('yaml')
box.cfg{}
pokemon:start()

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
print(yaml.encode(pokemon:map()))
print(pokemon:catch(1, player1))
print(pokemon:catch(1, player2))
print(yaml.encode(pokemon:map()))
