function mineFront2by1(z)
  DigAndMove()

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
    DigAndMove()
    turtle.digUp()
    SetRotation(0)
  else
    SetRotation(1)
    DigAndMove()
    turtle.digUp()
    SetRotation(2)
  end

  if sizeZ % 2 ~= 0 then 
    turtle.digDown()
    turtle.down()
  end
end

function Mine()
  DigAndMove()
  turtle.digUp()

  for x = 1, sizeX do
    for z = 1, sizeZ do
      mineFront2by1(z)
      if CheckFuel() == true or CheckShit() == true then
        local resumePoint = vector.new(gps.locate(5))
        local resumeDirection = direction
        Go(home)
        Refuel()
        DumpShit()
        Resume(resumePoint, resumeDirection)
      end
    end
    
    if x < sizeX then
      goToNewRow(x)
    end
  end
end

function DigAndMove()
  local startLocation = vector.new(gps.locate(5))
  turtle.dig()
  turtle.forward()
  local endLocation = vector.new(gps.locate(5))
  while startLocation.x == endLocation.x and  
        startLocation.y == endLocation.y and
        startLocation.z == endLocation.z do
    turtle.dig()
    turtle.forward()
    endLocation = vector.new(gps.locate(5))
  end
end

function Resume(resumePoint, resumeDirection)
  SetRotation(0)
  turtle.forward()
  Go(resumePoint)
  SetRotation(resumeDirection)
end

function Go(destination)
  print("Going to " .. destination.x .. ", " .. destination.y .. ", " .. destination.z)
  displacement = GetDisplacement(destination)

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
  local search = 0
	for search = 16, 1, -1 do
		turtle.select(search)
		turtle.drop()
	end
end

function GetDisplacement(destination)
  local turtlePos = vector.new(gps.locate(5))
  print("Location: " .. turtlePos.x .. ", " .. turtlePos.y .. ", " .. turtlePos.z)
  
  local displacement = destination - turtlePos
  print("Displacement: " .. displacement.x .. ", " .. displacement.y .. ", " .. displacement.z .. "\n")

  return displacement
end

function CheckFuel()
  local displacement = GetDisplacement(home)
  local displacementTotal = math.abs(displacement.x) + 
                            math.abs(displacement.y) + 
                            math.abs(displacement.z)

  local homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()

  if homeTravelCostPercent >= 0.90 then
    print("Fuel low. Must refuel.\n")
    return true
  end
  return false
end

function CheckShit()
  fullSlots = 0
	local search = 0
	for search = 16, 1, -1 do
		if turtle.getItemCount(search) > 0 then
			if tossShit == "yes" or tossShit == "y" or tossShit == "Y" then
				if turtle.getItemDetail().name == "minecraft:cobblestone" or
					 turtle.getItemDetail().name == "minecraft:stone" or
					 turtle.getItemDetail().name == "minecraft:dirt" or
					 turtle.getItemDetail().name == "minecraft:gravel" or
					 turtle.getItemDetail().name == "chisel:marble2" or
					 turtle.getItemDetail().name == "chisel:limestone2" or
					 turtle.getItemDetail().name == "minecraft:netherrack" or
					 turtle.getItemDetail().name == "natura:nether_tainted_soil" then
            turtle.select(search)
            turtle.drop()
				end
			end
    end
    
    itemCount = turtle.getItemCount(search)
		if itemCount > 0 then
			fullSlots = fullSlots + 1
		end
	end
	if fullSlots == 16 then
		return true
  end
  return false
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

io.write("Toss Shit Y/N? ")
tossShit = io.read()

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

Mine()