# -*- coding: utf-8 -*-

require "spec_helper"
require "shoulda-matchers"
require "ans-matchers"

describe EmailReceive do
  before do
    class EmailReceive
      include Ans::EmailReceiver::Model

      attr_accessor :message

      def after_bounced
        self.message = "bounced"
      end
    end
  end

  describe "スコープ" do
    subject{EmailReceive}

    it{should have_executable_scope(:old).by_sql(<<-__SQL)}
      SELECT `email_receives`.* FROM `email_receives`
      WHERE (`email_receives`.`deleted_at` IS NULL)
      AND (`email_receives`.`created_at` < now() - interval 1 year)
    __SQL
  end

  describe "receive" do
    subject{result[:message]}
    let(:result){{}}
    let(:body){}

    before do
      EmailReceive.receive body do |email_receive|
        result[:message] = "received"
      end
    end
    it{should == "received"}

  end

  describe "mail" do
    subject{email_receive.mail}
    let(:email_receive){EmailReceive.new body: body}
    let(:body){}
    it{should be_a Mail::Message}
  end

  describe "bounced" do
    let(:email_receive){EmailReceive.new}
    before do
      email_receive.bounced
    end

    describe "is_bounced" do
      subject{email_receive.is_bounced}
      it{should be_true}
    end
    describe "message" do
      subject{email_receive.message}
      it{should == "bounced"}
    end
  end
end
