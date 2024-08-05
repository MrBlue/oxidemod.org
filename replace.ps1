# Define the directory containing the files to be processed
$targetDirectory = "D:\oxidemod.org\oxidemod.org-jekyll"

# Define the subdirectories to ignore
$ignoredDirectories = @("_site")

# Function to replace sentinel and baseurl patterns
function Replace-SentinelAndBaseURL {
    param (
        [string]$content
    )

    # Use regex to match and replace the patterns
    $pattern1 = 'data-sentinel="\{\{sentinel\}\}"'
    $replacement1 = 'data-sentinel="{sentinel}"'
    $adjustedContent = $content -replace $pattern1, $replacement1

    $pattern2 = 'data-baseurl="[^"]*page-\{\{sentinel\}\}[^"]*"'
    $replacement2 = 'data-baseurl="page-{sentinel}"'
    $adjustedContent = $adjustedContent -replace $pattern2, $replacement2

    return $adjustedContent
}

# Function to read file content preserving the original encoding
function Get-FileContent {
    param (
        [string]$filePath
    )
    
    $streamReader = [System.IO.StreamReader]::new($filePath, [System.Text.Encoding]::UTF8, $true)
    $content = $streamReader.ReadToEnd()
    $encoding = $streamReader.CurrentEncoding
    $streamReader.Close()

    return [PSCustomObject]@{
        Content = $content
        Encoding = $encoding
    }
}

# Get all HTML files in the target directory and subdirectories, excluding ignored directories
$targetFiles = Get-ChildItem -Path $targetDirectory -Filter "*.html" -Recurse | Where-Object {
    $fullPath = $_.FullName
    $ignore = $false
    foreach ($ignoredDir in $ignoredDirectories) {
        if ($fullPath -like "*\$ignoredDir*") {
            $ignore = $true
            break
        }
    }
    -not $ignore
}

foreach ($file in $targetFiles) {
    # Load the content of the current target file while preserving its encoding
    $fileData = Get-FileContent -filePath $file.FullName
    $fileContent = $fileData.Content
    $fileEncoding = $fileData.Encoding

    # Replace the sentinel and baseurl patterns
    $adjustedContent = Replace-SentinelAndBaseURL -content $fileContent

    # Only write the new content back to the file if it has been modified
    if ($fileContent -ne $adjustedContent) {
        # Write the adjusted content back to the file with its original encoding
        [System.IO.File]::WriteAllText($file.FullName, $adjustedContent, $fileEncoding)
        Write-Output "Updated file: $($file.FullName)"
    }
}

Write-Output "Sentinel and baseurl replacement complete for all affected HTML files in $targetDirectory and subdirectories"
