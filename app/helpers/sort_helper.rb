# frozen_string_literal: true

# Methods to sort tables in various ways.
module SortHelper
  def order_to(title, primary: "", secondary: "#{primary} desc")
    sort_params = params.permit(:search)
    sort_field_order = (params[:order] == primary ? secondary : primary)
    link_class = params[:order].in?([primary, secondary].compact) ? "link-accent" : nil
    link_to title, url_for(sort_params.merge(order: sort_field_order)), class: link_class
  end
end
