turtle.digUp() -- Make sure there is no block above turtle

while turtle.getFuelLevel() < 1000000 do
    turtle.select(2) -- Select green chest in slot 2
    turtle.placeUp() -- Place green chest
    turtle.suckUp(1) -- Take full bucket from green chest (bucket goes into first empty slot, aka slot 2)
    turtle.digUp() -- Take green chest (goes into slot 3)

    turtle.refuel() -- Convert that lava bucket to an empty bucket and absorb its power!

    turtle.select(1) -- Select red chest in slot 1
    turtle.placeUp() -- Place red chest
    turtle.select(2) -- Select empty bucket in slot 2
    turtle.dropUp() -- Place empty bucket in red chest

    turtle.select(1) -- Select empty slot 1
    turtle.digUp() -- Take red chest (goes into slot 1 because we selected it and the slot is available)
    turtle.select(3) -- Select green chest in slot 3
    turtle.transferTo(2) -- Move green chest to slot 2

    -- Clear console and write out fuel level
    term.clear()
    term.setCursorPos(1, 1)
    io.write("Fuel level: " .. turtle.getFuelLevel() .. "/1000000")
end