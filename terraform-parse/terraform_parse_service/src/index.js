const express = require('express');
const fs = require('fs');
const path = require('path');
const renderer = require('./renderer');

const app = express();
app.use(express.json());

app.post('/render', (req, res) => {
  const body = req.body;
  if (!body || !body.payload || !body.payload.properties) {
    return res.status(400).json({ error: 'Invalid body. Expected { payload: { properties: {...} } }' });
  }

  try {
    const tf = renderer.renderTerraform(body.payload.properties);
    res.setHeader('Content-Type', 'text/plain');
    res.setHeader('X-Filename', 's3_bucket.tf');
    return res.send(tf);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
});

// Render and write the resulting terraform file into the repo `terraform/` folder
app.post('/render_and_write', (req, res) => {
  const body = req.body;
  if (!body || !body.payload || !body.payload.properties) {
    return res.status(400).json({ error: 'Invalid body. Expected { payload: { properties: {...} } }' });
  }

  try {
    const tf = renderer.renderTerraform(body.payload.properties);

    // Resolve a path to the repository terraform folder (two levels up from src)
    const outPath = path.resolve(__dirname, '..', '..', 'terraform', 's3_bucket.tf');

    // Ensure the terraform directory exists
    const outDir = path.dirname(outPath);
    if (!fs.existsSync(outDir)) {
      fs.mkdirSync(outDir, { recursive: true });
    }

    fs.writeFileSync(outPath, tf, { encoding: 'utf8' });

    return res.json({ written: outPath });
  } catch (err) {
    console.error('render_and_write error', err);
    return res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`terraform_parse_service listening on ${PORT}`));
