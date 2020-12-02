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

Position = vector.new(0, 0, 0)
Home = vector.new(0, 0, 0)
Rotation = 0
FuelLimit = 100000

function Rotate(direction)
    while Rotation ~= direction do
        if (Rotation == 3 and direction == 0) or Rotation < direction then
            Rotation = (Rotation + 1) % 4
            turtle.turnRight()
        else
            Rotation = (Rotation - 1)
            if Rotation < 0 then Rotation = 0 end
            turtle.turnLeft()
        end
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
    io.write("Fuel: " .. turtle.getFuelLevel() .. "/" .. FuelLimit .. "\n")
end

function Finish(reason, stop)
    if stop == false then
        Go(Home)
    end

    Rotate(0)
    io.write("Done: " .. reason .. "\n")
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
    for search = 14, 1, -1 do
        turtle.select(search)
        turtle.drop()
    end
end

-- MINING:
function Mine(startX, startY, startZ)
    turtle.select(16)
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
                PlaceLanterns()
                PatchHoles()
            end

            if x < SizeX then
                if Move(1) == false then return end
                PlaceLanterns()
                PatchHoles()
            end
        end

        if y ~= SizeY then
            Go(vector.new(Home.x, -y, Home.z + 1))
            PlaceLanterns()
            PatchHoles()
        end
    end

    Finish("Job completed successfully", false)
end

function PatchHoles()
    if IsPatchingHoles == false then
        return
    end

    if Position.z == (SizeZ + 1) then
        if Detect(0) == false then
            turtle.select(16)
            turtle.place()
        end
    end

    if Detect(1) == false then
        turtle.select(16)
        turtle.place()
    end

    if Position.z == 1 and Position.x > 0 then
        if Detect(2) == false then
            turtle.select(16)
            turtle.place()
        end
    end

    if Position.x == 0 then
        if Detect(3) == false then
            turtle.select(16)
            turtle.place()
        end
    end

    if Detect(5) == false then
        turtle.select(16)
        turtle.placeDown()
    end

    if IsFillingCeiling == true and Detect(4) == false then
        turtle.select(16)
        turtle.placeUp()
    end
end

function PlaceLanterns()
    if Position.x % 7 ~= 0 then
        return
    end

    if (Position.z - 1) % 6 ~= 0 then
        return
    end

    if ((Position.z - 1) / 6) % 2 == 0 then
        if (Position.x / 7) % 2 == 0 then
            turtle.digDown()
            turtle.select(15)
            turtle.placeDown()
        end
    else
        if (Position.x / 7) % 2 ~= 0 then
            turtle.digDown()
            turtle.select(15)
            turtle.placeDown()
        end
    end
end

-- STARTING POINT:
term.clear()
term.setCursorPos(1,1)
io.write("MINING PROGRAM\n")
io.write("Fuel: " .. turtle.getFuelLevel() .. "/" .. FuelLimit .. "\n")
io.write("---------------------------------------\n")
io.write("How deep down? ")
SizeY = tonumber(io.read())

io.write("How far? ")
SizeZ = tonumber(io.read()) - 1

io.write("How wide? ")
SizeX = tonumber(io.read())

io.write("Patch holes? (Safer, but slower) (y/n)\n")
local answer = io.read()
IsPatchingHoles = answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"

IsFillingCeiling = false
if answer == true then 
    io.write("Fill Ceiling? (y/n)\n")
    IsFillingCeiling = answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"
end

Move(0)
PlaceLanterns()
PatchHoles()
Mine(1, 1, 1)