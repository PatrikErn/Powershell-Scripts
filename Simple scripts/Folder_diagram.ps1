# Documentation http://psgraph.readthedocs.io
# Module made by Kevin Marquette
######################################
#
# Script made by
# Patrik Ernholdt
# 
######################################
# Based upon the example script made by Kevin Marquette
# 
# Requires Module PSGraph
# https://github.com/KevinMarquette/PSGraph/tree/master/docs
#
# I wanted to experiment by giving certain files their own color to distinguish the filetypes.
# To customize , just edit the values in $color.
# This is a big help if you have a large diagram.



# Color values. Add or edit colors and filetypes.
$color = @{
'.dll' = 'blue'
'.xml' = 'green' 
'.txt' = 'red'
'.html' = 'cyan'
'.xlsm' = 'magenta'
}

$files = Get-ChildItem C:\Temp -Recurse

#Diagram
graph folders  @{rankdir='LR'} {
    #File nodes
    node @{shape='rect'}
    node $files -NodeScript {$_.fullname} @{label={$_.name};style='filled';fillcolor={$color[$_.extension]}} 
    #Folder nodes
    node $files.Where({$_.PSIsContainer}).FullName @{shape='folder';style='filled'; fillcolor='yellow'}
    edge $files -FromScript {split-path $_.fullname} -ToScript {$_.fullname}
} | Export-PSGraph -ShowGraph