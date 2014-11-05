class AlphabetSerialNumberGenerator
  def self.generate(num)
    alphabets = ('a'..'z').to_a
    length = (num / alphabets.size).to_i
    mod = num % alphabets.size
    
    ('z' * length) + alphabets[mod]
  end
end

class Petrinet2LMNtalConverter
  def convert(petrinet)
    lmntal = []
    lmntal.push make_initial_var_names petrinet.places
    lmntal.push petrinet.transitions.map {|transition| "#{make_prefix transition}\n#{make_lhs transition} :- #{make_guard transition} | #{make_rhs transition}"}

    (lmntal.join ".\n") + ".\n"
  end

  def make_initial_var_names(places)
    places.map.with_index {|place,idx| make_global_var_name place.id, place.initial_marking}.join ','
  end

  def make_local_var_name(idx)
    "$#{AlphabetSerialNumberGenerator.generate idx}"
  end

  def make_local_tmp_var_name(idx)
    "#{make_local_var_name idx}_"
  end

  def make_global_var_name(id, val)
    "#{id}(#{val})"
  end

  def make_prefix(transition)
    prefix = []
    # prefix.push "// #{transition.inputs.map {|input| input.id}.join ','} -> #{transition.outputs.map {|input| input.id}.join ','}"
    prefix.push "#{transition.id} @@"

    prefix.join "\n"
  end

  def make_lhs(transition)
    lhs = []
    lhs.push transition.inputs.map.with_index {|input, idx| make_global_var_name input.id, (make_local_var_name idx)}.join ','
    lhs.push transition.outputs.map.with_index {|output, idx| make_global_var_name output.id, (make_local_var_name transition.inputs.size + idx)}.join ','

    lhs.join ', '
  end

  def make_rhs(transition)
    rhs = []
    rhs.push transition.inputs.map.with_index {|input, idx| make_global_var_name input.id, (make_local_tmp_var_name idx)}.join ','
    rhs.push transition.outputs.map.with_index {|output, idx| make_global_var_name output.id, (make_local_tmp_var_name transition.inputs.size + idx)}.join ','

    rhs.join ', '
  end

  def make_guard(transition)
    guard = []
    guard.push (0...transition.inputs.size).map {|idx| "#{make_local_var_name idx}>0"}.join ','
    guard.push transition.inputs.map.with_index {|input, idx| "#{make_local_tmp_var_name idx}=#{make_local_var_name idx}-1"}.join ','
    guard.push transition.outputs.map.with_index {|output, idx| "#{make_local_tmp_var_name transition.inputs.size + idx}=#{make_local_var_name transition.inputs.size + idx}+1"}.join ','

    guard.join ', '
  end
end
