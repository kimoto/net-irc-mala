#!/usr/bin/env ruby
# encoding: utf-8
require 'net/irc/mala'

Net::IRC::CLI.run(Net::IRC::Mala, ARGV)

