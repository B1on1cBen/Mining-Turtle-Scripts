-- Turtle Move API by Shisharupu
--
-- This API uses numbers 0 through 5 for directions to move or rotate.
-- These directions are all relative to the direction the turtle is facing when it is placed.
--
-- Directions:
-- 0: North
-- 1: East
-- 2: South
-- 3: West
-- 4: Up
-- 5: Down

Position = vector.new(0, 0, 0)
Home = vector.new(0, 0, 0)
Rotation = 0

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