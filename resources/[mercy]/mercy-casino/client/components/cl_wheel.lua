local IsWheelSpun = false
local WheelDui, DuiObject = nil, nil

-- [ Events ] --

RegisterNetEvent('mc-wheel/client/sync-wheel', function(Bool)
    if Bool then
        InitWheel(true)
    else
        InitWheel(false)
    end
end)

RegisterNetEvent('mc-wheel/client/sync-wheel-status', function(Bool)
    IsWheelSpun = Bool
end)

RegisterNetEvent('mc-wheel/client/do-spin', function(Data)
    if not HasCasinoMembership() then return end
    if IsWheelActive() then return end
    local Type = Data.Type
    local Paid = CallbackModule.SendCallback("mc-wheel/server/check-cash", Type)
    if Paid then
        for i = 1, Config.Options['Wheel']['Types'][Type]['SpinAmount'] do
            -- Get Chances for next or current slot
            local Speed = Config.Options['Wheel']['Types'][Type]['Speed']
            local Slot = math.random(0, #Config.Options['Wheel']['Slots'])
            if Slot == 23 then
                local RandomChance = math.random(1, 25000)
                if RandomChance == 1 then
                    Slot = 23 -- Car Win
                else 
                    Slot = 22
                end
            elseif Slot == 11 then
                local RandomChance = math.random(1, 10000)
                if RandomChance == 1 then
                    Slot = 11  -- $10,000
                else 
                    Slot = 10
                end
            elseif Slot == 17 then
                local RandomChance = math.random(1, 5000)
                if RandomChance == 1 then
                    Slot = 17 -- $5,000
                else 
                    Slot = 18
                end
            elseif Slot == 15 then
                local RandomChance = math.random(1, 3000)
                if RandomChance == 1 then
                    Slot = 15 -- $2,000
                else 
                    Slot = 14
                end
            elseif Slot == 3 then
                local RandomChance = math.random(1, 3000)
                if RandomChance == 1 then
                    Slot = 3 -- $2,000
                else 
                    Slot = 2
                end
            end
            -- Sync Everything
            TriggerServerEvent("mc-wheel/server/set-wheel-status", true)
            TriggerServerEvent("mc-wheel/server/sync-spin", Speed, Slot, Type)
            Citizen.Wait(Config.Options['Wheel']['Types'][Type]['Time'])
            EventsModule.TriggerServer("mc-wheel/server/give-reward", Slot)
        end
    end
end)

RegisterNetEvent('mc-wheel/client/sync-spin', function(WheelSpeed, WheelSlot, WheelType)
    SendDuiMessage(DuiObject, json.encode({
        Action = "DoWheel",
        Speed = WheelSpeed,
        Slot = WheelSlot,
    }))
    Citizen.Wait(Config.Options['Wheel']['Types'][WheelType]['Time'])
    TriggerServerEvent("mc-wheel/server/set-wheel-status", false)
end)

-- [ Functions ] --

function InitWheel(Bool)
    if Bool then
        if WheelDui then -- If wheel exists, reset
            exports['mercy-assets']:ChangeDuiURL(WheelDui['DuiId'], Config.WheelURL)
            AddReplaceTexture('vw_prop_vw_luckywheel_01a', 'script_rt_casinowheel', WheelDui['TxdDictName'], WheelDui['TxdName'])
        else
            WheelDui = exports['mercy-assets']:GenerateNewDui(Config.WheelURL, 1024, 1024, 'Casino-Wheel')
            if not WheelDui then return end
            DuiObject = WheelDui['DuiObject']
            AddReplaceTexture('vw_prop_vw_luckywheel_01a', 'script_rt_casinowheel', WheelDui['TxdDictName'], WheelDui['TxdName'])
            Citizen.Wait(2000)
            SendDuiMessage(DuiObject, json.encode({
                Action = 'CreateWheel',
                Slots = Config.Options['Wheel']['Slots'],
            }))
        end
    else
        WheelDui = nil
        RemoveReplaceTexture('vw_prop_vw_luckywheel_01a', 'script_rt_casinowheel')
    end
end

function IsWheelActive()
    if IsWheelSpun then
        exports['mercy-ui']:Notify("wheel-active", "The wheel is already spinning!", "error")
        return true
    end
    return false
end