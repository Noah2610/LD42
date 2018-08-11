#!/usr/bin/env ruby

require 'bundler'
Bundler.setup

require 'byebug'

require 'pathname'
require 'AdventureRL'

ROOT = Pathname.new(__FILE__).realpath.dirname

DIR = {
  src:      ROOT.join('src'),
  assets:   ROOT.join('assets'),
  images:   ROOT.join('assets/images'),
  audio:    ROOT.join('assets/audio'),
  settings: ROOT.join('settings.yml')
}

require DIR[:src].join('misc/require_files')

GAME = Game.new AdventureRL::Settings.new(DIR[:settings])
GAME.show
