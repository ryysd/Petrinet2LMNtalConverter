require_relative './petrinet/petrinet.rb'
require_relative './petrinet/pnml.rb'
require_relative './conv_env.rb'
require 'pp'

env = ConvEnv.new
transitions = PNML.parse (File.open env.pnml_file).read
pp transitions
