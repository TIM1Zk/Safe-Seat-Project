const express = require('express');
const cors = require('cors');
require('dotenv').config();

const userRoutes = require('./routes/userRoutes');
const walletRoutes = require('./routes/walletRoutes');
const authRoutes = require('./routes/authRoutes');
const buddyRequestRoutes = require('./routes/buddyRequestRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/users', userRoutes);
app.use('/api/wallets', walletRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/buddy-team', buddyRequestRoutes);

app.get('/', (req, res) => {
  res.send('Backend API is running...');
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
