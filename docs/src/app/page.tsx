'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Lock, Unlock, Server, Database, Shield, Zap, CheckCircle, AlertTriangle, Terminal, Globe, Settings, Monitor } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion'

const PASSWORD = 'caixapretastack2626'

export default function InstallGuide() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (password === PASSWORD) {
      setIsAuthenticated(true)
      setError('')
    } else {
      setError('Senha incorreta. Verifique suas credenciais.')
      setPassword('')
    }
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-md"
        >
          <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
            <CardHeader className="text-center">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2 }}
                className="mx-auto mb-4 w-16 h-16 bg-purple-600 rounded-full flex items-center justify-center"
              >
                <Lock className="w-8 h-8 text-white" />
              </motion.div>
              <CardTitle className="text-2xl font-bold text-white">CaixaPreta Stack</CardTitle>
              <CardDescription className="text-purple-200">
                Guia de Instalação Exclusivo
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleLogin} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="password" className="text-purple-200">Senha de Acesso</Label>
                  <Input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Digite a senha fornecida"
                    className="bg-slate-700 border-purple-500/30 text-white placeholder:text-slate-400"
                  />
                </div>
                {error && (
                  <motion.p
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="text-red-400 text-sm"
                  >
                    {error}
                  </motion.p>
                )}
                <Button type="submit" className="w-full bg-purple-600 hover:bg-purple-700">
                  <Unlock className="w-4 h-4 mr-2" />
                  Acessar Guia
                </Button>
              </form>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div className="container mx-auto px-4 py-8">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <div className="flex items-center justify-center mb-6">
            <motion.div
              initial={{ rotate: -180 }}
              animate={{ rotate: 0 }}
              transition={{ duration: 0.8 }}
              className="w-20 h-20 bg-gradient-to-r from-purple-600 to-pink-600 rounded-full flex items-center justify-center mr-4"
            >
              <Server className="w-10 h-10 text-white" />
            </motion.div>
            <div>
              <h1 className="text-4xl font-bold text-white mb-2">CaixaPreta Stack</h1>
              <p className="text-purple-200 text-lg">Guia Completo de Instalação e Configuração</p>
            </div>
          </div>
        </motion.div>
        <Tabs defaultValue="overview" className="w-full">
          <TabsList className="grid w-full grid-cols-4 bg-slate-800/50 border-purple-500/20">
            <TabsTrigger value="overview" className="data-[state=active]:bg-purple-600">Visão Geral</TabsTrigger>
            <TabsTrigger value="installation" className="data-[state=active]:bg-purple-600">Instalação</TabsTrigger>
            <TabsTrigger value="configuration" className="data-[state=active]:bg-purple-600">Configuração</TabsTrigger>
            <TabsTrigger value="troubleshooting" className="data-[state=active]:bg-purple-600">Suporte</TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="mt-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
              {[
                { icon: Zap, title: 'n8n Automação', desc: 'Workflows poderosos em modo queue', color: 'from-yellow-500 to-orange-500' },
                { icon: Database, title: 'MEGA Chatwoot V4', desc: 'Atendimento multicanal profissional', color: 'from-blue-500 to-cyan-500' },
                { icon: Shield, title: 'Evolution API', desc: 'WhatsApp Business integrado', color: 'from-green-500 to-emerald-500' },
                { icon: Globe, title: 'Traefik + SSL', desc: 'Proxy reverso com certificados automáticos', color: 'from-purple-500 to-pink-500' },
                { icon: Monitor, title: 'Grafana', desc: 'Dashboards e monitoramento completo', color: 'from-red-500 to-rose-500' },
                { icon: Settings, title: 'Docker Swarm', desc: 'Orquestração profissional de containers', color: 'from-indigo-500 to-blue-500' }
              ].map((service, index) => (
                <motion.div
                  key={service.title}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm hover:bg-slate-800/70 transition-all">
                    <CardHeader>
                      <div className={`w-12 h-12 rounded-lg bg-gradient-to-r ${service.color} flex items-center justify-center mb-3`}>
                        <service.icon className="w-6 h-6 text-white" />
                      </div>
                      <CardTitle className="text-white">{service.title}</CardTitle>
                      <CardDescription className="text-purple-200">{service.desc}</CardDescription>
                    </CardHeader>
                  </Card>
                </motion.div>
              ))}
            </div>

            <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="text-white flex items-center">
                  <AlertTriangle className="w-5 h-5 mr-2 text-yellow-500" />
                  Requisitos do Servidor
                </CardTitle>
              </CardHeader>
              <CardContent className="text-purple-200">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="font-semibold text-white mb-2">Mínimo Recomendado:</h4>
                    <ul className="space-y-1 text-sm">
                      <li>• CPU: 2 vCores</li>
                      <li>• RAM: 4GB</li>
                      <li>• Storage: 40GB SSD</li>
                      <li>• OS: Ubuntu 20.04+ ou Debian 11+</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-white mb-2">Para Produção:</h4>
                    <ul className="space-y-1 text-sm">
                      <li>• CPU: 4+ vCores</li>
                      <li>• RAM: 8GB+</li>
                      <li>• Storage: 100GB+ SSD</li>
                      <li>• Backup: Configuração automática</li>
                    </ul>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
          <TabsContent value="installation" className="mt-8">
            <div className="space-y-6">
              <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white flex items-center">
                    <Terminal className="w-5 h-5 mr-2 text-green-500" />
                    Instalação Rápida (5 Minutos)
                  </CardTitle>
                  <CardDescription className="text-purple-200">
                    Siga os passos abaixo para instalar sua stack completa
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="space-y-4">
                    {[
                      {
                        step: 1,
                        title: 'Conecte no seu servidor',
                        content: 'Acesse seu VPS via SSH como usuário root',
                        code: 'ssh root@SEU_IP_DO_SERVIDOR'
                      },
                      {
                        step: 2,
                        title: 'Baixe o script de instalação',
                        content: 'Execute os comandos abaixo para baixar e preparar o script',
                        code: `wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/caixapreta-stack.sh
chmod +x caixapreta-stack.sh`
                      },
                      {
                        step: 3,
                        title: 'Execute a instalação',
                        content: 'Inicie o processo automatizado',
                        code: 'sudo ./caixapreta-stack.sh'
                      },
                      {
                        step: 4,
                        title: 'Configure os dados solicitados',
                        content: 'O script pedirá duas informações importantes:',
                        details: [
                          'Seu domínio principal (ex: meusite.com)',
                          'Seu e-mail para certificados SSL'
                        ]
                      },
                      {
                        step: 5,
                        title: 'Configure DNS',
                        content: 'Aponte os subdomínios para o IP do seu servidor:',
                        details: [
                          'n8n.seudominio.com',
                          'mega.seudominio.com', 
                          'evolution.seudominio.com',
                          'portainer.seudominio.com',
                          'traefik.seudominio.com',
                          'minio.seudominio.com',
                          'grafana.seudominio.com'
                        ]
                      }
                    ].map((step, index) => (
                      <motion.div
                        key={step.step}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.1 }}
                        className="border border-purple-500/20 rounded-lg p-4 bg-slate-700/30"
                      >
                        <div className="flex items-start space-x-4">
                          <div className="w-8 h-8 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold text-sm">
                            {step.step}
                          </div>
                          <div className="flex-1">
                            <h4 className="font-semibold text-white mb-2">{step.title}</h4>
                            <p className="text-purple-200 text-sm mb-3">{step.content}</p>
                            {step.code && (
                              <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 overflow-x-auto">
                                <pre>{step.code}</pre>
                              </div>
                            )}
                            {step.details && (
                              <ul className="space-y-1 text-sm text-purple-200 mt-2">
                                {step.details.map((detail, i) => (
                                  <li key={i}>• {detail}</li>
                                ))}
                              </ul>
                            )}
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
          <TabsContent value="configuration" className="mt-8">
            <div className="space-y-6">
              <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white">Acessos e Credenciais</CardTitle>
                  <CardDescription className="text-purple-200">
                    URLs de acesso e credenciais padrão do sistema
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {[
                      { service: 'n8n Automação', url: 'n8n.seudominio.com', desc: 'Plataforma de workflows' },
                      { service: 'MEGA Chatwoot', url: 'mega.seudominio.com', desc: 'Sistema de atendimento' },
                      { service: 'Evolution API', url: 'evolution.seudominio.com', desc: 'API do WhatsApp' },
                      { service: 'Portainer', url: 'portainer.seudominio.com', desc: 'Gerenciamento Docker' },
                      { service: 'Traefik Dashboard', url: 'traefik.seudominio.com', desc: 'Proxy reverso' },
                      { service: 'MinIO Console', url: 'minio.seudominio.com', desc: 'Armazenamento S3' },
                      { service: 'Grafana', url: 'grafana.seudominio.com', desc: 'Monitoramento' }
                    ].map((item, index) => (
                      <motion.div
                        key={item.service}
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ delay: index * 0.05 }}
                        className="border border-purple-500/20 rounded-lg p-4 bg-slate-700/30"
                      >
                        <h4 className="font-semibold text-white">{item.service}</h4>
                        <p className="text-purple-200 text-sm mb-2">{item.desc}</p>
                        <code className="text-green-400 text-sm bg-slate-900 px-2 py-1 rounded">
                          https://{item.url}
                        </code>
                      </motion.div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              <Card className="border-red-500/20 bg-red-900/20 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white flex items-center">
                    <AlertTriangle className="w-5 h-5 mr-2 text-red-500" />
                    Credenciais Padrão - ALTERE IMEDIATAMENTE
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="border border-red-500/20 rounded p-3">
                      <h4 className="font-semibold text-white mb-2">PostgreSQL</h4>
                      <p className="text-sm text-red-200">Usuário: <code>postgres</code></p>
                      <p className="text-sm text-red-200">Senha: <code>caixapretastack2626</code></p>
                    </div>
                    <div className="border border-red-500/20 rounded p-3">
                      <h4 className="font-semibold text-white mb-2">MinIO S3</h4>
                      <p className="text-sm text-red-200">Usuário: <code>admin</code></p>
                      <p className="text-sm text-red-200">Senha: <code>caixapretastack2626</code></p>
                    </div>
                    <div className="border border-red-500/20 rounded p-3">
                      <h4 className="font-semibold text-white mb-2">Evolution API</h4>
                      <p className="text-sm text-red-200">API Key: <code>caixapretastack2626</code></p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white">Pós-Instalação Obrigatório</CardTitle>
                </CardHeader>
                <CardContent>
                  <Accordion type="single" collapsible className="w-full">
                    <AccordionItem value="security">
                      <AccordionTrigger className="text-white">1. Configurações de Segurança</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p>• Altere TODAS as senhas padrão imediatamente</p>
                        <p>• Configure firewall UFW (já instalado)</p>
                        <p>• Ative autenticação de dois fatores onde possível</p>
                        <p>• Configure backups automáticos dos dados</p>
                      </AccordionContent>
                    </AccordionItem>
                    <AccordionItem value="monitoring">
                      <AccordionTrigger className="text-white">2. Monitoramento</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p>• Acesse Grafana e configure alertas</p>
                        <p>• Monitore uso de CPU, RAM e disco</p>
                        <p>• Configure notificações por email/Slack</p>
                        <p>• Verifique logs regularmente via Portainer</p>
                      </AccordionContent>
                    </AccordionItem>
                    <AccordionItem value="backup">
                      <AccordionTrigger className="text-white">3. Backup e Recuperação</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p>• Configure backup automático do PostgreSQL</p>
                        <p>• Faça backup dos volumes Docker em /data/</p>
                        <p>• Teste procedimentos de recuperação</p>
                        <p>• Configure backup offsite (S3, Google Drive, etc.)</p>
                      </AccordionContent>
                    </AccordionItem>
                  </Accordion>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
          <TabsContent value="troubleshooting" className="mt-8">
            <div className="space-y-6">
              {/* Quick Fix Scripts Section */}
              <Card className="border-green-500/20 bg-green-900/20 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white flex items-center">
                    <Terminal className="w-5 h-5 mr-2 text-green-500" />
                    Scripts de Diagnóstico e Correção Automática
                  </CardTitle>
                  <CardDescription className="text-green-200">
                    Use estes scripts para diagnosticar e corrigir problemas automaticamente
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {[
                      {
                        title: 'Redis - Diagnóstico',
                        desc: 'Analisa problemas nos serviços Redis (n8n e MEGA)',
                        script: './diagnose-redis.sh',
                        color: 'from-red-500 to-red-600'
                      },
                      {
                        title: 'Redis - Correção',
                        desc: 'Corrige automaticamente problemas do Redis',
                        script: 'sudo ./fix-redis-deployment.sh',
                        color: 'from-red-600 to-red-700'
                      },
                      {
                        title: 'PostgreSQL - Diagnóstico',
                        desc: 'Analisa problemas no banco de dados PostgreSQL',
                        script: './diagnose-postgres.sh',
                        color: 'from-blue-500 to-blue-600'
                      },
                      {
                        title: 'PostgreSQL - Correção',
                        desc: 'Corrige automaticamente problemas do PostgreSQL',
                        script: 'sudo ./fix-postgres-deployment.sh',
                        color: 'from-blue-600 to-blue-700'
                      },
                      {
                        title: 'MEGA - Diagnóstico',
                        desc: 'Analisa problemas no sistema de atendimento MEGA',
                        script: './diagnose-mega.sh',
                        color: 'from-purple-500 to-purple-600'
                      },
                      {
                        title: 'MEGA - Correção',
                        desc: 'Corrige erro 404 e problemas do MEGA',
                        script: 'sudo ./fix-mega.sh',
                        color: 'from-purple-600 to-purple-700'
                      },
                      {
                        title: 'Traefik - Diagnóstico',
                        desc: 'Analisa problemas de SSL e proxy reverso',
                        script: './diagnose-traefik.sh',
                        color: 'from-orange-500 to-orange-600'
                      },
                      {
                        title: 'Portainer - Diagnóstico',
                        desc: 'Analisa problemas de acesso ao Portainer',
                        script: './diagnose-portainer.sh',
                        color: 'from-cyan-500 to-cyan-600'
                      }
                    ].map((item, index) => (
                      <motion.div
                        key={item.title}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="border border-green-500/20 rounded-lg p-4 bg-slate-700/30 hover:bg-slate-700/50 transition-all"
                      >
                        <div className={`w-full h-2 rounded-full bg-gradient-to-r ${item.color} mb-3`}></div>
                        <h4 className="font-semibold text-white mb-2">{item.title}</h4>
                        <p className="text-green-200 text-sm mb-3">{item.desc}</p>
                        <div className="bg-slate-900 rounded p-2 font-mono text-sm text-green-400">
                          <code>{item.script}</code>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                  
                  <div className="mt-6 p-4 bg-yellow-900/20 border border-yellow-500/20 rounded-lg">
                    <h4 className="font-semibold text-yellow-300 mb-2">📥 Como baixar os scripts:</h4>
                    <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 overflow-x-auto">
                      <pre>{`# Baixar todos os scripts de uma vez
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-redis.sh
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-redis-deployment.sh
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-postgres.sh
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-postgres-deployment.sh
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/diagnose-mega.sh
wget https://raw.githubusercontent.com/hudsonargollo/caixapreta-stack/main/fix-mega.sh

# Tornar executáveis
chmod +x *.sh`}</pre>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white">Problemas Comuns e Soluções</CardTitle>
                </CardHeader>
                <CardContent>
                  <Accordion type="single" collapsible className="w-full">
                    <AccordionItem value="redis-issues">
                      <AccordionTrigger className="text-white">🔴 Redis não funciona (0/1 replicas)</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p><strong>Sintomas:</strong> n8n e MEGA não funcionam, Redis mostra 0/1 replicas</p>
                        <p><strong>Solução Rápida:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 mb-2">
                          <pre>sudo ./fix-redis-deployment.sh</pre>
                        </div>
                        <p><strong>Solução Manual:</strong></p>
                        <ul className="list-disc list-inside space-y-1 ml-4">
                          <li>Verificar permissões: <code>ls -la /data/redis_*</code></li>
                          <li>Corrigir permissões: <code>chown -R 999:999 /data/redis_*</code></li>
                          <li>Reiniciar serviços: <code>docker service update --force db_redis-n8n</code></li>
                        </ul>
                      </AccordionContent>
                    </AccordionItem>

                    <AccordionItem value="postgres-issues">
                      <AccordionTrigger className="text-white">🔵 PostgreSQL não inicia (0/1 replicas)</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p><strong>Sintomas:</strong> Banco não conecta, serviços dependentes falham</p>
                        <p><strong>Solução Rápida:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 mb-2">
                          <pre>sudo ./fix-postgres-deployment.sh</pre>
                        </div>
                        <p><strong>Causas Comuns:</strong></p>
                        <ul className="list-disc list-inside space-y-1 ml-4">
                          <li>PostgreSQL do sistema conflitando na porta 5432</li>
                          <li>Permissões incorretas em /data/postgres (precisa UID 999)</li>
                          <li>Memória insuficiente (mínimo 512MB disponível)</li>
                          <li>Diretório de dados corrompido</li>
                        </ul>
                      </AccordionContent>
                    </AccordionItem>

                    <AccordionItem value="mega-404">
                      <AccordionTrigger className="text-white">🟣 MEGA retorna erro 404</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p><strong>Sintomas:</strong> mega.seudominio.com mostra página 404</p>
                        <p><strong>Solução Rápida:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 mb-2">
                          <pre>sudo ./fix-mega.sh</pre>
                        </div>
                        <p><strong>Causa:</strong> Banco de dados não inicializado corretamente</p>
                        <p><strong>Solução Manual:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400">
                          <pre>{`docker run --rm --network internal-net \\
  -e DATABASE_URL=postgresql://postgres:caixapretastack2626@db_postgres:5432/main_db \\
  -e RAILS_ENV=production \\
  sendingtk/chatwoot:v4.11.2 \\
  bundle exec rails db:chatwoot_prepare`}</pre>
                        </div>
                      </AccordionContent>
                    </AccordionItem>

                    <AccordionItem value="ssl">
                      <AccordionTrigger className="text-white">🔒 Certificados SSL não funcionam</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p><strong>Causa:</strong> DNS não propagado ou configurado incorretamente</p>
                        <p><strong>Diagnóstico:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 mb-2">
                          <pre>./diagnose-ssl-dns.sh</pre>
                        </div>
                        <p><strong>Soluções:</strong></p>
                        <ul className="list-disc list-inside space-y-1 ml-4">
                          <li>Verifique DNS: <code>nslookup n8n.seudominio.com</code></li>
                          <li>Aguarde propagação (até 24h)</li>
                          <li>Reinicie Traefik: <code>docker service update --force core_traefik</code></li>
                          <li>Verifique logs: <code>docker service logs core_traefik</code></li>
                        </ul>
                      </AccordionContent>
                    </AccordionItem>

                    <AccordionItem value="memory">
                      <AccordionTrigger className="text-white">⚡ Servidor lento ou travando</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p><strong>Causa:</strong> Falta de recursos (RAM/CPU)</p>
                        <p><strong>Diagnóstico:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 mb-2">
                          <pre>free -h && df -h && docker stats --no-stream</pre>
                        </div>
                        <p><strong>Soluções:</strong></p>
                        <ul className="list-disc list-inside space-y-1 ml-4">
                          <li>Monitore recursos: <code>htop</code></li>
                          <li>Aumente RAM do servidor se necessário</li>
                          <li>Configure swap: <code>fallocate -l 2G /swapfile</code></li>
                          <li>Reduza workers do n8n se pouca RAM</li>
                        </ul>
                      </AccordionContent>
                    </AccordionItem>

                    <AccordionItem value="network">
                      <AccordionTrigger className="text-white">🌐 Problemas de conectividade interna</AccordionTrigger>
                      <AccordionContent className="text-purple-200 space-y-2">
                        <p><strong>Sintomas:</strong> Serviços não se comunicam entre si</p>
                        <p><strong>Diagnóstico:</strong></p>
                        <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400 mb-2">
                          <pre>docker network ls && docker network inspect internal-net</pre>
                        </div>
                        <p><strong>Soluções:</strong></p>
                        <ul className="list-disc list-inside space-y-1 ml-4">
                          <li>Recriar rede: <code>docker network rm internal-net</code></li>
                          <li>Recriar com overlay: <code>docker network create --driver overlay --attachable internal-net</code></li>
                          <li>Reiniciar stack: <code>docker stack rm db && docker stack deploy -c swarm-db.yml db</code></li>
                        </ul>
                      </AccordionContent>
                    </AccordionItem>
                  </Accordion>
                </CardContent>
              </Card>

              <Card className="border-green-500/20 bg-green-900/20 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white flex items-center">
                    <CheckCircle className="w-5 h-5 mr-2 text-green-500" />
                    Comandos Úteis para Diagnóstico
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <h4 className="font-semibold text-white mb-2">Status dos Serviços</h4>
                      <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400">
                        <pre>{`docker service ls
docker stack ls
docker node ls`}</pre>
                      </div>
                    </div>
                    <div>
                      <h4 className="font-semibold text-white mb-2">Logs e Debugging</h4>
                      <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400">
                        <pre>{`docker service logs [service_name]
docker stats
htop`}</pre>
                      </div>
                    </div>
                    <div>
                      <h4 className="font-semibold text-white mb-2">Reiniciar Serviços</h4>
                      <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400">
                        <pre>{`docker service update --force [service]
docker stack rm [stack_name]
docker stack deploy -c [file.yml] [stack]`}</pre>
                      </div>
                    </div>
                    <div>
                      <h4 className="font-semibold text-white mb-2">Backup Rápido</h4>
                      <div className="bg-slate-900 rounded p-3 font-mono text-sm text-green-400">
                        <pre>{`tar -czf backup-$(date +%Y%m%d).tar.gz /data/
pg_dump -h localhost -U postgres main_db > backup.sql`}</pre>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="border-purple-500/20 bg-slate-800/50 backdrop-blur-sm">
                <CardHeader>
                  <CardTitle className="text-white">Suporte CaixaPreta</CardTitle>
                  <CardDescription className="text-purple-200">
                    Precisa de ajuda? Nossa comunidade e suporte estão aqui para você
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="border border-purple-500/20 rounded p-4">
                      <h4 className="font-semibold text-white mb-2">Comunidade Exclusiva</h4>
                      <p className="text-purple-200 text-sm mb-3">Acesso direto à comunidade de clientes CaixaPreta</p>
                      <Button className="w-full bg-purple-600 hover:bg-purple-700">
                        Acessar Comunidade
                      </Button>
                    </div>
                    <div className="border border-purple-500/20 rounded p-4">
                      <h4 className="font-semibold text-white mb-2">Consultoria Direta</h4>
                      <p className="text-purple-200 text-sm mb-3">Suporte direto com Hudson Argollo</p>
                      <Button className="w-full bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700">
                        Agendar Consultoria
                      </Button>
                    </div>
                  </div>
                  <div className="text-center">
                    <p className="text-purple-200 text-sm">
                      Visite nosso site principal: 
                      <a href="https://caixapreta.clubemkt.digital/" className="text-purple-400 hover:text-purple-300 ml-1">
                        caixapreta.clubemkt.digital
                      </a>
                    </p>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}