local ox_inventory = exports.ox_inventory

local IsTargetReady = GetResourceState(Config.target) == "started" or GetResourceState("ox_target") == "started" or GetResourceState("qb-target") == "started"

local WeaponData = {}
local itsme
local active = false

local function SpawnPed()
    if pedSpawned then return end
    local model = joaat(Config.model)
    lib.requestModel(model)
    local coords = Config.coords4
    local shopdude = CreatePed(0, model, coords.x, coords.y, coords.z-1.0, coords.w, false, false)

    spawnedPed = shopdude

    TaskStartScenarioInPlace(shopdude, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(shopdude, true)
    SetEntityInvincible(shopdude, true)
    SetBlockingOfNonTemporaryEvents(shopdude, true)

    pedSpawned = true
    if true then
        if IsTargetReady then
            if Config.targettype == 'ox' then
                exports.ox_target:addLocalEntity(shopdude, {
                    {
                        name = 'rj-gunrepairs',
                        label = 'Repair Weapon?',
                        event = 'rj-gunrepairs:client:targetted',
                        icon = 'fa-sharp fa-solid fa-gun',
                        canInteract = function(_, distance)
                            return distance < 2.0
                        end
                    }
                })
            elseif Config.targettype == 'qb' then
                exports['qb-target']:AddTargetEntity(shopdude, {
                    {
                        num = 1,
                        type = 'client',
                        event = 'rj-gunrepairs:client:targetted',
                        icon = 'fa-sharp fa-solid fa-gun',
                        label = 'Repair Weapon?',
                        canInteract = function(_, distance)
                            return distance < 2.0
                        end
                    }
                })
            else
                print('This target is not supported')
            end
        else
            print('No targets found')
        end
    end
end

CreateThread(function()
    SpawnPed()
end)

RegisterNetEvent('rj-gunrepairs:client:targetted', function()
    active = lib.callback.await('rj-gunrepairs:callback:active', false)
    itsme = lib.callback.await('rj-gunrepairs:callback:getped', false)
    Wait(250)
    lib.registerContext({
        id = 'gunrepairmenu',
        title = 'Gun Repairs',
        onExit = function()
            lib.notify({
                title = 'See you Later!',
                description = 'Thankyou for stopping by and have a great rest of your day!',
                type = 'error'
            })
        end,
        options = {
            {
                title = 'Repair Weapon',
                disabled = active,
                description = 'Give me your weapon and ill fix it up for you!',
                icon = 'fa-sharp fa-solid fa-gun',
                onSelect = function(args)
                    lib.notify({
                        title = 'Thankyou',
                        description = 'Thankyou for using my services, this will take around 5 minutes of your time, Please wait nearby!',
                        type = 'success'
                    })
                end,
                event = 'rj-gunrepairs:client:repair',
                args = {type = 'repair'},
                metadata = {
                    {label = 'Price', value = '$'..Config.Cost}
                }
            },
            {
                title = 'Get weapon',
                disabled = not itsme,
                description = 'Get your weapon',
                icon = 'fa-solid fa-hand',
                onSelect = function(args)
                    lib.notify({
                        title = 'Thankyou',
                        description = 'Thankyou for using my services, Have a great rest of your day!',
                        type = 'success'
                    })
                end,
                event = 'rj-gunrepairs:client:repair',
                args = {type = 'get'}
            },
        }
    })
    if exports.ox_inventory:getCurrentWeapon() or itsme then
        lib.showContext('gunrepairmenu')
    else
        lib.notify({
            title = 'Get your gun out',
            description = 'Let me see your gun to see if I can work with it!',
            type = 'error'
        })
    end
end)

RegisterNetEvent('rj-gunrepairs:client:nomoney', function()
    lib.notify({
        title = 'Not enough cash',
        description = 'You do not have enough cash for this repair :(',
        type = 'error'
    })
end)

RegisterNetEvent('rj-gunrepairs:client:repair', function(data)
    if data.type == 'repair' then
        local gun = exports.ox_inventory:getCurrentWeapon()
        if gun then
            TriggerEvent('ox_inventory:disarm')
            Wait(1500)
            TriggerServerEvent('rj-gunrepairs:server:repair', gun)
            if Config.Debug then
                print(json.encode(gun, {indent=true}))
            end
        end
    elseif data.type == 'get' then 
        TriggerServerEvent('rj-gunrepairs:server:getitem')
        active = false
        itsme = false
    end      
end)

-- RegisterNetEvent('rj-gunrepairs:client:fixhand', function()
--     Wait(2000)
--     SetCurrentPedWeapon(source, `WEAPON_UNARMED`, true)
-- end)

