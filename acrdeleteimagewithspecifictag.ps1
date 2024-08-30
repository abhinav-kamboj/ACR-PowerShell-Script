# Poswershell script to delete images with specific tag from specific repository.

$ResourceGroup = "learn101" # your resource group name
$AcrName = "uslearntesting" # your ACR name
$Repositories = @("newqat", "dev") # add repo name from which you want to delete image.
$TagsToDelete = @("20240821.10", "20240821.13") # add more tags which you want to delete.

# Loop through each repository
foreach ($RepoName in $Repositories) {
    Write-Output "Processing repository: $RepoName"

    # Loop through each tag to delete
    foreach ($TagToDelete in $TagsToDelete) {
        Write-Output "Checking for tag: $TagToDelete in repository: $RepoName"

        # List tags in the repository and check for the specified tag
        $ImageTags = az acr repository show-tags --name $AcrName --repository $RepoName --output tsv

        if ($ImageTags -contains $TagToDelete) {
            # output to show which image will be delete from which repository
            Write-Output "Deleting image with tag: $TagToDelete in repository: $RepoName"
            # adding pause of 10 second in case you entered wrong tag and want to abort the process before starting delete process.
            Start-Sleep -Seconds 10 
            
            Write-Output "Starting delete process for image with tag: $TagToDelete in repository: $RepoName"

            # Delete the image tag
            
            az acr repository delete --name $AcrName --image ${RepoName}:${TagToDelete} --yes
            Write-Output "Deleted image with tag: $TagToDelete from repository: $RepoName"
        } else {
            Write-Output "Tag: $TagToDelete not found in repository: $RepoName"
        }
    }
}

Write-Output "Image deletion process completed."
