require_relative './petrinet/petrinet.rb'
require_relative './petrinet/pnml.rb'
require_relative './conv_env.rb'

env = ConvEnv.new
petrinet = PNML.parse (File.open env.pnml_file).read
