require "spec_helper"
require "mailerooby/email_verifier"

RSpec.describe Mailerooby::EmailVerifier do
  describe ".verify_email" do
    subject(:verify_email) { Mailerooby::EmailVerifier.verify_email(email_address: email_address) }

    let(:email_address) { "email_address" }
    let(:body) { double(raw_source: "Test Body") }
    let(:verifying_api_key) { "verifying_api_key" }

    before do
      Mailerooby.verifying_api_key = verifying_api_key
    end

    def stub_maileroo_request(status:, response_body:)
      stub_request(:post, "https://api.zeruh.com/v1/verify").
        with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/json",
            "User-Agent" => "Ruby",
            "X-Api-Key" => verifying_api_key
          }
        ).
        to_return(status: status, body: response_body.to_json, headers: {})
    end

    it "verifies an email successfully" do
      stub_maileroo_request(
        status: 200,
        response_body: { success: true }
      )
      response = verify_email
      expect(response["success"]).to be true
    end

    context "when email address is missing" do
      let(:email_address) { nil }

      it "raises a validation error" do
        expect { verify_email }.to raise_error(Mailerooby::ValidationError)
      end
    end

    context "when the API returns an error" do
      it "raises an error" do
        stub_maileroo_request(
          status: 400,
          response_body: { success: false, message: "Error" }
        )
        expect { verify_email }.to raise_error(Mailerooby::BadRequestError)
      end
    end
  end
end
