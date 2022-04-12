# Listing 4 - Running the oscdimg.exe
$filePath = ".\Chapter10\Helper Scripts\oscdimg.exe"
# Get the path to the etfsboot.com file
$Path = @{
	Path      = $ExtractTo
	ChildPath = 'boot\etfsboot.com'
}
# Get the path to the efisys.bin file
$etfsboot = Join-Path @Path
$Path = @{
	Path      = $ExtractTo
	ChildPath = 'efi\microsoft\boot\efisys.bin'
}
$efisys = Join-Path @Path
# Build an array with the arguments for the oscdimg.exe
$arguments = @(
    '-m'
    '-o'
    '-u2'
    '-udfver102'
    "-bootdata:2#p0,e,b$($etfsboot)#pEF,e,b$($efisys)"
    $ExtractTo
    $NewIsoPath
)

# execute the oscdimg.exe with the arguments using the call operator
& $filePath $arguments

