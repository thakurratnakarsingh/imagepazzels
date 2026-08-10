const fs = require('fs');
const path = require('path');

async function testUpload() {
  try {
    const dummyPath = path.join(__dirname, 'dummy.jpg');
    fs.writeFileSync(dummyPath, 'dummy content');

    const form = new FormData();
    form.append('title', 'Test Splash');
    form.append('display_duration', '3000');
    
    // In Node 24, fetch natively supports FormData, but file handling requires Blob
    const fileBlob = new Blob([fs.readFileSync(dummyPath)], { type: 'image/jpeg' });
    form.append('image', fileBlob, 'dummy.jpg');

    console.log('Sending request...');
    const res = await fetch('http://127.0.0.1:5000/api/v1/admin/splashes', {
      method: 'POST',
      body: form
    });

    const data = await res.json();
    console.log('Response Status:', res.status);
    console.log('Response Data:', data);
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    try { fs.unlinkSync(path.join(__dirname, 'dummy.jpg')); } catch(e){}
  }
}

testUpload();
