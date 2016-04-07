# encoding: UTF-8


Shoes.app width: 900, height: 700, title: "Break in your Doc's" do
    
    style(Shoes::Link, stroke: black, underscore: "none")
    style(Shoes::LinkHover, stroke: darkred, underscore: "none")
    
    # get the list of Classes 'ri' knows about, memorize them by first letter of top Class
    classes = `ri -f ansi -l`.split().reduce({}) do |m,line| 
        # Pick only classes, modules ...
        next m if ("a".."z").include? line[0]
        
        m[line[0]] ||= []
        top = line.split("::")[0]
        m[line[0]] << top unless m[line[0]].include? top
        m
    end
    
    # build alphabet list of classes able to dynamically 
    # create left index and right ouput area
#    alphab = classes.reduce([]) do |m,(k,v)|
    alphab = classes.each_with_object([]) do |(k,v),m|
        m << link(k) { 
                @index.replace( *( v.reduce([]) { |m2, cl| 
                    m2 << link(cl) { @board.clear { para fetch(cl) }
                                     @search_box.text = cl 
                                     @board.scroll_top = 0
                                   } << "\n"
                    m2 } )
                )
                @board.clear
             } << "  "
#        m
    end
    
    stack do
        flow do
            background darkseagreen..lavender
            @list_alpha = para *alphab, align: "center", margin: 10
        end
        
        flow do
            stack width: 300, height: 695, top: 40, left: 0, attach: Shoes::Window, scroll: true  do
                flow margin: 10 do
                    button("Search help") { show_rihelp }
                    @search_box = edit_line "", width: 250, height: 30
                    @search_box.finish = proc { |e| @board.clear { para fetch(@search_box.text) }
                                                    @board.scroll_top = 0 }
#                    button "search" do 
#                        @board.clear { para fetch(@search_box.text) }
#                        @board.scroll_top = 0
#                    end
                end
                @index = para "", size: 11
            end
            @board = stack(margin_left: 300) {}
        end
    end
    
    def show_rihelp
        window title: "ri command help" do
            para em("This is the help page that is shown when you type 'ri --help' on the command line\n"),
                 em("Don't type 'ri' in the search box !!\n", stroke: darkred),
                 em("Just the symbol or combination of symbols you're looking for\n"),
                 em("Don't try '-i' or '--interactive' unless you enjoy hanging guis   (...)\n\n"), margin: 15
            para `ri --help`, margin: [5,15,5,5]
        end
    end
    
    def fetch(lookup)
        if ["--interactive", "-i", "--list", "-l"].any? { |e| lookup.match e }
            warning = "\nYou can't use \"#{$&}\" as search options !"
            @search_box.text = @search_box.text.sub($&, "")
            return span(warning, stroke: darkred, size: 14)
        end
        
        r = `ri -f ansi #{lookup}`
        
        return span("\nNothing known about #{lookup}", stroke: darkred) if r.empty?
        
        arr = r.force_encoding("UTF-8").split(/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?m/)
        # first escape sequence not relevant here => droping first 3 elements
        scan(arr.drop(3))
    end
    
    def scan(enu)
        spans = []
        @reverse = false
        
        while enu.size != 0
            graphs = enu[0].split(";")
            # !! assumes there is 1 or 2 graphics directives
            case graphs.size
            when 2
                sample = enu.take 4
                sample.delete_at(1)
                enu = enu.drop 4
            when 1
                sample = enu.take 3
                enu = enu.drop 3
            else
                Shoes.show_log
                raise "There is more than 2 graphics directives in the escape sequence : #{graphs.inspect}"
            end
            
            ## Now we have three items: 
            # an array of graphics directives (graphs or sample[0])
            # the text to be stylized (sample[1]), 
            # the following text, as is (sample[2]), until next escape sequence if exists
            
            unless @reverse # ouch !
                @styling = {}
            
                graphs.each do |g|
                    @styling.merge! case g
                        when "1"
                            {weight: "bold"}
                        when "4"
                            {underline: "single"}
                        when "7"
                            # styling differently
                            {stroke: darkred, emphasis: "italic"}
                        else
                            if g.length == 2
                                color = case g[1]
                                when "0"; black
                                when "1"; red
                                when "2"; green
                                when "3"; yellow
                                when "4"; blue
                                when "5"; magenta
                                when "6"; cyan
                                when "7"; white
                                end
                                { (g[0] == '3' ? :stroke : :fill) => color }
                            else
                                # means TODO not yet implemented or Error
                                # "5", "8" (blink, concealed)
                                {fill: darkorange}
                            end
                        end 
                end
                
                # "Reverse video on" (7) as "modifier" for preceding sequence
                # sequence is spread on 7..8 parts, not 3..4 as usual ('\e[32m\e[7m' instead of '\e[32;7m') 
                if sample[2] == '7' && sample[1].empty?
                    @reverse = true
                    next
                end
            else # fixing above .......
                sample[1] = graphs[0] + sample[1]
                @reverse = false
            end
            
            spans << span(sample[1], @styling) << sample[2]
        end
        spans
    end
    
end


=begin
# regex used to erase escape sequence from return of ri command
ESC_RE = '"s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
ret = `ri -f ansi Array | sed -r #{ESC_RE}`
=end
