const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, 'src', 'pages');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.jsx'));

files.forEach(file => {
  const filePath = path.join(dir, file);
  let content = fs.readFileSync(filePath, 'utf8');

  // We are looking for lines that contain `background: 'var(--primary-color)'` and `color: 'var(--text-light)'`
  // or `color: '#000'` and replacing the color with `#ffffff`.
  // Since we replaced everything to `var(--text-light)`, let's fix that.
  
  content = content.replace(/(background:\s*['"]var\(--primary-color\)['"][^}]+color:\s*['"])var\(--text-light\)(['"])/g, "$1#ffffff$2");
  content = content.replace(/(color:\s*['"])var\(--text-light\)(['"][^}]+background:\s*['"]var\(--primary-color\)['"])/g, "$1#ffffff$2");

  fs.writeFileSync(filePath, content, 'utf8');
});

console.log('Fixed primary button text colors!');
