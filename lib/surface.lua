local module = {}

local palmtreelib = require('lib.entities.palmtree')

local sky_hard_texture_id
local surface_hard_texture_id
do
    local sky_hard_texture_def = TextureDefinition.new()
    sky_hard_texture_def.width = 512
    sky_hard_texture_def.height = 512
    sky_hard_texture_def.tile_width = 512
    sky_hard_texture_def.tile_height = 512
    sky_hard_texture_def.texture_path = "res/base_sky_hardending.png"
    sky_hard_texture_id = define_texture(sky_hard_texture_def)

    local surface_hard_texture_def = TextureDefinition.new()
    surface_hard_texture_def.width = 1024
    surface_hard_texture_def.height = 1024
    surface_hard_texture_def.tile_width = 1024
    surface_hard_texture_def.tile_height = 256
    surface_hard_texture_def.texture_path = "res/base_surface_hardending.png"
    surface_hard_texture_id = define_texture(surface_hard_texture_def)

    local surface_foreground_hard_texture_def = TextureDefinition.new()
    surface_foreground_hard_texture_def.width = 1024
    surface_foreground_hard_texture_def.height = 1024
    surface_foreground_hard_texture_def.tile_width = 512
    surface_foreground_hard_texture_def.tile_height = 256
    surface_foreground_hard_texture_def.texture_path = "res/base_surface_hardending.png"
    surface_foreground_hard_texture_id = define_texture(surface_foreground_hard_texture_def)
end

local function create_surface_layer_looping(x)
    local bg_surface_layer_1 = get_entity(spawn_entity(ENT_TYPE.BG_SURFACE_LAYER, 0, 0, LAYER.FRONT, 0, 0))
    bg_surface_layer_1.relative_x, bg_surface_layer_1.relative_y = x, 111.150--seems to be 10 higher than intro
    bg_surface_layer_1.width = 60
    bg_surface_layer_1.height = 3.75
    bg_surface_layer_1.hitboxx = 30
    bg_surface_layer_1.hitboxy = 1.875
    bg_surface_layer_1.tile_width = 4
    bg_surface_layer_1.tile_height = 1
    bg_surface_layer_1.animation_frame = 3
    bg_surface_layer_1:set_post_update_state_machine(
        ---@param self Movable | Entity | BGSurfaceLayer
        function (self)
            if self.relative_x >= 93 then
                self.relative_x = self.relative_x - 119.97
            else
                self.relative_x = self.relative_x + 0.02
            end
        end
    )
end

function module.build_credits_surface()
    for x = 3, 38, 1 do
        spawn_grid_entity(ENT_TYPE.FLOOR_SURFACE_HIDDEN, x, 110, LAYER.FRONT)
    end
    for y = 111, 113, 1 do
        spawn_grid_entity(ENT_TYPE.FLOOR_SURFACE_HIDDEN, 4, y, LAYER.FRONT)
        spawn_grid_entity(ENT_TYPE.FLOOR_SURFACE_HIDDEN, 24, y, LAYER.FRONT)
    end

    local bg_sky = get_entity(spawn_entity(ENT_TYPE.BG_SPACE, 27.5, 112.950, LAYER.FRONT, 0, 0))
    local bg_sun = get_entity(spawn_entity(ENT_TYPE.BG_SURFACE_NEBULA, 14, 115, LAYER.FRONT, 0, 0))
    bg_sun.width = 9
    bg_sun.height = 4.5
    -- # TODO: Make a timeout to set this value 
    bg_sun.relative_x, bg_sun.relative_y = 0, 0--seems to be 10 higher than intro
    bg_sun:set_post_update_state_machine(
        ---@param self Movable | Entity | Player
        function (self)
            if self.relative_x ~= 0 or self.relative_y ~= 0 then
                self.relative_x, self.relative_y = 0, 0
            end
        end
    )

    create_surface_layer_looping(25)
    create_surface_layer_looping(25 - 60)
    local bg_surface_layer_2
    local bg_surface_layer_3
    if state.win_state == WIN_STATE.HUNDUN_WIN then
        bg_sky:set_texture(sky_hard_texture_id)
    end
    --[[
        #TODO:
        Set statemachine callbacks to scroll decorations
    ]]
end

function module.decorate_surface()
    local TO_REMOVE = {ENT_TYPE.ITEM_EGGSHIP, ENT_TYPE.FX_EGGSHIP_DOOR, ENT_TYPE.FX_EGGSHIP_SHELL, ENT_TYPE.BG_SURFACE_STAR}
    local TO_MOVE = {ENT_TYPE.BG_LEVEL_BACKWALL, ENT_TYPE.BG_SURFACE_BACKGROUNDSEAM}
    local TO_DECORATE = {ENT_TYPE.BG_SURFACE_LAYER, ENT_TYPE.BG_SURFACE_ENTITY}

    for _, uid in pairs(get_entities_by_type(TO_REMOVE)) do
        get_entity(uid):destroy()
    end

    for _, uid in pairs(get_entities_by_type(TO_MOVE)) do
        local x, _, _ = get_position(uid)
        local deco = get_entity(uid)
        if deco.type.id == ENT_TYPE.BG_LEVEL_BACKWALL then
            deco:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.BACKWALL)
        end
        if x < 40 then
            deco:destroy()
        else
            deco.x = deco.x - 7
        end
    end

    local sky = get_entity(get_entities_by_type(ENT_TYPE.BG_SPACE)[1])
    sky:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.SKY)

    local sun = get_entity(get_entities_by_type(ENT_TYPE.BG_SURFACE_NEBULA)[1])
    sun.width = 9
    sun.height = 4.5
    sun:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.SUN)

    if state.win_state == WIN_STATE.HUNDUN_WIN then
        sun:set_texture(TEXTURE.DATA_TEXTURES_BG_DUAT2_0)
        local sky_uids = get_entities_by_type(ENT_TYPE.BG_SPACE)
        if #sky_uids > 0 then
            get_entity(sky_uids[1]):set_texture(sky_hard_texture_id)
        end
    end

    -- prevent teetering animation in intro
    spawn_grid_entity(ENT_TYPE.FLOOR_GENERIC, 53, 99, LAYER.FRONT)

    palmtreelib.create_palmtree(30, 100, 1, palmtreelib.SURFACE_BG_DEPTH.FOREGROUND)

    for _, uid in pairs(get_entities_by_type(TO_DECORATE)) do
        ---@type BGSurfaceLayer
        local bg = get_entity(uid)
        local texture_id = bg:get_texture()
        if texture_id == TEXTURE.DATA_TEXTURES_BASE_SURFACE_1 then
            if state.win_state == WIN_STATE.HUNDUN_WIN then
                bg:set_texture(surface_foreground_hard_texture_id)
            end
            --foreground
            bg:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.FOREGROUND)
        elseif texture_id == TEXTURE.DATA_TEXTURES_BASE_SURFACE_0 then
            if state.win_state == WIN_STATE.HUNDUN_WIN then
                bg:set_texture(surface_hard_texture_id)
            end
            if bg.animation_frame == 3 then
                --front-background
                bg:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.BACKGROUND)
                palmtreelib.create_palmtree(16, 103, 2, palmtreelib.SURFACE_BG_DEPTH.BACKGROUND)
                palmtreelib.create_palmtree(23, 103, 0, palmtreelib.SURFACE_BG_DEPTH.BACKGROUND)
                palmtreelib.create_palmtree(32, 103, 1, palmtreelib.SURFACE_BG_DEPTH.BACKGROUND, true)
            elseif bg.animation_frame == 2 then
                --mid-background
                bg:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.MID_BACKGROUND)
                palmtreelib.create_palmtree_relative(-7, 2, 1, palmtreelib.SURFACE_BG_DEPTH.MID_BACKGROUND, bg)
                palmtreelib.create_palmtree_relative(-3, 1, 0, palmtreelib.SURFACE_BG_DEPTH.MID_BACKGROUND, bg, true)
                palmtreelib.create_palmtree_relative(3.5, 1, 2, palmtreelib.SURFACE_BG_DEPTH.MID_BACKGROUND, bg, true)
            elseif bg.animation_frame == 1 then
                --back-background
                bg:set_draw_depth(palmtreelib.SURFACE_BG_DEPTH.BACK_BACKGROUND)
                -- palmtreelib.create_palmtree_relative(-10, -1, 0, palmtreelib.SURFACE_BG_DEPTH.BACK_BACKGROUND, bg, true)
                -- No palmtrees in back_background!
            end
        end
    end
end

return module