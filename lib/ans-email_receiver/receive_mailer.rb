# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  class ReceiveMailer < ActionMailer::Base
    def receive(m)
      m
    end
  end
end
