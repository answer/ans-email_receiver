# -*- coding: utf-8 -*-

require "spec_helper"
require "email_receive"

class EmailReceive
  include Ans::EmailReceiver::Model
end

module Ans::EmailReceiver
  describe Mailer do
    before do
      class MyMailer
        include Mailer

        attr_accessor :message

        def save(email_receive)
          self.message = "saved"
        end
      end

      email_receive
      mailer.receive mail
      email_receive.reload
    end
    let(:email_receive){EmailReceive.create message_id: 0}
    let(:mailer){MyMailer.new}
    let(:mail){
      mail = Object.new
      class << mail
        attr_accessor :bounce

        def message_id
          0
        end
        def bounced?
          self.bounce
        end
      end
      mail.bounce = is_bounce
      mail
    }

    context "通常のメールの場合" do
      let(:is_bounce){false}

      describe "email_receive.is_bounced" do
        subject{email_receive.is_bounced}
        it{should be_false}
      end
      describe "mailer.message" do
        subject{mailer.message}
        it{should == "saved"}
      end
    end

    context "エラーメールの場合" do
      let(:is_bounce){true}

      describe "email_receive.is_bounced" do
        subject{email_receive.is_bounced}
        it{should be_true}
      end
      describe "mailer.message" do
        subject{mailer.message}
        it{should be_nil}
      end
    end

  end
end
