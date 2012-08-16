# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  module Controller
    def show
      Resque.enqueue "#{params[:id].to_s.camelize}Receiver".constantize
      render text: "ok"
    rescue NameError
      render text: "ng", status: 404
    end
  end
end
