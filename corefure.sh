#!/bin/bash

# Script to automate core feature implementation for Global Financial POS system

# Set project directory
PROJECT_DIR=~/global-pos-system/nextjs-global-pos

# Function to create a new API endpoint
create_api_endpoint() {
  local endpoint_name=$1
  local file_path="$PROJECT_DIR/pages/api/$endpoint_name.js"

  echo "Creating API endpoint: $endpoint_name.js"
  cat <<EOF > "$file_path"
import pool from '../../lib/db';

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const { amount, currency } = req.body;

    try {
      const result = await pool.query(
        'INSERT INTO transactions (amount, currency, status) VALUES (\$1, \$2, \$3) RETURNING *',
        [amount, currency, 'pending']
      );

      res.status(200).json({ transaction: result.rows[0] });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}
EOF
}

# Function to create a database connection file
create_db_connection() {
  local file_path="$PROJECT_DIR/lib/db.js"

  echo "Creating database connection: db.js"
  cat <<EOF > "$file_path"
import { Pool } from 'pg';

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'pos_system',
  password: process.env.DB_PASS,
  port: process.env.DB_PORT || 5432,
});

export default pool;
EOF
}

# Function to create Stripe integration file
create_stripe_integration() {
  local file_path="$PROJECT_DIR/lib/stripe.js"

  echo "Creating Stripe integration: stripe.js"
  cat <<EOF > "$file_path"
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export default stripe;
EOF
}

# Function to create POS component
create_pos_component() {
  local file_path="$PROJECT_DIR/components/POS.js"

  echo "Creating POS component: POS.js"
  cat <<EOF > "$file_path"
import { useState } from 'react';
import axios from 'axios';

const POS = () => {
  const [amount, setAmount] = useState('');
  const [currency, setCurrency] = useState('usd');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('/api/transactions', { amount, currency });
      console.log('Transaction successful:', response.data);
    } catch (error) {
      console.error('Transaction failed:', error.response.data);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        required
      />
      <select value={currency} onChange={(e) => setCurrency(e.target.value)}>
        <option value="usd">USD</option>
        <option value="eur">EUR</option>
      </select>
      <button type="submit">Pay Now</button>
    </form>
  );
};

export default POS;
EOF
}

# Function to create initial styles
create_styles() {
  local file_path="$PROJECT_DIR/styles/globals.css"

  echo "Creating global styles: globals.css"
  cat <<EOF > "$file_path"
/* Global styles for the POS system */
body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 20px;
  background-color: #f5f5f5;
}

form {
  background-color: white;
  padding: 20px;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

input, select, button {
  margin: 10px 0;
}
EOF
}

# Function to create .env.example file
create_env_file() {
  local file_path="$PROJECT_DIR/.env.example"

  echo "Creating environment file: .env.example"
  cat <<EOF > "$file_path"
# Environment variables for the Global POS system
DB_USER=pos_user
DB_PASS=securepassword
DB_HOST=localhost
DB_NAME=pos_system
DB_PORT=5432
STRIPE_SECRET_KEY=your_stripe_secret_key
EOF
}

# Execute functions
create_db_connection
create_stripe_integration
create_api_endpoint "transactions"
create_pos_component
create_styles
create_env_file

echo "Core features implementation completed."
echo "Remember to update .env with your actual environment variables."
