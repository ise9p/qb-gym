fx_version 'cerulean'
game 'gta5'

description 'qb-Gym'
version '2.0.0'
author 'Se9p Script'  

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

dependencies {
    'oxmysql',
}

lua54 'yes'