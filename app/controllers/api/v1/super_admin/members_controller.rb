class Api::V1::SuperAdmin::MembersController < Api::V1::SuperAdmin::BaseController
  before_action :member, only: %i[update show]

  def index
    scope = MembersFinder.new(permitted_params).perform
    @members = paginate(scope:, params: permitted_params)
  end

  def show
    @member
  end

  def create
    member_attr = {
      name: permitted_params[:name],
      pix_key: permitted_params[:pix_key],
      external_id: permitted_params[:external_id],
      active: permitted_params[:active],
      team_ids: permitted_params[:team_ids]
    }.compact_blank

    @member = Member.new(member_attr)
    @member.save || render_error
  end

  def update
    @member.update(permitted_params) || render_error
  end

  private

  def permitted_params
    params.permit(:name, :pix_key, :external_id, :all_records, :page,
                  :active, :sort_by, :sort_order, :with_hours, team_ids: [])
  end

  def member
    @member ||= Member.includes(:memberships, :teams).find(params[:id])
  end

  def render_error
    render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
  end
end
