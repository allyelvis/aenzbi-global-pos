#!/bin/bash

# Script to set up Global Financial POS system with Next.js

# Update system and install dependencies
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
sudo apt-get install -y docker.io docker-compose

# Install Nix (optional for reproducibility)
echo "Installing Nix..."
curl -L https://nixos.org/nix/install | sh

# Create project directory
echo "Creating project directory..."
mkdir -p ~/global-pos-system
cd ~/global-pos-system

# Clone POS repository from GitHub (replace with your actual repository)
echo "Cloning POS repository..."
git clone https://github.com/username/nextjs-global-pos.git
cd nextjs-global-pos

# Install project dependencies
echo "Installing project dependencies..."
npm install

# Set up Docker environment for the project
echo "Setting up Docker environment..."
docker-compose up -d

# Set up PostgreSQL Database
echo "Setting up PostgreSQL database..."
sudo -u postgres psql -c "CREATE DATABASE pos_system;"
sudo -u postgres psql -c "CREATE USER pos_user WITH PASSWORD 'securepassword';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE pos_system TO pos_user;"

# Configure environment variables
echo "Creating environment file..."
cp .env.example .env
sed -i 's/DB_USER=pos_user/DB_USER=pos_user/' .env
sed -i 's/DB_PASS=your_password/DB_PASS=securepassword/' .env

# Start the development environment
echo "Starting Next.js development environment..."
npm run dev

echo "Global Financial POS system setup completed."
