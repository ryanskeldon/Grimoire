--[[
	Copyright (C) 2016, Ryan Skeldon
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
_addon.version = '1.1.0'
_addon.name = 'Grimoire'
_addon.author = 'psykad'
_addon.commands = {'grimoire'}

require 'tables'
require 'strings'

res = require('resources')

local skillchains = {
	[288] = {id=288,english='Light',elements={'Light','Fire','Thunder','Wind'}},
	[289] = {id=289,english='Darkness',elements={'Dark','Earth','Water','Ice'}},
	[290] = {id=290,english='Gravitation',elements={'Dark','Earth'}},
	[291] = {id=291,english='Fragmentation',elements={'Thunder','Wind'}},
	[292] = {id=292,english='Distortion',elements={'Water','Ice'}},
	[293] = {id=293,english='Fusion',elements={'Light','Fire'}},
	[294] = {id=294,english='Compression',elements={'Dark'}},
	[295] = {id=295,english='Liquefaction',elements={'Fire'}},
	[296] = {id=296,english='Induration',elements={'Ice'}},
	[297] = {id=297,english='Reverberation',elements={'Water'}},
	[298] = {id=298,english='Transfixion', elements={'Light'}},
	[299] = {id=299,english='Scission',elements={'Earth'}},
	[300] = {id=300,english='Detonation',elements={'Wind'}},
	[301] = {id=301,english='Impaction',elements={'Thunder'}}
}

local magic_tiers = {
	[1] = {suffix=''},
	[2] = {suffix='II'},
	[3] = {suffix='III'},
	[4] = {suffix='IV'},
	[5] = {suffix='V'},
	[6] = {suffix='VI'}
}

local spell_priorities = {
	[1] = {element='Thunder'},
	[2] = {element='Ice'},
	[3] = {element='Wind'},
	[4] = {element='Fire'},
	[5] = {element='Water'},
	[6] = {element='Earth'}
}

local storms = { 
	[178] = {id=178,name='Firestorm',weather=4}, 
	[179] = {id=179,name='Hailstorm',weather=12}, 
	[180] = {id=180,name='Windstorm',weather=10}, 
	[181] = {id=181,name='Sandstorm',weather=8}, 
	[182] = {id=182,name='Thunderstorm',weather=14}, 
	[183] = {id=183,name='Rainstorm',weather=6}, 
	[184] = {id=184,name='Aurorastorm',weather=16}, 
	[185] = {id=185,name='Voidstorm',weather=18},
	[589] = {id=589,name='Firestorm',weather=5}, 
	[590] = {id=590,name='Hailstorm',weather=13}, 
	[591] = {id=591,name='Windstorm',weather=11}, 
	[592] = {id=592,name='Sandstorm',weather=9}, 
	[593] = {id=593,name='Thunderstorm',weather=15}, 
	[594] = {id=594,name='Rainstorm',weather=7}, 
	[595] = {id=595,name='Aurorastorm',weather=17}, 
	[596] = {id=596,name='Voidstorm',weather=19}
}

local elements = {
	['Light'] = {spell=nil,helix='Luminohelix',ga=nil,ja=nil,ra=nil},
	['Dark'] = {spell=nil,helix='Noctohelix',ga=nil,ja=nil,ra=nil},
	['Fire'] = {spell='Fire',helix='Pyrohelix',ga='Firaga',ja='Firaja',ra='Fira'},
	['Ice'] = {spell='Blizzard',helix='Cryohelix',ga='Blizzaga',ja='Blizzaja',ra='Blizzara'},
	['Wind'] = {spell='Aero',helix='Anemohelix',ga='Aeroga',ja='Aeroja',ra='Aerora'},
	['Earth'] = {spell='Stone',helix='Geohelix',ga='Stonega',ja='Stoneja',ra='Stonera'},
	['Thunder'] = {spell='Thunder',helix='Ionohelix',ga='Thundaga',ja='Thundaja',ra='Thundara'},
	['Water'] = {spell='Water',helix='Hydrohelix',ga='Waterga',ja='Waterja',ra='Watera'}
}

local last_skillchain = nil

windower.register_event('addon command', function(...)
	if #arg == 0 then return end
	
	local command = arg[1]
	
	if command == 'cast' then
		-- Verify a skillchain actually happened at some point.	
		if last_skillchain == nil then 
			windower.console.write(_addon.name..': No skillchain found.')
			return 
		end

		-- Verify a spell type was defined. 
		local spell_type = arg[2]		
		if spell_type == nil then
			windower.console.write(_addon.name..': No spell type defined.')
			return
		elseif not T{'spell', 'helix', 'ga', 'ja', 'ra'}:contains(spell_type) then
			-- Invalid type
			windower.console.write(_addon.name..': Invalid type specified.')
			return
		end	
		
		-- Verify a spell tier was defined.
		local spell_tier = tonumber(arg[3])		
		if spell_tier == nil then
			windower.console.write(_addon.name..': No spell tier defined.')
			return
		end

		-- Default to weather element.
		local weather_element = get_weather_element()
		local skillchain_element = nil
		
		-- Check if skillchain contains weather element.				
		if T(last_skillchain.elements):contains(weather_element) then
			skillchain_element = weather_element
		end
		
		-- If nothing was found for the current weather element, try the day element.
		if skillchain_element == nil then
			day_element = get_day_element()
			
			if T(last_skillchain.elements):contains(day_element) then
				skillchain_element = day_element
			end
		end
		
		-- If no element was found based weather or day, or no spell exists for computed element, go by priority list.
		if skillchain_element == nil or elements[skillchain_element][spell_type] == nil then		
			for i=1,#spell_priorities do
				if skillchain_element == nil and T(last_skillchain.elements):contains(spell_priorities[i].element) then
					skillchain_element = spell_priorities[i].element
				end
			end
		end
		
		-- If we get here and no element was found (shouldn't happen), fail out now.
		if skillchain_element == nil then
			windower.add_to_chat(8, _addon.name..': Unable to find a valid element.')
			return
		end
		
		-- Build spell name.
		local spellName = string.trim(elements[skillchain_element][spell_type].." "..magic_tiers[spell_tier].suffix)

		-- Cast the spell!		 		
		windower.send_command('input /ma "'..spellName..'" <t>')
		windower.add_to_chat(8, _addon.name..': Casting '..spellName)
	end
end)

windower.register_event('incoming chunk', function(id, original)
	if id == 0x28 then
		local action_packet = windower.packets.parse_action(original)
		
		for _, target in pairs(action_packet.targets) do
			local battle_target = windower.ffxi.get_mob_by_target("bt")
			
			if battle_target ~= nil and target.id == battle_target.id then
				for _, action in pairs(target.actions) do
					if action.add_effect_message > 287 and action.add_effect_message < 302 then
						last_skillchain = skillchains[action.add_effect_message]
						windower.add_to_chat(8, _addon.name..': Skillchain '..last_skillchain.english)
						windower.send_command('timers c "Skillchain: '..last_skillchain.english..'" 5 down')
					end
				end
			end			
		end
	end
end)

function get_weather_element()
	local player = windower.ffxi.get_player()
	local weather_id = windower.ffxi.get_info().weather
		
	-- Check if any storm is active.		
	if #player.buffs > 0 then		
		for i=1,#player.buffs do
			local buff = player.buffs[i]
			
			for _, storm in pairs(storms) do
				if storm.id == buff then
					-- A storm is active, override weather with storm element.					
					weather_id = storm.weather	
				end
			end			
		end
	end
	
	-- Return the name of the element.
	return res.elements[res.weather[weather_id].element].en
end

function get_day_element()
	local day_id = windower.ffxi.get_info().day	
	
	-- Return the name of the element.
	return res.elements[res.days[day_id].element].en
end
