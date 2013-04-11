# line 1 "wc.rb.rl"
#!/usr/bin/env ruby

# line 12 "wc.rb.rl"


class LineCount
  def initialize
    
# line 11 "wc.rb"
class << self
	attr_accessor :_lineCount_actions
	private :_lineCount_actions, :_lineCount_actions=
end
self._lineCount_actions = [
	0, 1, 0
]

class << self
	attr_accessor :_lineCount_key_offsets
	private :_lineCount_key_offsets, :_lineCount_key_offsets=
end
self._lineCount_key_offsets = [
	0
]

class << self
	attr_accessor :_lineCount_trans_keys
	private :_lineCount_trans_keys, :_lineCount_trans_keys=
end
self._lineCount_trans_keys = [
	10, 0
]

class << self
	attr_accessor :_lineCount_single_lengths
	private :_lineCount_single_lengths, :_lineCount_single_lengths=
end
self._lineCount_single_lengths = [
	1
]

class << self
	attr_accessor :_lineCount_range_lengths
	private :_lineCount_range_lengths, :_lineCount_range_lengths=
end
self._lineCount_range_lengths = [
	0
]

class << self
	attr_accessor :_lineCount_index_offsets
	private :_lineCount_index_offsets, :_lineCount_index_offsets=
end
self._lineCount_index_offsets = [
	0
]

class << self
	attr_accessor :_lineCount_trans_targs_wi
	private :_lineCount_trans_targs_wi, :_lineCount_trans_targs_wi=
end
self._lineCount_trans_targs_wi = [
	0, 0, 0
]

class << self
	attr_accessor :_lineCount_trans_actions_wi
	private :_lineCount_trans_actions_wi, :_lineCount_trans_actions_wi=
end
self._lineCount_trans_actions_wi = [
	1, 0, 0
]

class << self
	attr_accessor :lineCount_start
end
self.lineCount_start = 0;
class << self
	attr_accessor :lineCount_first_final
end
self.lineCount_first_final = 0;
class << self
	attr_accessor :lineCount_error
end
self.lineCount_error = -1;

class << self
	attr_accessor :lineCount_en_main
end
self.lineCount_en_main = 0;

# line 17 "wc.rb.rl"
    # %%
    
# line 97 "wc.rb"
begin
	 @cs = lineCount_start
end
# line 19 "wc.rb.rl"
    # %%
    
    @curline = 0
  end
  
  def execute(data)
    p = 0
    pe = data.length
    @data = data
    
    
# line 113 "wc.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	if p != pe
	while true
	_break_resume = false
	begin
	_break_again = false
	_keys = _lineCount_key_offsets[ @cs]
	_trans = _lineCount_index_offsets[ @cs]
	_klen = _lineCount_single_lengths[ @cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if  @data[p] < _lineCount_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif  @data[p] > _lineCount_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _lineCount_range_lengths[ @cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if  @data[p] < _lineCount_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif  @data[p] > _lineCount_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	 @cs = _lineCount_trans_targs_wi[_trans]
	break if _lineCount_trans_actions_wi[_trans] == 0
	_acts = _lineCount_trans_actions_wi[_trans]
	_nacts = _lineCount_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _lineCount_actions[_acts - 1]
when 0:
# line 7 "wc.rb.rl"
		begin
 bump_line; 		end
# line 7 "wc.rb.rl"
# line 184 "wc.rb"
		end # action switch
	end
	end while false
	break if _break_resume
	p += 1
	break if p == pe
	end
	end
	end
# line 30 "wc.rb.rl"
    # %%
    
    if @cs == lineCount_error
      return -1
    elsif @cs >= lineCount_first_final
      return 1
    else
      return 0
    end
  end
  
  def finish
    
# line 208 "wc.rb"
# line 43 "wc.rb.rl"
    # %%
  end
  
  def bump_line
    @curline += 1
    # puts @curline
  end
  
  def parse(stream)
    done = false
    while (!done)
      data = stream.read(65536);
      if (!data.nil?)
        result = self.execute(data)
        if result < 0
          puts "Scanner result: #{result}"
          break
        end
      else
        done = true
      end
    end
  end
  
  def print_summary
    puts "Number of lines: #{@curline}"
  end
end

if __FILE__ == $0
  lineCount = LineCount::new
  lineCount.parse($stdin)
  lineCount.print_summary
end