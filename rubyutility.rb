def max_int
    0xffffffff
end

def generate_password(length=6)  
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'  
  password = ''  
  length.downto(1) { |i| password << chars[rand(chars.length - 1)] }  
  password  
end  
  
 

def rand_get_from_array(ar)
    return ar[rand(ar.size)]
end

def obj_is_number?(o)
    return o.is_a?(Numeric)
end
def str_is_number?(s)
    return s.to_i.to_s == s
end


def unrand(min, max, rate=2)
  s = max - min +1
  index = (rand(rate*s)+rand(rate*s))/rate
  index = s-1 if index == s
  index = s-index%s if index > s
  return index + min
end

=begin pastable code
begin
    raise Exception.new
rescue Exception=>e
    stack = 100
    if e.backtrace.size >=2 
        stack  += 1
        stack = e.backtrace.size-1 if stack >= e.backtrace.size
        p e.backtrace[1..stack].join("\n") 
    end
end
=end
def show_stack(stack = nil)
	stack = 99999 if stack == nil || stack <= 0
	begin
	    raise Exception.new
	rescue Exception=>e
	    if e.backtrace.size >=2 
	        stack  += 1
	        stack = e.backtrace.size-1 if stack >= e.backtrace.size
	        return e.backtrace[1..stack].join("\n") 
	    end
	end
	return ""
end
def util_get_prop(prop, k)
      js = prop
      if js.class == String
            begin
                js = JSON.parse(prop)
            rescue Exception=>e
                p "parse json string failed, error:#{e.inspect}, string=#{prop}"
                err(e)
            end
          
      end
      if js
          return js[k]
      else
          return nil
      end
end
def util_set_prop(prop,n,v)
      js = prop
      if js.class == String
          js = JSON.parse(prop)
      end
      if js == nil
          js =JSON.parse("{}")
      end

    js[n] = v
   return  js.to_json
end

# ==========================
#  File system
# ==========================

# append content to file and add "\n" automatically
def append_file(fname, content)
    dir = get_dir(fname)
    FileUtils.makedirs(dir) if dir
     begin
         aFile = File.new(fname,"a")
         aFile.puts content
         aFile.close
     rescue Exception=>e
         # logger.error e
         p e.inspect
     end
end
def read_file(fname)
    begin
        if FileTest::exists?(fname) 
            data= nil  
            open(fname, "r") {|f|
                   data = f.read
            }
            return data
        end
    rescue Exception=>e
         logger.error e
         p e.inspect
    end
    return nil
end
def readout_file(fname)
    begin
    if FileTest::exists?(fname)   

        data = nil
        open(fname, "r+") {|f|
            data = f.read
                f.seek(0) 
                f.truncate(0)
            }
            return data
        end
    rescue Exception=>e
                logger.error e
                p e.inspect
    end
    return nil
end
def read_delete_file(fname)
    begin
    if FileTest::exists?(fname)   

        data = nil
        open(fname, "r+") {|f|
            data = f.read
             File.delete(fname)
            }
            return data
        end
    rescue Exception=>e
                logger.error e
                p e.inspect
    end
    return nil
end
def get_dir(path)
    if path.end_with?("/")
        return path[0..path.size-2]
    end
    index = path.rindex("/")
    return nil if !index
    return path[0..index-1]
end
def save_to_file(data, fname)
    dir = get_dir(fname)
    FileUtils.makedirs(dir) if dir
    begin
            open(fname, "w+") {|f|
                   f.write(data)
               }    
    rescue Exception=>e
         err e
         return false
    end
    return true
end
def append_to_file(data, fname)
    # append(fname, data)
    dir = get_dir(fname)
    FileUtils.makedirs(dir) if dir
     begin
         open(fname, "a") {|f|
                f.write(data)
            }
     rescue Exception=>e
         # logger.error e
         p e.inspect
     end
end
=begin
def test
  count = {}
  for a in 0..1000
    i = unrand(0, 10)
    if count[i] == nil
      count[i] = 0
    else
      count[i] += 1
    end
  end
  for a in 0..10
    p "#{a}:#{count[a]}"
  end
end
=end
# p i_to_ch(3)

p "hello rubyutility"