Config = {


    CzasLowienia = math.random(10000,25000),  -- Czas oczekiwania na próbę udaną lub nie udaną 1000 = 1 sekunda

    MiejscaLowienia = {x = -1850.04, y = -1250.68,  z = 8.61},  -- Miejsce w którym możemy łowić ryby

    Przyciski_anuluj = {73},  -- {X} --Przyciski które jak klikniemy anulują nam łowienie ryby | Dodanie kolejnego przycisku: Przyciski_anuluj = {73},{32},{12},

    Use_3dme = false, -- Jeżeli używasz 3dme lub triggerów od niego takich jak : 3dme:shareDisplay/3ddo:shareDisplay daj na true

    Blips = true -- Używanie blipa
}

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local blips = {
  {title="Łowienie Ryb", colour=3, id=68, x=Config.MiejscaLowienia.x, y=Config.MiejscaLowienia.y, z=Config.MiejscaLowienia.z},
}

if Config.Blips == true then
Citizen.CreateThread(function()

   for _, info in pairs(blips) do
     info.blip = AddBlipForCoord(info.x, info.y, info.z)
     SetBlipSprite(info.blip, info.id)
     SetBlipDisplay(info.blip, 4)
     SetBlipScale(info.blip, 0.8)
     SetBlipColour(info.blip, info.colour)
     SetBlipAsShortRange(info.blip, true)
     BeginTextCommandSetBlipName("STRING")
     AddTextComponentString(info.title)
     EndTextCommandSetBlipName(info.blip)
   end
end)
end

ESX                           = nil
local PlayerData                = {}
local przerwane = false
local lowienie = false
local MozeszNacisnac = true
local MozeszNacisnac1 = true
local notyfikacja = true


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    Citizen.Wait(5000)
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    
    Citizen.Wait(5000)

end)

Citizen.CreateThread(function()
    while true do
          local playerPed = GetPlayerPed(-1)
      Citizen.Wait(10)
          if lowienie == true then
              for k, button in pairs(Config.Przyciski_anuluj) do
                  if IsControlJustPressed(1, button) then
                      PrzerwijLowienie()
                  end
              end
              if IsEntityDead(playerPed) then
                      PrzerwijLowienie()
              end
              if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.MiejscaLowienia.x, Config.MiejscaLowienia.y, Config.MiejscaLowienia.z, true) > 10.0 then
                      PrzerwijLowienie()
              end
          end
    end
  end)



RegisterNetEvent('sokol_sprawdz-lowienie')
AddEventHandler('sokol_sprawdz-lowienie', function()
    local ped = PlayerPedId()
	if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.MiejscaLowienia.x, Config.MiejscaLowienia.y, Config.MiejscaLowienia.z, true) < 10.0  then
        if not IsPedInAnyVehicle(ped, false) then
        TriggerEvent('sokol_start-lowienie')
        else
        exports.pNotify:SendNotification({text = "Musisz opuścić pojazd przed rozpoczęciem łowienia!", type = "error", timeout = 2500, layout = "centerRight", queue = "right"})
    end
    else
        exports.pNotify:SendNotification({text = "To nie jest za dobre miejsce na złapanie ryby", type = "error", timeout = 2500, layout = "centerRight", queue = "right"})
	end
end, false)



RegisterNetEvent('sokol_start-lowienie')
AddEventHandler('sokol_start-lowienie', function()
    if lowienie == false then
    local playerPed = GetPlayerPed(-1)
    local CzasLowienia = Config.CzasLowienia
    local chanceUdaneLubNie = math.random(1,100)
    lowienie = true
    przerwane = false
    MozeszNacisnac = true
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_STAND_FISHING', 0, true)

    if Config.Use_3dme == true then
        TriggerServerEvent("3dme:shareDisplay", "Zarzuca wędkę")
    else
    end

        exports.pNotify:SendNotification({text = "Zaczynasz łowić ryby, poczekaj może coś weźmie!", type = "success", timeout = 5000, layout = "centerRight", queue = "right"})
        Citizen.Wait(CzasLowienia)
        if not przerwane then
        exports.pNotify:SendNotification({text = "Czujesz jak coś zaczepiło się o haczyk! Kliknij [E] aby zacząć ciągnąć!", type = "success", timeout = 5000, layout = "centerRight", queue = "right"})
        while MozeszNacisnac and not przerwane do
            Citizen.Wait(10)
        if IsControlJustPressed(1, 38) then
            MozeszNacisnac = false
        if chanceUdaneLubNie <= 30 then
        TriggerEvent('sokol_nieudane-lowienie')
        elseif chanceUdaneLubNie <= 100 then
        TriggerEvent('sokol_udane-lowienie')
       end
     end
   end
end
   else
   exports.pNotify:SendNotification({text = "Łowisz już ryby!", type = "error", timeout = 2000, layout = "centerRight", queue = "right"})
  end
end)

RegisterNetEvent('sokol_nieudane-lowienie')
AddEventHandler('sokol_nieudane-lowienie', function()
local startNieudane = true
local chanceCo = math.random(1,100)
if startNieudane and not przerwane then
    exports.pNotify:SendNotification({text = "Starasz się wyciągnąć wędkę z wody!", type = "success", timeout = 5000, layout = "centerRight", queue = "right"})
    Citizen.Wait(5000)
if chanceCo <= 25 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Wyciąga wędkę z wody")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Na haczyku widać starą puszkę")
    else
    end
    exports.pNotify:SendNotification({text = "Wyciągasz wędkę z wody ale niestety to była tylko stara puszka", type = "error", timeout = 5000, layout = "centerRight", queue = "right"})
    PrzerwijLowienieAkcja()

elseif chanceCo <= 50 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Wyciąga wędkę z wody")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Na haczyku widać zdechłą rybę")
    else
    end
    exports.pNotify:SendNotification({text = "Wyciągasz wędkę z wody ale niestety ryba nie przeżyła więc ją wyrzucasz", type = "error", timeout = 5000, layout = "centerRight", queue = "right"})
    Citizen.Wait(3000)
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Wyrzuca zdechłą rybę do wody")
    else
    end
        PrzerwijLowienieAkcja()
elseif chanceCo <= 80 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Wyciąga wędkę z wody")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Wędka nie posiada żyłki")
    else
    end
    exports.pNotify:SendNotification({text = "Wyciągasz wędkę z wody ale niestety urwała się żyłka", type = "error", timeout = 5000, layout = "centerRight", queue = "right"})
    PrzerwijLowienieAkcja()
elseif chanceCo <= 100 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Z całej siły ciągnie wędkę")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Ryba była bardzo silna i wyrwała wędkę z rąk")
    else
        ESX.ShowNotification('~b~Ryba~w~ wyrywa ci wędkę z ręki!')
    end
    exports.pNotify:SendNotification({text = "Ryba była za silna i wyrwała ci wędkę z rąk", type = "error", timeout = 4000, layout = "centerRight", queue = "right"})
    TriggerServerEvent("sokol_usunwedke-lowienie")
    PrzerwijLowienie()
    end
  end
end)

RegisterNetEvent('sokol_udane-lowienie')
AddEventHandler('sokol_udane-lowienie', function()
    local startUdane = true
    MozeszNacisnac1 = true
    local chanceCo1 = math.random(1,100)
    if startUdane and not przerwane then
        Citizen.Wait(2000)
if chanceCo1 <= 20 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Z całej siły ciągnie wędkę!")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Na haczyku widać bardzo dużą rybę!")
    else
        exports.pNotify:SendNotification({text = "Z całej siły ciągniesz wędkę", type = "success", timeout = 1000, layout = "centerRight", queue = "right"})
    end
    exports.pNotify:SendNotification({text = "Złowiłeś Wielką Rybę!", type = "success", timeout = 2000, layout = "centerRight", queue = "right"})
    TriggerServerEvent("sokol_dajrybeDuza-lowienie")
    PrzerwijLowienieAkcja()
elseif chanceCo1 <= 65 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Ciągnie wędkę")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Na haczyku widać rybę")
    else
    end
    exports.pNotify:SendNotification({text = "Złowiłeś Rybę!", type = "success", timeout = 2000, layout = "centerRight", queue = "right"})
    TriggerServerEvent("sokol_dajrybe-lowienie")
    PrzerwijLowienieAkcja()
elseif chanceCo1 <= 100 then
    if Config.Use_3dme == true then
    TriggerServerEvent("3dme:shareDisplay", "Ciągnie wędkę")
    Citizen.Wait(5000)
    TriggerServerEvent("3ddo:shareDisplay", "Na haczyku widać małą rybkę")
    else
        exports.pNotify:SendNotification({text = "Ciągniesz wędkę!", type = "success", timeout = 1000, layout = "centerRight", queue = "right"})
end
    Citizen.Wait(1000)
    exports.pNotify:SendNotification({text = "Złowiłeś bardzo małą rybkę, Naciśnij [E] aby ją wypuścić lub [Y] żeby ją wziąść", type = "success", timeout = 8000, layout = "centerRight", queue = "right"})
    while MozeszNacisnac1 and not przerwane do
        Citizen.Wait(10)
    if IsControlJustPressed(1, 38) then
        MozeszNacisnac1 = false
        if Config.Use_3dme == true then
        Citizen.Wait(5000)
    TriggerServerEvent("3dme:shareDisplay", "Wrzuca małą rybkę do wody")
        Citizen.Wait(3000)
    TriggerServerEvent("3ddo:shareDisplay", "Rybka wpada do wody i odpływa")
    else
        ESX.ShowNotification('Wrzuciłeś małą ~b~rybkę ~w~do wody!')
end
        PrzerwijLowienieAkcja()
end 
 if IsControlJustPressed(1, 246) then
    MozeszNacisnac1 = false
    if Config.Use_3dme == true then
        Citizen.Wait(3000)
    TriggerServerEvent("3dme:shareDisplay", "Zabiera ze sobą małą rybkę")
    else 
        ESX.ShowNotification('Zabierasz ze sobą małą ~b~rybkę')
    end
    TriggerServerEvent("sokol_dajrybeMala-lowienie")
   
    PrzerwijLowienieAkcja()
        end
      end
    end
  end
end)


function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict( dict )
        Citizen.Wait(5)
    end
end


function PrzerwijLowienie()
    lowienie = false
    przerwane = true
    ClearPedTasks(GetPlayerPed(-1))
    exports.pNotify:SendNotification({text = "Przestałeś łowić ryby!", type = "error", timeout = 2500, layout = "centerRight", queue = "right"})
end

function PrzerwijLowienieAkcja()
    lowienie = false
    przerwane = true
end