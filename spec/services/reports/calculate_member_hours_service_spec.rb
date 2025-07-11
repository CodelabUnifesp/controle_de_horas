require 'rails_helper'

RSpec.describe Reports::CalculateMemberHoursService, type: :service do
  describe '#perform' do
    let(:member) { create(:member) }
    let(:service) { described_class.new(member) }
    let(:team) { create(:team) }
    let!(:membership) { create(:membership, member: member, team: team) }

    def hours_to_seconds(hours)
      hours * 60 * 60
    end

    def create_event(duration_seconds:, occurred_at:)
      event = build(:event, duration_seconds: duration_seconds, occurred_at: occurred_at)
      event.teams << team
      event.save!

      create(:event_assignment, member: member, event: event)

      event
    end

    context 'when member has no events' do
      it 'returns zero metrics' do
        result = service.perform

        expect(result).to eq({
                               id: member.id,
                               name: member.name,
                               created_at: member.created_at,
                               disabled_at: member.disabled_at,
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
                             })
      end
    end

    context 'when member has 1 event only' do
      let(:event_date) { Date.new(2025, 7, 6) }
      let(:duration_seconds) { 900 } # 15 minutes

      it 'returns correct metrics for single event' do
        create_event(duration_seconds: duration_seconds, occurred_at: event_date)

        result = service.perform

        expect(result).to eq({
                               id: member.id,
                               name: member.name,
                               created_at: member.created_at,
                               disabled_at: member.disabled_at,
                               total_seconds: duration_seconds,
                               event_count: 1,
                               real: {
                                 total_weeks: 0,
                                 average_hours_per_week: 0.0,
                                 first_event_at: event_date,
                                 last_event_at: event_date
                               },
                               ideal: {
                                 total_weeks: 0,
                                 average_hours_per_week: 0,
                                 first_event_at: event_date,
                                 last_event_at: event_date
                               }
                             })
      end
    end

    context 'when event window is 23 weeks' do
      let(:first_event_at) { Date.new(2025, 1, 6) }
      let(:last_event_at) { first_event_at + 23.weeks }

      it 'calculates metrics for 100 hours' do
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(100))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(23)
        expect(result[:real][:average_hours_per_week]).to eq(4.35)
        expect(result[:ideal][:total_weeks]).to eq(20)
        expect(result[:ideal][:average_hours_per_week]).to eq(5)
      end

      it 'calculates metrics for 80 hours' do
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(30), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(80))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(23)
        expect(result[:real][:average_hours_per_week]).to eq(3.48)
        expect(result[:ideal][:total_weeks]).to eq(20)
        expect(result[:ideal][:average_hours_per_week]).to eq(4)
      end

      it 'calculates metrics for 71 hours' do
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(21), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(71))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(23)
        expect(result[:real][:average_hours_per_week]).to eq(3.09)
        expect(result[:ideal][:total_weeks]).to eq(18)
        expect(result[:ideal][:average_hours_per_week]).to eq(4)
      end
    end

    context 'when event window is 30 weeks' do
      let(:first_event_at) { Date.new(2025, 1, 6) }
      let(:last_event_at) { first_event_at + 30.weeks }

      it 'calculates metrics for 100 hours' do
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(100))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(3.33)
        expect(result[:ideal][:total_weeks]).to eq(25)
        expect(result[:ideal][:average_hours_per_week]).to eq(4)
      end

      it 'calculates metrics for 80 hours' do
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(30), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(80))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(2.67)
        expect(result[:ideal][:total_weeks]).to eq(27)
        expect(result[:ideal][:average_hours_per_week]).to eq(3)
      end

      it 'calculates metrics for 70 hours' do
        create_event(duration_seconds: hours_to_seconds(50), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(20), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(70))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(2.33)
        expect(result[:ideal][:total_weeks]).to eq(23)
        expect(result[:ideal][:average_hours_per_week]).to eq(3)
      end

      it 'calculates metrics for 60 hours' do
        create_event(duration_seconds: hours_to_seconds(40), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(20), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(60))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(2)
        expect(result[:ideal][:total_weeks]).to eq(30)
        expect(result[:ideal][:average_hours_per_week]).to eq(2)
      end

      it 'calculates metrics for 50 hours' do
        create_event(duration_seconds: hours_to_seconds(30), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(20), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(50))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(1.67)
        expect(result[:ideal][:total_weeks]).to eq(25)
        expect(result[:ideal][:average_hours_per_week]).to eq(2)
      end

      it 'calculates metrics for 40 hours' do
        create_event(duration_seconds: hours_to_seconds(30), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(10), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(40))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(1.33)
        expect(result[:ideal][:total_weeks]).to eq(20)
        expect(result[:ideal][:average_hours_per_week]).to eq(2)
      end

      it 'calculates metrics for 30 hours' do
        create_event(duration_seconds: hours_to_seconds(10), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(10), occurred_at: first_event_at + 1.week)
        create_event(duration_seconds: hours_to_seconds(10), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(30))
        expect(result[:event_count]).to eq(3)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(1)
        expect(result[:ideal][:total_weeks]).to eq(30)
        expect(result[:ideal][:average_hours_per_week]).to eq(1)
      end

      it 'calculates metrics for 20 hours' do
        create_event(duration_seconds: hours_to_seconds(10), occurred_at: first_event_at)
        create_event(duration_seconds: hours_to_seconds(10), occurred_at: last_event_at)

        result = service.perform

        expect(result[:total_seconds]).to eq(hours_to_seconds(20))
        expect(result[:event_count]).to eq(2)
        expect(result[:real][:total_weeks]).to eq(30)
        expect(result[:real][:average_hours_per_week]).to eq(0.67)
        expect(result[:ideal][:total_weeks]).to eq(20)
        expect(result[:ideal][:average_hours_per_week]).to eq(1)
      end
    end
  end
end
