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
    while Rotation ~= direction do
        Rotation = (Rotation + 1) % 4
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

    if direction == 0 then Position.z = Position.z + 1
    elseif direction == 1 then Position.x = Position.x + 1
    elseif direction == 2 then Position.z = Position.z - 1
    elseif direction == 3 then Position.x = Position.x - 1
    elseif direction == 4 then Position.y = Position.y + 1
    elseif direction == 5 then Position.y = Position.y - 1
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
    local displacement = Position - destination
    io.write("Displacement: " .. displacement.x .. ", " .. displacement.y .. ", " .. displacement.z .. "\n")
    local destinationIsHome = (destination.x == Home.x and destination.y == Home.y and destination.z == Home.z)

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
        Go(Home)
    end

    Rotate(0)
    io.write("Done: " .. reason .. "\n")
end

function CheckStatus()
    Info()

    if IsLowOnFuel() == true or IsFullOfShit() == true then
        local resumePoint = vector.new(Position.x, Position.y, Position.z)
        local resumeRotation = Rotation
        io.write("Resuming at position " .. resumePoint.x .. ", " .. resumePoint.y .. ", " .. resumePoint.z .. " and rotation " .. resumeRotation .. "\n")
        Go(Home)
        DumpShit()
        
        if IsLowOnFuel() == true and Refuel() == false then
            Finish("No fuel in fuel chest", true)
            return false
        else
            Resume(resumePoint, resumeRotation)
        end
    end

    if IsOutOfBounds() == true then
        Finish("Out of bounds at " .. Position.x .. ", " .. Position.y .. ", " .. Position.z, true)
        return false
    end

    return true
end

function IsOutOfBounds()
    return Position.x > (SizeX - 1) or
           Position.x < 0 or
           Position.y < -SizeY or
           Position.y > 0 or
           Position.z > (SizeZ + 1) or
           Position.z < 0
end

function IsLowOnFuel()
    local displacement = Position - Home
    local displacementTotal = math.abs(displacement.x) + 
                              math.abs(displacement.y) + 
                              math.abs(displacement.z)
  
    local homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()

    if homeTravelCostPercent >= 0.80 then
        return true
    end

    return false
end

function CheckRequiredFuel()
    local fuelCost = SizeX * SizeZ * SizeY * 1.5
    io.write("Estimated fuel cost: " .. fuelCost .. "\n")

    if turtle.getFuelLevel() < fuelCost then
        io.write("Insufficent fuel. Proceed anyway? (y/n) ")
        local answer = io.read()
        if answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes" then
            return true
        else
            return false
        end
    end

    return true
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
    io.write("Resume point: " .. resumePoint.x .. ", " .. resumePoint.y .. ", " .. resumePoint.z .. "\n")
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
    for y = startY, SizeY do
        if y > startY then
            startX = 1
            startZ = 1
        end

        for x = startX, SizeX do
            for z = startZ, SizeZ do
                if x ~= startX and x % 2 == 0 then
                    if Move(2) == false then return end
                else
                    if Move(0) == false then return end
                end

                if CheckStatus() == false then return end
            end

            if x < SizeX then
                if Move(1) == false then return end
                if CheckStatus() == false then return end
            end
        end

        if y ~= SizeY then
            Go(vector.new(Home.x, -y, Home.z + 1))
        end
    end

    Finish("Job completed successfully", false)
end

function SmartResume()
    local resumeX = 1
    local resumeY = 1
    local resumeZ = 1

    while(Detect(5) == false) do
        if Move(5) == false then return end
        if CheckStatus() == false then return end
        resumeY = resumeY + 1
    end

    while(Detect(1) == false) do
        if Move(1) == false then return end
        if CheckStatus() == false then return end
        resumeX = resumeX + 1
    end
        
    Rotate(0)
    Mine(resumeX, resumeY, resumeZ)
end

-- STARTING POINT:
Info()

io.write("How deep down? ")
SizeY = tonumber(io.read())

io.write("How far? ")
SizeZ = tonumber(io.read()) - 1

io.write("How wide? ")
SizeX = tonumber(io.read())

Position = vector.new(0, 0, 0)
Home = vector.new(0, 0, 0)
Rotation = 0

-- Check fuel requirement and attempt to refuel if lower.
if CheckRequiredFuel() == true then
    Info()
    Move(0)
    SmartResume()
else
    Finish("Cancelled; Insufficent fuel", true)
end