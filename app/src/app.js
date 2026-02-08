const express = require('express');
const AWS = require('aws-sdk');
const app = express();

const dynamodb = new AWS.DynamoDB.DocumentClient({ region: 'eu-north-1' });
const USERS_TABLE = process.env.USERS_TABLE || 'Users';
const TASKS_TABLE = process.env.TASKS_TABLE || 'Tasks';

app.use(express.json());

// Health check for ALB
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Create user
app.post('/users', async (req, res) => {
  const { userId, name, email } = req.body;
  
  const params = {
    TableName: USERS_TABLE,
    Item: { userId, name, email, createdAt: new Date().toISOString() }
  };

  try {
    await dynamodb.put(params).promise();
    res.status(201).json({ userId, name, email });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Could not create user' });
  }
});

app.get('/users/:userId', async (req, res) => {
  const params = {
    TableName: USERS_TABLE,
    Key: { userId: req.params.userId }
  };

  try {
    const result = await dynamodb.get(params).promise();
    if (result.Item) {
      res.json(result.Item);
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Could not retrieve user' });
  }
});

app.post('/tasks', async (req, res) => {
  const { taskId, userId, description } = req.body;
  
  const params = {
    TableName: TASKS_TABLE,
    Item: { 
      taskId, 
      userId, 
      description, 
      status: 'pending',
      createdAt: new Date().toISOString() 
    }
  };
    try {
    await dynamodb.put(params).promise();
    res.status(201).json({ taskId, userId, description, status: 'pending' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Could not create task' });
  }
});

app.get('/tasks/:taskId', async (req, res) => {
  const params = {
    TableName: TASKS_TABLE,
    Key: { taskId: req.params.taskId }
  };

  try {
    const result = await dynamodb.get(params).promise();
    if (result.Item) {
      res.json(result.Item);
    } else {
      res.status(404).json({ error: 'Task not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Could not retrieve task' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});