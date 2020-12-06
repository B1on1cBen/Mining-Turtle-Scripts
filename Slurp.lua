Position = vector.new(0, 0, 0)
Home = vector.new(0, 0, 0)
Rotation = 0
FuelLimit = 1000000
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

    if direction < 4 then
        Slurp()
        turtle.forward()
    elseif direction == 4 then
        SlurpUp()
        turtle.up()
    elseif direction == 5 then
        SlurpDown()
        turtle.down()
    end

    if direction == 0 then Position.z = Position.z + 1
    elseif direction == 1 then Position.x = Position.x + 1
    elseif direction == 2 then Position.z = Position.z - 1
    elseif direction == 3 then Position.x = Position.x - 1
    elseif direction == 4 then Position.y = Position.y + 1
    elseif direction == 5 then Position.y = Position.y - 1
    end

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
        Finish("Out of bounds at " .. Position.x .. ", " .. Position.y .. ", " .. Position.z, false)
        return false
    end

    if GoingHome == true then
        return true
    end

    if turtle.getFuelLevel() >= FuelLimit then
        Finish("Fully refueled", false)
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

function StripSlurp(startY)
    turtle.select(1)
    for y = startY, SizeY do
        for x = 1, SizeX do
            for z = 1, SizeZ do
                if Position.x % 2 == 0 then
                    if Move(0) == false then return end
                else
                    if Move(2) == false then return end
                end
            end

            if x < SizeX then
                if Move(1) == false then return end
            end
        end

        if y ~= SizeY then
            Go(vector.new(Home.x, -y, Home.z + 1))
        end
    end

    Finish("Job completed successfully", false)
end

function Slurp()
    turtle.place()
    turtle.refuel()
end

function SlurpUp()
    turtle.placeUp()
    turtle.refuel()
end

function SlurpDown()
    turtle.placeDown()
    turtle.refuel()
end

function CheckStartRequirements()
    term.clear()
    term.setCursorPos(1,1)

    io.write("             SLURP PROGRAM            \n")
    io.write("---------------------------------------\n")
    io.write("Fuel: " .. turtle.getFuelLevel() .. "/" .. FuelLimit .. "\n")
    io.write("Slurps up lava to refuel!\n")
    io.write("How to use:\n")
    io.write("- Place empty bucket in slot 1\n")
    io.write("---------------------------------------\n")
    io.write("Press enter once requirements are met")

    io.read()

    if turtle.getItemCount(1) > 0 then
        return true
    end

    term.clear()
    term.setCursorPos(1, 1)
    io.write("No bucket in slot 1. Press enter to continue\n")
    io.read()
    return false
end

function GoDown()
    local startY = 1
    for i = 1, GoDownSize do
        Move(5)
        startY = startY + 1
    end

    StripSlurp(startY)
end

-- STARTING POINT:
term.clear()
term.setCursorPos(1,1)

while CheckStartRequirements() == false do
    CheckStartRequirements()
end

io.write("How deep down? ")
SizeY = tonumber(io.read())

io.write("How far? ")
SizeZ = tonumber(io.read()) - 1

io.write("How wide? ")
SizeX = tonumber(io.read())

io.write("How far down is lava from home position? ")
GoDownSize = tonumber(io.read())

SizeY = SizeY + GoDownSize

term.clear()
term.setCursorPos(1, 1)

Move(0)
GoDown()
Move(2)
Move(2)
Move(2)