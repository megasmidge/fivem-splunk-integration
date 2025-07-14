fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'QBCore Integration with Splunk Logger'
version '1.0.0'

dependencies {
    'qb-core',
    'splunk-logger'
}

server_scripts {
    'server/player_events.lua',
    'server/economy_events.lua',
    'server/job_events.lua',
    'server/vehicle_events.lua',
    'server/crime_events.lua'
}
