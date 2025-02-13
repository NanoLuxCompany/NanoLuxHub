local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/Gamelist.lua"))()

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        game.StarterGui:SetCore("SendNotification", {
        Title = "NanoLux Script Hub";
        Text = "The script is loading, please wait.";
        Icon = "";
        Duration = "3";
        Button1 = "Okay";})
        loadstring(game:HttpGet(Execute))()
    --else
        --game.Players.LocalPlayer:Kick("There is no script added to this game yet. Please wait. Best regards, NanoLuxHub.") end
    end
end