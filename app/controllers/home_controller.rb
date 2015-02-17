class HomeController < ApplicationController
  def index
    redirect_to castings_path if signed_in?
  end
end
