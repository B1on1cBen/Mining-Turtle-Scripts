function WriteColoredText(text, color)
	term.setTextColor(color)
	io.write(text)
	term.setTextColor(colors.white)
end

function ListProgram(name, description)
	io.write(" ")
	WriteColoredText(name, colors.yellow)
	io.write(" - " .. description .. "\n")
end

function UpdateProgram(pastebinURL, name)
	fs.delete(name)
	shell.run("pastebin", "get", pastebinURL, name)
end

function UpdateAPI(pastebinURL, name)
	os.unloadAPI(name)
	UpdateProgram(pastebinURL, name)
	os.loadAPI(name)
end

UpdateAPI("yprrHtcW", "move")

UpdateProgram("LY9hpKka", "mine")
UpdateProgram("NueyacPA", "slurp")
UpdateProgram("70rSA8uG", "enderRefuel")

term.clear()
term.setCursorPos(1, 1)

io.write("Hello! I am ")
WriteColoredText(os.getComputerLabel() .. "!\n", colors.yellow)
io.write("My current fuel level is ")
WriteColoredText(turtle.getFuelLevel() .. "\n", colors.yellow)
io.write("\n")
io.write("Here are my installed programs:\n")
ListProgram("mine", "mine an area and return items")
ListProgram("slurp", "refuel from lava lake")
ListProgram("enderRefuel", "refuel with ender chests")
io.write("\n")
io.write("How may I be of service?\n")
