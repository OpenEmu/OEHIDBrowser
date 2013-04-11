# line 1 "mtexport.rb.rl"
#!/usr/bin/env ruby

EntryBase = Struct.new(:author, :title, :status, :allow_comments, :basename,
  :convert_breaks, :allow_pings, :primary_category, :category, :date,
  :body, :extended_body, :excerpt, :keywords)

class Entry < EntryBase
  def setMetadata(key, value)
    case key
    when "AUTHOR"
      self.author = value
    when "TITLE"
      self.title = value
    when "STATUS"
      self.status = value
    when "ALLOW COMMENTS"
      self.allow_comments = (value == "0")
    when "CONVERT BREAKS"
      self.convert_breaks = value
    when "ALLOW PINGS"
      self.allow_pings = (value == "0")
    when "PRIMARY CATEGORY"
      self.primary_category = value
    when "CATEGORY"
      self.category = value
    when "DATE"
      self.date = value
    when "BODY"
      self.body = value
    when "EXTENDED BODY"
      self.extended_body = value
    when "EXCERPT"
      self.excerpt = value
    when "KEYWORDS"
      self.keywords = value
    end
  end

  def output_meta(key, value)
    if (!value.nil?)
      puts "#{key}: #{value}"
    end
  end

  def output_meta_bool(key, value)
    output_meta(key, value ? "1" : "0")
  end
  
  def output_multi(key, value)
    puts "#{key}:"
    value = "" if value.nil?
    puts "#{value}\n"
    puts "-----"
  end

  def to_export
    output_meta("AUTHOR", self.author)
    output_meta("TITLE", self.title)
    output_meta("BASENAME", self.basename)
    output_meta_bool("ALLOW COMMENTS", self.allow_comments)
    output_meta("CONVERT BREAKS", self.convert_breaks)
    output_meta_bool("ALLOW PINGS", self.allow_pings)
    output_meta("PRIMARY CATEGORY", self.primary_category)
    output_meta("CATEGORY", self.category)
    output_meta("DATE", self.date)
    output_meta_bool("ALLOW COMMENTS", false)
    output_meta_bool("ALLOW PINGS", false)
    puts "-----"
    output_multi("BODY", self.body)
    output_multi("EXTENDED BODY", self.extended_body)
    output_multi("EXCERPT", self.excerpt)
    output_multi("KEYWORDS", self.keywords)
    puts
    puts
    puts "--------"
  end
  
  def adjust_basename
    basename = self.title.dup
    if self.keywords =~ /([^\]]*) \s* \[ ([^\]]+) \] \s* ([^\]]*)/x
      basename = $2
      self.keywords = $1 + $3
    end
    basename.gsub!(" ", "_")
    basename.gsub!(/[.\',\!\-]/, "")
    basename.tr!('A-Z', 'a-z')
    self.basename = basename
  end
end

# line 150 "mtexport.rb.rl"


class MTExportParser
  def initialize
    
# line 99 "mtexport.rb"
class << self
	attr_accessor :_mtExportScanner_trans_keys
	private :_mtExportScanner_trans_keys, :_mtExportScanner_trans_keys=
end
self._mtExportScanner_trans_keys = [
	0, 0, 10, 122, 10, 10, 
	32, 122, 32, 32, 10, 
	13, 10, 10, 45, 45, 
	45, 45, 45, 45, 45, 45, 
	10, 13, 10, 75, 10, 
	45, 10, 10, 45, 45, 
	45, 45, 45, 45, 45, 45, 
	45, 45, 45, 45, 45, 
	45, 10, 13, 10, 10, 
	79, 79, 68, 68, 89, 89, 
	58, 58, 10, 13, 10, 
	45, 10, 13, 10, 10, 
	10, 45, 10, 45, 10, 45, 
	10, 45, 10, 13, 10, 
	10, 10, 10, 88, 88, 
	67, 84, 69, 69, 82, 82, 
	80, 80, 84, 84, 69, 
	69, 78, 78, 68, 68, 
	69, 69, 68, 68, 32, 32, 
	66, 66, 69, 69, 89, 
	89, 87, 87, 79, 79, 
	82, 82, 68, 68, 83, 83, 
	10, 10, 10, 122, 0
]

class << self
	attr_accessor :_mtExportScanner_key_spans
	private :_mtExportScanner_key_spans, :_mtExportScanner_key_spans=
end
self._mtExportScanner_key_spans = [
	0, 113, 1, 91, 1, 4, 1, 1, 
	1, 1, 1, 4, 66, 36, 1, 1, 
	1, 1, 1, 1, 1, 1, 4, 1, 
	1, 1, 1, 1, 4, 36, 4, 1, 
	36, 36, 36, 36, 4, 1, 1, 1, 
	18, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 113
]

class << self
	attr_accessor :_mtExportScanner_index_offsets
	private :_mtExportScanner_index_offsets, :_mtExportScanner_index_offsets=
end
self._mtExportScanner_index_offsets = [
	0, 0, 114, 116, 208, 210, 215, 217, 
	219, 221, 223, 225, 230, 297, 334, 336, 
	338, 340, 342, 344, 346, 348, 350, 355, 
	357, 359, 361, 363, 365, 370, 407, 412, 
	414, 451, 488, 525, 562, 567, 569, 571, 
	573, 592, 594, 596, 598, 600, 602, 604, 
	606, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 626, 628, 630
]

class << self
	attr_accessor :_mtExportScanner_indicies
	private :_mtExportScanner_indicies, :_mtExportScanner_indicies=
end
self._mtExportScanner_indicies = [
	0, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 3, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 4, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 1, 1, 1, 1, 1, 1, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 1, 0, 1, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 5, 1, 
	1, 1, 1, 1, 1, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 1, 
	1, 1, 1, 1, 1, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 1, 
	6, 1, 8, 7, 7, 9, 7, 8, 
	1, 10, 1, 11, 1, 12, 1, 13, 
	1, 14, 1, 1, 15, 1, 16, 1, 
	1, 17, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 18, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 19, 1, 
	1, 20, 1, 1, 1, 1, 1, 21, 
	1, 16, 1, 1, 17, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 18, 1, 16, 1, 
	22, 1, 23, 1, 24, 1, 25, 1, 
	26, 1, 27, 1, 28, 1, 29, 1, 
	1, 30, 1, 29, 1, 31, 1, 32, 
	1, 33, 1, 34, 1, 35, 1, 1, 
	36, 1, 38, 37, 37, 39, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 40, 37, 38, 
	37, 37, 39, 37, 41, 1, 38, 37, 
	37, 39, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 42, 37, 38, 37, 37, 39, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 43, 37, 
	38, 37, 37, 39, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 44, 37, 38, 37, 37, 
	39, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	37, 37, 37, 37, 37, 37, 37, 37, 
	45, 37, 46, 37, 37, 47, 37, 46, 
	1, 35, 1, 48, 1, 49, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 50, 1, 
	51, 1, 52, 1, 53, 1, 33, 1, 
	54, 1, 55, 1, 56, 1, 57, 1, 
	58, 1, 59, 1, 19, 1, 60, 1, 
	61, 1, 62, 1, 63, 1, 64, 1, 
	65, 1, 33, 1, 14, 1, 0, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 3, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 4, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 1, 
	1, 1, 1, 1, 1, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 1, 
	0
]

class << self
	attr_accessor :_mtExportScanner_trans_targs_wi
	private :_mtExportScanner_trans_targs_wi, :_mtExportScanner_trans_targs_wi=
end
self._mtExportScanner_trans_targs_wi = [
	1, 0, 2, 3, 7, 4, 5, 5, 
	1, 6, 8, 9, 10, 11, 12, 59, 
	13, 14, 15, 24, 39, 52, 16, 17, 
	18, 19, 20, 21, 22, 60, 23, 25, 
	26, 27, 28, 29, 38, 30, 29, 31, 
	32, 29, 33, 34, 35, 36, 12, 37, 
	40, 41, 45, 42, 43, 44, 46, 47, 
	48, 49, 50, 51, 53, 54, 55, 56, 
	57, 58
]

class << self
	attr_accessor :_mtExportScanner_trans_actions_wi
	private :_mtExportScanner_trans_actions_wi, :_mtExportScanner_trans_actions_wi=
end
self._mtExportScanner_trans_actions_wi = [
	1, 0, 0, 2, 0, 0, 0, 3, 
	4, 0, 0, 0, 0, 0, 1, 0, 
	1, 0, 0, 2, 2, 2, 0, 0, 
	0, 0, 0, 0, 0, 5, 0, 2, 
	2, 2, 0, 1, 0, 3, 6, 7, 
	8, 9, 8, 8, 8, 8, 10, 0, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2
]

class << self
	attr_accessor :mtExportScanner_start
end
self.mtExportScanner_start = 60;
class << self
	attr_accessor :mtExportScanner_first_final
end
self.mtExportScanner_first_final = 60;
class << self
	attr_accessor :mtExportScanner_error
end
self.mtExportScanner_error = 0;

class << self
	attr_accessor :mtExportScanner_en_main
end
self.mtExportScanner_en_main = 60;

# line 155 "mtexport.rb.rl"
    # %%
    @data = ""
    
# line 315 "mtexport.rb"
begin
	p ||= 0
	pe ||=  @data.length
	 @cs = mtExportScanner_start
end
# line 158 "mtexport.rb.rl"
    # %%
    
    @curline = 0
    @key = ""
    @value = ""
    @charsToDelete = 0
    @entries = []
    @current_entry = Entry.new
  end
  
  def execute(data)
    @data = data
    p = 0
    pe = data.length
    
    
# line 338 "mtexport.rb"
begin # ragel fflat
	_slen, _trans, _keys, _inds, _acts, _nacts = nil
	if p != pe # pe guard
	if  @cs != 0 # errstate guard
	while true # _resume loop 
		_break_resume = false
	begin
		_break_again = false
	_keys =  @cs << 1
	_inds = _mtExportScanner_index_offsets[ @cs]
	_slen = _mtExportScanner_key_spans[ @cs]
	_trans = if (   _slen > 0 && 
			_mtExportScanner_trans_keys[_keys] <=  @data[p] && 
			 @data[p] <= _mtExportScanner_trans_keys[_keys + 1] 
		    ) then
			_mtExportScanner_indicies[ _inds +  @data[p] - _mtExportScanner_trans_keys[_keys] ] 
		 else 
			_mtExportScanner_indicies[ _inds + _slen ]
		 end
	 @cs = _mtExportScanner_trans_targs_wi[_trans]
	break if _mtExportScanner_trans_actions_wi[_trans] == 0
	case _mtExportScanner_trans_actions_wi[_trans]
	when 2
# line 95 "mtexport.rb.rl"
		begin
 @key << data[p].chr; 		end
# line 95 "mtexport.rb.rl"
	when 3
# line 96 "mtexport.rb.rl"
		begin
 @value << data[p].chr		end
# line 96 "mtexport.rb.rl"
	when 1
# line 117 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 117 "mtexport.rb.rl"
	when 8
# line 111 "mtexport.rb.rl"
		begin
 @charsToDelete += 1 		end
# line 111 "mtexport.rb.rl"
# line 96 "mtexport.rb.rl"
		begin
 @value << data[p].chr		end
# line 96 "mtexport.rb.rl"
	when 4
# line 117 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 117 "mtexport.rb.rl"
# line 97 "mtexport.rb.rl"
		begin

    @current_entry.setMetadata(@key, @value)
    @key = ""
    @value = ""
  		end
# line 97 "mtexport.rb.rl"
	when 10
# line 117 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 117 "mtexport.rb.rl"
# line 102 "mtexport.rb.rl"
		begin

    @value = @value.slice(0, @value.length - @charsToDelete)
    @current_entry.setMetadata(@key, @value)
    # puts "#{@key} = <#{@value}>\n"
    @charsToDelete = 0;
    @key = ""
    @value = ""
  		end
# line 102 "mtexport.rb.rl"
	when 5
# line 117 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 117 "mtexport.rb.rl"
# line 112 "mtexport.rb.rl"
		begin

    @entries << @current_entry
    @current_entry = Entry.new
  		end
# line 112 "mtexport.rb.rl"
	when 7
# line 110 "mtexport.rb.rl"
		begin
 @charsToDelete = 0 		end
# line 110 "mtexport.rb.rl"
# line 111 "mtexport.rb.rl"
		begin
 @charsToDelete += 1 		end
# line 111 "mtexport.rb.rl"
# line 96 "mtexport.rb.rl"
		begin
 @value << data[p].chr		end
# line 96 "mtexport.rb.rl"
	when 9
# line 117 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 117 "mtexport.rb.rl"
# line 111 "mtexport.rb.rl"
		begin
 @charsToDelete += 1 		end
# line 111 "mtexport.rb.rl"
# line 96 "mtexport.rb.rl"
		begin
 @value << data[p].chr		end
# line 96 "mtexport.rb.rl"
	when 6
# line 110 "mtexport.rb.rl"
		begin
 @charsToDelete = 0 		end
# line 110 "mtexport.rb.rl"
# line 117 "mtexport.rb.rl"
		begin
 @curline += 1; 		end
# line 117 "mtexport.rb.rl"
# line 111 "mtexport.rb.rl"
		begin
 @charsToDelete += 1 		end
# line 111 "mtexport.rb.rl"
# line 96 "mtexport.rb.rl"
		begin
 @value << data[p].chr		end
# line 96 "mtexport.rb.rl"
# line 469 "mtexport.rb"
	end # action switch
	end while false # _again loop
	break if _break_resume
	break if  @cs == 0
	p += 1
	break if p == pe
	end # _resume loop
	end # errstate guard
	end # pe guard
end # ragel fflat# line 174 "mtexport.rb.rl"
    # %%
    
    if @cs == mtExportScanner_error
      return -1
    elsif @cs >= mtExportScanner_first_final
      return 1
    else
      return 0
    end
  end
  
  def finish
    
# line 493 "mtexport.rb"
# line 187 "mtexport.rb.rl"
    # %%
  end
  
  def bump_line
    @curline += 1
    # puts @curline
  end
  
  def parse(stream)
    done = false
    bytes = 0;
    while (!done)
      data = stream.read(65536);
      if (!data.nil?)
        result = self.execute(data)
        if result < 0
          $stderr.puts "Scanner result: #{result}"
          break
        end
      else
        done = true
      end
    end
    $stderr.puts "Bytes: #{bytes}"
  end
  
  def print_summary
    $stderr.puts "Number of lines: #{@curline}"
    # @entries[0].to_export
    @entries.each do |e|
      e.adjust_basename
      e.to_export
    end
  end
end

if __FILE__ == $0
  parser = MTExportParser::new
  parser.parse($stdin)
  parser.print_summary
end