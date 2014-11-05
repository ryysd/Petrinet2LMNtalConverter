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
    expressions = petrinet.transitions.map do |transition|
      var_table = create_var_table transition
      "#{make_prefix transition}\n#{make_lhs transition, var_table} :- #{make_guard transition, var_table} | #{make_rhs transition, var_table}"
    end
    lmntal.push expressions

    (lmntal.join ".\n") + ".\n"
  end

  def create_var_table(transition)
    places = (transition.inputs + transition.outputs).uniq
    places.map.with_index {|p, idx| [p.id, (AlphabetSerialNumberGenerator.generate idx)]}.to_h
  end

  def make_initial_var_names(places)
    places.map.with_index {|place,idx| make_global_var_name place.id, place.initial_marking}.join ','
  end

  def make_local_var_name(val)
    "$#{val}"
  end

  def make_local_tmp_var_name(val)
    "#{make_local_var_name val}_"
  end

  def make_global_var_name(id, val)
    "#{id}(#{val})"
  end

  def make_lhs_var_name(place, var_table)
    make_global_var_name place.id, (make_local_var_name var_table[place.id])
  end

  def make_rhs_var_name(place, var_table)
    make_global_var_name place.id, (make_local_tmp_var_name var_table[place.id])
  end

  def make_inc_expr(place, var_table, val = 1)
    "#{make_local_tmp_var_name var_table[place.id]}=#{make_local_var_name var_table[place.id]}+#{val}"
  end

  def make_dec_expr(place, var_table, val = 1)
    "#{make_local_tmp_var_name var_table[place.id]}=#{make_local_var_name var_table[place.id]}-#{val}"
  end

  def make_prefix(transition)
    prefix = []
    # prefix.push "// #{transition.inputs.map {|input| input.id}.join ','} -> #{transition.outputs.map {|input| input.id}.join ','}"
    prefix.push "#{transition.id} @@"

    prefix.join "\n"
  end

  def make_lhs(transition, var_table)
    lhs = []
    lhs.push transition.inputs.map {|input| make_lhs_var_name input, var_table}.join ','
    lhs.push transition.outputs.map {|output| make_lhs_var_name output, var_table}.join ','

    lhs.join ', '
  end

  def make_rhs(transition, var_table)
    rhs = []
    rhs.push transition.inputs.map {|input| make_rhs_var_name input, var_table}.join ','
    rhs.push transition.outputs.map {|output| make_rhs_var_name output, var_table}.join ','

    rhs.join ', '
  end

  def make_guard(transition, var_table)
    guard = []
    guard.push transition.inputs.map {|input| "#{make_local_var_name var_table[input.id]}>0"}.join ','
    guard.push transition.inputs.map {|input| "#{make_dec_expr input, var_table}"}.join ','
    guard.push transition.outputs.map {|output| "#{make_inc_expr output, var_table}"}.join ','

    guard.join ', '
  end
end
