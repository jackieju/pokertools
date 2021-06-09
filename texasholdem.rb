require_relative "rubyutility.rb"
require_relative "arrayparser.rb"

def print_usage()
    print "===== usage ======\n"
    print "ruby texasholdem.rb -t <times> -p <player number> norank nosim norecord \n"
    print "Times default is never stop， press control-c to stop. \n"
   # print "Player number is 9 \n"
    print "By default will do simulation while recording to file, and do ranking using records in file afterwards.\n"
    print "If specify norecord, analyzing will only use record in memory.\n"
    print "If you only analyze records, using 'ruby texasholdem.rb nosim'\n"
end

def gen_cards
    ar = []
    for i in 0..3
        for j in 2..14
            #ar.push("#{j.to_s(16)}#{i}")
            #ar.push("#{j.to_s(16)}#{i}".chars)
            ar.push([j, i])
        end
    end
    return ar
end

# big to small sort
def sort_cards(a)
    a = a.sort{|i,j|
         j[0] <=>  i[0]
    }
    return a
end

#cards = gen_cards
#p cards
#p cards.size
#p sort_cards(cards)

def is_flush(a, out)
    a[0].last ==  a[1].last  && a[0].last == a[2].last && a[0].last == a[3].last && a[0].last == a[4].last
end

def is_straight(a, out)
     a[0].first-1 ==  a[1].first && a[1].first-1 ==  a[2].first && a[2].first-1 ==  a[3].first && a[3].first-1 ==  a[4].first 
end

def is_fullhouse(a,out)
    out.clear
    find = false
    for i in 0 .. a.size-1
        s = [i]
        ss = [a[i]]
        for j in  (i+1) .. a.size-1
            if a[i][0] == a[j][0]
                s.push(j)
                 ss.push(a[j])
            end
        end

        if s.size ==3 
            find = true
            out.concat(ss)
            break
        end

        
    end
    return false if !find
    
    b = [0,1,2,3,4] - s
    #p a
    #p b
    if a[b[0]][0] == a[b[1]][0]
        out.push(a[b[0]])
        out.push(a[b[1]])
        return true
    end
    return false
end


def is_stripes(a,out)
    out.clear
    for i in 0 .. a.size-1
        s = [i]
        ss = [a[i]]
        for j in i+1..a.size-1
            if  a[i][0] == a[j][0]
                s.push(j)
                ss.push(a[j])
            end
        end
        if s.size ==3 
            out.concat(ss)
            for k in 0..a.size-1
                out.push(a[k]) if !s.include?(k)
            end
            return true
        end
    end
    return false
end

def is_twopairs(b,out)
    out.clear()
    a = b.clone
    find = []
    i = 0
    for i in 0..a.size-1
        break if i > a.size-1
        c = a[i]
      #  s = [i]
        ss = [c]
        for j in i+1..a.size-1
            if c[0] == a[j][0]
                ss.push(a[j])
            end
        end
       
        if ss.size == 2
            find.push(ss)
            if find.size >= 2
                if find[0][0][0] > find[1][0][0]
                    out.concat(find[0])
                    out.concat(find[1])
                else
                    out.concat(find[1])
                    out.concat(find[0])
                end
                a.delete(find[0][0])
                a.delete(find[0][1])
                a.delete(ss[0])
                a.delete(ss[1])
                if a.size != 1
                    raise "size of a is not 1 ! #{a}"
                end
                out.push(a[0])
                return true
            end
        end
        
        if ss.size >= 2 # can be tripes
            ss[1..ss.size-1].each{|sss|
                a.delete(sss)
            }
        end

    end
    
    return false
end

def is_onepair(a,out)
    out.clear()
    for i in 0 .. a.size-1
        s = [i]
        for j in i+1..a.size-1
            if a[i][0] == a[j][0]
                #p "#{a[i][0]} == {a[j][0]}"
                s.push(j)
                out.push(a[s[0]])
                out.push(a[s[1]])
                b = a.clone
                b.delete_at(s[0])
                b.delete_at(s[1])
                out.concat(b)
                return true
            end
        end
         #p "s1 = #{s}"
    end
    return false
end

def is_fourofakind(a, out)
    out.clear()
    #for i in 0 .. a.size-1
    #    s = [i]
    #    for j in i+1..a.size-1
    #        if a[i][0] == a[j][0]
    #            s.push(j)
    #        end
    #    end
    #    if s.size == 4
    #        return true
    #    end
    #end
    
    # sorted, so only two possiblity 
    if a[0][0] == a[1][0] && a[1][0] == a[2][0] && a[2][0] == a[3][0]     
         out.concat(a)
         return true
    elsif a[1][0] == a[2][0] && a[2][0] == a[3][0] && a[3][0] == a[4][0] 
        out.concat(a[1..4])
        out.push(a[0])
        return true
    end
    return false
end
# score of cards array
# a alreadys sorted
# return [score, desc, reordered_cards]
def score(a)
    # flush straight    8000
    # four of a kind    7000
    # full houlse       6000
    # flush             5000
    # straight          4000
    # tripes            3000
    # two pairs         2000
    # one pair          1000
    # high card         0
    s = 0
    d = ""
    out = a.clone
    # is flush straight
    if is_flush(a,out)
        if is_straight(a,out)
            s += 8000
            d = "straight flush"
        else
            s += 5000
            d = "flush"
        end
    elsif is_fourofakind(a,out)
        d ="four of a kind"
        s += 7000
    elsif is_straight(a,out)
        d ="straight"
        s += 4000
    elsif is_fullhouse(a,out)
        d = "fullhouse"
        s += 6000
    elsif is_stripes(a,out)
        d = "stripes"
        s += 3000
    elsif is_twopairs(a,out)
        d = "twopairs"
        s += 2000
    elsif is_onepair(a,out)
        d ="one pair"
        s += 1000
    else
        out = a.clone
        d = "high card"
    end
    return [s, d, out]
end

# a, b already sorted
def compare_high(a,b)
   # p a
   # p b

    for i in 0..a.size-1
        if a[i][0] > b[i][0]
            return 1
        elsif a[i][0] < b[i][0]
            return -1
        end
    end
    return 0
end

def compare(a, b)
    a = sort_cards(a)
    b = sort_cards(b)
    
    #p "compare1:#{a}"
    #p "compare2:#{b}"
    sa = score(a) 
  #  p sa
    sb = score(b)
  #  p sb
    
    if sa[0] == sb[0]
       # if sa[0] < 1000
       #     return compare_high(a,b)
       # elsif sa[0] < 2000
       # elsif sa[0] < 3000
       # elsif sa[0] < 4000
       # elsif sa[0] < 5000
       # elsif sa[0] < 6000
       # elsif sa[0] < 7000 
       # elsif sa[0] < 8000    
       #     
       # elsif sa[0] < 9000
            return compare_high(sa[2],sb[2])
       # end
    elsif sa[0] > sb[0]
        return 1
    else
        return -1
    end
end


def show_cards(a, only_number=false)
    r = ""
    for i in 0..a.size-1
        s = ""
        c = a[i]
        if c[0]>=10
            case c[0]
                when 10
                    s += "T"
                when 11
                     s += "J"
                when 12
                     s += "Q"
                when 13
                     s += "K"
                when 14
                     s += "A"
            end
        else
            s += "#{c[0]}"
        end
        
        if !only_number
            case c[1]
                when 0
                     s += "♦️"
                when 1
                     s += "♠️"
                when 2
                     s += "♥️"
                when 3
                     s += "♣️"
            end
        end
        if only_number
            r += "#{s}"
        else
            r += "#{s}  "
        end
    end
    
    if a.size ==2 && only_number
        #if a[0][0] == a[1][0] 
        #    p "==>#{a}, #{a[0][1]}, #{a[1][1]}， #{a[0][1]==a[1][1]}"
        #end
        if a[0][1] == a[1][1]
            r += "s"
        else
            r += "o"
        end
        #if  a[0][0] == a[1][0] && a[0][1] == a[1][1]
        #   p "ssssss:#{r}"
        #end
    end
    
    return r
end
def test
    srand()
    cards = gen_cards
    
    a = [] 
    b = []
    for i in 0..4
        k = rand(cards.size)
        a.push(cards[k])
        cards.delete_at(k)
    end
    
    for i in 0..4
        k = rand(cards.size)
        b.push(cards[k])
        cards.delete_at(k)
    end
    
 #   a = sort_cards(a)
 #  b = sort_cards(b)
    p "==="
    p a
    p "#{show_cards(a)}  #{score(a)[1]}"
    p b
    p "#{show_cards(b)}  #{score(b)[1]}"
    
    r = compare(a,b)
    
    if r == 1
        p "#{show_cards(a)} win"
    elsif r == -1
        p "#{show_cards(b)} win"
    else
        "duce"
    end
            
end



def pick5in7(a)
    #p "pick5in7:#{a}"
    g = nil
    for i in 0..6
        for j in i+1..6
            b =  a.clone
            b.delete(a[i])
            b.delete(a[j])
            if !g ||compare(b,g) ==1
                g = b
            end
        end
    end
    return sort_cards(g)
end

def test_pick5in7
    srand()
    cards = gen_cards
    
    a = []
    for i in 0..6
        k = rand(cards.size)
        a.push(cards[k])
        cards.delete_at(k)
    end
    
    b = pick5in7(a)
    
    p "#{show_cards(a)}"
    p "#{show_cards(b)} "
    p score(b)
end

def deal(cards)
    k = rand(cards.size)
    a = cards[k]
    cards.delete_at(k)
    return a
end
$g_list= []
def sim(player_number)
    
    srand()
    cards = gen_cards
    players = []
    for i in 0..player_number-1
        a = []
        a.push(deal(cards))
        a.push(deal(cards))
        a = sort_cards(a)

        players.push([a, nil])
    end
    
    public_cards = []
    for i in 0..4
        public_cards.push(deal(cards))
    end
    p "public cards:#{show_cards(public_cards)}"
    g = -1
    start_cards = []
   # scores = []
    for i in 0..player_number-1
        start_cards.push(players[i][0])
        players[i][1] = pick5in7(players[i][0]+public_cards)
        if g == -1 || compare(players[i][1], players[g][1]) == 1
            g = i
        end
        players[i][2] = score(players[i][1])
     #   scores.push(players[i][2])
    end
    p "player #{g} win!"
   

    for i in 0..player_number-1
        kk = players[i][2]
        org = players[i][0]
        p "player[#{i}]: #{show_cards(org[0..1])} --- #{show_cards(players[i][1])} #{kk[1]}"
    end

   
   return [
        public_cards,
        start_cards,
        g   # winner
    ]
    
end

def append_array_to_file(fname, ar)
    #p "append_array_to_file"
    
    content = ""
    ar.each{|l|
        content+="#{l}\n"
        #p "line:#{l}"
    }
    append_file(fname, content)
end


def load_array_from_file(fname)
    content = read_file(fname)
    if content == nil
        raise "load file #{fname} failed"
    end
    p "file #{fname} loaded, size #{content.size}"
    list = []
    i = 0
  #  p content
    begin # can be interrupt
        content.lines.each{|l|
       # File.foreach(fname) { |l|
    
               #p "=>#{l}"
            list.push(ArrayParser.new(l).parse_array())
            i +=1
            if i % 1000 == 0
                print "loading #{i}th record\r"
            end

             #
             #print "\\\r"
             #print "|\r"
             #print "/\r"
     
        }
    rescue SystemExit, Interrupt => e
    end
    print "\n"
   
   # p list
   p "#{list.size} records loaded"
   return list
end

def run_sim(times=1000, sleep_interval=100, sleep_time=0.1)
    list = []
    i = 0
    for i in 0..times
        p "*****test #{i}/#{$sim_num}******"
        #test
       # test_pick5in7
       r = sim($player_num)
      
      list.push(r)
      $g_list.push(r)
        $sim_num +=1
      if (sleep_interval)
           if i == sleep_interval
               sleep(sleep_time)
               i = 0
           else
               i += 1
           end
       end
    end
    
    # serialize, but not human readible, and easy to be corrupt
    # o = Marshal.dump($g_list)
    # Marshal.load File.read('g_list') to load
    #append_file("g_list", o)
    
   # append_array_to_file($record_file, $g_list)
   return list
end

def get_record(r)
    return {
        :public_cards=>r[0],
        :start_cards=>r[1], # start cards of all players
        :winner=>r[2] 
    }
end

def get_record2(r)
    return [
            r[0], # public cards
            r[1], # start cards of all players
            r[2]  # winner
        ]
        
end
def hands_rank(records)
    p "start analyze hands result..."
    list = {}
    count = 0
    begin # can be interrupt
    records.each{|r|
        #    p r
                pc, sc, winner =  get_record2(r)
                scores = []
                for i in 0..sc.size-1
                    c = pick5in7(sc[i]+pc)
                    scores.push([i,score(c)[0]])
                end
                
                scores = scores.sort_by{|e|
                    e[1]
                }.reverse()
                
                win_equity = scores[0][1]+scores[1][1]
                loser = scores[1][0]
                #p "scores:#{scores}"
    

                for i in 0..sc.size-1
                    c = sc[i]
                    cards = "#{show_cards(c, true)}"
                     if list[cards]==nil
                          list[cards] = {
                              :win=>0,
                              :total=>1,
                              :equity =>0
                          }
                     else
                          list[cards][:total] +=1
                     end

                     if winner == i
                         list[cards][:win] +=1
                         list[cards][:equity] += win_equity
                     end
                     if loser == i
                         list[cards][:equity] -= win_equity
                     end
                 
                end

                count +=1
                if count%1000 == 0
                    print "processed #{count} game\n"
                    sleep(0.2)
                end
        
        }
    rescue SystemExit, Interrupt => e
    end
    list.each{|k,l|
        l[:winrate] = l[:win].to_f/l[:total]
        l[:rate] = l[:total].to_f / count
        l[:equity] = l[:equity] / l[:total]
        l[:x] = l[:equity] * l[:rate] 
    }
    
    p list
    r = list.sort_by{|k,v|
        v[:winrate]
    }
    
    # save range
    range_rank = []
    r.each{|l|
        p l
        range_rank.push([l[0], l[1][:winrate]])
    }    
    rrs = "\##{$player_num} player table from #{count} hand\n"
    range_rank.each{|l|
        rrs += l.to_s + ",\n"
    }
    #print rrs
    
    save_to_file(rrs, "range_#{Time.now}")
    
    p "*** bottom 20"
    r[0..20].reverse.each{|l|
        p l
    }

    p "*** top 20"
    for i in r.size-21..r.size-1
        p r[i]
    end    
    
    # by equity
    r = list.sort_by{|k,v|
        v[:equity]
    }

    p "*** by equity"
    for i in 0..r.size-1
        p r[i]
    end  
    
    
    # by x
    #r = list.sort_by{|k,v|
    #    v[:x]
    #}
    #p "*** top 20 x"
    #for i in r.size-21..r.size-1
    #    p r[i]
    #end  
       
    p "total hands #{count}"
    p "best hand #{r[r.size-1]}"
end

def how_AA(list)
    ace_number = 0
    ace_win = 0
    ace_hand = []
    list.each{|r|
        #p r
        for i in 0..r[1].size-1
            c = r[1][i] # start hand
            if c[0][0] == 14 && c[1][0] == 14  # is AA ?
                ace_hand.push([r,i])
                ace_number +=1
                if r[2] == i
                    ace_win +=1
                end
            end
        end
    }
    p "AA #{ace_number} win #{ace_win} in total #{list.size} hand"
    ace_hand.each{|h|
        r = h[0]
        pos = h[1]
        p "----"
        p "public:#{show_cards(r[0])}"
        p "#{show_cards(r[1][pos])}"
        p "#{show_cards(r[1][r[2]])}"

    }
end

$sim_num = 0
def run_sim_and_save(times)
    for i in 0..times/100
        list = run_sim(100, nil)
        if !$norecord
            append_array_to_file($record_file, list)
        end
        sleep(0.2)
    end
end



n = 99999999999

#if $*.size > 0
#    n = $*[0].to_i
#end
$nosim = false
$norank = false
$record_file = "records_9"
$player_num = 9
$norecord = false
if $*.size > 0
    for i in 0..$*.size-1
        cmd = $*[i]
        if cmd == "nosim"
            $nosim = true
        elsif cmd == "norank"
            $norank = true
        elsif cmd == "norecord"
            $norecord = true
        elsif cmd == "-t"
            i +=1
            cmd = $*[i]
            n = cmd.to_i
        elsif cmd == "-p"
            i += 1
            cmd = $*[i]
            $player_num = cmd.to_i
            $record_file = "records_#{$player_num}"
        end
    end
else
    print_usage()
    exit
end
if n < 100
    p "times cannot less than 100"
    return
end

t = Time.now.to_f
if !$nosim
    begin
        run_sim_and_save(n)
    rescue SystemExit, Interrupt => e
    end
    te = Time.now.to_f
    p "run #{ $sim_num } sim took #{te-t}s"
    t = te
else
    p "skip sim"
end
if !$norank
    begin
         if !$norecord
             p "load records from #{$record_file}"
             records = load_array_from_file($record_file)
         else 
             records = $g_list
         end
    rescue SystemExit, Interrupt => e
    end
    te = Time.now.to_f
    p "load #{records.size} records took #{te-t}s"
    t = te
    begin
        hands_rank(records)
    rescue SystemExit, Interrupt => e
    end
    te = Time.now.to_f
    p "analyze #{records.size} hands for #{$player_num} players took #{te-t}s"
    t = te
end


p "-----"
#p is_twopairs([[2,0],[2,8],[2,4],[6,4],[6,3]])
#p is_fullhouse([[2,0],[2,8],[2,4],[6,4],[6,3]])