# Rename file naming for very basic files
#  1.mp4,  2.mp4, ...,  9.mp4, 10.mp4... to
# 01.mp4, 02.mp4, ..., 09.mp4, 10.mp4

# If you file names are more complex, add the part which leads up to the number
# between the ^ and \d, then the part after the number between \d and \.

# Currently only supports files numbered [0, 100)

# Made for the purpose of being able to go "mpv *" in a directory with lots of
# videos that one would want to watch back to back.

$cwd = Get-Location | Select -ExpandProperty Path

Get-ChildItem "$cwd" | 
Foreach-Object {
    $Path = $_.FullName
    $Name = $_.Name
    if ( $Name -match '^\d\.' ) {
        $NewName = "0" + "$Name"
        Rename-Item -Path $Path -NewName $NewName
    }
}