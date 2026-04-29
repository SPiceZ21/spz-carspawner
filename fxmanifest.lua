fx_version 'cerulean'
game 'gta5'

name 'spz-carspawner'
description 'Standalone Car Spawner with NUI'
version '1.0.10'
author 'SPiceZ-Core'

ui_page 'ui/dist/index.html'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'ui/dist/**/*',
}

dependencies {
    'spz-lib',
    'spz-vehicles'
}
