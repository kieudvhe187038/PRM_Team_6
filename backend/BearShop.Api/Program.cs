using System.Text;
using BearShop.Api.Data;
using BearShop.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// --- Dịch vụ ---
builder.Services.AddControllers().AddJsonOptions(o =>
{
    // Tránh lỗi vòng lặp tham chiếu khi serialize Order <-> OrderItem.
    o.JsonSerializerOptions.ReferenceHandler =
        System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
});
builder.Services.AddOpenApi();

// CSDL SQL Server thật (Server=localhost, database BearShopDb).
builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlServer(builder.Configuration.GetConnectionString("Default")));

builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<VnPayService>();

// Xác thực bằng JWT Bearer.
var jwt = builder.Configuration.GetSection("Jwt");
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwt["Issuer"],
            ValidAudience = jwt["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwt["Key"]!)),
        };
    });
builder.Services.AddAuthorization();

// Cho phép Flutter (emulator/web) gọi API.
builder.Services.AddCors(o => o.AddDefaultPolicy(p =>
    p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

// Tạo DB + seed dữ liệu khi khởi động (demo nên dùng EnsureCreated).
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();

    // Seed tài khoản demo để chấm bài đăng nhập nhanh.
    if (!db.Users.Any(u => u.Email == "demo@bearshop.vn"))
    {
        db.Users.Add(new BearShop.Api.Models.User
        {
            FullName = "Khách Demo",
            Email = "demo@bearshop.vn",
            Phone = "0900000000",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            Role = "Customer",
        });
        db.SaveChangesAsync().GetAwaiter().GetResult();
    }

    // Seed tài khoản quản lý (Admin) để chấm bài demo tính năng quản lý.
    if (!db.Users.Any(u => u.Email == "admin@bearshop.vn"))
    {
        db.Users.Add(new BearShop.Api.Models.User
        {
            FullName = "Quản lý BearShop",
            Email = "admin@bearshop.vn",
            Phone = "0900000001",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
            Role = "Admin",
        });
        db.SaveChangesAsync().GetAwaiter().GetResult();
    }
}

// --- Pipeline ---
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
