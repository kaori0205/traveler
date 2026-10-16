ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
# OneDriveで同期中のフォルダ内ではファイルのロックやアクセス権の問題が起きやすいため、ブーツナップのキャッシュ機能を無効化
# require "bootsnap/setup" # Speed up boot time by caching expensive operations.
