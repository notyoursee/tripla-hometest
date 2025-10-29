const renderer = require('./src/renderer');

const sample = {
  'aws-region': 'eu-west-1',
  acl: 'private',
  'bucket-name': 'tripla-bucket'
};

try {
  const tf = renderer.renderTerraform(sample);
  console.log('--- Generated terraform ---');
  console.log(tf);
} catch (err) {
  console.error('Render failed:', err.message);
  process.exit(1);
}
