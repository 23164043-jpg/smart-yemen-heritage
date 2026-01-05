const express = require('express');
const dotenv = require('dotenv');
const morgan = require('morgan');
const cors = require('cors');
const connectDB = require('./config/db');
const aiRoutes = require("./ai/aiRoutes");

dotenv.config();
const app = express();

//Upload
app.use('/uploads', express.static('uploads'));
app.use('/api/upload', require('./routes/uploadRoutes'));

// middleware
app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(morgan('dev'));

// connect db
connectDB();

// routes
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/admins', require('./routes/adminRoutes'));
app.use('/api/content', require('./routes/contentRoutes'));
app.use('/api/content-details', require('./routes/contentDetailsRoutes'));
app.use('/api/services', require('./routes/serviceRoutes'));
app.use('/api/arview', require('./routes/arViewRoutes'));
app.use('/api/banner', require('./routes/bannerRoutes'));
app.use('/api/feedback', require('./routes/feedbackRoutes'));
app.use('/api/contenttypes', require('./routes/contentTypeRoutes'));
app.use('/api/notification', require('./routes/notificationRoutes'));
app.use("/api/ai", aiRoutes);

//  استدعاء swagger
const { swaggerUi, swaggerSpec } = require('./swagger');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// error handlers
app.use((req, res, next) => {
  res.status(404).json({ message: 'Route not found' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ message: err.message || 'Server Error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT} (listening on all interfaces)`));

