fx_version 'cerulean'
game 'gta5'

name 'spz-carspawner'
description 'Standalone Car Spawner with NUI'
version '1.0.0'
author 'SPiceZ-Core'

ui_page 'ui/index.html'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    -- Inherit branding from spz-spawn if needed, or just keep it simple
}

dependencies {
    'spz-lib',
    'spz-vehicles'
}
