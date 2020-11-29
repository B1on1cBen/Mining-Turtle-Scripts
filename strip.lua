function goToNewRow(x)
  if x % 2 == 0 then
    SetRotation(1)
    DigAndMove()
    SetRotation(0)
  else
    SetRotation(1)
    DigAndMove()
    SetRotation(2)
  end
end

function Mine()
  for y = 1, sizeY do
    SetRotation(0)
    DigAndMove()

    local yDerp = y - 1
    for i = 1, yDerp do
      turtle.digDown()
      turtle.down()
    end

    for x = 1, sizeX do
      for z = 1, sizeZ do
        DigAndMove()
        Info()
        CheckStatus()
      end
      
      if x < sizeX then
        goToNewRow(x)
      end
    end

    Go(home)
    Refuel()
    DumpShit()
  end
end

function CheckStatus()
  if IsLowOnFuel() == true or IsFullOfShit() == true then
    local resumePoint = vector.new(gps.locate(5))
    local resumeDirection = direction
    Go(home)
    Refuel()
    DumpShit()
    Resume(resumePoint, resumeDirection)
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
  displacement = GetDisplacement(destination)
  isHome = (destination.x == home.x and destination.y == home.y and destination.z == home.z)

  if(isHome == false) then
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
  end

  -- Up
  while displacement.y > 0 do
    turtle.up()
    displacement.y = displacement.y - 1
  end

  -- Down
  while displacement.y < 0 do
    turtle.down()
    displacement.y = displacement.y + 1
  end

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

  if(isHome == true) then
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
  end
end

function Refuel()
  if turtle.getFuelLevel() < turtle.getFuelLimit() then
    SetRotation(3)
    turtle.suck()
    turtle.select(1)
    turtle.refuel()
  end
end

function DumpShit()
  SetRotation(2)
  local search = 0
	for search = 16, 1, -1 do
		turtle.select(search)
		turtle.drop()
	end
end

function GetDisplacement(destination)
  local turtlePos = vector.new(gps.locate(5))
  local displacement = destination - turtlePos
  return displacement
end

function IsLowOnFuel()
  local displacement = GetDisplacement(home)
  local displacementTotal = math.abs(displacement.x) + 
                            math.abs(displacement.y) + 
                            math.abs(displacement.z)

  local homeTravelCostPercent = displacementTotal / turtle.getFuelLevel()

  if homeTravelCostPercent >= 0.90 then
    return true
  end
  return false
end

function IsFullOfShit()
  local fullSlots = 0
  for search = 16, 1, -1 do
		if turtle.getItemCount(search) > 0 then
			fullSlots = fullSlots + 1
		end
  end
  
	if fullSlots == 16 then
		return true
  end
  
  return false
end

function SetRotation(rotation)
  while direction ~= rotation do
      direction = (direction + 1) % 4
      turtle.turnRight()
  end
end

function Info()
  term.clear()
  term.setCursorPos(1,1)
  print("Fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())
end

-- STARTING POINT:
io.write("Size X: ")
sizeX = tonumber(io.read())

io.write("Size Z: ")
sizeZ = tonumber(io.read()) - 1

io.write("How many layers deep? ")
sizeY = tonumber(io.read())

-- io.write("Toss Shit Y/N? ")
-- tossShit = io.read()

--[[
  North - 0
  East - 1
  South - 2
  West - 3
]]
direction = 0;
home = vector.new(gps.locate(5))

Refuel()
Info()
Mine()