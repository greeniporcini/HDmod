-- hdtypelib = require 'lib.entities.hdtype'

local module = {}

function module.create_tikitrap(x, y, l)
	removelib.remove_floor_and_embedded_at(x, y, l)
	local floor_uid = get_grid_entity_at(x, y-1, l)
    local uid = -1
    if floor_uid ~= -1 then
        uid = spawn_entity_over(ENT_TYPE.FLOOR_TOTEM_TRAP, floor_uid, 0, 1)
        local s_head = spawn_entity_over(ENT_TYPE.FLOOR_TOTEM_TRAP, uid, 0, 1)
        -- if test_flag(state.level_flags, 18) == true then
        --     spawn_entity_over(ENT_TYPE.FX_SMALLFLAME, s_head, 0.24, 0.04)--0.29, 0.26)
        --     spawn_entity_over(ENT_TYPE.FX_SMALLFLAME, s_head, -0.24, 0.04)---0.29, 0.26)
        -- end
    end

    return uid
end

set_callback(function()
    if test_flag(state.level_flags, 18) == true then
        local totems = get_entities_by({ENT_TYPE.FLOOR_TOTEM_TRAP, ENT_TYPE.FLOOR_LION_TRAP}, 0, LAYER.FRONT)
        for _t, totem in pairs(totems) do
            local flames = entity_get_items_by(totem, ENT_TYPE.FX_SMALLFLAME, 0)
            for _f, flame_uid in pairs(flames) do
                -- print(flame_uid)
                local flame = get_entity(flame_uid)
                if flame.x < 0 then
                    flame.x = -0.24
                else
                    flame.x = 0.24
                end
                flame.y = 0.04
            end
        end
    end
end, ON.POST_LEVEL_GENERATION)

function module.create_tikitrap_procedural(x, y, l)
    module.create_tikitrap(x, y, l)
end

set_post_entity_spawn(function(entity)
    entity.spawn_entity_type = ENT_TYPE.ITEM_LION_SPEAR
    -- entity.first_sound_id = VANILLA_SOUND.TRAPS_LIONTRAP_TRIGGER
end, SPAWN_TYPE.ANY, MASK.ANY, ENT_TYPE.FLOOR_TOTEM_TRAP)

return module