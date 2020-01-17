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

    def json
      FileNotFoundException.new("File not Found: #{metrics_file}") unless has_metrics?
      return unless has_metrics?
      File.open(metrics_file) do |file|
        yield JSON.load(file, symbolize_names: true)
      end
    end
  end

  class ProductsProvider
    attr_reader :products

    def initialize
        @products = Dir.glob(PRODUCT_PATH + "/*").map { |dir_path| Product.new dir_path }     
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