fx_version 'cerulean'
game 'gta5'

name 'benchmark'

server_script 'server.lua'

client_scripts {
    'config.lua',
    'client/state.lua',
    'client/camera.lua',
    'client/visual.lua',
    'client/hud.lua',
    'client/benchmark.lua',
    'client/main.lua',
}

ui_page 'ui/index.html'
files   { 'ui/index.html' }
