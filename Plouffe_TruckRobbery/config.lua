TruckRobbery = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

TruckRobbery.Keys = {
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

TruckRobbery.KeyChances = 9
TruckRobbery.SearchTimer = 180
TruckRobbery.SpawnTruckModel = "stockade"
TruckRobbery.SpawnTruckCoords = vector3(-5.23, -670.55, 31.94)
TruckRobbery.SapwnTruckHeading = 182.91
TruckRobbery.MinCops = 3
TruckRobbery.EffectTimer = 120000
TruckRobbery.RobTimer = 16000
TruckRobbery.MaxTruckDistance = 9
TruckRobbery.ActiveyRobbing = false
TruckRobbery.MaxRob = 10
TruckRobbery.LastTruckRobbery = 0
TruckRobbery.TimerBeforeNewRob = 21200
TruckRobbery.UseBlackMoney = true
TruckRobbery.MaxCashReward = 12500
TruckRobbery.MinCashReward = 6000
TruckRobbery.UseJewels = true
TruckRobbery.MaxJewels = 30
TruckRobbery.MinJewels = 10
TruckRobbery.UseBag = true
TruckRobbery.TntInstalationTimer = 20000
TruckRobbery.SearchKeyTimer = 15000

TruckRobbery.Txt ={
    ["Search"] = "Vous rechercher dans les tirroirs",
    ["CheckingKey"] = "Verification de votre clé en cour",
    ["BackDoor"] = "Appuyer sur [E] pour forcer la porte",
    ["NoBackDoor"] = "Appuyer sur [E] pour fouiller le camion",
    ["RobbingTruck"] = "Vous fouillez le camion",
    ["TimerWait"] = "Vous devez attendre encore: ",
    ["TimerWaitMinutes"] = " minutes",
    ["MoreCops"] = "Pas asser de policier en service, il doit y avoir minimum "..tostring(TruckRobbery.MinCops).." policier en service",
    ["FoundKey"] = "Vous avez trouvez une clé!",
    ["NothingFound"] = "Vous n'avez rien trouver...",
    ["UsingEffect"] = "Ouverture des portes",
    ["CashReward"] = "Vous avez recu: ",
    ["Jewels"] = " bijoux",
    ["GoBehind"] = "Diriger vous derriere le camion!",
    ["NeedBag"] = "Vous avez besoin d'un sac!",
    ["PoliceAlertForTruck"] = "Les systems d'ugence d'un camion de transport on été déclancher!",
    ["TooFar"] = "Vous etes aller trop loin !",
    ["Finish"] = "Il n'y a plus rien dans le camion",
    ["InstallingTnt"] = "Instalation d'une petite charge de tnt",
    ["TntInstalationDone"] = "Instalation de la charge terminer eloigner vous!",
    ["TooFarFromDoor"] = "Aucune porte près..",
    ["NoKey"] = "Vous n'avez pas de clé légale...",
    ["GoodKey"] = "Votre clé a été valider!"
}

TruckRobbery.Coords = {
    {["type"] = "search", ["coords"] = vector3(149.7, -1043.39, 29.58),["heading"] = 162.19, ["txt"] = "Appuyer sur [E] pour fouiller",  ["txtSize"] = 0.4, ["maxDst"] = 1.0, ["issearched"] = false},
    {["type"] = "search", ["coords"] = vector3(313.96, -281.72,54.16), ["heading"] = 157.77, ["txt"] = "Appuyer sur [E] pour fouiller",  ["txtSize"] = 0.4, ["maxDst"] = 1.0, ["issearched"] = false},
    {["type"] = "search", ["coords"] = vector3(-1211.14,-332.82,37.78),["heading"] = 206.45, ["txt"] = "Appuyer sur [E] pour fouiller",  ["txtSize"] = 0.4, ["maxDst"] = 1.0, ["issearched"] = false},
    {["type"] = "search", ["coords"] = vector3(-2960.0,483.05,15.7),   ["heading"] = 265.26, ["txt"] = "Appuyer sur [E] pour fouiller",  ["txtSize"] = 0.4, ["maxDst"] = 1.0, ["issearched"] = false},
    {["type"] = "search", ["coords"] = vector3(1174.61,2709.35,38.09), ["heading"] = 354.03, ["txt"] = "Appuyer sur [E] pour fouiller",  ["txtSize"] = 0.4, ["maxDst"] = 1.0, ["issearched"] = false},
    {["type"] = "search", ["coords"] = vector3(-351.46,-52.44,49.04),  ["heading"] = 160.3, ["txt"] = "Appuyer sur [E] pour fouiller",  ["txtSize"] = 0.4, ["maxDst"] = 1.0, ["issearched"] = false},
    {["type"] = "spawntruck", ["coords"] = vector3(-4.69,-654.09,33.45),  ["heading"] = 160.3, ["txt"] = "Appuyer sur [E] pour sortir un camion",  ["txtSize"] = 0.4, ["maxDst"] = 1.0},
    {["type"] = "robbery", ["coords"] = vector3(1641.42, 3804.62,34.6),  ["heading"] = 160.3, ["txt"] = "Appuyer sur [E] pour commencer un vole de camion",  ["txtSize"] = 0.8, ["maxDst"] = 4.0, ["car"] = TruckRobbery.SpawnTruckModel},
    {["type"] = "robbery", ["coords"] = vector3(2466.37, 1589.26, 32.33),  ["heading"] = 160.3, ["txt"] = "Appuyer sur [E] pour commencer un vole de camion",  ["txtSize"] = 0.8, ["maxDst"] = 4.0, ["car"] = TruckRobbery.SpawnTruckModel},
    {["type"] = "robbery", ["coords"] = vector3(-1598.72, 3076.11, 32.17),  ["heading"] = 160.3, ["txt"] = "Appuyer sur [E] pour commencer un vole de camion",  ["txtSize"] = 0.8, ["maxDst"] = 4.0, ["car"] = TruckRobbery.SpawnTruckModel}

}
