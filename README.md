# Controle de Horas - CODELAB TEEN UNIFESP

Sistema inteligente para controle e monitoramento de horas trabalhadas por diferentes times de desenvolvimento.

## 📖 Sobre o Projeto

O **Controle de Horas** é uma aplicação web moderna desenvolvida para auxiliar empresas e organizações no gerenciamento eficiente do tempo de trabalho de suas equipes. O sistema permite:

- 📊 **Registro de Eventos**: Controle detalhado de atividades realizadas por cada time
- 👥 **Gestão de Times**: Organização de membros em diferentes equipes com papéis específicos
- 📈 **Relatórios**: Visualização de métricas e estatísticas de produtividade
- 🔐 **Autenticação Segura**: Sistema de login com JWT para garantir segurança dos dados
- 🎯 **Multi-Team**: Suporte a eventos que envolvem múltiplos times simultaneamente

## 🚀 Tecnologias

- **Backend**: Ruby 3.2.2 + Rails 7.0.8
- **Frontend**: Vue.js 3 com Vite
- **Styling**: Bootstrap + CSS personalizado
- **Database**: PostgreSQL
- **Containerização**: Docker & Docker Compose
- **Autenticação**: Devise + JWT
- **Testes**: RSpec + FactoryBot

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Ruby 3.2.2 (recomendado usar RVM para gerenciar versões)
- Node.js 20.x ou superior

## 🔧 Instalação

### 1. Clone o repositório

```bash
git clone <URL-DO-REPOSITORIO>
cd controle_de_horas
```

### 2. Configure o ambiente

Crie um arquivo `.env` na raiz do projeto (use o `.env.example` como base):

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DATABASE=controle_de_horas
POSTGRES_USERNAME=myuser
POSTGRES_PASSWORD=my_password

DEVISE_JWT_SECRET_KEY=seu_token_secreto_aqui
```

### 3. Inicie a aplicação

```bash
# Inicie os serviços do Docker (PostgreSQL e Redis)
docker-compose up -d

# Instale as dependências
bundle install
npm install

# Configure o banco de dados
rails db:create
rails db:migrate
rails db:seed
```

### 4. Execute a aplicação

```bash
# Em um terminal - backend Rails
rails server
```

### 5. Acesse a aplicação

[http://localhost:3000](http://localhost:3000)

## 👤 Usuários de Exemplo

O sistema vem configurado com usuários de demonstração:

### Super Administrador

- **Email**: john@acme.inc
- **Senha**: Password1!
- **Permissões**: Acesso total ao sistema

### Usuário Líder

- **Email**: leader@acme.inc
- **Senha**: Password1!
- **Permissões**: Gestão de times e eventos

## 🏢 Estrutura dos Dados

O sistema inclui dados de exemplo com:

- **5 Times**: Desenvolvimento, Design, Produto, QA e Infraestrutura
- **14 Membros**: Distribuídos entre os times com diferentes papéis
- **25+ Eventos**: Atividades realistas de desenvolvimento de software
- **7 Eventos Cross-Team**: Colaborações entre múltiplos times

### Tipos de Eventos Incluídos

- 💻 **Desenvolvimento**: APIs, code reviews, refatorações, dashboards
- 🎨 **Design**: Protótipos, pesquisa UX, design system, landing pages
- 📊 **Produto**: Análise de métricas, planejamento, pesquisa de mercado
- 🔍 **QA**: Testes de regressão, automação, validação de performance
- 🔧 **Infraestrutura**: Deploys, monitoramento, otimização de banco
- 🤝 **Colaboração**: Alinhamentos, planning sessions, all hands

## 🔍 Regras de Validação

O sistema implementa validações importantes para garantir a integridade dos dados:

### Events (Eventos)

- **Title**: Obrigatório
- **Duration**: Apenas valores específicos permitidos: 15min, 30min, 1h, 2h, 3h, 4h
- **Teams**: Deve ter pelo menos um time associado
- **Members**: Membros devem pertencer aos times do evento
- **Occurred At**: Data de ocorrência obrigatória

### Teams (Times)

- **Name**: Obrigatório, entre 3 e 100 caracteres
- **Description**: Opcional

### Members (Membros)

- **Name**: Obrigatório
- **PIX Key**: Único quando fornecido
- **Active**: Padrão verdadeiro
- **Email**: Usado como identificador único

### Memberships (Associações)

- **Role**: Enum (member, leader)
- **Unique**: Um membro não pode ter múltiplas associações no mesmo time

## 🔗 API Endpoints

### Públicos

- `POST /users/sign_in` - Login de usuário
- `DELETE /users/sign_out` - Logout de usuário

### Autenticados

- `GET /api/v1/users/my_user` - Dados do usuário logado
- `GET /api/v1/teams` - Lista de times
- `GET /api/v1/members` - Lista de membros
- `GET /api/v1/events` - Lista de eventos
- `POST /api/v1/events` - Criar novo evento

### Super Admin

- `GET /api/v1/super_admin/reports/hours` - Relatórios de horas
- `POST /api/v1/super_admin/teams` - Criar times
- `POST /api/v1/super_admin/members` - Criar membros

## 📝 Comandos Úteis

```bash
# Executar testes
bundle exec rspec

# Limpar e recriar banco com seeds
rails db:reset

# Console do Rails
rails console
```

## 📊 Estatísticas dos Dados de Exemplo

- ⏰ **85+ horas** de eventos registrados
- 👥 **5 líderes** de time
- 👨‍💻 **9 membros** regulares
- 🤝 **8 eventos** multi-team
- 📅 **30 dias** de histórico de atividades
- ✅ **100%** eventos com durações válidas (15min, 30min, 1h, 2h, 3h, 4h)

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais no **CODELAB TEEN UNIFESP**.

## 🤝 Suporte

Em caso de dúvidas ou problemas:

- Abra uma issue no repositório
- Consulte a documentação do Rails e Vue.js
