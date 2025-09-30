# 🌐 Web Deployment Guide

This guide covers deploying the Hipster Video Call Flutter web app to various hosting platforms.

## 📋 Prerequisites

1. **Build the Web App**
   ```bash
   flutter build web --release
   ```

2. **Verify Build Output**
   - Check that `build/web` folder contains all necessary files
   - Ensure `index.html`, `main.dart.js`, and assets are present

## 🚀 Deployment Options

### 1. Firebase Hosting (Recommended)

Firebase Hosting provides excellent performance and HTTPS by default.

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init hosting

# Deploy
firebase deploy
```

**Firebase Configuration (`firebase.json`):**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Permissions-Policy",
            "value": "camera=*, microphone=*, display-capture=*"
          }
        ]
      }
    ]
  }
}
```

### 2. Netlify

Simple drag-and-drop deployment with automatic HTTPS.

1. Go to [netlify.com](https://netlify.com)
2. Drag the `build/web` folder to the deploy area
3. Configure custom domain if needed

**Netlify Configuration (`netlify.toml`):**
```toml
[build]
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    Permissions-Policy = "camera=*, microphone=*, display-capture=*"
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
```

### 3. Vercel

GitHub integration with automatic deployments.

1. Connect your GitHub repository to Vercel
2. Set build command: `flutter build web --release`
3. Set output directory: `build/web`

**Vercel Configuration (`vercel.json`):**
```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Permissions-Policy",
          "value": "camera=*, microphone=*, display-capture=*"
        }
      ]
    }
  ]
}
```

### 4. GitHub Pages

Free hosting for public repositories.

1. Build the web app: `flutter build web --release`
2. Copy contents of `build/web` to `docs` folder or `gh-pages` branch
3. Enable GitHub Pages in repository settings

### 5. Custom Web Server

For deployment to your own server:

1. Upload `build/web` contents to your web server
2. Configure web server for SPA routing
3. Ensure HTTPS is enabled

**Apache Configuration (`.htaccess`):**
```apache
RewriteEngine On
RewriteBase /

# Handle Angular and other SPA routing
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]

# Security headers
Header always set Permissions-Policy "camera=*, microphone=*, display-capture=*"
Header always set X-Frame-Options "DENY"
Header always set X-Content-Type-Options "nosniff"
```

**Nginx Configuration:**
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    root /path/to/build/web;
    index index.html;
    
    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Security headers
    add_header Permissions-Policy "camera=*, microphone=*, display-capture=*";
    add_header X-Frame-Options "DENY";
    add_header X-Content-Type-Options "nosniff";
    
    # SSL configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
}
```

## 🔒 Security Considerations

### HTTPS Requirement
WebRTC requires HTTPS for camera and microphone access. Ensure your deployment uses HTTPS.

### CORS Configuration
If your API is on a different domain, configure CORS headers:

```javascript
// Express.js example
app.use(cors({
  origin: ['https://your-app-domain.com'],
  credentials: true
}));
```

### Content Security Policy
Add CSP headers for enhanced security:

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' https://download.agora.io; 
               connect-src 'self' https://reqres.in https://*.agora.io wss://*.agora.io; 
               media-src 'self' blob:; 
               img-src 'self' data: https:;">
```

## 🧪 Testing Web Deployment

### Local Testing
```bash
# Serve the built web app locally
cd build/web
python -m http.server 8000
# or
npx serve -s . -l 8000
```

### Browser Compatibility Testing
Test on multiple browsers:
- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge

### Mobile Browser Testing
Test responsive design on mobile browsers:
- Chrome Mobile
- Safari Mobile
- Firefox Mobile

## 📊 Performance Optimization

### Enable Compression
Configure gzip/brotli compression on your server:

```nginx
# Nginx gzip configuration
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

### CDN Configuration
Use a CDN for better global performance:
- Cloudflare
- AWS CloudFront
- Google Cloud CDN

### Caching Strategy
Configure appropriate cache headers:

```nginx
# Cache static assets
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Don't cache HTML
location ~* \.html$ {
    expires -1;
    add_header Cache-Control "no-cache, no-store, must-revalidate";
}
```

## 🔧 Troubleshooting

### Common Issues

1. **White Screen on Load**
   - Check browser console for errors
   - Verify all assets are loading correctly
   - Ensure proper base href configuration

2. **Camera/Microphone Not Working**
   - Verify HTTPS deployment
   - Check browser permissions
   - Test on different browsers

3. **Routing Issues**
   - Configure server for SPA routing
   - Check that all routes redirect to index.html

4. **API CORS Errors**
   - Configure CORS on your API server
   - Check API endpoints are accessible

### Debug Mode
For debugging, build with:
```bash
flutter build web --debug
```

## 📈 Monitoring

### Analytics
Add web analytics to track usage:
- Google Analytics
- Firebase Analytics
- Custom analytics

### Error Monitoring
Implement error tracking:
- Sentry
- LogRocket
- Custom error reporting

---

**🎉 Your Flutter video calling app is now ready for web deployment!**
