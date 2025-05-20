# frozen_string_literal: true

require 'grpc'
require 'concurrent'
require 'liquid'
require 'ostruct'

DemoProduct = Struct.new(:name, :description, :price, keyword_init: true)
DemoCategory = Struct.new(:name, keyword_init: true)
ProductRequest = Struct.new(:id)
Empty = Struct.new(:dummy)
RecommendationsRequest = Struct.new(:product_id)

module Ecommerce
  # Thread-safe in-memory cache with per-key TTL
  class Cache
    Entry = Struct.new(:value, :expires_at)

    def initialize(default_ttl: 60)
      @default_ttl = default_ttl
      @store = Concurrent::Map.new
    end

    def fetch(key, ttl: @default_ttl)
      entry = @store[key]
      if entry && entry.expires_at > Time.now
        entry.value
      else
        value = yield
        @store[key] = Entry.new(value, Time.now + ttl)
        value
      end
    end
  end

  # Renders a product page using data fetched from three gRPC services
  class ProductPage
    def initialize(product_client, category_client, recommendation_client, executor: Concurrent.global_io_executor)
      @product_client = product_client
      @category_client = category_client
      @recommendation_client = recommendation_client
      @executor = executor
      @cache = Cache.new(default_ttl: 300)
    end

    def render(product_id)
      product_f = fetch_product(product_id)
      categories_f = fetch_categories
      recommendations_f = fetch_recommendations(product_id)

      product, categories, recommendations =
        Concurrent::Promises.zip(product_f, categories_f, recommendations_f).value!

      template.render(
        'product' => product,
        'categories' => categories,
        'recommendations' => recommendations,
      )
    end

    private

    def fetch_product(id)
      Concurrent::Promises.future_on(@executor) do
        @cache.fetch("product:#{id}") do
          @product_client.fetch(ProductRequest.new(id: id))
        end
      end
    end

    def fetch_categories
      Concurrent::Promises.future_on(@executor) do
        @cache.fetch('categories', ttl: 3600) do
          @category_client.list(Empty.new)
        end
      end
    end

    def fetch_recommendations(id)
      Concurrent::Promises.future_on(@executor) do
        @cache.fetch("recommendations:#{id}", ttl: 120) do
          @recommendation_client.list(RecommendationsRequest.new(product_id: id))
        end
      end
    end

    def template
      @template ||= Liquid::Template.parse(
        File.read(File.join(__dir__, 'templates', 'product_page.liquid')),
      )
    end
  end
end

# Example service stubs used for demonstration only
class ProductService
  class Stub
    def fetch(_request)
      DemoProduct.new(name: 'Demo Product', description: 'Example', price: 10)
    end
  end
end

class CategoryService
  class Stub
    def list(_request)
      [DemoCategory.new(name: 'Category A'), DemoCategory.new(name: 'Category B')]
    end
  end
end

class RecommendationService
  class Stub
    def list(_request)
      [DemoProduct.new(name: 'Another Product', price: 9)]
    end
  end
end
