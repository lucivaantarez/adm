-- Standalone stale watchdog. Run as its own script alongside the farm.
-- Watches the character; if it doesn't move for 3 minutes, kicks so the
-- rejoin system brings the tab back fresh. Does not touch the farm script.
do
    local STALE_LIMIT = 180  -- seconds of no movement before kicking (3 min)
    local SAMPLE      = 15    -- seconds between position samples
    local MOVE_MIN    = 8      -- studs; movement >= this in a sample = "moving"

    local plr = game:GetService("Players").LocalPlayer

    local function pos()
        local c = plr.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        return root and root.Position or nil
    end

    task.spawn(function()
        task.wait(SAMPLE)          -- let the game load before first sample
        local last = pos()
        local stillFor = 0
        while true do
            task.wait(SAMPLE)
            local p = pos()
            if p and last and (p - last).Magnitude >= MOVE_MIN then
                stillFor = 0            -- moved -> reset
            else
                stillFor = stillFor + SAMPLE  -- no move / no character -> stale tick
            end
            last = p or last
            if stillFor >= STALE_LIMIT then
                plr:Kick("[watchdog] no movement "..STALE_LIMIT.."s - rejoining")
                break
            end
        end
    end)
end
 
