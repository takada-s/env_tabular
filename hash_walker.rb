require 'erb'

class HashWalker
  def initialize(erb_template, name)
    @key2env_vals = {}
    @envs         = []
    @erb_file     = erb_template
    @key2class    = {}
    @name         = name
  end

  def register(hash, env_name)
    @envs << env_name

    # walk into hash members
    walk(hash, env_name, '')
  end

  def hash_for(env)
    @key2env_vals[env]
  end

  def to_html
    calc_diff_class
    @keys       = @key2env_vals.keys.sort
    @conf       = @key2env_vals
    @class_map  = @key2class
    erb_content = File.read(@erb_file)
    ERB.new(erb_content).result(binding)
  end

  private
  def walk(hash, env_name, prefix)
    hash.each do |key, val|
      next_pref = "#{prefix}/#{key}"

      case val
        when Hash
          next_hash = val
          walk(next_hash, env_name, next_pref)

        else
          leaf_key = next_pref
          leaf_val = val.to_s

          leaf_val = case leaf_val
                       when nil
                         '(nil)'
                       when ''
                         '""'
                       else
                         leaf_val
                     end

          @key2env_vals[leaf_key]           ||= {}
          @key2env_vals[leaf_key][env_name] = leaf_val
      end
    end
  end

  def calc_diff_class
    return nil if @key2env_vals.empty?
    return @key2class unless @key2class.empty?

    # key2class: key -> { development => diff0, int => diff1, std => diff1, prd => diff2 }
    @key2env_vals.each do |key, vals|
      @key2class[key] ||= {}

      known = []

      vals.each do |env, val|
        idx     = known.find_index(val)
        diff_no =
            if idx
              idx % 10
            else
              known << val
              (known.size - 1) % 10
            end

        @key2class[key][env] = "diff#{diff_no}"
      end
    end

    @key2class
  end

end
