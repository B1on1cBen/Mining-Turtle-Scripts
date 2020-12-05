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
GoingHome = false

function Rotate(wantedRotation)
    while Rotation ~= wantedRotation do
        if Rotation == 3 and wantedRotation == 0 then
            Rotation = 0
            turtle.turnRight()
            return
        end

        if Rotation == 0 and wantedRotation == 3 then
            Rotation = 3
            turtle.turnLeft()
            return
        end

        if Rotation < wantedRotation then
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

    if CheckPlaceLantern() == false then return false end
    if CheckStatus() == false then return false end

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

    if(destinationIsHome) then
        GoingHome = true
    end

    if destinationIsHome == true then
        CorrectDisplacement(displacement.y, 4, 5)
        CorrectDisplacement(displacement.x, 1, 3)
        CorrectDisplacement(displacement.z, 0, 2)
    else
        CorrectDisplacement(displacement.z, 0, 2)
        CorrectDisplacement(displacement.x, 1, 3)
        CorrectDisplacement(displacement.y, 4, 5)
    end

    if(destinationIsHome) then
        GoingHome = false
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

function CheckStatus()
    Info()

    if IsOutOfBounds() == true then
        Finish("Out of bounds at " .. Position.x .. ", " .. Position.y .. ", " .. Position.z, true)
        return false
    end

    if GoingHome == true then
        return true
    end

    if IsLowOnFuel() == true or IsFullOfShit() == true then
        local resumePoint = vector.new(Position.x, Position.y, Position.z)
        local resumeRotation = Rotation

        Go(Home)
        DumpShit()

        if IsLowOnFuel() == true and Refuel() == false then
            Finish("No fuel in fuel chest", true)
            return false
        else
            turtle.select(15)
            Resume(resumePoint, resumeRotation)
        end
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

function CheckRequiredFuel(fuelCost)
    if turtle.getFuelLevel() < fuelCost then
        io.write("Insufficent fuel. Proceed anyway? (y/n) ")
        local answer = io.read()
        return answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"
    end

    return true
end

function EstimateRequiredChestSpace()
    local space = ((SizeX * (SizeZ + 1) * SizeY / 64) * 1.5) / 42
    io.write("Estimated large chests required: " .. math.ceil(space))
end

function CheckStartRequirements()
    term.clear()
    term.setCursorPos(1,1)
    io.write("             MINING PROGRAM            \n")
    io.write("---------------------------------------\n")
    io.write("Fuel: " .. turtle.getFuelLevel() .. "/" .. FuelLimit .. "\n")
    io.write("How to use:\n")
    io.write("- Place fuel chest to left of turtle\n")
    io.write("- Place block chest behind turtle\n")
    io.write("- Place Jack O' Lanterns in slot 15 to \n  prevent mob spawning\n")
    io.write("- If patching holes, place block in \n  last slot (16)\n")
    io.write("---------------------------------------\n")
    io.write("Press enter once requirements are met")

    io.read()

    local requirementsMet = turtle.getItemCount(15) > 0 and
                      turtle.getItemCount(16) > 0
   
    if requirementsMet then
        return true
    end

    term.clear()
    term.setCursorPos(1, 1)
    if turtle.getItemCount(15) == 0 then
        io.write("No Jack O' Lanterns in slot 15.\n")
    end

    if turtle.getItemCount(16) == 0 then
        io.write("No blocks in slot 15.\n")
    end

    io.write("Continue? (y/n)")
    local answer = io.read()
    return answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"
end

function IsFullOfShit()
    local fullSlots = 0
    for search = 14, 1, -1 do
        if turtle.getItemCount(search) > 0 then
            fullSlots = fullSlots + 1
        end
    end

    if fullSlots == 14 then
        return true
    end

    return false
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
    for search = 14, 1, -1 do
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
                if (startX % 2 == 0) == (Position.x % 2 == 0) then
                    if Move(2) == false then return end
                else
                    if Move(0) == false then return end
                end
                PatchHoles()
            end

            if x < SizeX then
                if Move(1) == false then return end
                PatchHoles()
            end
        end

        if y ~= SizeY then
            Go(vector.new(Home.x, -y, Home.z + 1))
            PatchHoles()
        end
    end

    Finish("Job completed successfully", false)
end

function PatchHoles()
    if IsFillingCeiling == true and Position.y == 0 and Detect(4) == false then
        turtle.select(16)
        turtle.placeUp()
    end

    if IsPatchingHoles == false then
        return true
    end

    if turtle.getItemCount(16) == 0 then
        Finish("Out of filler blocks", false)
        return false
    end

    if Position.z == (SizeZ + 1) then
        if Detect(0) == false then
            turtle.select(16)
            turtle.place()
        end
    end

    if Detect(1) == false and IsResuming == false then
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

    turtle.select(15)
    return true
end

function CheckPlaceLantern()
    if(IsPlacingLights == false) then
        return
    end

    if PlaceLanternsAlongFarZ == true then
        if (Position.z - 1) == SizeZ then
            if Position.x % 6 == 0 and (Position.x / 6) % 2 ~= 0 then
                return PlaceLantern()
            end
        end
    end

    if PlaceLanternsAlongFarX == true then
        if (Position.x) == (SizeX - 1) then
            if (Position.z - 1) % 5 == 0 and ((Position.z - 1) / 5) % 2 == 0 then
                return PlaceLantern()
            end
        end
    end

    if Position.x % 6 ~= 0 then
        return
    end

    if (Position.z - 1) % 5 ~= 0 then
        return
    end

    if ((Position.z - 1) / 5) % 2 == 0 then
        if (Position.x / 6) % 2 == 0 then
            return PlaceLantern()
        end
    else
        if (Position.x / 6) % 2 ~= 0 then
            return PlaceLantern()
        end
    end

    return true
end

function PlaceLantern()
    turtle.digDown()
    turtle.select(15)
    if turtle.getItemCount(15) == 0 then
        Finish("Out of Jack O' Lanterns", false)
        return false
    end
    turtle.placeDown()
    return true
end

function Resume(resumePoint, resumeRotation)
    Go(resumePoint)
    Rotate(resumeRotation)
end

function ResumePreviousJob()
    local resumeX = 1
    local resumeY = 1
    local resumeZ = 1

    while(Detect(5) == false) do
        if Move(5) == false then return end
        resumeY = resumeY + 1
    end

    while(Detect(1) == false) do
        if Move(1) == false then return end
        resumeX = resumeX + 1
    end

    Rotate(0)
    IsResuming = false
    io.write("Resume pos: " .. resumeX .. ", " .. resumeY .. ", " .. resumeZ)
    Mine(resumeX, resumeY, resumeZ)
end

-- STARTING POINT:
while CheckStartRequirements() == false do
    CheckStartRequirements()
end

term.clear()
term.setCursorPos(1, 1)

io.write("How deep down? ")
SizeY = tonumber(io.read())

io.write("How far? ")
SizeZ = tonumber(io.read()) - 1

io.write("How wide? ")
SizeX = tonumber(io.read())

PlaceLanternsAlongFarZ = SizeZ % 5 ~= 0
PlaceLanternsAlongFarX = (SizeX - 1) % 6 ~= 0

term.clear()
term.setCursorPos(1, 1)
io.write(SizeX .. " x " .. SizeY .. " x " .. (SizeZ + 1) .. "\n")
EstimateRequiredChestSpace()
local fuelCost = SizeX * SizeZ * SizeY * 1.5
io.write("Estimated fuel cost: " .. fuelCost .. "\n  out of " .. FuelLimit)

while CheckRequiredFuel(fuelCost) == false do
    term.clear()
    term.setCursorPos(1, 1)
    io.write(SizeX .. " x " .. SizeY .. " x " .. SizeZ .. "\n")
    EstimateRequiredChestSpace()
    fuelCost = SizeX * SizeZ * SizeY * 1.5
    io.write("Estimated fuel cost: " .. fuelCost .. " out of " .. FuelLimit)
end

io.write("---------------------------------------\n")

io.write("Resume previous job? (y/n)\n")
local answer = io.read()
IsResuming = answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"

io.write("Patch holes? (Safer, but slower) (y/n)\n")
answer = io.read()
IsPatchingHoles = answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"

io.write("Place lights? (y/n)\n")
answer = io.read()
IsPlacingLights = answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"

io.write("Fill Ceiling? (y/n)\n")
answer = io.read()
IsFillingCeiling = answer == "y" or answer == "Y" or answer == "yes" or answer == "Yes"

turtle.select(15)
Move(0)
PatchHoles()
if IsResuming == true then
    ResumePreviousJob()
else
    Mine(1, 1, 1)
end