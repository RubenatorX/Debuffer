defaults = {}
defaults.pos = {}
defaults.pos.x = 600
defaults.pos.y = 300
defaults.text = {}
defaults.text.font = 'Consolas'
defaults.text.size = 10
defaults.flags = {}
defaults.flags.bold = false
defaults.flags.draggable = true
defaults.bg = {}
defaults.bg.alpha = 255

settings = config.load(defaults)
box = texts.new('${current_string}', settings)
box:show()

function update_box()
    local current_string = ''
    local debuff_strings = {}
    local player = windower.ffxi.get_player()
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')

    if target and target.valid_target and target.is_npc and (target.claim_id ~= 0 or target.spawn_type == 16) then
        local current_debuffs = debuffed_mobs[target.id]

        if current_debuffs then
            for buff_id, buff_info in pairs(current_debuffs) do
                if buff_info.spell_start_time + buff_info.expected_duration - os.clock() >= 0 then
                    if ja_spells:contains(buff_info.spell_id) then
                        debuff_strings:append(get_ja_buff_info(buff_info))
                    else
                        debuff_string:append(get_buff_info(buff_info))
                    end
                else
                    if buff_info.remove_at_end_of_timer then

                    end
                end
            end
        end
    end

    box.current_string = 'Debuffs: ' .. target.name .. '\n\n' .. debuff_strings:concat('\n')
end