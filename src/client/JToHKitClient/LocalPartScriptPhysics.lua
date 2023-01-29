--[[
This comes from LocalPartScript written by the main developers of the JToH kit, Jukereise and Gammattor

It handles player-related physics groups
]]
--

return function()
    local phs = game:GetService("PhysicsService")

    local function initplr(p)
        local function initchar(c)
            if not c then return end
            for i,v in pairs(c:GetChildren()) do
                if v:IsA("BasePart") then
                    phs:SetPartCollisionGroup(v,'OtherPlayers')
                end
            end
            c.ChildAdded:connect(function(v)
                if v:IsA("BasePart") then
                    phs:SetPartCollisionGroup(v,'OtherPlayers')
                end
            end)
        end
        p.CharacterAdded:Connect(initchar)
        initchar(p.Character)
    end
    game.Players.PlayerAdded:Connect(initplr)
    for _,p in pairs(game.Players:GetPlayers()) do
        initplr(p)
    end
    local p=game.Players.LocalPlayer
    local function initchar(c)
        if not c then return end
        for i,v in pairs(c:GetChildren()) do
            if v:IsA("BasePart") then
                phs:SetPartCollisionGroup(v,'Player')
            end
        end
        c.ChildAdded:connect(function(v)
            if v:IsA("BasePart") then
                phs:SetPartCollisionGroup(v,'Player')
            end
        end)
    end
    p.CharacterAdded:Connect(initchar)
    initchar(p.Character)
end