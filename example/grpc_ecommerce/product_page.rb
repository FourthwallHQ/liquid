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
  # Simple in-memory cache with TTL
  class Cache
    def initialize(max_age: 60)
      @max_age = max_age
      @store = {}
    end

    def fetch(key)
      entry = @store[key]
      if entry && (Time.now - entry[:time] < @max_age)
        entry[:value]
      else
        value = yield
        @store[key] = { value: value, time: Time.now }
        value
      end
    end
  end

  # Renders a product page using data fetched from three gRPC services
  class ProductPage
    def initialize(product_client, category_client, recommendation_client)
      @product_client = product_client
      @category_client = category_client
      @recommendation_client = recommendation_client
      @cache = Cache.new(max_age: 300)
    end

    def render(product_id)
      futures = Concurrent::Promises.zip(
        fetch_product(product_id),
        fetch_categories,
        fetch_recommendations(product_id),
      )

      product, categories, recommendations = futures.value!
      template.render(
        'product' => product,
        'categories' => categories,
        'recommendations' => recommendations,
      )
    end

    private

    def fetch_product(id)
      Concurrent::Promises.future do
        @cache.fetch("product:#{id}") do
          @product_client.fetch(ProductRequest.new(id: id))
        end
      end
    end

    def fetch_categories
      Concurrent::Promises.future do
        @cache.fetch('categories') do
          @category_client.list(Empty.new)
        end
      end
    end

    def fetch_recommendations(id)
      Concurrent::Promises.future do
        @cache.fetch("recommendations:#{id}") do
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
      # Replace with real gRPC call
      DemoProduct.new(name: "Demo Product", description: "Example", price: 10)
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
