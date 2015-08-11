require 'sinatra'
require 'json'
require 'openssl'
require_relative 'ecs'

class PackagerApp < Sinatra::Base
  post '/receive' do
    payload_body = request.body.read
    verify_signature(payload_body)
    payload = JSON.parse(payload_body)
    if payload['action'] == 'published'
      tar_url = payload['release']['tarball_url']
      ECSCaller.new(tar_url).perform
    else
      return halt 500, 'Webhook only for releases'
    end
  end

  def verify_signature(payload_body)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
    return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end
end
