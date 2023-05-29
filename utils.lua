local LocalPlayer = game.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local WorldToViewportPoint = CurrentCamera.worldToViewportPoint
local ViewportSize = CurrentCamera.ViewportSize

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utilities = {}

function Utilities:indexExists(object, index)
    local exist = pcall(function() return object[index] end)
    return exist
end

function Utilities:tp(cf) LocalPlayer.Character.HumanoidRootPart.CFrame = cf end 
function Utilities:get_character(player) return indexExists(player, 'Character') end
function Utilities:is_alive(player) return player.Character and player.Character:FindFirstChild('Humanoid') and player.Character:FindFirstChild('Humanoid').Health > 0 and player.Character:FindFirstChild('HumanoidRootPart') end

function Utilities:bypass_teleport(cf)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
        local a = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(1,Enum.EasingStyle.Linear), {CFrame=cf})
        a:Play()
        a.Completed:Wait()
    end
end

function Utilities:locate( table, value )
    for i = 1, #table do
        if table[i] == value then return true end
    end
    return false
end

function Utilities:isPointVisible(targetForWallCheck)
    local castPoints = {targetForWallCheck.Position}
    local ignoreList = {targetForWallCheck, game.Players.LocalPlayer.Character, game.Workspace.CurrentCamera}
    local result = workspace.CurrentCamera:GetPartsObscuringTarget(castPoints, ignoreList)
    
    return #result <= 1
end

function Utilities:isTeammate(player)
    return LocalPlayer.Team == player.Team
end

function Utilities:getClosestPlayer(FOV, Bones) 
    for _, v in next, game.Players:GetPlayers() do
        if v == LocalPlayer then continue end
        if Utilities:isTeammate(v) then continue end
        if not v.Character then continue end
        if not v.Character:FindFirstChild("HumanoidRootPart") then continue end
        if not v.Character:FindFirstChild("Humanoid") then continue end
        if v.Character:FindFirstChild("Humanoid").Health == 0 then continue end

        for _, bone in pairs(Bones) do
            local valid = pcall(function() return v.Character[bone].Position end)
            if not valid then continue end

            local ScreenPoint = CurrentCamera:WorldToScreenPoint(v.Character[bone].Position)
            if ScreenPoint.z <= 0 then continue end
      
            local isVisible = isPointVisible(v.Character[bone])
            if not isVisible then continue end
            
            local VectorDistance = (ViewportSize/2 - Vector2.new(ScreenPoint.x, ScreenPoint.y)).Magnitude 
            if not (VectorDistance < FOV) then continue end

            return v, bone
        end
    end
end

Utilities.Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 180,
        Color = Color3.new(255, 0, 0),
        Part = {"Head"}
    }
}

function Utilities:SetupAimbot()
    local FOV_CIRCLE = Drawing.new("Circle")
    FOV_CIRCLE.Thickness = 1
    FOV_CIRCLE.Filled = false
    FOV_CIRCLE.Transparency = 1

    RunService.RenderStepped:Connect(function()
        FOV_CIRCLE.Position = ViewportSize/2
        FOV_CIRCLE.Radius = Utilities.Settings.Aimbot.FOV
        FOV_CIRCLE.Visible = Utilities.Settings.Aimbot.Enabled
        FOV_CIRCLE.Color = Utilities.Settings.Aimbot.Color

        if Utilities.Settings.Aimbot.Enabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.X) then
                pcall(function()
                    local cp, bone = getClosestPlayer(Utilities.Settings.Aimbot.FOV, Utilities.Settings.Aimbot.Part)

                    if (cp and bone) then
                        TweenService:Create(CurrentCamera, TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(CurrentCamera.CFrame.Position, cp.Character[bone].Position)}):Play()
                    end
                end)
            end
        end
    end)
end

return Utilities
