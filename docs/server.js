#!/usr/bin/env node

/**
 * Caixa Preta Local Development Server
 * Serves landing page, installer, and painel
 */

const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname)));

// CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// Session storage (in-memory for demo)
const sessions = new Map();

// Routes

// Main landing page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index-main.html'));
});

// Installer login page
app.get('/installer', (req, res) => {
    res.sendFile(path.join(__dirname, 'installer-login.html'));
});

// Installer access (with password check)
app.post('/api/installer/login', (req, res) => {
    const { password } = req.body;
    
    if (password === 'cxblack26') {
        const sessionId = Math.random().toString(36).substring(7);
        sessions.set(sessionId, { timestamp: Date.now() });
        res.json({ success: true, sessionId });
    } else {
        res.status(401).json({ success: false, error: 'Senha incorreta' });
    }
});

// Installer page (protected)
app.get('/installer/:sessionId', (req, res) => {
    const { sessionId } = req.params;
    
    if (!sessions.has(sessionId)) {
        return res.redirect('/installer');
    }
    
    res.sendFile(path.join(__dirname, 'clean-install.html'));
});

// Painel (protected)
app.get('/painel/:sessionId', (req, res) => {
    const { sessionId } = req.params;
    
    if (!sessions.has(sessionId)) {
        return res.redirect('/installer');
    }
    
    res.sendFile(path.join(__dirname, 'painel-admin.html'));
});

// API endpoints
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
    console.log(`
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║         🚀 CAIXA PRETA - LOCAL DEVELOPMENT SERVER         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

📍 Access Points:

  🏠 Landing Page:
     http://localhost:${PORT}

  🔐 Installer (Password Protected):
     http://localhost:${PORT}/installer
     Password: cxblack26

  🎛️  Admin Painel:
     http://localhost:${PORT}/painel (after login)

  ✅ Health Check:
     http://localhost:${PORT}/api/health

════════════════════════════════════════════════════════════

Press Ctrl+C to stop the server
    `);
});
