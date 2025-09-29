#!/bin/bash

# Script Vars
TOI_REPO_URL="https://github.com/pybern/selfhost.git"
TOI_APP_DIR=~/toiapp

# Pull the latest changes from the Git repository
if [ -d "$TOI_APP_DIR" ]; then
  echo "Pulling latest changes from the repository..."
  cd $TOI_APP_DIR
  git pull origin main
else
  echo "Cloning repository from $TOI_REPO_URL..."
  git clone $TOI_REPO_URL $TOI_APP_DIR
  cd $TOI_APP_DIR
fi

# Build and restart the Docker containers from the app directory (~/toiapp)
echo "Rebuilding and restarting Docker containers..."
sudo docker-compose down
sudo docker-compose up --build -d

# Check if Docker Compose started correctly
if ! sudo docker-compose ps | grep "Up"; then
  echo "Docker containers failed to start. Check logs with 'docker-compose logs'."
  exit 1
fi

# Output final message
echo "Update complete. Your Next.js app has been deployed with the latest changes."

