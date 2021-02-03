$Listings = Get-ChildItem '.\Chapter2\' -Filter "Listing *"

foreach($file in $Listings){
    $file.FullName    
    $content = Get-Content $file.FullName
    $section = 'body'
    for($i = 0; $i -lt $content.Count; $i++){
        $line = $content[$i]
        if($line -like '#A *'){
            $section = 'notes'
        }
        if($i -eq 0){
            if($line.Replace('# ','') -ne $file.BaseName){
                "Bad Name $($line.Replace('# ','')) -ne $($file.BaseName)"
            }
        }
        elseif($i -gt 0 -and $section -eq 'body'){
            if($line -like '*    #*' -and $line.Length -gt 61){
                "Line $i : To long for annotated line"
            }
            elseif($line.Length -gt 76){
                "Line $i : To long for regular line"
            }
        }
        elseif($section -eq 'notes' -and $line -notmatch '^#[A-Z]') {
            "Line $i : Bad annotation"
        }
    }
}