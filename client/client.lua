local http = require('curl').http()
local json = require('json')
local URI = os.getenv('SERVER_URI')

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

local pokemon = {
    name="Pikachu",
    chance=99.1,
    id=1,
    status="active",
    location = {
        x=1,
        y=2
    }
}

function request(method, body)
    local resp = http:sync_request(
        method, URI, body
    )
    print(resp.body)
end

print('Create pokemon')
request('POST', '{"method": "add", "params": ['..json.encode(pokemon)..']}')
request('GET', '')

print('Catch pokemon by player 1')
request('POST', '{"method": "catch", "params": [1, '..json.encode(player1)..']}')

print('Catch pokemon by player 2')
request('POST', '{"method": "catch", "params": [1, '..json.encode(player2)..']}')

request('GET', '')
os.exit()
