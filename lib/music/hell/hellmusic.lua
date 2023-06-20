local module = {}

module.dynamic_music_debug_print = false

local has_seen_bao_this_cycle = false
local has_seen_difu_or_chujiang_this_cycle = false
local difu_count = 0

local function pick_random(table)
    return table[prng:random(#table)]
end

local function is_difu_stem(stem_id)
    if stem_id == "difu" or stem_id == "difu_lush" or stem_id == "difu_nude" then
        return true
    else
        return false
    end
end

local function is_player_in_vlads(player)
    if feelingslib.feeling_check(feelingslib.FEELING_ID.VLAD) then
        if player ~= nil then
            local x, y, layer = get_position(player)

            local roomx, roomy = locatelib.locate_levelrooms_position_from_game_position(x, y)
            local _subchunk_id = roomgenlib.global_levelassembly.modification.levelrooms[roomy][roomx]
            if (
                    _subchunk_id == roomdeflib.HD_SUBCHUNKID.VLAD_TOP
                    or _subchunk_id == roomdeflib.HD_SUBCHUNKID.VLAD_MIDSECTION
                    or _subchunk_id == roomdeflib.HD_SUBCHUNKID.VLAD_BOTTOM
            ) then
                return true
            end
        end
    end
    return false
end

-- TODO once music can continue playing during transitions change start_sound_id to intro
module.HELL_CUSTOM_MUSIC = {
    base_volume = 0.5,
    start_sound_id = "avici",
    sounds = {
        {
            id = "intro",
            sound = create_sound("res/music/BGM_Hell_Intro.ogg"),
            length = 1893,
            next_sound_id = "avici"
        },
        {
            id = "avici",
            sound = create_sound("res/music/BGM_Hell_Avīci.ogg"),
            length = 14666,
            next_sound_id = function(ctx)
                -- A cycle is defined by the return to Avici.
                -- At the end of a cycle we reset 'has_seen_bao', 'has_seen_difu_or_chujiang_this_cycle' and 'difu_count'
                if has_seen_bao_this_cycle ~= false or has_seen_difu_or_chujiang_this_cycle ~= false or difu_count ~= 0 then
                    has_seen_bao_this_cycle = false
                    has_seen_difu_or_chujiang_this_cycle = false
                    difu_count = 0

                    if module.dynamic_music_debug_print then
                        print("[Cycle End] has_seen_bao = false, has_seen_difu_or_chujiang_this_cycle = false, difu_count = 0")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                return pick_random({ "abi_a", "abi_b" })
            end
        },
        {
            id = "abi_a",
            sound = create_sound("res/music/BGM_Hell_Abi_A.ogg"),
            length = 8000,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                if has_seen_bao_this_cycle then
                    local next_stem = pick_random({ "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu", "difu_lush", "difu_nude" })

                    if is_difu_stem(next_stem) then
                        difu_count = difu_count + 1
                    end

                    return next_stem
                else
                    return pick_random({ "bao_a", "bao_b" })
                end
            end
        },
        {
            id = "abi_b",
            sound = create_sound("res/music/BGM_Hell_Abi_B.ogg"),
            length = 8000,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                if has_seen_bao_this_cycle then
                    local next_stem = pick_random({ "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu", "difu_lush", "difu_nude" })

                    if is_difu_stem(next_stem) then
                        difu_count = difu_count + 1
                    end

                    return next_stem
                else
                    return pick_random({ "bao_a", "bao_b" })
                end
            end
        },
        {
            id = "bao_a",
            sound = create_sound("res/music/BGM_Hell_Bao_A.ogg"),
            length = 17000,
            next_sound_id = function(ctx)
                if not has_seen_bao_this_cycle then
                    has_seen_bao_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_bao = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem

                -- If we have seen chujiang or difu this cycle, one possible next stem can be avici completing a cycle
                if has_seen_difu_or_chujiang_this_cycle then
                    next_stem = pick_random({ "avici", "difu", "difu_lush", "difu_nude" })
                -- If we have not seen chujiang or difu this cycle, we pick chujiang or difu stems
                else
                    next_stem = pick_random({ "chujiang_lite", "chujiang", "difu", "difu_lush", "difu_nude" })
                end

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "bao_b",
            sound = create_sound("res/music/BGM_Hell_Bao_B.ogg"),
            length = 25333,
            next_sound_id = function(ctx)
                if not has_seen_bao_this_cycle then
                    has_seen_bao_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_bao = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem

                -- If we have seen chujiang or difu this cycle, one possible next stem can be avici completing a cycle
                if has_seen_difu_or_chujiang_this_cycle then
                    next_stem = pick_random({ "avici", "difu", "difu_lush", "difu_nude" })
                -- If we have not seen chujiang or difu this cycle, we pick chujiang or difu stems
                else
                    next_stem = pick_random({ "chujiang_lite", "chujiang", "difu", "difu_lush", "difu_nude" })
                end

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "chujiang_lite",
            sound = create_sound("res/music/BGM_Hell_Chujiang_lite.ogg"),
            length = 16000,
            next_sound_id = function(ctx)
                if not has_seen_difu_or_chujiang_this_cycle then
                    has_seen_difu_or_chujiang_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_difu_or_chujiang_this_cycle = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end


                return "chujiang"
            end
        },
        {
            id = "chujiang",
            sound = create_sound("res/music/BGM_Hell_Chujiang.ogg"),
            length = 16000,
            next_sound_id = function(ctx)
                if not has_seen_difu_or_chujiang_this_cycle then
                    has_seen_difu_or_chujiang_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_difu_or_chujiang_this_cycle = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "bao_a", "bao_b", "difu", "difu_lush", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "difu",
            sound = create_sound("res/music/BGM_Hell_Difu.ogg"),
            length = 12666,
            next_sound_id = function(ctx)
                if not has_seen_difu_or_chujiang_this_cycle then
                    has_seen_difu_or_chujiang_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_difu_or_chujiang_this_cycle = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    difu_count = 0
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    difu_count = 0
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    difu_count = 0
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                if difu_count < 2 then
                    local next_stem = pick_random({ "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_lush", "difu_nude" })

                    if is_difu_stem(next_stem) then
                        difu_count = difu_count + 1
                    end

                    return next_stem
                else
                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] difu_count = 2; exiting block")
                    end

                    difu_count = 0
                    return pick_random({ "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang" })
                end
            end
        },
        {
            id = "difu_lush",
            sound = create_sound("res/music/BGM_Hell_Difu_lush.ogg"),
            length = 12666,
            next_sound_id = function(ctx)
                if not has_seen_difu_or_chujiang_this_cycle then
                    has_seen_difu_or_chujiang_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_difu_or_chujiang_this_cycle = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    difu_count = 0
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    difu_count = 0
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    difu_count = 0
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                if difu_count < 2 then
                    local next_stem = pick_random({ "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu", "difu_nude" })

                    if is_difu_stem(next_stem) then
                        difu_count = difu_count + 1
                    end

                    return next_stem
                else
                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] difu_count = 2; exiting block")
                    end

                    difu_count = 0
                    return pick_random({ "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang" })
                end
            end
        },
        {
            id = "difu_nude",
            sound = create_sound("res/music/BGM_Hell_Difu_nude.ogg"),
            length = 12666,
            next_sound_id = function(ctx)
                if not has_seen_difu_or_chujiang_this_cycle then
                    has_seen_difu_or_chujiang_this_cycle = true

                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] has_seen_difu_or_chujiang_this_cycle = true")
                    end
                end

                if is_player_in_vlads(players[1].uid) then
                    difu_count = 0
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    difu_count = 0
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    difu_count = 0
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                if difu_count < 2 then
                    local next_stem = pick_random({ "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu", "difu_lush" })

                    if is_difu_stem(next_stem) then
                        difu_count = difu_count + 1
                    end

                    return next_stem
                else
                    if module.dynamic_music_debug_print then
                        print("[Hell Music Debug] difu_count = 2; exiting block")
                    end

                    difu_count = 0
                    return pick_random({ "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang" })
                end
            end
        },
        {
            id = "idle_a",
            sound = create_sound("res/music/BGM_Hell_Idle_A.ogg"),
            length = 6000,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "avici", "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "idle_b",
            sound = create_sound("res/music/BGM_Hell_Idle_B.ogg"),
            length = 6000,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_c" })
                end

                local next_stem = pick_random({ "avici", "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "idle_c",
            sound = create_sound("res/music/BGM_Hell_Idle_C.ogg"),
            length = 6000,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b" })
                end

                local next_stem = pick_random({ "avici", "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "lowhp_1",
            sound = create_sound("res/music/BGM_Hell_LOWHP_1.ogg"),
            length = 13333,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "avici", "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "lowhp_2",
            sound = create_sound("res/music/BGM_Hell_LOWHP_2.ogg"),
            length = 13333,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "avici", "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "lowhp_3",
            sound = create_sound("res/music/BGM_Hell_LOWHP_3.ogg"),
            length = 13333,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "avici", "abi_a", "abi_b", "bao_a", "bao_b", "chujiang_lite", "chujiang", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "yaoguai_1",
            sound = create_sound("res/music/BGM_Hell_Yaoguai_1.ogg"),
            length = 14666,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_2"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "chujiang_lite", "chujiang", "difu", "difu_lush", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        },
        {
            id = "yaoguai_2",
            sound = create_sound("res/music/BGM_Hell_Yaoguai_2.ogg"),
            length = 18333,
            next_sound_id = function(ctx)
                if is_player_in_vlads(players[1].uid) then
                    return "yaoguai_1"
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_LIFE) == 1 then
                    return pick_random({ "lowhp_1", "lowhp_2", "lowhp_3" })
                end

                if ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.PLAYER_ACTIVITY) == 0 then
                    return pick_random({ "idle_a", "idle_b", "idle_c" })
                end

                local next_stem = pick_random({ "chujiang_lite", "chujiang", "difu", "difu_lush", "difu_nude" })

                if is_difu_stem(next_stem) then
                    difu_count = difu_count + 1
                end

                return next_stem
            end
        }
    }
}

return module
