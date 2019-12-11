require('luau')
packets = require('packets')
texts = require('texts')
res = require('resources')

windower.register_event('load', function()
    player = windower.ffxi.get_player()
    gearTable = update_gear_table()
end)

windower.register_event('incoming chunk', function(id, data)
    if id == constants.packets.ACTION_PACKET then
        parse_incoming_action_packet(data)
    elseif id == constants.packets.ACTION_MESSAGE_PACKET then
        parse_incoming_action_message_packet(data)
    elseif id == constants.packets.EQUIP_PACKET then
        parse_incoming_equip_packet(data)
    end
end)

function parse_incoming_action_packet(data)
    local packet = windower.packets.parse_action(data)

    if packet.category == categories.SPELL_CAST_FINISHED then
        handle_spell_packet(packet)
    elseif S{categories.MELEE_HIT, categories.RANGED_ATTACK, categories.WEAPONSKILL_DAMAGE_ABILITY, categories.PET_TP_ABILITY}:contains(packet.category) then

    end
end

function parse_incoming_action_message_packet(data)
    local action_message_packet = {}
    action_message_packet.target_id = data:unpack('I', 0x09)
    action_message_packet.status_id = data:unpack('I', 0x0D)
    action_message_packet.message_id = data:unpack('H', 0x19) % 32768

    handle_incoming_action_message_packet(action_message_packet)
end

function handle_spell_packet(packet)
    local spell_info = get_spell_info(packet.param)
    player = windower.ffxi.get_player()

    if spell_info == nil then return end

    local first_message = packet.targets[1].actions[1].message
    
    if message_ids.enfeeble_success:contains(first_message) then
        handle_mob_enfeeble(packet, spell_info)
    elseif message_ids.mob_takes_damage:contains(first_message) then
        if spell_groups.dia_spells:contains(spell_info.id) then
            handle_dia_spell(packet, spell_info)
        elseif spell_groups.helix_spells:contains(spell_info.id) then
            handle_helix_spell(packet, spell_info)
        elseif spell_groups.ja_spells:contains(spell_info.id) then
            handle_ja_spall(packet, spell_info)
        end
    elseif message_ids.absorb_success:contains(first_message) then

    end
end

function handle_incoming_action_message_packet(action_message_packet)
    if message_ids.mob_death:contains(action_message_packet.message_id) then
        remove_debuffed_mob(action_message_packet.target_id)
    elseif message_ids.debuff_wears:contains(action_message_packet.message_id) then
        remove_mob_debuff(action_message_packet.target_id, action_message_packet.status_id)

        if action_message_packet.message_id == 206 then
            if action_message_packet.status_id == 136 then
                remove_mob_debuff(action_message_packet.target_id, 266)
            elseif action_message_packet.status_id == 137 then
                remove_mob_debuff(action_message_packet.target_id, 267)
            elseif action_message_packet.status_id == 138 then
                remove_mob_debuff(action_message_packet.target_id, 268)
            elseif action_message_packet.status_id == 139 then
                remove_mob_debuff(action_message_packet.target_id, 269)
            elseif action_message_packet.status_id == 140 then
                remove_mob_debuff(action_message_packet.target_id, 270)
            elseif action_message_packet.status_id == 141 then
                remove_mob_debuff(action_message_packet.target_id, 271)
            elseif action_message_packet.status_id == 142 then
                remove_mob_debuff(action_message_packet.target_id, 272)
            elseif action_message_packet.status_id == 146 then
                remove_mob_debuff(action_message_packet.target_id, 242)
            end
        end
    end
end

windower.register_event('logout', 'zone change', function()
    clear_debuffed_mobs()
end)

windower.register_event('prerender', function()
    local current_time = os.clock()
    if current_time > 
end)