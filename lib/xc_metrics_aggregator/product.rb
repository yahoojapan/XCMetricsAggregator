require 'etc'
require 'json'

module XcMetricsAggregator
  PRODUCT_PATH = File.join('/', 'Users', Etc.getlogin, 'Library', 'Developer' , 'Xcode', 'Products')

  class Product
    def metrics_dir
      Pathname.new(File.join(@path, 'Metrics'))
    end

    def metrics_file
        Pathname.new(File.join(metrics_dir, 'AppStore/Metrics.xcmetricsdata'))
    end

    def bundle_id
        Pathname.new(@path).basename
    end

    def has_metrics?
        File.exists?(metrics_dir)
    end

    def initialize(path)
      @path = path
    end

    def open
      FileNotFoundException.new("File not Found: #{metrics_file}") unless has_metrics?
      return unless has_metrics?
      File.open(metrics_file) do |file|
        yield JSON.load(file, symbolize_names: true)
      end
    end
  end

  class ProductsService
    attr_reader :products

    def initialize
        @products = Dir.glob(PRODUCT_PATH + "/*").map { |dir_path| Product.new dir_path }     
    end

    def targets(bundle_ids=[])
      if bundle_ids.empty?
        products
      else
        products.select do |product|
           bundle_ids.include? product.bundle_id.to_s
        end
      end
    end

    def target(bundle_id)
      if bundle_id.nil?
        raise StandardError.new("needs bundle id")
      end

      products.select { |product| bundle_id == product.bundle_id.to_s }.first
    end

    def each_product(bundle_ids=[])
      targets(bundle_ids).each do |product|
        yield product
      end
    end

    def to_s
      rows = []
      products.each do |product|
        status = 
          if product.has_metrics?
            "has metrics"
          else
            "fail to get metrics"
          end
        rows << [product.bundle_id, status]
      end

      table = Terminal::Table.new :headings => ['bundle id', 'status'], :rows => rows
      table.to_s
    end
  end
end