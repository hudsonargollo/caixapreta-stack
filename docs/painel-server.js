#!/usr/bin/env node

/**
 * Caixa Preta Admin Painel Server
 * Serves the admin dashboard and provides API endpoints for system monitoring
 */

const express = require('express');
const { exec } = require('child_process');
const { promisify } = require('util');
const path = require('path');
const os = require('os');

const execAsync = promisify(exec);
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// Routes

// Serve dashboard
app.get('/painel', (req, res) => {
    res.sendFile(path.join(__dirname, 'painel-admin.html'));
});

// API: Get all services status
app.get('/api/services', async (req, res) => {
    try {
        const { stdout } = await execAsync('docker service ls --format "{{.Name}}|{{.Mode}}|{{.Replicas}}|{{.Image}}"');
        const services = stdout.trim().split('\n').map(line => {
            const [name, mode, replicas, image] = line.split('|');
            return { name, mode, replicas, image };
        });
        res.json(services);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Get service logs
app.get('/api/logs/:service', async (req, res) => {
    try {
        const { stdout } = await execAsync(`docker service logs ${req.params.service} --tail 50 2>&1`);
        res.json({ logs: stdout });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Get system stats
app.get('/api/stats', async (req, res) => {
    try {
        const cpus = os.cpus();
        const totalMemory = os.totalmem();
        const freeMemory = os.freemem();
        const usedMemory = totalMemory - freeMemory;

        const { stdout: diskOutput } = await execAsync('df -h / | tail -1');
        const diskParts = diskOutput.trim().split(/\s+/);
        const diskUsed = diskParts[2];
        const diskTotal = diskParts[1];
        const diskPercent = diskParts[4];

        const { stdout: uptimeOutput } = await execAsync('uptime -p');

        res.json({
            cpu: {
                cores: cpus.length,
                usage: Math.round((1 - os.loadavg()[0] / cpus.length) * 100)
            },
            memory: {
                total: Math.round(totalMemory / 1024 / 1024 / 1024),
                used: Math.round(usedMemory / 1024 / 1024 / 1024),
                percent: Math.round((usedMemory / totalMemory) * 100)
            },
            disk: {
                used: diskUsed,
                total: diskTotal,
                percent: diskPercent
            },
            uptime: uptimeOutput.trim()
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Restart service
app.post('/api/services/:service/restart', async (req, res) => {
    try {
        await execAsync(`docker service update --force ${req.params.service}`);
        res.json({ success: true, message: `Service ${req.params.service} restarted` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Get service details
app.get('/api/services/:service', async (req, res) => {
    try {
        const { stdout } = await execAsync(`docker service inspect ${req.params.service}`);
        const details = JSON.parse(stdout)[0];
        res.json(details);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Health check
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
    console.log(`Caixa Preta Admin Painel running on port ${PORT}`);
    console.log(`Access at: http://localhost:${PORT}/painel`);
});
