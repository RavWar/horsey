# Load the Rails application.
require File.expand_path('../application', __FILE__)

Haml::Template.options[:attr_wrapper] = '"'
Haml::Template.options[:format] = :html5
Haml::Template.options[:autoclose] = %w[meta link img br input source]

# Initialize the Rails application.
Horsey::Application.initialize!
