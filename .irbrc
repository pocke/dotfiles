require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:HISTORY_FILE] = File.expand_path('~/.cache/.irb_history') 

def ls(obj)
  methods = Set.new
  map = {}
  singleton_class = obj.singleton_class rescue nil

  [singleton_class, *obj.class.ancestors].compact.each do |klass|
    break if klass == Object

    ms = klass.instance_methods(false).reject { |m| methods.include?(m) }
    methods.merge ms
    map[klass] = ms
  end

  map.reverse_each.with_index do |(klass, ms), idx|
    next if ms.empty?

    p klass
    puts ms.join(' ')
    puts if idx != map.size - 1
  end

  nil
end if RUBY_VERSION < '3.1'
