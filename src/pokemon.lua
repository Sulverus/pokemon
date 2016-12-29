local fiber = require('fiber')
local avro = require('avro_schema')
local log = require('log')
local gis = require('gis')
gis.install()

local schema = {
    player = {
        type="record",
        name="player_schema",
        fields={
            {name="id", type="long"},
            {name="name", type="string"},
            {
                name="location",
                type= {
                    type="record",
                    name="player_location",
                    fields={
                        {name="x", type="double"},
                        {name="y", type="double"}
                    }
                }
            }
        }
    },
    pokemon = {
        type="record",
        name="pokemon_schema",
        fields={
            {name="id", type="long"},
            {name="status", type="string"},
            {name="name", type="string"},
            {name="chance", type="double"},
            {
                name="location",
                type= {
                    type="record",
                    name="pokemon_location",
                    fields={
                        {name="x", type="double"},
                        {name="y", type="double"}
                    }
                }
            }
        }
    }
}

local game = {
    wgs84 = 4326, -- WGS84 World-wide Projection (Lon/Lat)
    nationalmap = 2163, -- US National Atlas Equal Area projection (meters)
    catch_distance = 100,
    respawn_time = 60,
    player_model = {},
    monster_model = {},
    -- pokemon respawn fiber
    respawn = function(self)
        fiber.name('Respawn fiber')
        while true do
            for _, tuple in box.space.monsters.index[1]:pairs{'catched'} do
                box.space.monsters:update(tuple[1], {{'=', 2, 'active'}})
            end
            fiber.sleep(self.respawn_time)
        end
    end,

    -- event notification fiber
    notify = function(self, player, pokemon)
        log.info("Player '%s' catched '%s'", player.name, pokemon.name)
    end,

    -- create game object
    start = function(self)
        -- create spaces and indexes
        if box.space.monsters == nil then
            box.schema.create_space('monsters')
            box.space.monsters:create_index(
                "primary", {type = 'hash', parts = {1, 'unsigned'}}
            )
            box.space.monsters:create_index(
                "status", {type = "tree", parts = {2, 'str'}}
            )
        end

        -- create and compile models
        local ok_m, monster = avro.create(schema.pokemon)
        local ok_p, player = avro.create(schema.player)
        local ok_cm, compiled_monster = avro.compile(monster)
        local ok_cp, compiled_player = avro.compile(player)

        if ok_m and ok_p and ok_cm and ok_cp then
            -- start game loop
            self.monster_model = compiled_monster
            self.player_model = compiled_player
            fiber.create(self.respawn, self)
            log.info('Started')
            return true
        end
        log.error('Start failed')
        return false
    end,

    -- return pokemons list in map
    map = function(self)
        local data = box.space.monsters.index[1]:select('active')
        local result = {}
        for _, tuple in pairs(data) do
            local ok, pokemon = self.monster_model.unflatten(tuple)
            table.insert(result, pokemon)
        end
        return result
    end,

    -- add pokemon to map and store it in Tarantool
    add_pokemon = function(self, pokemon)
        pokemon.status = 'active'
        local ok, tuple = self.monster_model.flatten(pokemon)
        if not ok then
            return false
        end
        box.space.monsters:replace(tuple)
        return true
    end,

    -- catch pokemon in location
    catch = function(self, pokemon_id, player)
        -- check player data
        local ok, tuple = self.player_model.flatten(player)
        if not ok then
            return false
        end
        -- get pokemon data
        local p_tuple = box.space.monsters:get(pokemon_id)
        if p_tuple == nil then
            return false
        end
        local ok, pokemon = self.monster_model.unflatten(p_tuple)
        if not ok then
            return false
        end
        local m_pos = gis.Point(
            {pokemon.location.x, pokemon.location.y}, self.wgs84
        ):transform(self.nationalmap)
        local p_pos = gis.Point(
            {player.location.x, player.location.y}, self.wgs84
        ):transform(self.nationalmap)

        -- check catch distance condition
        if p_pos:distance(m_pos) > self.catch_distance then
            return false
        end
        -- try to catch pokemon
        local catched = math.random(100) > 100 - pokemon.chance
        if catched then
            -- update and notify on success
            box.space.monsters:update(pokemon_id, {{'=', 2, 'catched'}})
            self:notify(player, pokemon)
        end
        return catched
    end
}

return game
