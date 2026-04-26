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
    'ui/public/logo.png',
    'ui/public/fonts/*.ttf',
}

dependencies {
    'spz-lib',
    'spz-vehicles'
}
