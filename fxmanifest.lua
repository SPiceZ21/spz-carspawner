fx_version 'cerulean'
game 'gta5'

name 'spz-carspawner'
description 'Standalone Car Spawner (ox_lib menu)'
version '1.5.3'
author 'SPiceZ-Core'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    '@spz-hud/shim.lua',   -- NUI goes through spz-hud
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

-- ui_page 'ui/index.html'  -- drawn by spz-hud now (web/public/apps/spz-carspawner); uncomment + drop the shim to roll back

-- UI files are not shipped from here: spz-hud serves this resource's page
-- (synced from ui/ by spz-hud/tools/sync-apps.mjs).

dependencies {
    'spz-hud',
    'ox_lib',
    'spz-vehicles'
}
