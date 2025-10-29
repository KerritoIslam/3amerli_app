# API Mapping — app -> backend

This file maps backend OpenAPI endpoints to the app's remote datasources / repositories. The backend base path is already set in `AppConstants.apiBaseUrl` (includes `/api/v1`).

Note: endpoints in the app use paths like `/authentication/otp/send` — the `ApiService` adds the base URL which already contains `/api/v1`.

- Authentication
  - POST /authentication/otp/send -> `lib/features/auth/data/datasources/auth_remote_datasource.dart` -> `sendOtp`
  - POST /authentication/otp/validate -> `auth_remote_datasource.dart` -> `validateOtp`
  - PUT  /authentication/register -> `auth_remote_datasource.dart` -> `register`
  - POST /authentication/refresh -> `auth_remote_datasource.dart` -> `refresh` and also used by `core/dio/auth_interceptor.dart` refresh flow

- User
  - GET /user/me -> `lib/features/auth/data/datasources/profile_remote_datasource.dart` (used by `ProfileRepositoryImpl`)
  - PUT /user/me -> update profile (check `profile_repository_impl.dart`)
  - PATCH /user/me/picture -> profile picture upload (if implemented in remote datasource)

- Products / Catalog
  - GET /products/all -> `lib/features/catalog/data/datasources/catalog_remote_datasource.dart`
  - GET /products/{id} -> `catalog_remote_datasource.dart` (single product)
  - POST /products/create -> product creation (used by seller flows, check `products_remote_datasource.dart`)
  - GET /products/main-categories -> `categories_remote_datasource.dart`
  - POST /products/categories -> create category

- Orders
  - POST /order -> `lib/features/orders/data/datasources/orders_remote_datasource.dart` -> `createOrder`
  - GET /order/all -> list orders
  - GET /order/{orderId}/products -> order products

- Notifications
  - GET/POST/PATCH/DELETE -> `lib/features/notifications/data/datasources/notifications_remote_datasource.dart`

If you want, I can:
- Expand this mapping into a machine-readable JSON and add path -> method tests.
- Update any datasource whose path/verb does not match the OpenAPI spec.

Small note: many datasources already use `ApiService` (Dio) and `AuthInterceptor`. I changed the interceptor to use status code ranges and to treat refresh success using 2xx ranges.
