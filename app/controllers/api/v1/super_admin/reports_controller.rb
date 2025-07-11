class Api::V1::SuperAdmin::ReportsController < Api::V1::SuperAdmin::BaseController
  def hours
    member = Member.find(params[:member_id])

    @member_with_hours = Reports::CalculateMemberHoursService.new(member).perform
    @member_events = member.events.includes(:teams).order(occurred_at: :desc) if @member_with_hours
  end

  private

  def permitted_params
    params.permit(:member_id)
  end
end
