gear_table = {}
gear_slot_map = {
    [0]='main',
    [1]='sub',
    [2]='range',
    [3]='ammo',
    [4]='head',
    [5]='body',
    [6]='hands',
    [7]='legs',
    [8]='feet',
    [9]='neck',
    [10]='waist',
    [11]='left_ear',
    [12]='right_ear',
    [13]='left_ring',
    [14]='right_ring',
    [15]='back'
}

function parse_incoming_equip_packet(data)
    local equip_packet = packets.parse('incoming', data)
    local item_bag = equip_packet['Inventory Bag']
    local item_slot = equip_packet['Inventory Index']
    local gear_table_index = equip_packet['Equipment Slot']
    
    gear_table[gear_table_index] = get_item(item_bag, item_slot)
end

function update_gear_table()
    for index, slot_name in ipairs(gear_slot_map) do
        gear_table[index] = get_gear_in_slot(slot_name)
    end
end

function get_item(item_bag, item_slot)
    return windower.ffxi.get_items(item_bag)[item_slot] ~= nil and windower.ffxi.get_items(item_bag)[item_slot].id or 0
end

function get_gear_in_slot(slot_name)
    local current_equipment = windower.ffxi.get_items()['equipment']
    local item_bag = current_equipment[slot_name .. '_bag']
    local item_slot = current_equipment[slot_name]

    return get_item(item_bag, item_slot)
end