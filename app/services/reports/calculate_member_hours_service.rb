require 'ostruct'

class Reports::CalculateMemberHoursService
  def initialize(member)
    @member = member
  end

  def perform
    build_member_metrics(fetch_aggregated_data)
  end

  private

  def fetch_aggregated_data
    result = ActiveRecord::Base.connection.execute(aggregated_sql)
    return nil if result.ntuples.zero?

    OpenStruct.new(
      id: result[0]['id'].to_i,
      name: result[0]['name'],
      created_at: parse_time(result[0]['created_at']),
      event_count: result[0]['event_count'].to_i,
      total_seconds: result[0]['total_seconds'].to_i,
      first_event_at: parse_time(result[0]['first_event_at']),
      last_event_at: parse_time(result[0]['last_event_at'])
    )
  end

  def aggregated_sql
    <<~SQL
      SELECT#{' '}
        members.id,
        members.name,
        members.created_at,
        COUNT(events.id) as event_count,
        COALESCE(SUM(events.duration_seconds), 0) as total_seconds,
        MIN(events.occurred_at) as first_event_at,
        MAX(events.occurred_at) as last_event_at
      FROM members
      LEFT JOIN event_assignments ON event_assignments.member_id = members.id
      LEFT JOIN events ON events.id = event_assignments.event_id
      WHERE members.id = #{@member.id}
      GROUP BY members.id, members.name, members.created_at
    SQL
  end

  def parse_time(value)
    return nil if value.nil?
    return value if value.is_a?(Time)

    Time.zone.parse(value)
  end

  def build_member_metrics(data)
    return build_member_without_events if data.nil? || data.event_count.zero?

    first_event_at = data.first_event_at
    last_event_at = data.last_event_at
    total_seconds = data.total_seconds.to_i

    real_weeks = calculate_real_weeks(first_event_at, last_event_at)
    real_average = calculate_real_average(total_seconds, real_weeks)

    ideal_weeks, ideal_average = calculate_ideal_metrics(total_seconds, real_weeks)

    {
      id: data.id,
      name: data.name,
      created_at: data.created_at,
      disabled_at: @member.disabled_at,
      total_seconds: total_seconds,
      event_count: data.event_count,
      real: {
        total_weeks: real_weeks.round,
        average_hours_per_week: real_average,
        first_event_at: first_event_at,
        last_event_at: last_event_at
      },
      ideal: {
        total_weeks: ideal_weeks,
        average_hours_per_week: ideal_average,
        first_event_at: first_event_at,
        last_event_at: first_event_at + ideal_weeks.weeks
      }
    }
  end

  def build_member_without_events
    {
      id: @member.id,
      name: @member.name,
      created_at: @member.created_at,
      disabled_at: @member.disabled_at,
      total_seconds: 0,
      event_count: 0,
      real: {
        total_weeks: 0.0,
        average_hours_per_week: 0.0,
        first_event_at: nil,
        last_event_at: nil
      },
      ideal: {
        total_weeks: 0,
        average_hours_per_week: 0,
        first_event_at: nil,
        last_event_at: nil
      }
    }
  end

  def calculate_real_weeks(first_event_at, last_event_at)
    return 0.0 if first_event_at.nil? || last_event_at.nil?

    days_difference = (last_event_at - first_event_at) / 1.day
    (days_difference / 7.0).round(2)
  end

  def calculate_real_average(total_seconds, real_weeks)
    return 0.0 if real_weeks.zero?

    ((total_seconds / 3600.0) / real_weeks).round(2)
  end

  # Calcula duas métricas ideais:
  #  - número de semanas a considerar
  #  - horas inteiras por semana
  # Retorna [semanas, horas]
  def calculate_ideal_metrics(total_seconds, real_weeks)
    # Sem semanas reais, sem métricas
    return [0, 0] if real_weeks.zero?

    total_hours = total_seconds / 3600.0
    max_weeks = [real_weeks.ceil, 1].max

    # Tentativa inicial: horas/semana arredondado a 2 casas
    # Se o valor já é inteiro ≥ 1, devolve direto
    initial = (total_hours / max_weeks).round(2)
    return [max_weeks, initial.to_i] if initial.modulo(1).zero? && initial >= 1

    # Próximo inteiro alvo (mínimo 1)
    target = [initial.ceil, 1].max

    before_pass = nil # último valor antes de “passar” do inteiro alvo

    # Testa da maior para a menor semana possível
    max_weeks.downto(1) do |week|
      hours = (total_hours / week).round(2)

      # Achou valor exatamente inteiro e igual ao alvo
      return [week, target] if hours.modulo(1).zero? && hours.to_i == target

      if hours < target
        # Ainda não passou do inteiro → guarda como “antes de passar”
        before_pass = { week:, hours: }
      else
        passed = { week:, hours: }

        return [passed[:week], target] unless before_pass

        # Compara qual dos dois está mais perto do alvo
        return [before_pass[:week], target] if (before_pass[:hours] - target).abs <= (passed[:hours] - target).abs

        return [passed[:week], target]
      end
    end

    before_pass ? [before_pass[:week], target] : [max_weeks, target]
  end
end
