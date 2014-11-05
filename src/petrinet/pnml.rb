require 'active_support/core_ext'

class PNML
  def self.pipe_form_pnml?(xml_hash)
    xml_hash['pnml']['net']['type'] == 'P/T net'
  end

  def self.parse(xml)
    hash =  Hash.from_xml xml
    pipe = pipe_form_pnml? hash

    net = pipe ? hash['pnml']['net'] : hash['pnml']['net']['page']
    value_key = pipe ? 'value' : 'text'

    places = net['place'].map{|p| Place.new p['id'], (p.has_key? 'name') ? p['name'][value_key] : p['id']}
    transitions = net['transition'].map{|t| Transition.new t['id'], (t.has_key? 'name') ? t['name'][value_key] : t['id']}

    nodes = places + transitions
    net['arc'].each do |a| 
      source_id = a['source']
      target_id = a['target']

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

    transitions
  end
end

