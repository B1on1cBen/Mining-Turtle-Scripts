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
  turtle.dig()
  turtle.forward()
  turtle.digUp()

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
  displacement = getDisplacement()

  -- Correct Positive X Displacement
  setRotation(3) -- West
  while displacement.x > 0 do
    turtle.forward()
    displacement.x = displacement.x - 1
    print("Displacement X: " .. displacement.x)
  end

  -- Correct Negative X Displacement
  setRotation(1) -- East
  while displacement.x < 0 do
    turtle.forward()
    displacement.x = displacement.x + 1
    print("Displacement X: " .. displacement.x)
  end

  -- Correct Positive Z Displacement
  setRotation(0) -- North
  while displacement.z < 0 do
    turtle.forward()
    displacement.z = displacement.z + 1
    print("Displacement Z: " .. displacement.z)
  end

  -- Correct Negative Z Displacement
  setRotation(2) -- South
  while displacement.z > 0 do
    turtle.forward()
    displacement.z = displacement.z - 1
    print("Displacement Z: " .. displacement.z)
  end
end

function Refuel()
  --print("Refueling. Fuel: " .. turtle.getFuelLevel())
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

  --if homeTravelCostPercent >= 0.9 then
    print("Fuel low. Must refuel.\n")
    GoHome()
    Refuel()
  --end
end

function setRotation(rotation)
  print("Setting rotation to " .. rotation)
  --print("Current rotation: " .. direction)
  --print("Desired rotation: " .. rotation)
  rotateSteps = math.abs(rotation - direction)
  direction = rotation

  for i = 1, rotateSteps do
      turtle.turnRight()
  end

  print("Finished rotating. Direction: " .. direction .. "\n")
end

-- STARTING POINT:
io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read()) - 1

--[[
  North - 0
  East - 1
  South - 2
  West - 3
]]
direction = 0;

home = vector.new(gps.locate(5))
print("Home: " .. home.x .. ", " .. home.y .. ", " .. home.z .. "\n")
print("Fuel: " .. turtle.getFuelLevel())

turtle.forward()
turtle.forward()
turtle.forward()
setRotation(1)
turtle.forward()
turtle.forward()
turtle.forward()
checkFuel()

--go()