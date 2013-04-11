#!/usr/bin/env ruby

%%{
  machine lineCount;
  access @;
  
  action onNewline { bump_line; }

  newline = '\r'? '\n' @onNewline;
  any_count_line = any | newline;
  main := any_count_line*;
}%%

class LineCount
  def initialize
    %% write data;
    # %%
    %% write init;
    # %%
    
    @curline = 0
  end
  
  def execute(data)
    p = 0
    pe = data.length
    @data = data
    
    %% write exec;
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
    %% write eof;
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