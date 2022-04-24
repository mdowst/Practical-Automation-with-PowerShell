# Listing 2 - New-WordTableFromArray
Function New-WordTableFromArray{
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]    
        [object]$object
    )

    # Get the name of the columns
    $columns = $object | Select-Object -First 1 | 
    Select-Object -Property @{l='Name';e={$_.psobject.Properties.Name}} | 
    Select-Object -ExpandProperty Name

    # Create the table
    $Table = $Selection.Tables.add(
    $Word.Selection.Range, 
    $Object.Count + 1, 
    $columns.Count, 
[Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior
    ,[Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent
    )

    # Set the table style
    $Table.Style = 'Grid Table 1 Light'
    
    # Add the header row
    for($c = 0; $c -lt $columns.Count; $c++){
        $Table.Cell(1,$c+1).Range.Text = $columns[$c]
    }

    # Loop through each item in the array row, adding the data to the correct row
    for($r = 0; $r -lt $object.Count; $r++){
        # Loop through each column, adding the data to the correct cell
        for($c = 0; $c -lt $columns.Count; $c++){
            $Table.Cell($r+2,$c+1).Range.Text = 
                $object[$r].psobject.Properties.Value[$c].ToString()
        }
    }

    # Add paragraph after the table
    $Word.Selection.Start= $Document.Content.End
    $Selection.TypeParagraph()
}
