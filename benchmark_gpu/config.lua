Config = {}

Config.command      = 'benchmark'
Config.fadeDuration = 900

Config.scoreThresholds = { ultra = 80, high = 55, medium = 35 }

-- heading ignoré par la cam scriptée, rot.z = yaw
Config.phases = {
    {
        id = 'aube', label = 'Aube — Zone Portuaire',
        zone = 'Port (Ouest)', conditions = 'Aube, ciel dégagé',
        duration = 13000, weather = 'CLEARING', hour = 6,
        pedDensity = 0.5, vehicleDensity = 0.6,
        -- Vue aérienne plongeante sur le port
        cam1 = { pos = vector3(-1580.0, -1020.0, 55.0), rot = vector3(-55.0, 0.0,  30.0), fov = 75.0 },
        cam2 = { pos = vector3(-1540.0, -1060.0, 42.0), rot = vector3(-45.0, 0.0,  60.0), fov = 80.0 },
        explosions = {
            vector3(-1620.0, -1000.0, 13.0),
            vector3(-1600.0, -1030.0, 13.0),
        },
    },
    {
        id = 'matin', label = 'Matin — Centre-Ville',
        zone = 'Downtown (Centre)', conditions = 'Beau temps, plein soleil',
        duration = 13000, weather = 'EXTRASUNNY', hour = 10,
        pedDensity = 1.2, vehicleDensity = 1.2,
        cam1 = { pos = vector3(140.0, -750.0, 110.0), rot = vector3(-60.0, 0.0, -60.0), fov = 70.0 },
        cam2 = { pos = vector3(170.0, -800.0,  90.0), rot = vector3(-50.0, 0.0, -30.0), fov = 78.0 },
        explosions = {
            vector3(210.0, -830.0, 30.0),
            vector3(190.0, -800.0, 30.0),
            vector3(175.0, -845.0, 30.0),
        },
    },
    {
        id = 'midi_orage', label = 'Midi — Orage Vinewood',
        zone = 'Vinewood Hills (Nord)', conditions = 'Orage, éclairs',
        duration = 12000, weather = 'THUNDER', hour = 13,
        pedDensity = 0.4, vehicleDensity = 0.7,
        -- Vue en hauteur sur les collines, jamais derrière une paroi
        cam1 = { pos = vector3(-1250.0, 420.0, 140.0), rot = vector3(-50.0, 0.0, -130.0), fov = 85.0 },
        cam2 = { pos = vector3(-1310.0, 450.0, 125.0), rot = vector3(-42.0, 0.0, -100.0), fov = 75.0 },
        explosions = {
            vector3(-1265.0, 460.0, 100.0),
            vector3(-1290.0, 440.0, 100.0),
            vector3(-1310.0, 455.0, 100.0),
        },
    },
    {
        id = 'aprem_trafic', label = 'Après-midi — Densité Trafic',
        zone = 'Centre-Sud (Autoroute)', conditions = 'Ciel couvert, trafic dense',
        duration = 13000, weather = 'OVERCAST', hour = 17,
        pedDensity = 1.5, vehicleDensity = 1.5,
        cam1 = { pos = vector3(310.0, -1360.0, 62.0), rot = vector3(-52.0, 0.0, -20.0), fov = 85.0 },
        cam2 = { pos = vector3(270.0, -1410.0, 50.0), rot = vector3(-44.0, 0.0,  10.0), fov = 80.0 },
        explosions = {
            vector3(355.0, -1370.0, 29.0),
            vector3(330.0, -1395.0, 29.0),
        },
    },
    {
        id = 'crepuscule', label = 'Crépuscule — Collines',
        zone = 'Collines Ouest', conditions = 'Pluie, crépuscule',
        duration = 12000, weather = 'RAIN', hour = 20,
        pedDensity = 0.6, vehicleDensity = 0.8,
        cam1 = { pos = vector3(-680.0, 290.0, 120.0), rot = vector3(-55.0, 0.0, -50.0), fov = 80.0 },
        cam2 = { pos = vector3(-730.0, 330.0, 105.0), rot = vector3(-45.0, 0.0, -20.0), fov = 72.0 },
        explosions = {
            vector3(-660.0, 320.0, 83.0),
            vector3(-685.0, 300.0, 83.0),
        },
    },
    {
        id = 'nuit_props', label = 'Nuit — Zone Industrielle',
        zone = 'Grapeseed (Nord-Est)', conditions = 'Brouillard épais, nuit',
        duration = 13000, weather = 'FOGGY', hour = 23,
        pedDensity = 0.3, vehicleDensity = 0.4,
        spawnObjects = true,
        cam1 = { pos = vector3(1940.0, 3730.0, 60.0), rot = vector3(-55.0, 0.0, 195.0), fov = 78.0 },
        cam2 = { pos = vector3(1975.0, 3765.0, 48.0), rot = vector3(-45.0, 0.0, 175.0), fov = 70.0 },
        explosions = {
            vector3(1970.0, 3750.0, 32.0),
            vector3(1950.0, 3760.0, 32.0),
            vector3(1980.0, 3730.0, 32.0),
        },
    },
    -- MEGA STRESS TEST — cam fixe
    {
        id = 'stress_final', label = 'STRESS TEST',
        zone = 'Downtown Sud', conditions = 'Orage, nuit, chaos total',
        duration = 20000, weather = 'THUNDER', hour = 3,
        pedDensity = 1.0, vehicleDensity = 1.0,
        isMegaStress = true,
        cam1 = { pos = vector3(187.68, -923.15, 81.50), rot = vector3(-75.0, 0.0, 70.49), fov = 90.0 },
        cam2 = { pos = vector3(187.68, -923.15, 81.50), rot = vector3(-85.0, 0.0, 70.49), fov = 95.0 },
        megaCenter = vector3(197.25, -934.80, 30.68),
    },
}

Config.stressObjects = {
    { model = 'prop_barrel_02a',       ox =  5.0, oy =  5.0 },
    { model = 'prop_barrel_02a',       ox = -5.0, oy =  5.0 },
    { model = 'prop_barrel_02a',       ox =  5.0, oy = -5.0 },
    { model = 'prop_barrel_02a',       ox = -5.0, oy = -5.0 },
    { model = 'prop_consite_port_01a', ox = 10.0, oy =  0.0 },
    { model = 'prop_consite_port_01a', ox =-10.0, oy =  0.0 },
    { model = 'prop_dumpster_01a',     ox =  0.0, oy = 12.0 },
    { model = 'prop_dumpster_01a',     ox =  0.0, oy =-12.0 },
}

-- Véhicules pour le stress test
Config.megaVehicles = {
    'adder','zentorno','infernus','t20','osiris','fmj',
    'bullet','entityxf','cheetah2','voltic','reaper','vagner',
    'nero','tempesta','pfister811','deveste','le7b','tyrant',
    'emerus','krieger','scramjet','vigilante','stromberg','deluxo',
}
