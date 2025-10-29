# Periodically Delete Non-Release Tags

$tags = git tag --list

$workingTags = $tags | Where-Object { $_ -like "*working*" -or $_ -like "*development*"-or $_ -like "*testing*"}

if ( 0 -le $workingTags.count ) {
    $workingTags | ForEach-Object {
        git tag -d $_
    }
    $workingTags | ForEach-Object {
        git push origin --delete  $_
    }
}
