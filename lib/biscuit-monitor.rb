# encoding: utf-8

require 'biscuit-monitor/version'
require 'thor'

module Biscuit
  module Monitor
    class CLI < Thor
      default_task :login

      desc "login", "prompts for username and password"
      def login
        username = ask("Enter your username:  ") { |q| q.echo = true }
        password = ask("Enter your password:  ") { |q| q.echo = "*" }

        puts username
        puts password
      end
    end
  end
end
