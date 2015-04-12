require 'base64'
require 'openssl'
class S3SignaturesController < ApplicationController
  before_action :authenticate_user!

  def create
    encoded = sign(params[:to_sign])
    render text: encoded, status: 200
  end

private
  def sign(details)
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, ENV['S3_SECRET_KEY'], details)
    Base64.encode64(hmac).gsub("\n", '')
  end
end
