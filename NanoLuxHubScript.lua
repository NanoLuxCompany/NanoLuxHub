local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/NanoLuxCompany/NanoLuxHub/refs/heads/main/Gamelist.lua"))()

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        game.StarterGui:SetCore("SendNotification", {
        Title = "NanoLux Script Hub";
        Text = "Script Injected. Please Wait.";
        Icon = "";
        Duration = "2";})
        loadstring(game:HttpGet(Execute))()
    end
end
