# BearShop 🧸 — Hệ thống bán gấu bông online (Flutter + .NET)

Đồ án PRM393. Ứng dụng bán hàng trực tuyến gấu bông theo kiến trúc
**Frontend khách hàng (Flutter) + Backend (ASP.NET Core Web API) + Trang quản
trị** (có **2 lựa chọn** cùng tồn tại: ASP.NET Core MVC và Flutter Web), dùng
**ảnh thật**. Dữ liệu (tài khoản, sản phẩm, đơn hàng, chat) lưu thật trong CSDL
SQL Server ở backend. Có 2 vai trò: **Khách hàng** (mua sắm trên app Flutter)
và **Quản lý/Admin** (CRUD sản phẩm, quản lý đơn hàng/người dùng, thống kê,
trả lời chat — trên 1 trong 2 trang quản trị riêng, không dùng chung app với
khách hàng).

```
┌─────────────────┐     HTTP/JSON + JWT      ┌──────────────────────────┐
│  Flutter app    │ ───────────────────────► │  ASP.NET Core Web API     │
│  (Provider)     │ ◄─────────────────────── │  EF Core + SQL Server      │
│  Khách hàng     │   10.0.2.2:5095/api       │  BearShop.Api              │
└─────────────────┘                           └──────────────────────────┘
                                                        ▲     ▲
                                       server-to-server │     │ HTTP/JSON + JWT
                                              (HttpClient)     │ (gọi trực tiếp từ trình duyệt, CORS)
┌─────────────────┐                                    │     │
│  BearShop.Admin │ ───────────────────────────────────┘     │
│  ASP.NET MVC    │   localhost:5095/api                     │
│  Quản lý (web)  │                                           │
└─────────────────┘                                           │
                                                                │
┌─────────────────┐                                            │
│  admin_web      │ ───────────────────────────────────────────┘
│  Flutter Web    │   localhost:5095/api
│  Quản lý (web)  │
└─────────────────┘
        │
        ▼
  VNPay (thanh toán online, gọi từ BearShop.Api)
```

> Hai trang quản trị (`BearShop.Admin` và `admin_web`) là **2 lựa chọn tương
> đương**, cùng gọi 1 backend `BearShop.Api`, không phụ thuộc nhau — chỉ cần
> chạy 1 trong 2 để quản lý cửa hàng.

## Cấu trúc thư mục
```
online_sales_systems/
├── frontend/            # Flutter app — khách hàng (project riêng)
├── admin_web/           # Flutter Web — trang quản trị #2 (project riêng, độc lập với frontend/)
└── backend/
    ├── BearShop.Api/    # ASP.NET Core Web API — backend dùng chung
    ├── BearShop.Admin/  # ASP.NET Core MVC — trang quản trị #1 (web, không phải Flutter)
    └── BearShop.sln     # Solution gộp 2 project .NET trên
```

## Kiến trúc & công nghệ
**Frontend khách hàng (thư mục `frontend/lib/`)**
- State management: **Provider** (`AuthProvider`, `CartProvider`, `OrderProvider`,
  `ProductProvider`, `NotificationProvider`, `ChatProvider`)
- Gọi REST API: gói `http` qua `lib/services/api_service.dart`
- Lưu JWT/phiên: `shared_preferences`; định dạng tiền VND: `intl`
- Thanh toán VNPay: `webview_flutter` (nhúng trong app trên Android/iOS) /
  `url_launcher` (mở trình duyệt ngoài trên Web/Windows)
- Cache sản phẩm offline: `sqflite` (chỉ Android/iOS)
- Chỉ dành cho **Customer** — tài khoản Admin đăng nhập vào app này sẽ bị từ
  chối kèm thông báo dùng trang quản trị web.

**Backend dùng chung (thư mục `backend/BearShop.Api/`)**
- **ASP.NET Core Web API** (.NET 9), controllers
- **EF Core + SQL Server** (database `BearShopDb`, `Server=localhost`,
  Windows Authentication) — CSDL server thật, tự tạo bảng khi chạy lần đầu
  (`EnsureCreated`, không dùng migrations)
- **Xác thực JWT Bearer** kèm claim vai trò (Role: Customer/Admin); mật khẩu băm
  bằng **BCrypt**
- Validation phía server bằng DataAnnotations; CORS mở cho app
- **VNPay**: `Services/VnPayService.cs` ký/xác thực URL thanh toán bằng HMACSHA512

**Trang quản trị (thư mục `backend/BearShop.Admin/`)**
- **ASP.NET Core MVC + Razor** (.NET 9), Bootstrap 5 (đóng gói cục bộ, không CDN)
- Không truy cập CSDL trực tiếp — gọi `BearShop.Api` qua `HttpClient` typed
  (`Services/BearShopApiClient.cs`)
- Đăng nhập bằng **cookie riêng** của trang Admin; JWT của `BearShop.Api` được
  lưu trong 1 claim của cookie đó và tự động gắn vào mọi request gọi API qua
  `Services/JwtAuthHandler.cs` (một `DelegatingHandler`)
- Chỉ tài khoản `Role=Admin` mới đăng nhập được (kiểm tra ở `AccountController`
  + `AuthorizationPolicy` fallback yêu cầu `RequireRole("Admin")`)
- Các trang: `Dashboard`, `Products` (CRUD), `Orders` (đổi trạng thái), `Users`
  (khóa/mở khóa), `Chat` (danh sách hội thoại + trả lời)

**Trang quản trị #2 — Flutter Web (thư mục `admin_web/`)**
- Project **Flutter riêng biệt hoàn toàn** với `frontend/` (không dùng chung
  code) — chỉ build cho nền tảng **Web** (`flutter create --platforms web`)
- Cùng kiến trúc Provider + gọi REST API như app khách hàng: `AuthProvider`
  (chỉ nhận đăng nhập role `Admin`, từ chối role `Customer`), `AdminProvider`
  (sản phẩm/đơn hàng/người dùng/thống kê), `ChatProvider` (hội thoại theo khách
  hàng + trả lời)
- Gọi thẳng `BearShop.Api` **từ trình duyệt** qua gói `http` (không qua server
  trung gian) — cần CORS mở ở `BearShop.Api` (đã bật `AllowAnyOrigin`)
- Base URL cấu hình qua `lib/services/api_service.dart` (mặc định
  `http://localhost:5095/api`, đổi lúc build bằng
  `--dart-define=API_BASE_URL=...`)
- Các màn: `AdminShell` (sidebar) chứa `DashboardScreen`, `ProductsScreen`
  (CRUD qua dialog), `OrdersScreen` (đổi trạng thái), `UsersScreen`
  (khóa/mở khóa), `ChatListScreen` + `ChatDetailScreen`

### API endpoints (BearShop.Api — dùng chung cho app khách hàng và cả 2 trang quản trị)
| Method | Route | Mô tả | Auth |
|--------|-------|-------|------|
| POST | `/api/auth/register` | Đăng ký (luôn tạo role Customer) | ❌ |
| POST | `/api/auth/login` | Đăng nhập (trả JWT + role) | ❌ |
| GET | `/api/products` | Danh sách sản phẩm (lọc `?category=`) | ❌ |
| GET | `/api/products/{id}` | Chi tiết sản phẩm | ❌ |
| POST/PUT/DELETE | `/api/products` | Tạo/sửa/xóa sản phẩm | ✅ Admin |
| GET | `/api/orders` | Đơn hàng của tôi | ✅ JWT |
| POST | `/api/orders` | Tạo đơn hàng | ✅ JWT |
| GET | `/api/orders/all` | Tất cả đơn hàng | ✅ Admin |
| PUT | `/api/orders/{id}/status` | Cập nhật trạng thái đơn | ✅ Admin |
| GET | `/api/users` | Danh sách người dùng | ✅ Admin |
| PUT | `/api/users/{id}/status` | Khóa/mở khóa tài khoản | ✅ Admin |
| GET | `/api/dashboard` | Thống kê tổng quan + doanh thu 7 ngày + đơn theo trạng thái | ✅ Admin |
| GET/POST | `/api/chat/mine` | Xem/gửi tin nhắn hội thoại của tôi | ✅ JWT |
| GET | `/api/chat/conversations` | Danh sách hội thoại theo khách hàng | ✅ Admin |
| GET/POST | `/api/chat/{customerId}` | Xem/trả lời hội thoại 1 khách hàng | ✅ Admin |
| POST | `/api/payment/vnpay/create` | Tạo URL thanh toán VNPay cho 1 đơn | ✅ JWT |
| GET | `/api/payment/vnpay-return` | VNPay redirect về sau khi thanh toán | ❌ (VNPay gọi) |

## Cách chạy
**0. Yêu cầu:** SQL Server (Developer/Express/LocalDB đều được) chạy sẵn trên máy,
instance mặc định (`Server=localhost`, Windows Authentication). Đổi connection
string trong `backend/BearShop.Api/appsettings.json` nếu dùng instance khác.

**1. Chạy backend trước:**
```bash
cd backend/BearShop.Api
dotnet run                       # lắng nghe http://localhost:5095
```
Lần chạy đầu sẽ tự tạo database `BearShopDb` + toàn bộ bảng + seed dữ liệu mẫu
(sản phẩm, tài khoản demo — xem mục **Tài khoản test** bên dưới).

> **Thanh toán VNPay**: cần đăng ký sandbox miễn phí tại
> [sandbox.vnpayment.vn](https://sandbox.vnpayment.vn), sau đó điền `TmnCode` và
> `HashSecret` thật vào `backend/BearShop.Api/appsettings.json` (mục `VnPay`).
> Nếu chưa điền, đơn hàng vẫn tạo được bình thường nhưng bước mở trang VNPay sẽ
> báo lỗi từ phía VNPay (sai/chưa duyệt merchant).

**2. Chạy trang quản trị (chỉ cần chạy 1 trong 2 — cả 2 đều cần backend ở bước 1 đang chạy):**

**2a. Trang quản trị #1 — web .NET (`BearShop.Admin`):**
```bash
cd backend/BearShop.Admin
dotnet run                       # lắng nghe http://localhost:5190
```
Mở `http://localhost:5190`, đăng nhập bằng tài khoản Admin seed sẵn (xem mục
**Tài khoản test**). Địa chỉ gọi tới `BearShop.Api` cấu hình ở
`backend/BearShop.Admin/appsettings.json` (mục `Api:BaseUrl`).

Hoặc mở cả 2 project .NET cùng lúc qua solution:
```bash
cd backend
dotnet build BearShop.sln
```

**2b. Trang quản trị #2 — Flutter Web (`admin_web`):**
```bash
cd admin_web
flutter pub get
flutter run -d chrome            # chạy trực tiếp trên Chrome, hoặc:
flutter run -d web-server --web-port=5200   # chạy như server, mở http://localhost:5200
flutter build web --release      # build tĩnh, deploy được lên bất kỳ static host nào
```
Đăng nhập bằng tài khoản Admin seed sẵn (xem mục **Tài khoản test**). Nếu
`BearShop.Api` không chạy ở `localhost:5095`, đổi base URL lúc chạy/build:
`flutter run -d chrome --dart-define=API_BASE_URL=http://may-chu:5095/api`.

**3. Chạy app Flutter cho khách hàng (emulator Android gọi host qua 10.0.2.2):**
```bash
cd frontend
flutter pub get
flutter run                      # chạy app
flutter test                     # 1 widget test + 2 unit test
flutter build apk --release      # build APK nộp bài
```
> Base URL được cấu hình trong `frontend/lib/services/api_service.dart`
> (`10.0.2.2` cho Android Emulator, `localhost` cho web/desktop).
> Android đã bật cleartext cho `10.0.2.2`/`localhost` (file
> `frontend/android/app/src/main/res/xml/network_security_config.xml`).

## Tài khoản test
| Vai trò | Email | Mật khẩu | Ghi chú |
|---|---|---|---|
| Khách hàng | `demo@bearshop.vn` | `123456` | Đăng nhập trên app Flutter |
| Quản lý (Admin) | `admin@bearshop.vn` | `admin123` | Đăng nhập trên `http://localhost:5190` (BearShop.Admin) **hoặc** `admin_web` — không đăng nhập được trên app Flutter khách hàng |

Đăng ký tài khoản mới qua màn Đăng ký (Flutter) luôn tạo role Customer — chỉ
tài khoản admin seed sẵn ở trên mới vào được trang quản trị.

## Danh sách màn hình
**Khách hàng — app Flutter (12 màn — đủ cho nhóm 5 người, mỗi người ≥ 2)**
1. Đăng nhập — validation email/mật khẩu, gọi API
2. Đăng ký — validation họ tên, email, SĐT, mật khẩu, xác nhận
3. Trang chủ / danh sách sản phẩm — tải từ API, lọc danh mục, kéo để refresh,
   tự chuyển sang xem cache offline khi mất mạng
4. Tìm kiếm
5. Chi tiết sản phẩm
6. Giỏ hàng
7. Thanh toán — validation, tạo đơn qua API, hỗ trợ COD/chuyển khoản/**VNPay**
8. Đặt hàng thành công
9. Lịch sử đơn hàng — đọc từ API (theo JWT)
10. Thông báo
11. Bản đồ / cửa hàng
12. Chat với shop — nhắn tin thật qua backend, Admin trả lời (trên trang web)
+ Khung điều hướng `main_shell` (BottomNavigationBar) và `profile_screen`.

**Quản lý — trang web BearShop.Admin (5 trang, ASP.NET Core MVC)**
1. Tổng quan (`/Dashboard`) — số liệu tổng, biểu đồ doanh thu 7 ngày, đơn theo
   trạng thái, sản phẩm bán chạy, đơn gần đây
2. Sản phẩm (`/Products`) — CRUD đầy đủ (thêm/sửa/xóa)
3. Đơn hàng (`/Orders`) — xem tất cả đơn, đổi trạng thái
4. Người dùng (`/Users`) — xem danh sách, khóa/mở khóa tài khoản
5. Tin nhắn (`/Chat`) — danh sách hội thoại theo khách hàng, trả lời trực tiếp

**Quản lý — trang web admin_web (5 màn tương đương, Flutter Web)**
1. Tổng quan (`DashboardScreen`) — cùng số liệu như bản .NET
2. Sản phẩm (`ProductsScreen` + `product_form_dialog.dart`) — CRUD qua dialog
3. Đơn hàng (`OrdersScreen`) — đổi trạng thái qua bottom sheet
4. Người dùng (`UsersScreen`) — khóa/mở khóa tài khoản
5. Tin nhắn (`ChatListScreen` + `ChatDetailScreen`) — danh sách hội thoại, trả lời

## Kiểm thử
- Unit test: `frontend/test/unit/cart_provider_test.dart`, `frontend/test/unit/validators_test.dart`
- Widget test: `frontend/test/widget_test.dart` (màn đăng nhập + validation),
  `admin_web/test/widget_test.dart` (màn đăng nhập trang quản trị + validation)
- `flutter analyze` sạch ở cả `frontend/` và `admin_web/` (không lỗi biên dịch)
- Backend đã được smoke-test toàn bộ endpoint (auth, products, orders, admin,
  chat, dashboard, 401/403/400)
- BearShop.Admin đã build thành công (`dotnet build`) và được smoke-test thật
  qua HTTP (đăng nhập admin, xem Dashboard với dữ liệu thật từ SQL Server, tạo
  và xóa sản phẩm qua form)
- `admin_web` đã build thành công cho Web (`flutter build web --release`) và
  `flutter test` chạy qua
