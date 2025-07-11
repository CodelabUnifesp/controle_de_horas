puts '🌱 Iniciando criação das seeds...'

User.find_or_create_by!(email: 'john@acme.inc') do |user|
  user.password = 'Password1!'
  user.super_admin = true
  user.name = 'John Doe'
end
puts '✅ Usuário admin criado'

User.find_or_create_by!(email: 'leader@acme.inc') do |user|
  user.password = 'Password1!'
  user.super_admin = false
  user.name = 'Leader Doe'
end
puts '✅ Usuário leader criado'

team_dev = Team.find_or_create_by!(name: 'Time de Desenvolvimento') do |team|
  team.description = 'Responsável pelo desenvolvimento de software, APIs e infraestrutura'
end

team_design = Team.find_or_create_by!(name: 'Time de Design') do |team|
  team.description = 'Responsável por UX/UI, prototipagem e design visual'
end

team_product = Team.find_or_create_by!(name: 'Time de Produto') do |team|
  team.description = 'Responsável por estratégia de produto, análise de mercado e roadmap'
end

team_qa = Team.find_or_create_by!(name: 'Time de QA') do |team|
  team.description = 'Responsável por testes, qualidade e validação de features'
end

team_infra = Team.find_or_create_by!(name: 'Time de Infraestrutura') do |team|
  team.description = 'Responsável por DevOps, monitoramento e infraestrutura de TI'
end
puts '✅ Times criados'

members_data = [
  { name: 'Ana Silva', email: 'ana.silva@empresa.com', role: :leader, teams: [team_dev] },
  { name: 'Bruno Santos', email: 'bruno.santos@empresa.com', role: :member, teams: [team_dev] },
  { name: 'Carlos Oliveira', email: 'carlos.oliveira@empresa.com', role: :member, teams: [team_dev] },
  { name: 'Daniela Costa', email: 'daniela.costa@empresa.com', role: :leader, teams: [team_design] },
  { name: 'Eduardo Lima', email: 'eduardo.lima@empresa.com', role: :member, teams: [team_design] },
  { name: 'Fernanda Alves', email: 'fernanda.alves@empresa.com', role: :leader, teams: [team_product] },
  { name: 'Gabriel Rocha', email: 'gabriel.rocha@empresa.com', role: :member, teams: [team_product] },
  { name: 'Helena Martins', email: 'helena.martins@empresa.com', role: :leader, teams: [team_qa] },
  { name: 'Igor Ferreira', email: 'igor.ferreira@empresa.com', role: :member, teams: [team_qa] },
  { name: 'Julia Pereira', email: 'julia.pereira@empresa.com', role: :member, teams: [team_dev, team_qa] },
  { name: 'Marcos Ribeiro', email: 'marcos.ribeiro@empresa.com', role: :leader, teams: [team_infra] },
  { name: 'Paula Nascimento', email: 'paula.nascimento@empresa.com', role: :member, teams: [team_infra] },
  { name: 'Rafael Torres', email: 'rafael.torres@empresa.com', role: :member, teams: [team_design, team_product] },
  { name: 'Sonia Barbosa', email: 'sonia.barbosa@empresa.com', role: :member, teams: [team_dev, team_infra] }
]

members_data.each do |member_info|
  member = Member.find_or_create_by!(email: member_info[:email]) do |m|
    m.name = member_info[:name]
    m.pix_key = member_info[:email]
    m.active = true
  end

  member_info[:teams].each do |team|
    Membership.find_or_create_by!(member: member, team: team) do |membership|
      membership.role = member_info[:role]
    end
  end
end
puts '✅ Membros e memberships criados'

development_events = [
  {
    teams: [team_dev],
    title: 'Desenvolvimento API de Autenticação',
    description: 'Implementação completa da API de autenticação com JWT e refresh tokens',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 1.day.ago
  },
  {
    teams: [team_dev],
    title: 'Code Review - Sistema de Pagamentos',
    description: 'Revisão detalhada do código do módulo de pagamentos e integração com gateway',
    duration_seconds: 2.hours.to_i,
    member_count: 3,
    occurred_at: 2.days.ago
  },
  {
    teams: [team_dev],
    title: 'Correção de Bugs Críticos',
    description: 'Correção de bugs críticos reportados pelos usuários em produção',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 3.days.ago
  },
  {
    teams: [team_dev],
    title: 'Refatoração do Sistema de Notificações',
    description: 'Refatoração completa do sistema de notificações para melhor performance',
    duration_seconds: 4.hours.to_i,
    member_count: 1,
    occurred_at: 4.days.ago
  },
  {
    teams: [team_dev],
    title: 'Implementação de Dashboard Administrativo',
    description: 'Desenvolvimento do dashboard para administradores com métricas em tempo real',
    duration_seconds: 4.hours.to_i,
    member_count: 3,
    occurred_at: 5.days.ago
  },
  {
    teams: [team_dev],
    title: 'Daily Standup',
    description: 'Reunião diária de alinhamento da equipe de desenvolvimento',
    duration_seconds: 15.minutes.to_i,
    member_count: 4,
    occurred_at: 6.days.ago
  }
]

design_events = [
  {
    teams: [team_design],
    title: 'Criação de Protótipos Mobile',
    description: 'Desenvolvimento de protótipos de alta fidelidade para a aplicação mobile',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 7.days.ago
  },
  {
    teams: [team_design],
    title: 'Pesquisa de Usabilidade',
    description: 'Condução de testes de usabilidade com usuários reais da plataforma',
    duration_seconds: 3.hours.to_i,
    member_count: 1,
    occurred_at: 8.days.ago
  },
  {
    teams: [team_design],
    title: 'Design System - Componentes',
    description: 'Criação e documentação de novos componentes para o design system',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 9.days.ago
  },
  {
    teams: [team_design],
    title: 'Redesign da Landing Page',
    description: 'Reformulação completa do design da página inicial do produto',
    duration_seconds: 3.hours.to_i,
    member_count: 1,
    occurred_at: 10.days.ago
  }
]

product_events = [
  {
    teams: [team_product],
    title: 'Análise de Métricas Q4',
    description: 'Análise detalhada das métricas de produto do último trimestre',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 11.days.ago
  },
  {
    teams: [team_product],
    title: 'Planejamento de Features 2024',
    description: 'Sessão de planejamento e priorização de features para o próximo ano',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 12.days.ago
  },
  {
    teams: [team_product],
    title: 'Pesquisa de Mercado - Concorrentes',
    description: 'Análise competitiva e benchmarking com principais concorrentes',
    duration_seconds: 2.hours.to_i,
    member_count: 1,
    occurred_at: 13.days.ago
  },
  {
    teams: [team_product],
    title: 'Definição de OKRs Q1',
    description: 'Workshop para definição dos objetivos e resultados-chave do trimestre',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 14.days.ago
  }
]

qa_events = [
  {
    teams: [team_qa],
    title: 'Testes de Regressão - Release 2.1',
    description: 'Execução completa de testes de regressão para a nova versão',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 15.days.ago
  },
  {
    teams: [team_qa],
    title: 'Automação de Testes E2E',
    description: 'Desenvolvimento de novos testes automatizados end-to-end',
    duration_seconds: 4.hours.to_i,
    member_count: 1,
    occurred_at: 16.days.ago
  },
  {
    teams: [team_qa],
    title: 'Validação de Performance',
    description: 'Testes de carga e performance da aplicação com cenários reais',
    duration_seconds: 3.hours.to_i,
    member_count: 2,
    occurred_at: 17.days.ago
  },
  {
    teams: [team_qa],
    title: 'Documentação de Casos de Teste',
    description: 'Atualização e criação de documentação para novos casos de teste',
    duration_seconds: 2.hours.to_i,
    member_count: 1,
    occurred_at: 18.days.ago
  }
]

infra_events = [
  {
    teams: [team_infra],
    title: 'Deploy de Produção',
    description: 'Deploy da nova versão em ambiente de produção com rollback strategy',
    duration_seconds: 2.hours.to_i,
    member_count: 2,
    occurred_at: 19.days.ago
  },
  {
    teams: [team_infra],
    title: 'Configuração de Monitoramento',
    description: 'Setup de alertas e dashboards de monitoramento da infraestrutura',
    duration_seconds: 3.hours.to_i,
    member_count: 1,
    occurred_at: 20.days.ago
  },
  {
    teams: [team_infra],
    title: 'Otimização de Database',
    description: 'Otimização de queries e índices do banco de dados para melhor performance',
    duration_seconds: 4.hours.to_i,
    member_count: 2,
    occurred_at: 21.days.ago
  },
  {
    teams: [team_infra],
    title: 'Backup e Disaster Recovery',
    description: 'Implementação de estratégias de backup e plano de recuperação de desastres',
    duration_seconds: 3.hours.to_i,
    member_count: 1,
    occurred_at: 22.days.ago
  }
]

all_events = development_events + design_events + product_events + qa_events + infra_events

all_events.each do |event_info|
  event = Event.find_by(title: event_info[:title])
  next if event

  event = Event.new(
    title: event_info[:title],
    description: event_info[:description],
    duration_seconds: event_info[:duration_seconds],
    occurred_at: event_info[:occurred_at]
  )

  event_info[:teams].each do |team|
    event.teams << team
  end

  event.save!

  available_members = Member.joins(:teams).where(teams: { id: event_info[:teams].map(&:id) }).distinct.to_a
  selected_members = available_members.sample(event_info[:member_count])

  selected_members.each do |member|
    EventAssignment.create!(event: event, member: member)
  end
end
puts '✅ Eventos individuais dos times criados'

cross_team_events = [
  {
    teams: [team_dev, team_design],
    title: 'Alinhamento Frontend - Novos Componentes',
    description: 'Reunião para alinhar implementação de novos componentes do design system',
    duration_seconds: 1.hour.to_i,
    custom_members: [team_dev.members.sample(2), team_design.members.sample(1)].flatten,
    occurred_at: 23.days.ago
  },
  {
    teams: [team_dev, team_infra],
    title: 'Planejamento de Arquitetura Cloud',
    description: 'Workshop para definir migração para arquitetura cloud-native',
    duration_seconds: 4.hours.to_i,
    custom_members: [team_dev.members.first, team_infra.members.first],
    occurred_at: 24.days.ago
  },
  {
    teams: [team_product, team_design, team_dev],
    title: 'Sprint Planning - Feature Checkout',
    description: 'Planejamento conjunto para desenvolvimento da nova funcionalidade de checkout',
    duration_seconds: 2.hours.to_i,
    custom_members: Member.joins(:memberships).where(memberships: { role: :leader }).limit(3),
    occurred_at: 25.days.ago
  },
  {
    teams: [team_qa, team_dev],
    title: 'Definição de Estratégia de Testes',
    description: 'Alinhamento sobre processo de QA e integração contínua',
    duration_seconds: 1.hour.to_i,
    custom_members: [team_qa.members.first, team_dev.members.sample(2)].flatten,
    occurred_at: 26.days.ago
  },
  {
    teams: [team_dev, team_design, team_product, team_qa, team_infra],
    title: 'All Hands - Review Trimestral',
    description: 'Reunião geral para apresentação de resultados e planejamento do próximo trimestre',
    duration_seconds: 2.hours.to_i,
    custom_members: Member.joins(:memberships).where(memberships: { role: :leader }),
    occurred_at: 27.days.ago
  },
  {
    teams: [team_product, team_qa],
    title: 'Validação de Requisitos - Sistema de Relatórios',
    description: 'Sessão para validar e refinar requisitos do novo sistema de relatórios',
    duration_seconds: 2.hours.to_i,
    custom_members: [team_product.members.first, team_qa.members.first],
    occurred_at: 28.days.ago
  },
  {
    teams: [team_infra, team_qa],
    title: 'Configuração de Ambiente de Testes',
    description: 'Setup e configuração de novos ambientes para testes automatizados',
    duration_seconds: 3.hours.to_i,
    custom_members: [team_infra.members.sample(1), team_qa.members.sample(1)].flatten,
    occurred_at: 29.days.ago
  },
  {
    teams: [team_design],
    title: 'Workshop de Acessibilidade',
    description: 'Treinamento sobre práticas de acessibilidade em design digital',
    duration_seconds: 30.minutes.to_i,
    custom_members: team_design.members.sample(2),
    occurred_at: 30.days.ago
  }
]

cross_team_events.each do |event_info|
  event = Event.find_by(title: event_info[:title])
  next if event

  event = Event.new(
    title: event_info[:title],
    description: event_info[:description],
    duration_seconds: event_info[:duration_seconds],
    occurred_at: event_info[:occurred_at]
  )

  event_info[:teams].each do |team|
    event.teams << team
  end

  event.save!

  event_team_ids = event_info[:teams].map(&:id)

  event_info[:custom_members].each do |member|
    next unless member.teams.where(id: event_team_ids).exists?

    EventAssignment.find_or_create_by!(event: event, member: member)
  end
end
puts '✅ Eventos cross-team criados'

puts "\n📊 RESUMO DOS DADOS CRIADOS:"
puts "👤 Usuários: #{User.count}"
puts "👥 Times: #{Team.count}"
puts "🧑‍💼 Membros: #{Member.count}"
puts "🔗 Memberships: #{Membership.count}"
puts "📅 Eventos: #{Event.count}"
puts "🔗 Event Teams: #{EventTeam.count}"
puts "📝 Event Assignments: #{EventAssignment.count}"

leaders_count = Member.joins(:memberships).where(memberships: { role: :leader }).distinct.count
members_count = Member.joins(:memberships).where(memberships: { role: :member }).distinct.count
multi_team_events = Event.joins(:event_teams).group('events.id').having('COUNT(event_teams.team_id) > 1').count.size
total_hours = Event.sum(:duration_seconds) / 3600.0

puts "👑 Líderes: #{leaders_count}"
puts "👨‍💻 Membros: #{members_count}"
puts "🤝 Eventos Multi-Team: #{multi_team_events}"
puts "⏰ Total de Horas Registradas: #{total_hours.round(1)}h"
puts "\n✨ Seeds executados com sucesso!"
