# frozen_string_literal: true

# Simple pages to test various interface configurations.
class ThemesController < ApplicationController
  # GET /themes/dashboard-test
  def dashboard_test
    # render layout: "layouts/full_page"
  end

  # GET /themes/full-test
  def full_test
    render layout: "layouts/full_page"
  end

  # GET /themes/menu-test
  def menu_test
    render layout: "layouts/full_page_sidebar_dark"
  end

  # # GET /themes/transition-test
  # def transition_test
  # end
end
