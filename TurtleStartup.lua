local sPath = ".:/rom/programs"
if turtle then
	sPath = sPath..":/rom/programs/turtle"
else
	sPath = sPath..":/rom/programs/computer"
end
if http then
	sPath = sPath..":/rom/programs/http"
end
if term.isColor() then
	sPath = sPath..":/rom/programs/color"
end

shell.setPath( sPath )
help.setPath( "/rom/help" )

shell.setAlias( "ls", "list" )
shell.setAlias( "dir", "list" )
shell.setAlias( "cp", "copy" )
shell.setAlias( "mv", "move" )
shell.setAlias( "rm", "delete" )
shell.setAlias( "preview", "edit" )

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

function UpdatePrograms()
	fs.delete("slurp")
	fs.delete("mine")
	
	shell.run("pastebin", "get", "LY9hpKka", "mine")
	shell.run("pastebin", "get", "NueyacPA", "slurp")
	
	term.clear()
	term.setCursorPos(1, 1)
end

UpdatePrograms()

io.write("Hello! I am " .. os.getComputerLabel() .. "!\n")
io.write("My current fuel level is ")
WriteColoredText(turtle.getFuelLevel() .. "\n", colors.yellow)
io.write("\n")
io.write("Here are my installed programs:\n")
ListProgram("mine", "mine an area and return items")
ListProgram("slurp", "refuel from lava lake")
io.write("\n")
io.write("How may I be of service?\n")

if fs.exists( "/rom/autorun" ) and fs.isDir( "/rom/autorun" ) then
	local tFiles = fs.list( "/rom/autorun" )
	table.sort( tFiles )
	for n, sFile in ipairs( tFiles ) do
		if string.sub( sFile, 1, 1 ) ~= "." then
			local sPath = "/rom/autorun/"..sFile
			if not fs.isDir( sPath ) then
				shell.run( sPath )
			end
		end
	end
end