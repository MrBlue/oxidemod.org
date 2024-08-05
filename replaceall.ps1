# Define the start directory
$startDirectory = "D:\oxidemod.org\oxidemod.org-jekyll"

# Function to replace the class attribute in an HTML file
function Replace-ClassAttribute {
    param (
        [string]$filePath
    )
    
    try {
        $content = Get-Content -Path $filePath -Raw -Encoding UTF8
        
        # Replace class attribute
        $newContent = $content -replace 'page-{{sentinel}}"', 'page-{%raw%}{{sentinel}}{%endraw%}"'
        
        if ($newContent -ne $content) {
            Set-Content -Path $filePath -Value $newContent -Force -Encoding UTF8 -NoNewline
            Write-Host "Class attribute updated in $filePath"
        } else {
            Write-Host "No changes made to $filePath"
        }
    } catch {
        Write-Host "Error processing ${filePath}: $_"
    }
}

# Function to recursively process the directory
function Process-Directory {
    param (
        [string]$directory
    )
    
    Get-ChildItem -Path $directory -Recurse -File -Filter *.html | ForEach-Object {
        Replace-ClassAttribute -filePath $_.FullName
    }
}

# Start processing from the start directory
Process-Directory -directory $startDirectory
