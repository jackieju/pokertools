class ArrayParser
    
    def initialize(s)
        @buffer = s
        @pos = 0
        @ch = nil
    end
    def get
        @ch = @buffer[@pos]
    end
    def nextch
        @pos +=1
        get
    end
    
    def pos
        @pos
    end
    
    def ch 
        @ch
    end
    
    def white_space()
        while ch == "\n" or ch == " " or ch == "\r"
            nextch
        end
    end
    
    def expect(c)
        s = @buffer
        white_space

        if ch = c
            nextch
            return 
        end
        raise "parse failed"
    end

    def parse_array_content()
        ar = []
        i = 0
        white_space

        while ch != "]" 
            white_space
            
            c = ""
         #   p @pos
         #   p ch
            while ch != "]" && ch !=","
                if ch =="["
                     ar.push(parse_array())
                else
                    while ch != "]" && ch !=","
                       c += ch
                       nextch
                    end
                    ar.push(Integer(c))
                end
            end
            nextch if ch == ","
       
        end
        return ar
    end
    def parse_array()
        ar = []
        expect("[")
      
        ar.concat(parse_array_content())
      
    
        expect("]")
        return ar
    end
end

#s = "[[[14, 1], [6, 0], [14, 0], [7, 1], [13, 2]], [[[4, 3], [2, 2]], [[2, 0], [4, 2]], [[13, 3], [7, 2]], [[7, 3], [7, 0]], [[8, 3], [3, 2]], [[12, 3], [9, 1]], [[9, 0], [8, 0]], [[5, 0], [10, 3]], [[3, 1], [8, 2]]], 3]"
#p s
#p ArrayParser.new(s).parse_array()