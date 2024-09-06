# Define variables
$sourceRegistry = "Your Source Registry example indiatesting.azurecr.io"
$destinationRegistry = "Your destination Registry example ustesting.azurecr.io"
$sourceResourceGroup = "Your source resource group name" 
$destinationResourceGroup = "Your Destination resource group name"

# Define repositories and their specific tags to copy
$repositoriesToCopy = @{
    "extra" = @("202400906.01", "20240906.02")
    "qat"   = @()
    "dev"   = @()
}

# Login to Azure
az login

# Login to source registry
$sourceLogin = az acr login --name indiatesting --output none

# Login to destination registry
$destinationLogin = az acr login --name ustesting --output none

# Loop through each repository to copy
foreach ($repo in $repositoriesToCopy.Keys) {
    # Check if the repository is "qat" or "dev" to get all tags
    if ($repo -eq "qat" -or $repo -eq "dev") {
        # Get all tags for the repository
        $tags = az acr repository show-tags --name indiatesting --repository $repo --output tsv
    } else {
        # Use specific tags for the "extra" repository
        $tags = $repositoriesToCopy[$repo]
    }

    # Loop through each specified tag and copy the image to the destination registry
    foreach ($tag in $tags) {
        # Define source and destination image names
        $sourceImage = "$sourceRegistry/${repo}:${tag}"
        $destinationImage = "$destinationRegistry/${repo}:${tag}"

        # Pull the image from the source registry
        docker pull $sourceImage

        # Tag the image for the destination registry
        docker tag $sourceImage $destinationImage

        # Push the image to the destination registry
        docker push $destinationImage

        # Optional: Remove the local image to save space
        docker rmi $sourceImage
        docker rmi $destinationImage
    }
}
