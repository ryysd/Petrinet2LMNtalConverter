require_relative './petrinet/pnml.rb'
require_relative './conv_env.rb'
require_relative './petrinet2lmntal_converter.rb'
require 'pp'

env = ConvEnv.new
petrinet = PNML.parse (File.open env.pnml_file).read
converter = Petrinet2LMNtalConverter.new
puts converter.convert petrinet
