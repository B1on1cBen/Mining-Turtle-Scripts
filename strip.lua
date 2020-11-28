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
    setRotation(1)
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    setRotation(0)
  else
    setRotation(1)
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    setRotation(2)
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
  while displacement.z > 0 do
    turtle.forward()
    displacement.z = displacement.z - 1
    print("Displacement Z: " .. displacement.z)
  end

  -- Correct Negative Z Displacement
  setRotation(2) -- South
  while displacement.z < 0 do
    turtle.forward()
    displacement.z = displacement.z + 1
    print("Displacement Z: " .. displacement.z)
  end

  -- Correct Positive Y Displacement
  while displacement.y > 0 do
    turtle.down()
    displacement.y = displacement.y - 1
    print("Displacement Y: " .. displacement.y)
  end

  -- Correct Negative Y Displacement
  while displacement.y < 0 do
    turtle.up()
    displacement.y = displacement.y + 1
    print("Displacement Y: " .. displacement.y)
  end

  setRotation(0)
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
  --print("Setting rotation to " .. rotation)
  --print("Current rotation: " .. direction)
  --print("Desired rotation: " .. rotation)
  while direction ~= rotation do
      direction = (direction + 1) % 4
      turtle.turnRight()
  end

  --print("Finished rotating. Direction: " .. direction .. "\n")
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

go()
checkFuel()