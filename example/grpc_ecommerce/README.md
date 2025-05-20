# gRPC E-commerce Example

This example demonstrates how a product page can combine information from multiple gRPC services while keeping rendering responsive. Each service call is executed concurrently and cached to avoid unnecessary network requests.

```ruby
product_client = ProductService::Stub.new
category_client = CategoryService::Stub.new
recommendation_client = RecommendationService::Stub.new

page = Ecommerce::ProductPage.new(
  product_client,
  category_client,
  recommendation_client,
)

puts page.render(1)
```

The `ProductPage` class uses `Concurrent::Promises` for parallel fetches and a thread-safe cache with per-key TTLs. Replace the stub classes with real gRPC clients in a production environment.
