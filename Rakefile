# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
begin
  require 'bundler'
  require 'bubble-wrap'
  require 'bubble-wrap/media'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'rm_audio_recorder'
  app.frameworks += ['AVFoundation', 'AudioToolbox']
end
