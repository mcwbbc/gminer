#!/usr/bin/env ruby

# this script launches a watcher with listens to the node queue to process messages
# we launch it with an id, so we can run more than one per server

require 'rubygems'
require 'mq'
require 'json'
require 'httparty'
require 'uuidtools'

# load order is important
require '../../app/models/messaging'
require '../../app/models/processor'
require '../../app/models/ncbo_service'
require '../../app/models/ncbo_exception'
require '../../app/models/constants'

  server = ARGV[0]
  p = Processor.new(server)
  p.run

exit(1)
