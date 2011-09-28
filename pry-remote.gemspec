#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pry-remote"

  s.version = "0.1.0"

  s.summary     = "Connect to Pry remotely"
  s.description = "Connect to Pry remotely using DRb"
  s.homepage    = "http://github.com/Mon-Ouie/pry-remote"

  s.email   = "mon.ouie@gmail.com"
  s.authors = ["Mon ouie"]

  s.files |= Dir["lib/**/*.rb"]
  s.files |= Dir["*.md"]

  s.require_paths = ["lib"]

  s.add_dependency "slop", "~> 2.1"
  s.add_dependency "pry", "~> 0.9.6"

  s.executables = ["pry-remote"]
end
