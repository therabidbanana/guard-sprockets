require 'guard'
require 'guard/guard'

require 'sprockets'

module Guard
  class Sprockets < Guard
    def initialize(watchers=[], options={})
      super 
      @destination = options.delete(:destination)
      @opts = options
    end

    def start
       UI.info "Sprockets waiting for js file changes..."
    end
    
    def run_all
      true
    end

    def run_on_change(paths)
      paths.each{ |js| sprocketize(js)}
      true
    end
    
    private
    
    def sprocketize(path)
      parts        = path.split('/')
      file         = parts.pop
      source_dir   = "#{parts[0...-1].join('/')}/*"
      destination  = parts[1..-1].join('/')
      @destination ||= destination
      secretary = ::Sprockets::Secretary.new(
        {
          :asset_root            => "#{parts.first}",
          :source_files          => ["#{path}"],
          :interpolate_constants => false
        }.merge(@opts)
      )
      # Generate a Sprockets::Concatenation object from the source files
      concatenation = secretary.concatenation
      # Write the concatenation to disk
      concatenation.save_to("#{@destination}/#{File.basename(path)}")
      # Install provided assets into the asset root
      secretary.install_assets
      UI.info "Sprockets creating file #{@destination}/#{File.basename(path)}"
    end
  end
end
