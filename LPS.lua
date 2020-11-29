-- LOCAL POSITIONING SYSYEM

position = vector.new(0, 0, 0)
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

end

Move(0)
Move(0)
Move(0)
Move(1)
Move(1)
Move(1)