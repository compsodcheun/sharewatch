require 'shoulda/matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose a library:
    # with.library :active_record
    with.library :active_model
    with.library :action_controller
  end
end
