# encoding: utf-8

module Biscuit
  module Monitor

    %w< etc logger sequel sqlite3 >.each { |dep| require dep }

    HOME_DIR = Etc.getpwuid.dir
    biscuit_monitor_root_dir = "#{HOME_DIR}/.biscuit-monitor"
    Dir.mkdir(biscuit_monitor_root_dir) unless File.directory?(biscuit_monitor_root_dir)
    biscuit_monitor_log_dir = "#{biscuit_monitor_root_dir}/log"
    Dir.mkdir(biscuit_monitor_log_dir) unless File.directory?(biscuit_monitor_log_dir)

    LOG_FILE = "#{biscuit_monitor_log_dir}/biscuit-monitor.log"
    LOGGER = Logger.new(LOG_FILE, 10, 1024000)

    DB_CONN = Sequel.sqlite("#{biscuit_monitor_root_dir}/biscuit_monitor.db", loggers: [LOGGER])

    Sequel.extension :migration
    Sequel::Migrator.apply(DB_CONN, File.expand_path(File.dirname(__FILE__)) + '/migrations')


    %w< version cinr rssi access_point_scanner poller cli signal_strength >.each { |dep| require "biscuit-monitor/#{dep}" }
  end
end
