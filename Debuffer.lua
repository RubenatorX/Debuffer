_addon.name = "Debuffer"
_addon.version = '0.1'

require "luau"
packets = require('packets')
texts = require('texts')

require "Enfeebling"
require "GearEquipping"
require "maps"
require "Events"
require "Display"

frame_time = 0
debuffed_mobs = {}

function get_spell_info(spell_id)
    return res.spells[spell_id] or nil
end

function handle_mob_enfeeble(packet, spell_info)
    for _, target in pairs(packet.targets) do
        add_debuffed_mob(target.id)
        local mob_debuffs = debuffed_mobs[target.id]
        local status_id = target.actions[1].param
        local expected_duration = custom_durations[spell_info.id] or spell_info.duration or 0

        if spell_info.skill == 35 then
            expected_duration = calculate_enfeebling_magic_expected_duration(spell_info)
        end

        if custom_overwrites[spell_info.id] then
            for _, overwrite_status_id in pairs(custom_overwrites[spell_info.id]) do
                remove_debuff_mob(target.id, overwrite_status_id)
            end
        elseif spell_info.overwrites then
            for _, overwrite_status_id in pairs(spell_info.overwrites) do
                remove_debuff_mob(target.id, overwrite_status_id)
            end
        end

        apply_debuff_mob(target.id, status_id, spell_info, expected_duration)
    end
end

function handle_dia_spell(packet, spell_info)
    for _, target in pairs(packet.targets) do
        add_debuffed_mob(target.id)
        local mob_debuffs = debuffed_mobs[target.id]
        local status_id = target.actions[1].param
        local expected_duration = custom_durations[spell_info.id] or spell_info.duration or 0

        if spell_info.skill == 35 then
            expected_duration = calculate_enfeebling_magic_expected_duration(spell_info)
        end

        if mob_debuffs[134] then
            if custom_overwrites[spell_info.id] and custom_overwrites[spell_info.id]:contains(mob_debuffs[134].spell_id) then
                remove_debuffed_mob(mob_id, 134)
                apply_debuff_mob(target.id, status_id, spell_info, expected_duration)
            elseif spell_info.overwrites and spell_info.overwrites:contains(mob_debuffs[134].spell_id) then
                remove_debuffed_mob(mob_id, 134)
                apply_debuff_mob(target.id, status_id, spell_info, expected_duration)
            else
                return
            end

        elseif mob_debuffs[135]
            if custom_overwrites[spell_info.id] and custom_overwrites[spell_info.id]:contains(mob_debuffs[135].spell_id) then
                remove_debuffed_mob(mob_id, 135)
                apply_debuff_mob(target.id, status_id, spell_info, expected_duration)
            elseif spell_info.overwrites and spell_info.overwrites:contains(mob_debuffs[135].spell_id) then
                remove_debuffed_mob(mob_id, 135)
                apply_debuff_mob(target.id, status_id, spell_info, expected_duration)
            else
                return
            end
        end  
    end
end

function handle_helix_spell(packet, spell_info)
    local target = packet.targets[1]

    add_debuffed_mob(target.id)

    local expected_duration = custom_durations[spell_info.id] or spell_info.duration or 0
    local status_id = target.actions[1].param

    apply_debuff_mob(target.id, status_id, spell_info, expected_duration)
end

function handle_ja_spell(packet, spell_info)
    for _, target in pairs(packet.targets) do
        add_debuffed_mob(target.id)
        local mob_debuffs = debuffed_mobs[target.id]
        local status_id = target.actions[1].param
        local expected_duration = custom_durations[spell_info.id] or spell_info.duration or 60

        if mob_debuffs[1000] and mob_debuffs[1000].spell_name:startswith(ja_spell_effects[spell_info.id]) then
            raise_ja_debuff_tier(target.id, spell_info)
        else
            apply_ja_debuff_mob(target.id, status_id, spell_info, expected_duration)
        end
    end
end

function add_debuffed_mob(mob_id)
    if not debuffed_mobs[mob_id] then
        debuffed_mobs[mob_id] = {}
    end
end

function remove_debuffed_mob(mob_id)
    if debuffed_mobs[mob_id] then
        debuffed_mobs[mob_id] = nil
    end
end

function apply_debuff_mob(mob_id, status_id, spell_info, expected_duration)
    if debuffed_mobs[mob_id][status_id] ~= nil then
        debuffed_mobs[mob_id][status_id] = nil
    end

    debuffed_mobs[mob_id][status_id] = {
        spell_id = spell_info.id,
        spell_name = spell_info.en,
        spell_start_time = os.clock()
        spell_duration = expected_duration
        spell_timer = os.clock() + expected_duration
    }
end

function apply_ja_debuff_mob(mob_id, status_id, spell_info, expected_duration)
    if debuffed_mobs[mob_id][status_id] ~= nil then
        debuffed_mobs[mob_id][status_id] = nil
    end

    debuffed_mobs[mob_id][status_id] = {
        spell_id = spell_info.id,
        spell_name = spell_info.en,
        spell_start_time = os.clock(),
        spell_duration = expected_duration,
        spell_timer = os.clock() + expected_duration,
        ja_tier = 1,
        spell_effect = ja_spell_effects[spell_info.id] .. '5%'
    }
end

function raise_ja_debuff_tier(mob_id, spell_info)
    if not debuffed_mobs[mob_id] then return end

    local current_ja_status = debuffed_mobs[mob_id][1000] or nil

    current_ja_status.ja_tier = current_ja_status.ja_tier + 1
    current_ja_status.spell_effect = ja_spell_effects[spell_info.id] .. tostring(current_ja_status.ja_tier * 5) .. '%'
end

function remove_debuff_mob(mob_id, status_id)
    if debuffed_mobs[mob_id] then
        debuffed_mobs[mob_id][status_id] = nil
    end
end

function clear_debuffed_mobs()
    debuffed_mobs = {}
end

function get_buff_info(buff_info)
    local time = os.clock()
    local info_string = buff_info.spell_name .. ' : ' .. string.format( "%.0f",buff_info.spell_timer - time)

    return info_string
end

function get_ja_buff_info(buff_info)
    local time = os.clock()
    local info_string = buff_info.spell_effect .. ' : ' .. string.format("%.0f", buff_info.spell_timer - time)

    return info_string
end