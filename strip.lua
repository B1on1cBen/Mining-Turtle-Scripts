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
    SetRotation(1)
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    SetRotation(0)
  else
    SetRotation(1)
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    SetRotation(2)
  end

  if sizeZ % 2 ~= 0 then 
    turtle.digDown()
    turtle.down()
  end
end

function Go()
  turtle.dig()
  turtle.forward()
  turtle.digUp()

  for x = 1, sizeX do
    for z = 1, sizeZ do
      mineFront2by1(z)
      CheckFuel()
    end
    
    if x < sizeX then
      goToNewRow(x)
    end
  end
end

function GoHome()
  print("Going home.")
  displacement = GetDisplacement()

  SetRotation(3) -- West
  while displacement.x > 0 do
    turtle.forward()
    displacement.x = displacement.x - 1
  end

  SetRotation(1) -- East
  while displacement.x < 0 do
    turtle.forward()
    displacement.x = displacement.x + 1
  end

  SetRotation(0) -- North
  while displacement.z > 0 do
    turtle.forward()
    displacement.z = displacement.z - 1
  end

  SetRotation(2) -- South
  while displacement.z < 0 do
    turtle.forward()
    displacement.z = displacement.z + 1
  end

  while displacement.y > 0 do
    turtle.up()
    displacement.y = displacement.y - 1
  end

  while displacement.y < 0 do
    turtle.down()
    displacement.y = displacement.y + 1
  end

  Refuel()
  DumpShit()
end

function Refuel()
  print("Refueling. Fuel: " .. turtle.getFuelLevel())
  SetRotation(3)
  turtle.suck()
  turtle.select(1)
  turtle.refuel()
  print("Refueling Complete. Fuel: " .. turtle.getFuelLevel())
end

function DumpShit()
  print("Dumping shit...")
  SetRotation(2)
	for search = 16, 1, -1 do
		turtle.select(search)
		turtle.drop()
	end
end

function GetDisplacement()
  location = vector.new(gps.locate(5))
  print("Location: " .. location.x .. ", " .. location.y .. ", " .. location.z)
  
  displacement = home - location
  print("Displacement: " .. displacement.x .. ", " .. displacement.y .. ", " .. displacement.z .. "\n")

  return displacement
end

function CheckFuel()
  displacement = GetDisplacement()
  displacementTotal = math.abs(displacement.x) + 
                      math.abs(displacement.y) + 
                      math.abs(displacement.z)

  homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()

  if homeTravelCostPercent >= 0.90 then
    print("Fuel low. Must refuel.\n")
    GoHome()
  end
end

function SetRotation(rotation)
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

--GoHome()

--Go()