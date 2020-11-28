io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read())

print("Fuel: " .. turtle.getFuelLevel())

function mineFront2by1(z)
  turtle.dig()
  turtle.forward()

  if z % 2 == 0 then
    turtle.digDown()
    turtle.down()
  else
    turtle.digUp()
    turtle.up()
  end
end

function goToNewRow(x)
  if x % 2 == 0 then
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
  else
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
    turtle.turnRight()
  end

  if sizeZ % 2 ~= 0 then 
    turtle.digDown()
    turtle.down()
  end
end

-- MAIN LOOP:
for x = 1, sizeX do
  for z = 1, sizeZ do
    mineFront2by1(z)
  end
  
  if x < sizeX then
    goToNewRow(x)
  end
end