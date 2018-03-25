require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'rails/mongoid'
require 'mongoid-rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model
  config.include ActionView::Helpers::AssetUrlHelper
  config.include SignInAs
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  DatabaseCleaner.clean
end
