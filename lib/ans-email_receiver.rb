require "ans-email_receiver/version"

module Ans
  module EmailReceiver
    autoload :Job,        "ans-email_receiver/job"
    autoload :Model,      "ans-email_receiver/model"
    autoload :Config,     "ans-email_receiver/config"
    autoload :Mailer,     "ans-email_receiver/mailer"
    autoload :Controller, "ans-email_receiver/controller"
  end
end
