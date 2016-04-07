# encoding: UTF-8

#
# Credits inspiration
# Fabio Cevasco (h3rald on github)
#

require "yaml"

class Clip < Shoes::Widget

  attr_reader :content

  def initialize(content=nil)
    @content = content || app.clipboard.strip
    
    self.style margin: 5
    background lavender
    border gainsboro
    
    parag = para @content
    
    click do |btn, left, top|
      app.clipboard = @content
      parag.stroke = firebrick
      timer(1) do 
        parag.stroke = black 
        remove if btn == 2
      end
    end
  end

end

class Pasty < Shoes::Widget

  def initialize
    stack margin: 15 do
      flow margin: 5 do
        para link("Clear Pasty") { clear_pasty }, " | ",
             link("Clear Clipboard") { clear_clipboard }, " | ",
             link("Save") { save_clips }, " | ",
             link("Load") { load_clips }, " | ",
             link("Restart") { Shoes.visit __FILE__; close }, align: "center"
      end
      
      stack margin: 5 do
        background aliceblue
        border lightblue
        @info = para "Ready.", stroke: mediumblue, emphasis: "italic"
      end
      
      flow margin: 5 do
        @search = edit_line width: 355
        para link("Search") { search }, " | ",
             link("Clear") { clear_search }
      end
      
      stack margin_left: 150 do
        button("Paste!", width: 200, margin_top: 5) { paste }
      end
      
      @dropstack = stack
      
      load_clips
      
    end
  end

  def flash_message(msg, type=nil, life=1)
    @info.replace msg
    
    @info.style stroke: case type
    when :error; red
    when :warning; orange
    when :success; green
    else; mediumblue
    end
    
    timer(life) do 
      @info.style stroke: mediumblue
      @info.replace "Ready."
    end
  end

  def paste
      #@dropstack.contents.delete_if { |c| c.content == app.clipboard.strip }        #?? GC sure ?
      @dropstack.contents.each { |c| c.remove if c.content == app.clipboard.strip } #
      
      @dropstack.prepend { clip }
      flash_message "Pasted!", :success
    rescue ArgumentError => e
      flash_message "The system clipboard doesn't contain text. Not nice!", :error, 2
  end


  def clear_search
    @search.text = ""
    
    unless @dropstack_contents.nil? || @dropstack_contents.empty?
      @dropstack.clear { @dropstack_contents.each { |c| clip c.content } }
      flash_message "Sorted clips cleared!", :success
    end
  end

  def search
    flash_message "Searching...", :success
    regexp = @search.text.match(/^\/.*\/[imxo]*$/) ? 
                        instance_eval(@search.text) : 
                        Regexp.new(@search.text)
    
    @dropstack_contents = @dropstack.contents.dup
    clips = @dropstack_contents.select { |c| c.content.match regexp }
    flash_message "#{clips.size} matching clips found.", :success
    
    @dropstack.clear { clips.each { |c| clip c.content } } if clips.size > 0
  end

  def clear_pasty
    @dropstack.clear
    flash_message "Pasty cleared!", :success
  end

  def clear_clipboard
    app.clipboard = ""
    flash_message "Clipboard cleared!", :success
  end

  def save_clips
    File.open("pasty.yml", "w+") do |f| 
      f.write @dropstack.contents.map { |c| c.content }.to_yaml
    end
    flash_message "Clips saved!", :success
  end
  
  def load_clips
    if File.exist? "pasty.yml"
      clips = YAML.load_file("pasty.yml")
      if clips.empty? || !clips.respond_to?(:each)
        flash_message "No clips to load...", :warning
      else
        clips.each { |c| @dropstack.append { clip c } }
        flash_message "#{clips.length} clips loaded!", :success
      end
    else
      flash_message "No clips to load...", :warning
    end
  end

end

Shoes.app :title => "Pasty", resizable: false, height: 700, width: 500 do

  style Shoes::Para, size: 10
  style Shoes::Link, weight: "bold", underline: false
  style Shoes::LinkHover, weight: "bold"
  
  pasty
  
end
