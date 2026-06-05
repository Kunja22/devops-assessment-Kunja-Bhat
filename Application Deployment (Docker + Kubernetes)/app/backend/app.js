const express = require("express");
const app = express();

app.get("/", (req, res) => {
  console.log(JSON.stringify({
    level: "INFO",
    endpoint: "/",
    message: "Root API called"
  }));

  res.json({ message: "Backend Running" });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy"
  });
});

app.get("/metrics", (req, res) => {
  res.json({
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

app.listen(3000, () => {
  console.log(JSON.stringify({
    level: "INFO",
    message: "Backend Started"
  }));
});
