# Periodically Delete Non-Release Tags

$tags = git tag --list

$workingTags = $tags | Where-Object { $_ -like "*working*" }

if ( 0 -lt $workingTags.count ) {
    $workingTags | ForEach-Object {
        git tag -d $_
    }
    $workingTags | ForEach-Object {
        git push origin --delete  $_
    }
}
