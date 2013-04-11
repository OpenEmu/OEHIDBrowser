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

%%{
  machine mtExportScanner;
  access @;
  
  action key { @key << data[fpc].chr; }
  action value { @value << data[fpc].chr}
  action onMetadata {
    @current_entry.setMetadata(@key, @value)
    @key = ""
    @value = ""
  }
  action onBody {
    @value = @value.slice(0, @value.length - @charsToDelete)
    @current_entry.setMetadata(@key, @value)
    # puts "#{@key} = <#{@value}>\n"
    @charsToDelete = 0;
    @key = ""
    @value = ""
  }
  action reset { @charsToDelete = 0 }
  action ch { @charsToDelete += 1 }
  action onEntry {
    @entries << @current_entry
    @current_entry = Entry.new
  }
  
  newline = '\r'? '\n' @{ @curline += 1; };
  
  key = ([a-zA-Z] | ' ')+;
  value = [^\n\r]*;
  
  metadata = (key $key ':' ' '+ value $value newline) @onMetadata
      | newline;
  
  end_metadata = "-"{5} newline;
  
  end_entry = "-"{8} newline;
  
  end_multiline = "-"{5} newline;
 
  multiline_ch = [^\n\r];
  content_line = multiline_ch* newline >reset $ch;
  multiline_line = (content_line - end_multiline $ch);
  multiline_value = (multiline_line* $value end_multiline);
#  multiline_value = (any* :>> (newline end_multiline) >reset $ch) $value;
  
  body = "BODY" $key ":" newline multiline_value @onBody;
  
  extended_body = "EXTENDED BODY" $key ":" newline multiline_value @onBody;
  
  excerpt = "EXCERPT" $key ":" newline multiline_value @onBody;

  keywords = "KEYWORDS" $key ":" newline multiline_value @onBody;

  multiline_field = body | extended_body | excerpt | keywords ;
  
  entry = metadata* end_metadata multiline_field* newline* end_entry @onEntry;
  
  main := entry*;
}%%

class MTExportParser
  def initialize
    %% write data;
    # %%
    @data = ""
    %% write init;
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
    
    %% write exec;
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
    %% write eof;
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