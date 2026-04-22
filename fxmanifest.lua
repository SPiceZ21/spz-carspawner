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
    'ui/public/logo.png',
    'ui/public/fonts/Panchang-Regular.ttf',
    'ui/public/fonts/Panchang-Bold.ttf',
    'ui/public/fonts/Panchang-Extrabold.ttf',
    'ui/public/fonts/Panchang-Light.ttf',
}

dependencies {
    'spz-lib',
    'spz-vehicles'
}
