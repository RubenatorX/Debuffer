enfeebling_percent_bonus_items = {
    -- <slot_id><item_id>
    [6] = {
        [25827] = {id = 25827, name = "Regal Cuffs", bonus = 20}
    },
    [11] = {
        [26109] = {id = 26109, name = "Snotra Earring", bonus = 10}
    },
    [12] = {
        [26109] = {id = 26109, name = "Snotra Earring", bonus = 10}
    },
    [13] = {
        [26188] = {id = 26188, name = "Kishar Ring", bonus = 10,},
    },
    [14] = {
        [26188] = {id = 26188, name = "Kishar Ring", bonus = 10,},
    },
}

enfeebling_flat_bonus_items = {
    [4] = {
        [26632] = {id = 26632, name = "Vitiation Chapeau", bonus = 3},
        [26633] = {id = 26633, name = "Viti. Chapeau +1", bonus = 3},
        [23067] = {id = 23067, name = "Viti. Chapeau +2", bonus = 3},
        [23402] = {id = 23402, name = "Viti. Chapeau +3", bonus = 3},
    }
}

enfeebling_saboteur_bonus_items = {
    [6] = { 
        [11208] = {id = 11208, name = "Estq. Ganthrt. +1", bonus = 5},
        [11108] = {id = 11108, name = "Estq. Ganthrt. +2", bonus = 10},
        [27060] = {id = 27060, name = "Leth. Gantherots", bonus = 11},
        [27061] = {id = 27061, name = "Leth. Gantherots +1", bonus = 12},
    }
}

enfeebling_augment_percent_bonus_items = {
    [9] = {
        [25441] = {id = 25441, name = "Duelist's Torque", bonus = 15},
        [25442] = {id = 25442, name = "Duelist's Torque +1", bonus = 20},
        [25443] = {id = 25443, name = "Duelist's Torque +2", bonus = 25},
    }
}

enfeebling_composure_items = {
    [4] = {
        [11068] = {id = 11068, name = "Estq. Chappel +2", set_ids = S{11068, 11088, 11108, 11128, 11148}},
        [26748] = {id = 26748, name = "Lethargy Chappel", set_ids = S{26748, 26906, 27060, 27245, 27419}},
        [26749] = {id = 26749, name = "Leth. Chappel +1", set_ids = S{26749, 26907, 27061, 27246, 27420}},
    },
    [5] = {
        [11088] = {id = 11088, name = "Estq. Sayon +2", set_ids = {11068, 11088, 11108, 11128, 11148}},
        [26906] = {id = 26906, name = "Lethargy Sayon", set_ids = S{26748, 26906, 27060, 27245, 27419}},
        [26907] = {id = 26907, name = "Lethargy Sayon +1", set_ids = S{26749, 26907, 27061, 27246, 27420}},
    },
    [6] = {
        [11108] = {id = 11108, name = "Estq. Ganthrt. +2", set_ids = {11068, 11088, 11108, 11128, 11148}},
        [27060] = {id = 27060, name = "Leth. Gantherots", set_ids = S{26748, 26906, 27060, 27245, 27419}},
        [27061] = {id = 27061, name = "Leth. Gantherots +1", set_ids = S{26749, 26907, 27061, 27246, 27420}},
    },
    [7] = {
        [11128] = {id = 11128, name = "Estqr. Fuseau +2", set_ids = {11068, 11088, 11108, 11128, 11148}},
        [27245] = {id = 27245, name = "Leth. Fuseau", set_ids = S{26748, 26906, 27060, 27245, 27419}},
        [27246] = {id = 27246, name = "Leth. Fuseau +1", set_ids = S{26749, 26907, 27061, 27246, 27420}},
    },
    [8] = {
        [11148] = {id = 11148, name = "Estq. Houseaux +2", set_ids = {11068, 11088, 11108, 11128, 11148}},
        [27419] = {id = 27419, name = "Leth. Houseaux", set_ids = S{26748, 26906, 27060, 27245, 27419}},
        [27420] = {id = 27420, name = "Leth. Houseaux +1", set_ids = S{26749, 26907, 27061, 27246, 27420}},
    },
}

function calculate_enfeebling_magic_expected_duration(spell_info)
    local base_duration = custom_durations[spell_info.id] or spell_info.duration or 0

    if player.main_job == "RDM" then
        local sabo_modifier = calculate_saboteur_modifier(spell_info)
        local flat_bonus = calculate_enfeebling_flat_duration_bonus(spell_info)
        local percent_bonus = calculate_enfeebling_magic_duration_modifier(spell_info)
        local augment_percent_bonus = calculate_augment_modifier(spell_info)
        local composure_percent_bonus = calculate_composure_modifier(spell_info)

        local expected_duration = math.floor(base_duration * sabo_modifier)
        expected_duration = math.floor((expected_duration + flat_bonus) * augment_percent_bonus / 100)
        expected_duration = math.floor(expected_duration * percent_bonus / 100)
        expected_duration = math.floor(expected_duration * composure_percent_bonus / 100)
    else
        local percent_bonus = calculate_enfeebling_magic_duration_modifier(spell_info)

        local expected_duration = math.floor(base_duration * percent_bonus / 100)
    end

    return expected_duration
end

function calculate_enfeebling_magic_duration_modifier(spell_info)
    local modifier = 100

    for slot_id, _ in pairs(enfeebling_percent_bonus_items) do
        local equipped_item = gear_table[slot_id]
        for item_id, item in pairs(enfeebling_percent_bonus_items[slot_id]) do
            if equipped_item == item_id then modifier = modifier + item.bonus end
        end
    end

    return modifier
end

function calculate_saboteur_modifier(spell_info)
    if player.main_job ~= "RDM" then return 100 end
    if not player.buffs[contants.buffs.SABOTEUR] then return 100 end

    local modifier = 200
    local hands_info = enfeebling_saboteur_bonus_items[6][gear_table[6].id] or nil
    
    if hands_info then modifier = modifier + hands_info.bonus end

    return modifier
end

function calculate_augment_modifier(spell_info)
    if player.main_job ~= "RDM" then return 100 end
    local default_bonus = 100

    local neck_info = enfeebling_augment_percent_bonus_items[9][gear_table[9].id] or nil

    if neck_info then
        default_bonus = default_bonus + neck_info.bonus
    end

    return default_bonus
end

function calculate_enfeebling_flat_duration_bonus(spell_info)
    local bonus_duration = 0
    local bonus_duration_jp = player.job_points(string.lower(player.main_job)).efeebling_magic_duration or 0
    local bonus_duration_stymie_jp = player.job_points(string.lower(player.main_job)).stymie_effect or 0
    local bonus_duration_merit = player.merits.enfeebling_magic_duration or 0

    if player.main_job == "RDM" then
        if bonus_duration_merit > 0 then
            local head_info = enfeebling_flat_bonus_items[4][gear_table[4].id] or nil
            bonus_duration = bonus_duration + (bonus_duration_merit * 6)

            if head_info then
                bonus_duration = bonus_duration + (bonus_duration_merit * 3)
            end
        end

        if bonus_duration_jp > 0 then
            bonus_duration = bonus_duration + bonus_duration_jp
        end

        if player.buffs[constants.buffs.STYMIE] and bonus_duration_stymie_jp > 0 then
            bonus_duration = bonus_duration + bonus_duration_stymie_jp
        end
    end

    return bonus_duration
end

function calculate_composure_modifier(spell_info)
    if player.main_job ~= "RDM" or not player.buffs[constants.buffs.COMPOSURE] then return 100 end

    local default_bonus = 100
    local bonus_modifiers = {[0] = 0, [1] = 0, [2] = 10, [3] = 20, [4] = 35, [5] = 50}

    local head_info = enfeebling_composure_items[4][gear_table[4].id] or nil
    local body_info = enfeebling_composure_items[5][gear_table[5].id] or nil
    local hands_info = enfeebling_composure_items[6][gear_table[6].id] or nil
    local legs_info = enfeebling_composure_items[7][gear_table[7].id] or nil
    local feet_info = enfeebling_composure_items[8][gear_table[8].id] or nil

    local composure_item_count = 0

    if head_info then composure_item_count = composure_item_count + 1 end
    if body_info then composure_item_count = composure_item_count + 1 end
    if hands_info then composure_item_count = composure_item_count + 1 end
    if legs_info then composure_item_count = composure_item_count + 1 end
    if feet_info then composure_item_count = composure_item_count + 1 end

    return default_bonus + bonus_modifiers[composure_item_count]
end