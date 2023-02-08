local ox_inventory = exports.ox_inventory
local active = false
local pedid
local WeaponData

RegisterNetEvent('rj-gunrepairs:server:repair', function(gun)
    local src = source
    local minute = 60 * 1000
    local time = Config.time * minute
    if ox_inventory:RemoveItem(src, 'money', Config.Cost) then
        if ox_inventory:RemoveItem(src, gun.name, 1) then
            active = true
            SetTimeout(10000, function()
                pedid = src
                WeaponData = gun 
            end)
        end
    else
        TriggerClientEvent('rj-gunrepairs:client:nomoney', src)
    end
end)

lib.callback.register('rj-gunrepairs:callback:active', function()
    return active
end)

lib.callback.register('rj-gunrepairs:callback:getped', function(source)
    if active and pedid == source then
        return true
    else
        return false
    end
end)

RegisterNetEvent('rj-gunrepairs:server:getitem', function()
    if WeaponData and pedid then
        WeaponData.metadata.durability = 100
        exports.ox_inventory:AddItem(pedid, WeaponData.name, 1, WeaponData.metadata)
        WeaponData = nil
        pedid = nil
        active = false
    end
end)


