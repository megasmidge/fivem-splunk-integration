fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'Splunk Integration for FiveM'
version '1.0.0'

server_scripts {
    'config.lua',
    'shared/events.lua',
    'server/formatters.lua',
    'server/http_client.lua',
    'server/queue_manager.lua',
    'server/main.lua'
}

client_scripts {
    'shared/events.lua',
    'client/main.lua'
}

exports {
    'LogEvent',
    'LogPlayerEvent',
    'LogSystemEvent',
    'GetQueueStats'
}
