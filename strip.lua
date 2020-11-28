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
  setRotation(2) -- west
  while displacement.x > 0 do
      turtle.forward()
      displacement.x = displacement.x - 1
  end
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
  rotateSteps = 0

  if direction == 0 and rotation == 1 then rotateSteps = 1 end
  if direction == 0 and rotation == 2 then rotateSteps = 3 end
  if direction == 0 and rotation == 3 then rotateSteps = 2 end

  if direction == 1 and rotation == 0 then rotateSteps = 3 end
  if direction == 1 and rotation == 2 then rotateSteps = 2 end
  if direction == 1 and rotation == 3 then rotateSteps = 1 end

  if direction == 2 and rotation == 0 then rotateSteps = 1 end
  if direction == 2 and rotation == 1 then rotateSteps = 2 end
  if direction == 2 and rotation == 3 then rotateSteps = 3 end

  if direction == 3 and rotation == 0 then rotateSteps = 2 end
  if direction == 3 and rotation == 1 then rotateSteps = 3 end
  if direction == 3 and rotation == 2 then rotateSteps = 1 end

  while rotateSteps > 0 do
      turtle.turnRight()
      direction = (direction + 1) % 4
      rotateSteps = rotateSteps - 1
      --print("Rotated right. Current rotation: " .. direction)
  end
end

-- STARTING POINT:
io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read()) - 1

--[[
  North - 0
  East - 1
  West - 2
  South - 3
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
turtle.up()

checkFuel()

--go()