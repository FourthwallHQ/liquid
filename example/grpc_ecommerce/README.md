# gRPC E-commerce Example

This example demonstrates how to render a product page using Liquid templates with data fetched from three gRPC services. Each service is queried in parallel and results are cached to speed up rendering.

Run the script below to render a demo page using stubbed service clients:

```ruby
product_client = ProductService::Stub.new
category_client = CategoryService::Stub.new
recommendation_client = RecommendationService::Stub.new

page = Ecommerce::ProductPage.new(product_client, category_client, recommendation_client)
puts page.render(1)
```

The `ProductPage` class shows how to orchestrate parallel gRPC requests and cache their responses.
