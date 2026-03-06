# frozen_string_literal: true

require "httparty"

module Mailerooby
  class EmailVerifier
    include HTTParty

    base_uri "https://api.zeruh.com/v1/verify"

    def self.verify_email(email_address:)
      raise ValidationError, "Missing email address" unless email_address

      headers = {
        "X-Api-Key" => ::Mailerooby.verifying_api_key,
        "Content-Type" => "application/json"
      }
      body = { email_address: email_address }
      response = post(base_uri, headers: headers, body: body.to_json)

      case response.code
      when 400
        raise BadRequestError, "Bad request: #{response.body}"
      when 401
        raise UnauthorizedError, "Unauthorized: #{response.body}"
      when 200
        JSON.parse(response.body)
      else
        raise GeneralAPIError, "API Error: #{response.body}"
      end
    end
  end
end
