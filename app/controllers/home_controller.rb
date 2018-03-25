require 'will_paginate/array'

class HomeController < ApplicationController
  def index
    @watches = Watch.all
      .where(:owner.ne => current_user)
      .order_by(created_at: :desc)
      .paginate(:page => params[:page], :per_page => 8)
  end
end
