require 'active_support/core_ext'
require_relative './petrinet_node.rb'
require_relative './place.rb'
require_relative './transition.rb'

class Petrinet
  attr_reader :places, :transitions

  def initialize(places, transitions)
    @places = places
    @transitions = transitions
  end
end

class PNML
  def self.pipe_form_pnml?(xml_hash)
    xml_hash['pnml']['net']['type'] == 'P/T net'
  end

  def self.parse(xml)
    hash =  Hash.from_xml xml
    pipe = pipe_form_pnml? hash

    net = pipe ? hash['pnml']['net'] : hash['pnml']['net']['page']
    value_key = pipe ? 'value' : 'text'

    places = net['place'].map{|p| Place.new p['id'], (p.has_key? 'name') ? (p['name'][value_key]) : p['id'], (p.has_key? 'initialMarking') ? (p['initialMarking'][value_key].gsub(/[^0-9]/, "").to_i) : 0}
    transitions = net['transition'].map{|t| Transition.new t['id'], (t.has_key? 'name') ? t['name'][value_key] : t['id']}

    nodes = places + transitions
    net['arc'].each do |a| 
      source_id = a['source'].downcase
      target_id = a['target'].downcase

      source = nodes.find{|n| n.id == source_id}
      target = nodes.find{|n| n.id == target_id}

      case source
      when Place
        target.add_input_place source
      when Transition
        source.add_output_place target
      else
        p 'invalid type'
      end
    end

    Petrinet.new places, transitions
  end
end

