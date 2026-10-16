# frozen_string_literal: true

require "livekit"
require "digest"
require "json"

module Webhooks
  class LivekitWebhookHandler
    class UnauthorizedError < StandardError; end

    def call(body:, auth_token:)
      raise UnauthorizedError if auth_token.blank?
      claims = verify_webhook!(auth_token, body)
      raise UnauthorizedError unless claims
      event = JSON.parse(body)
      Rails.logger.info(
        "[LiveKit Webhook] event=#{event["event"]} id=#{event["id"]}"
      )
      process_event(event)
    end

    private
    def process_event(_event)
      raise NotImplementedError, "#{self.class} must implement #process_event"
    end

    def verify_webhook!(auth_token, body)
      verifier = LiveKit::TokenVerifier.new(
        api_key: ENV.fetch("LIVEKIT_API_KEY"),
        api_secret: ENV.fetch("LIVEKIT_API_SECRET")
      )

      claims = verifier.verify(auth_token)
      expected_hash = claims.sha256
      actual_hash = Digest::SHA256.base64digest(body)

      return nil if expected_hash.blank?
      return nil unless ActiveSupport::SecurityUtils.secure_compare(
                          expected_hash, actual_hash)
      claims
    rescue StandardError => e
      Rails.logger.error(
        "[LiveKit Webhook] #{e.class}: #{e.message}\n" \
        "#{e.backtrace&.first(10)&.join("\n")}"
      )
      nil
    end
  end
end
