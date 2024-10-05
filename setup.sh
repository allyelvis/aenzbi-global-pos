#!/bin/bash

# Global Variables
PROJECT_DIR="global_pos_system"
DB_NAME="pos_db"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"
DATABASE_DIR="$PROJECT_DIR/database"
MODULES_DIR="$PROJECT_DIR/modules"
CONFIG_DIR="$PROJECT_DIR/config"
DOCS_DIR="$PROJECT_DIR/docs"

# Function to create project structure
create_project_structure() {
  echo "Creating project directories..."
  mkdir -p $PROJECT_DIR $BACKEND_DIR $FRONTEND_DIR $DATABASE_DIR $MODULES_DIR $CONFIG_DIR $DOCS_DIR
  echo "Project structure created!"
}

# Function to initialize Git
initialize_git() {
  echo "Initializing Git repository..."
  cd $PROJECT_DIR || exit
  git init
  echo "Git repository initialized!"
}

# Function to create a simple README
create_readme() {
  echo "Creating README.md..."
  cat <<EOL > $PROJECT_DIR/README.md
# Global POS System

This is a global financial and hospitality POS system. The system is modular and supports features like:
- Multi-currency and multi-language support
- Inventory management
- Customer relationship management (CRM)
- Payment processing
- Employee management
- Dockerized deployment

## Project Structure

- backend/: Contains backend services
- frontend/: Contains frontend user interfaces
- database/: Database schemas and migration scripts
- modules/: Modular components (POS, Inventory, etc.)
- config/: Configuration files for the system
- docs/: Documentation for setup and usage
EOL
  echo "README.md created!"
}

# Function to initialize Backend with Docker support
initialize_backend() {
  echo "Setting up backend with Docker..."
  cd $BACKEND_DIR || exit
  npm init -y
  npm install express mongoose cors dotenv
  touch server.js .env Dockerfile docker-compose.yml

  # Express server configuration
  cat <<EOL > server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB');
}).catch(err => {
  console.error('Database connection error:', err);
});

app.get('/', (req, res) => {
  res.send('POS Backend Running');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});
EOL

  # Dockerfile setup for backend
  cat <<EOL > Dockerfile
# Use Node.js image
FROM node:14

# Set working directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy app files
COPY . .

# Expose port
EXPOSE 3000

# Start the app
CMD ["node", "server.js"]
EOL

  # Docker Compose file setup
  cat <<EOL > docker-compose.yml
version: '3'
services:
  backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - MONGO_URI=mongodb://db:27017/$DB_NAME
    depends_on:
      - db
  db:
    image: mongo
    ports:
      - "27017:27017"
    volumes:
      - ./database:/data/db
EOL

  echo "Backend initialized with Docker and Express.js!"
}

# Function to initialize Frontend
initialize_frontend() {
  echo "Setting up frontend..."
  cd $FRONTEND_DIR || exit
  npx create-react-app pos-frontend
  echo "Frontend initialized with React.js!"
}

# Function to set up Database (MongoDB)
setup_database() {
  echo "Setting up MongoDB database schema..."
  cd $DATABASE_DIR || exit
  cat <<EOL > pos_schema.js
const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  stock: { type: Number, required: true },
  category: { type: String, required: true }
});

const OrderSchema = new mongoose.Schema({
  customerName: { type: String, required: true },
  items: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
  totalAmount: { type: Number, required: true },
  paymentMethod: { type: String, required: true },
  orderDate: { type: Date, default: Date.now }
});

module.exports = {
  Product: mongoose.model('Product', ProductSchema),
  Order: mongoose.model('Order', OrderSchema)
};
EOL

  echo "Database schema created for MongoDB!"
}

# Function to add basic configuration
setup_config() {
  echo "Setting up configuration files..."
  cat <<EOL > $CONFIG_DIR/default_config.json
{
  "currency": "USD",
  "language": "en",
  "payment_methods": ["cash", "credit_card", "mobile_payment"],
  "tax_rate": 0.07
}
EOL

  echo "Configuration file created!"
}

# Function to create basic module stubs
create_modules() {
  echo "Setting up modules..."
  touch $MODULES_DIR/pos_module.js $MODULES_DIR/inventory_module.js $MODULES_DIR/crm_module.js

  cat <<EOL > $MODULES_DIR/pos_module.js
// POS module
exports.createOrder = (orderData) => {
  console.log("Creating order:", orderData);
};
EOL

  cat <<EOL > $MODULES_DIR/inventory_module.js
// Inventory module
exports.addProduct = (productData) => {
  console.log("Adding product:", productData);
};
EOL

  echo "Modules created!"
}

# Function to set up environment variables
setup_environment() {
  echo "Setting up environment variables..."
  echo "PORT=3000" > $BACKEND_DIR/.env
  echo "MONGO_URI=mongodb://db:27017/$DB_NAME" >> $BACKEND_DIR/.env
  echo "Environment variables set!"
}

# Function to build and run Docker containers
run_docker_containers() {
  echo "Building and starting Docker containers..."
  cd $BACKEND_DIR || exit
  docker-compose up --build -d
  echo "Docker containers are up and running!"
}

# Execute functions
create_project_structure
initialize_git
create_readme
initialize_backend
initialize_frontend
setup_database
setup_config
create_modules
setup_environment
run_docker_containers

echo "Global POS System initialized and running!"
