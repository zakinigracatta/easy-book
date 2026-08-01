const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, 'src', 'pages');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.jsx'));

files.forEach(file => {
  const filePath = path.join(dir, file);
  let content = fs.readFileSync(filePath, 'utf8');

  // Replace color: 'white' -> color: 'var(--text-light)'
  content = content.replace(/color:\s*['"]white['"]/g, "color: 'var(--text-light)'");
  
  // Replace color: '#fff' -> color: 'var(--text-light)'
  content = content.replace(/color:\s*['"]#fff['"]/g, "color: 'var(--text-light)'");

  // Replace background: '#fff' with var(--bg-card) mostly for buttons in glass panels
  // Let's just do text color for now
  
  fs.writeFileSync(filePath, content, 'utf8');
});

console.log('Fixed hardcoded colors!');
