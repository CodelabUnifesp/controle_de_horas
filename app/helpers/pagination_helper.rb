module PaginationHelper
  def paginate(scope:, params:, per_page: 10)
    show_all_records = params[:all_records].present?
    max_results = show_all_records ? 999_999 : per_page
    scope.page(params[:page] || 1).per(max_results)
  end
end

