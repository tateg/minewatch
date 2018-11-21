require 'dotenv'
require 'simplecov'

# ENV vars are loaded from production config.env but prefixed with TEST_
Dotenv.load('config.env')

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda/context'
require_relative 'vcr_config'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
SimpleCov.start
