# frozen_string_literal: true

module Webhooks
  class LivekitController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      RecordingWebhookHandler.new.call(
        body: request.raw_post,
        auth_token: request.headers["Authorization"].to_s
          .delete_prefix("Bearer ")
          .strip
      )

      head :ok
    rescue LivekitWebhookHandler::UnauthorizedError
      head :unauthorized
    rescue JSON::ParserError
      head :bad_request
    end
  end
end
