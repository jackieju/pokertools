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

cards = gen_cards
p cards
p cards.size
p sort_cards(cards)

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
    p a
    p b
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
    p a
    p b

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
    
    p "compare1:#{a}"
    p "compare2:#{b}"
    sa = score(a) 
    p sa
    sb = score(b)
    p sb
    
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


def show_cards(a)
    r = ""
    for i in 0..a.size-1
        s = ""
        c = a[i]
        if c[0]>10
            case c[0]
                when  11
                     s += "J"
                when  12
                     s += "Q"
                when 13
                     s += "K"
                when 14
                     s += "A"
            end
        else
            s += "#{c[0]}"
        end
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
        r += "#{s}  "
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
    p "pick5in7:#{a}"
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

def sim(player_number)
    srand()
    cards = gen_cards
    players = []
    for i in 0..player_number-1
        a = []
        k = rand(cards.size)
        a.push(cards[k])
        cards.delete_at(k)
        
        k = rand(cards.size)
        a.push(cards[k])
        cards.delete_at(k)
        
        players.push([a, nil])
    end
    
    public_cards = []
    for i in 0..4
        k = rand(cards.size)
        public_cards.push(cards[k])
        cards.delete_at(k)
    end
    g = -1
    for i in 0..player_number-1
        players[i][1] = pick5in7(players[i][0]+public_cards)
        if g == -1 || compare(players[i][1], players[g][1]) ==1
            g = i
        end
    end
    
    p "public cards:#{show_cards(public_cards)}"
    for i in 0..player_number-1
        kk = score(players[i][1])
        org = players[i][0]
        p "player[#{i}]: #{show_cards(org[0..1])} --- #{show_cards(players[i][1])} #{kk[1]}"
    end
    p "player #{g} win  !"
    
end
for i in 0..100
    p "*****test #{i}******"
    #test
   # test_pick5in7
   sim(9)
end
p "-----"
#p is_twopairs([[2,0],[2,8],[2,4],[6,4],[6,3]])
#p is_fullhouse([[2,0],[2,8],[2,4],[6,4],[6,3]])