#!/usr/bin/env ruby

require 'bundler'
Bundler.setup

require 'byebug'

require 'pathname'
require 'adventure_rl'

ROOT = Pathname.new(__FILE__).realpath.dirname

DIR = {
  src:      ROOT.join('src'),
  assets:   ROOT.join('assets'),
  images:   ROOT.join('assets/images'),
  audio:    ROOT.join('assets/audio'),
  settings: ROOT.join('settings.yml'),
  levels:   ROOT.join('levels')
}

SETTINGS = AdventureRL::Settings.new(DIR[:settings])

require DIR[:src].join('misc/require_files')

GAME = Game.new SETTINGS
GAME.show
