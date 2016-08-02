module Certbot
  module Util
    extends self

    def self_signed_certificate?(certfile)
      self_signed_issuer = `openssl x509 -in #{certfile} -issuer -noout`.sub(/^issuer=/, '')
      self_signed_subject = `openssl x509 -in #{certfile} -subject -noout`.sub(/^subject=/, '')

      self_signed_issuer == self_signed_subject
    end
  end
end
