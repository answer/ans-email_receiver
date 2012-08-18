# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  begin
    class ReceiveMailer < ApplicationMailer; end
  rescue NameError
    class ReceiveMailer < ActionMailer::Base; end
  end

  class ReceiveMailer
    def receive(m)
      m
    end
  end
end
