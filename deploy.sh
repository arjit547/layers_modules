#!/bin/bash

# Define GCP Project ID
PROJECT_ID="devops-459203"

# Define image tags and container name
latest_image_tag="gcr.io/$PROJECT_ID/reviewl:latest"
old_image_tag="gcr.io/$PROJECT_ID/reviewl:old_image" # Backup name for the previous latest image
#container_name="sweet_mcclintock"
container_name="priceless_wiles"

# Path to the Dockerfile
#dockerfile_path="/home/ubuntu/rattapi/fastapi/Dockerfile"

dockerfile_path="/home/faithproject424/cicd/Dockerfile"

# Change directory to where the Dockerfile is located
#cd /home/ubuntu/rattapi/fastapi || { echo "Directory not found!"; exit 1; }

cd /home/faithproject424/cicd || { echo "Directory not found!"; exit 1; }
pwd
ls -la

# Set 777 permissions for necessary files
#echo "Setting permissions for log files..."
#sudo chmod -R 777 /home/ubuntu/rattapi/fastapi/sentiment_app/*

# Run tests before deployment (optional)
# echo "Running tests..."
# pytest /home/ubuntu/rattapi/fastapi/sentiment_app/tests/
# if [ $? -ne 0 ]; then
#     echo "Tests failed. Aborting deployment."
#     exit 1
# fi
# echo "Tests passed successfully."

# Remove the previous 'old_image' backup if it exists
old_image_id=$(docker images -q $old_image_tag)
if [ ! -z "$old_image_id" ]; then
    echo "Removing the previous 'old_image' backup..."
    docker rmi $old_image_tag
else
    echo "No previous 'old_image' backup found."
fi

# Tag the current 'latest' image as 'old_image' if it exists
current_image_id=$(docker images -q $latest_image_tag)
if [ ! -z "$current_image_id" ]; then
    echo "Tagging the current 'latest' image as 'old_image'..."
    docker tag $current_image_id $old_image_tag
else
    echo "No 'latest' image found to tag as 'old_image'."
fi

# Build the new Docker image and tag it as 'latest'
echo "Building the new Docker image and tagging it as 'latest'..."
docker build -t $latest_image_tag -f $dockerfile_path .

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Docker image built successfully."

    # Check if the running container exists
    container_id=$(docker ps -q --filter "name=$container_name")

    if [ ! -z "$container_id" ]; then
        # Stop and remove the currently running container
        echo "Stopping and removing the currently running container..."
        docker stop $container_id
        docker rm $container_id
    else
        echo "No currently running container found. Skipping stop and removal."
    fi

    # Run the new 'latest' Docker image with the same container name
    echo "Running the new 'latest' Docker image with the container name '$container_name' on port 80..."
    #docker run -d -p 5051:5051 --name $container_name $latest_image_tag
    docker run -d -p 80:80 --name $container_name $latest_image_tag
    #docker run -d -p 5051:5051 \
        #-v /home/ubuntu/rattapi/fastapi/sentiment_app/conversation:/app/sentiment_app/conversation \
        #--name $container_name \
        #$latest_image_tag

    echo "Deployment completed successfully."
else
    echo "Docker build failed. Keeping the current container running."
    exit 1
fi
