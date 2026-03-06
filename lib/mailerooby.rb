# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Mailerooby
  class BadRequestError < StandardError; end
  class DeliveryError < StandardError; end
  class GeneralAPIError < StandardError; end
  class UnauthorizedError < StandardError; end
  class ValidationError < StandardError; end

  class << self
    attr_accessor :sending_api_key, :verifying_api_key
  end

  # Automatically register Maileroob as a delivery method for ActionMailer
  if defined?(ActionMailer)
    ActionMailer::Base.add_delivery_method :mailerooby, Mailerooby::DeliveryMethod
  end
end