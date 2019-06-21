Import-Module -Name PoshSemanticVersion

cd $PSScriptRoot

$last = git tag |
  % {New-SemanticVersion $_} |
  Sort-Object -Descending -Property Major,Minor,Patch,@{e = {$_.PreRelease -eq ''}; Ascending = $true},@{e = {if ($_.PreRelease -eq $null) {''} else {$_.PreRelease}}},@{e = {if ($_.Build -eq $null) {''} else {$_.Build}}} |
  Select-Object -First 1

$new = if ($null -eq $last) {New-SemanticVersion "0.0.1"} else {$last.Patch += 1; $last}

git tag -a $new.ToString() -m "Release $($new.ToString())"
git push --tags origin master
