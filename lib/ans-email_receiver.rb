require "ans-email_receiver/version"

module Ans
  module EmailReceiver
    autoload :Helper, "ans-email_receiver/job_helper"
    autoload :Config, "ans-email_receiver/config"
    autoload :Config, "ans-email_receiver/mailer"
  end
end
