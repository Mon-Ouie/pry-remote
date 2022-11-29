#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pry-remote"

  s.version = "0.1.9"

  s.summary = "Connect to Pry remotely"
  s.description = "Connect to Pry remotely using DRb"
  s.homepage = "http://github.com/Mon-Ouie/pry-remote"

  s.email = "mon.ouie@gmail.com"
  s.authors = ["Mon ouie"]

  s.files |= Dir["lib/**/*.rb"]
  s.files |= Dir["*.md"]
  s.files << "LICENSE"

  s.require_paths = ["lib"]

  s.add_dependency "slop", "~> 4.0"
  s.add_dependency "pry", "~> 0.10"

  s.executables = ["pry-remote"]
end
