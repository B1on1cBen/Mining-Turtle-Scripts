-- LOCAL POSITIONING SYSYEM

position = vector.new(0, 0, 0)
home = vector.new(0, 0, 0)
rotation = 0

--[[
  North - 0
  East - 1
  South - 2
  West - 3
  --------
  Up - 4
  Down - 5
]]
function Rotate(direction)
    while rotation ~= direction do
        rotation = (rotation + 1) % 4
        turtle.turnRight()
    end
end

function Move(direction)
    if direction < 4 then
        Rotate(direction)
    end

    while Detect(direction) do
        if direction < 4 then turtle.dig()
        elseif direction == 4 then turtle.digUp()
        elseif direction == 5 then turtle.digDown()
        end
    end

    if direction < 4 then turtle.forward()
    elseif direction == 4 then turtle.up()
    elseif direction == 5 then turtle.down()
    end

    if direction == 0 then position.z = position.z + 1
    elseif direction == 1 then position.x = position.x + 1
    elseif direction == 2 then position.z = position.z - 1
    elseif direction == 3 then position.x = position.x - 1
    elseif direction == 4 then position.y = position.y + 1
    elseif direction == 5 then position.y = position.y - 1
    end
end

function Detect(direction)
    if direction < 4 then Rotate(direction); return turtle.detect()
    elseif direction == 4 then return turtle.detectUp()
    elseif direction == 5 then return turtle.detectDown()
    end
end

function Go(destination)
    displacement = position - destination
    isHome = (destination.x == home.x and destination.y == home.y and destination.z == home.z)

    if(isHome == false) then
        -- Displaced in +Z
        while displacement.z > 0 do
            Move(2) -- South
            displacement.z = displacement.z - 1
        end

        -- Displaced in -Z
        while displacement.z < 0 do
            Move(0)  -- North
            displacement.z = displacement.z + 1
        end
    end

    -- Displaced in +Y
    while displacement.y > 0 do
        Move(5) -- Down
        displacement.y = displacement.y - 1
    end

    -- Displaced in -Y
    while displacement.y < 0 do
        Move(4) -- Up
        displacement.y = displacement.y + 1
    end

    -- Displaced in +X
    while displacement.x > 0 do
        Move(3) -- West
        displacement.x = displacement.x - 1
    end

    -- Displaced in -X
    while displacement.x < 0 do
        Move(1) -- East
        displacement.x = displacement.x + 1
    end

    if(isHome == true) then
        -- Displaced in +Z
        while displacement.z > 0 do
            Move(2) -- South
            displacement.z = displacement.z - 1
        end

        -- Displaced in -Z
        while displacement.z < 0 do
            Move(0)  -- North
            displacement.z = displacement.z + 1
        end
    end
end

-- STATUS:
function Info()
    term.clear()
    term.setCursorPos(1,1)
    print("Fuel: " .. turtle.getFuelLevel() .. "/" .. 20000)
end

function CheckStatus()
    if IsLowOnFuel() == true or IsFullOfShit() == true then
        local resumePoint = position
        local resumeRotation = rotation
        Go(home)
        Refuel()
        DumpShit()
        Resume(resumePoint, resumeRotation)
    end
end

function IsLowOnFuel()
    local displacement = position - home
    local displacementTotal = math.abs(displacement.x) + 
                              math.abs(displacement.y) + 
                              math.abs(displacement.z)
  
    local homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()

    if homeTravelCostPercent >= 0.90 then
        return true
    end
    return false
end

function IsFullOfShit()
    local fullSlots = 0
    for search = 16, 1, -1 do
        if turtle.getItemCount(search) > 0 then
            fullSlots = fullSlots + 1
        end
    end
    
    if fullSlots == 16 then
        return true
    end
    
    return false
end

function Resume(resumePoint, resumeRotation)
    Go(resumePoint)
    Rotate(resumeRotation)
end

function Refuel()
    if turtle.getFuelLevel() < 20000 then
        Rotate(3)
        turtle.suck()
        turtle.select(1)
        turtle.refuel()
    end
end
  
function DumpShit()
    Rotate(2)
    local search = 0
    for search = 16, 1, -1 do
        turtle.select(search)
        turtle.drop()
    end
end

-- MINING:
function Mine()
    for y = 1, sizeY do
        Move(0)

        local yDerp = y - 1
        for i = 1, yDerp do
            Move(5)
        end

        for x = 1, sizeX do
            for z = 1, sizeZ do           
                if x % 2 == 0  then
                    Move(2)
                else
                    Move(0)
                end

                Info()
                CheckStatus()
            end
            
            if x < sizeX then
                Move(1)
            end
        end

        Go(home)
        Refuel()
        DumpShit()
    end
    Rotate(0)
end

-- STARTING POINT:
io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read()) - 1

io.write("How many layers deep? ")
sizeY = tonumber(io.read())

io.write("Refueling...")
Refuel()
Info()
Mine()