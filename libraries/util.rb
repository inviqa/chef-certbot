module Certbot
  module Util
    extend self

    def self_signed_certificate?(certfile)
      self_signed_issuer = Mixlib::ShellOut.new('openssl x509 -in #{certfile} -issuer -noout').run_command.stdout.sub(/^issuer=/, '')
      self_signed_subject = Mixlib::ShellOut.new('openssl x509 -in #{certfile} -subject -noout').run_command.stdout.sub(/^subject=/, '')

      self_signed_issuer == self_signed_subject
    end
  end
end
