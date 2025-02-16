local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/Gamelist.lua"))()

if not Games then
    game.Players.LocalPlayer:Kick("Failed to load game list. Please try again later.")
    return
end

local foundScript = false

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        game.StarterGui:SetCore("SendNotification", {
            Title = "NanoLux Script Hub",
            Text = "The script is loading, please wait.",
            Icon = "",
            Duration = 3,
            Button1 = "Okay"
        })
        loadstring(game:HttpGet(Execute))()
        foundScript = true
        break
    end
end

if not foundScript then
   -- game.Players.LocalPlayer:Kick("There is no script added to this game yet. Please wait. Best regards, NanoLuxHub.")
    game.StarterGui:SetCore("SendNotification", {
            Title = "NanoLux Script Hub",
            Text = "We couldn't find a script for your game. We're running our own for all games, please wait.",
            Icon = "",
            Duration = 3,
            Button1 = "Okay"
        })
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/scripts/NanoLuxScript.lua"))()
end
