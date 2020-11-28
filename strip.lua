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
    turtle.digUp()
    turtle.turnLeft()
  else
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.turnRight()
  end

  if sizeZ % 2 ~= 0 then 
    turtle.digDown()
    turtle.down()
  end
end

function go()
  for x = 1, sizeX do
    for z = 1, sizeZ do
      mineFront2by1(z)
    end
    
    if x < sizeX then
      goToNewRow(x)
    end
  end
end

function GoHome()
  print("Going home.")
end

function Refuel()
  print("Refueling. Fuel: " .. turtle.getFuelLevel())
end

function getDisplacement()
  location = vector.new(gps.locate(5))
  print("Location: " .. location.x .. ", " .. location.y .. ", " .. location.z)
  
  displacement = home - location
  print("Displacement: " .. displacement.x .. ", " .. displacement.y .. ", " .. displacement.z .. "\n")

  return displacement
end

function checkFuel()
  print("Fuel: " .. turtle.getFuelLevel())
  -- Get displacement from home
  -- if displacement is greater than or equal to fuel, go home and refuel

  displacement = getDisplacement()
  displacementTotal = math.abs(displacement.x) + 
                      math.abs(displacement.y) + 
                      math.abs(displacement.z)
  print("Blocks away from home: " .. displacementTotal)

  homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()
  print("Cost to travel home out of remaining fuel: " .. homeTravelCostPercent)

  if homeTravelCostPercent >= 0.9 then
    print("Fuel low. Must refuel.\n")
    GoHome()
    Refuel()
  end
end

-- STARTING POINT:
io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read()) - 1

home = vector.new(gps.locate(5))
print("Home: " .. home.x .. ", " .. home.y .. ", " .. home.z .. "\n")

turtle.forward()
turtle.forward()
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.forward()
turtle.forward()
turtle.up()

checkFuel()

turtle.dig()
turtle.forward()
turtle.digUp()

--go()