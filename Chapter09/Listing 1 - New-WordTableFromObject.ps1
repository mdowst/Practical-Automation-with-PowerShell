# Listing 1 - New-WordTableFromObject
Function New-WordTableFromObject {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]    
        [object]$object
    )
    
    # Get the properties of the object
    $Properties = @($object.psobject.Properties)
    
    # Create the table
    $Table = $Selection.Tables.add(
    $Word.Selection.Range, 
    $Properties.Count, 
    2, 
[Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior
    ,[Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent
    )

    # Loop through each property, adding it and the value to the table
    for ($r = 0; $r -lt $Properties.Count; $r++) {
        $Table.Cell($r + 1, 1).Range.Text = 
        $Properties[$r].Name.ToString()
        $Table.Cell($r + 1, 2).Range.Text = 
        $Properties[$r].Value.ToString()
    }

    # Add paragraph after the table
    $Word.Selection.Start = $Document.Content.End
    $Selection.TypeParagraph()
}
