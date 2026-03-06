# frozen_string_literal: true

require "httparty"

module Mailerooby
  class EmailSender
    include HTTParty

    base_uri "https://smtp.maileroo.com/api/v2/emails"

    def self.send_email(send_email_parser:)
      raise ValidationError, send_email_parser.validation_error unless send_email_parser.valid?

      headers = {
        "X-Api-Key" => ::Mailerooby.sending_api_key,
        "Content-Type" => "application/json"
      }
      body = send_email_parser.to_h
      response = post(base_uri, headers: headers, body: body.to_json, multipart: true)

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
