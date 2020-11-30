-- LOCAL POSITIONING SYSYEM

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

    if turtle.getFuelLevel() == 0 then
        Finish("Out of fuel", true)
        return false
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

    return true
end

function Detect(direction)
    if direction < 4 then Rotate(direction); return turtle.detect()
    elseif direction == 4 then return turtle.detectUp()
    elseif direction == 5 then return turtle.detectDown()
    end
end

function Go(destination)
    displacement = position - destination
    destinationIsHome = (destination.x == home.x and destination.y == home.y and destination.z == home.z)

    if destinationIsHome == true then
        CorrectDisplacement(displacement.y, 4, 5)
        CorrectDisplacement(displacement.x, 1, 3)
        CorrectDisplacement(displacement.z, 0, 2)
    else
        CorrectDisplacement(displacement.z, 0, 2)
        CorrectDisplacement(displacement.x, 1, 3)
        CorrectDisplacement(displacement.y, 4, 5)
    end
end

function CorrectDisplacement(displacement, positiveDirection, negativeDirection)
    while displacement < 0 do
        Move(positiveDirection)
        displacement = displacement + 1
    end

    while displacement > 0 do
        Move(negativeDirection)
        displacement = displacement - 1
    end
end

-- STATUS:
function Info()
    term.clear()
    term.setCursorPos(1,1)
    io.write("Fuel: " .. turtle.getFuelLevel() .. "/" .. 20000 .. "\n")
end

function Finish(reason, stop)
    if stop == false then
        Go(home)
    end

    Rotate(0)
    io.write("Finished. Reason: " .. reason .. "\n")
end

function CheckStatus()
    Info()

    if IsLowOnFuel() == true or IsFullOfShit() == true then
        local resumePoint = position
        local resumeRotation = rotation
        io.write("Resuming at position " .. resumePoint.x .. ", " .. resumePoint.y .. ", " .. resumePoint.z .. " and rotation " .. resumeRotation .. "\n")
        Go(home)
        DumpShit()
        
        if Refuel() == false then
            Finish("Could not refuel; no fuel left in fuel chest", true)
            return false
        else
            Resume(resumePoint, resumeRotation)
        end
    end

    if IsOutOfBounds() == true then
        Finish("Out of bounds at " .. position.x .. ", " .. position.y .. ", " .. position.z, true)
        return false
    end

    return true
end

function IsOutOfBounds()
    return position.x > sizeX or
           position.x < 0 or
           position.y < -sizeY or
           position.y > 0 or
           position.z > (sizeZ + 1) or
           position.z < 0
end

function IsLowOnFuel()
    local displacement = position - home
    local displacementTotal = math.abs(displacement.x) + 
                              math.abs(displacement.y) + 
                              math.abs(displacement.z)
  
    local homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()

    if homeTravelCostPercent >= 0.80 then
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
    io.write("Refueling..." .. "\n")
    if turtle.getFuelLevel() < 20000 then
        Rotate(3)
        turtle.suck()
        turtle.select(1)
        return turtle.refuel()
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
function Mine(startX, startY, startZ)
    for y = startY, sizeY do
        if y > startY then
            startX = 1
            startZ = 1
        end

        for x = startX, sizeX do
            for z = startZ, sizeZ do
                if x ~= startX and x % 2 == 0 then
                    if Move(2) == false then return end
                else
                    if Move(0) == false then return end
                end

                if CheckStatus() == false then return end
            end

            if x < sizeX then
                if Move(1) == false then return end
                if CheckStatus() == false then return end
            end
        end

        if y ~= sizeY then
            Go(vector.new(home.x, -y, home.z + 1))
        end
    end

    Finish("Job completed successfully", false)
end

function SmartResume()
    local resumeX = 1
    local resumeY = 1
    local resumeZ = 1

    while(Detect(5) == false) do
        Move(5)
        resumeY = resumeY + 1
    end

    while(Detect(1) == false) do
        Move(1)
        resumeX = resumeX + 1
    end
        
    Rotate(0)
    Mine(resumeX, resumeY, resumeZ)
end

-- STARTING POINT:
io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read()) - 1

io.write("How many layers deep? ")
sizeY = tonumber(io.read())

io.write("\n")

position = vector.new(0, 0, 0)
home = vector.new(0, 0, 0)
rotation = 0

Refuel()
Info()
Move(0)
SmartResume()