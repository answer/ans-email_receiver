# -*- coding: utf-8 -*-

module Ans::EmailReceiver
  class Config
    def initialize(name)
      @name = name
    end

    def host
      value "host", "localhost"
    end
    def port
      value "port", "110"
    end
    def user
      value "user", @name
    end
    def password
      value "password", "password"
    end

    private

    def value(name,default_value)
      config_value(name) || default_value
    end
    def config_value(name)
      SystemSetting.find_by_name(config_name name).try(:value)
    end
    def config_name(name)
      "#{config_prefix}#{@name}_#{name}#{config_suffix}"
    end
    def config_prefix
      "email_receive_"
    end
    def config_suffix
      ""
    end

  end
end
