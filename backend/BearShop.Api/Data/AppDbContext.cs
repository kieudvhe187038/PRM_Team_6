using BearShop.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Data;

/// <summary>EF Core DbContext — ánh xạ các bảng và seed dữ liệu sản phẩm.</summary>
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<User>().HasIndex(u => u.Email).IsUnique();
        b.Entity<Order>().HasIndex(o => o.Code).IsUnique();

        // Seed danh mục sản phẩm gấu bông (ảnh thật từ Unsplash).
        b.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Gấu Teddy bông trắng 1m2", Category = "Gấu Teddy", Price = 450000, Rating = 4.8, Sold = 1240, Stock = 35, ImageUrl = "https://images.unsplash.com/photo-1559454403-b8fb88521f11?w=600&q=80", Description = "Gấu Teddy lông trắng siêu mềm mịn, cao 1m2, nhồi bông gòn cao cấp. Quà tặng lý tưởng cho người thương trong các dịp sinh nhật, Valentine." },
            new Product { Id = 2, Name = "Gấu nâu áo len khổng lồ", Category = "Gấu nâu", Price = 620000, Rating = 4.9, Sold = 980, Stock = 20, ImageUrl = "https://images.unsplash.com/photo-1562040506-a9b32cb51b94?w=600&q=80", Description = "Gấu nâu mặc áo len dệt kim ấm áp, đường may chắc chắn. Kích thước lớn, ôm cực đã, phù hợp trang trí phòng ngủ." },
            new Product { Id = 3, Name = "Thú bông gấu trúc dễ thương", Category = "Thú bông", Price = 280000, Rating = 4.7, Sold = 2100, Stock = 60, ImageUrl = "https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&q=80", Description = "Gấu trúc bông đen trắng đáng yêu, chất liệu nhung mềm an toàn cho trẻ em. Size vừa tay, dễ mang theo bên mình." },
            new Product { Id = 4, Name = "Gấu Teddy nơ hồng", Category = "Gấu Teddy", Price = 350000, Rating = 4.6, Sold = 760, Stock = 45, ImageUrl = "https://images.unsplash.com/photo-1612213467223-3d6cc6f1c2ff?w=600&q=80", Description = "Gấu Teddy thắt nơ hồng điệu đà, lông mượt không rụng. Món quà ngọt ngào dành cho các cô gái." },
            new Product { Id = 5, Name = "Gấu bông mini để bàn", Category = "Gấu mini", Price = 99000, Rating = 4.5, Sold = 3400, Stock = 120, ImageUrl = "https://images.unsplash.com/photo-1535990379313-44fdcca50e16?w=600&q=80", Description = "Gấu bông mini cao 20cm, nhỏ gọn để bàn học, bàn làm việc hoặc treo balo. Giá hạt dẻ, mua làm quà tặng kèm." },
            new Product { Id = 6, Name = "Gấu nâu ôm tim \"I Love You\"", Category = "Gấu nâu", Price = 410000, Rating = 4.8, Sold = 1500, Stock = 30, ImageUrl = "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600&q=80", Description = "Gấu nâu ôm trái tim thêu chữ \"I Love You\", biểu tượng tình yêu. Lựa chọn hoàn hảo cho ngày kỷ niệm." },
            new Product { Id = 7, Name = "Thỏ bông tai dài", Category = "Thú bông", Price = 230000, Rating = 4.7, Sold = 890, Stock = 50, ImageUrl = "https://images.unsplash.com/photo-1606115915090-be18fea23ec7?w=600&q=80", Description = "Thỏ bông tai dài màu pastel, mềm mại đáng yêu. Bạn đồng hành dễ thương cho bé khi đi ngủ." },
            new Product { Id = 8, Name = "Gấu Teddy size đại 1m6", Category = "Gấu Teddy", Price = 890000, Rating = 5.0, Sold = 420, Stock = 12, ImageUrl = "https://images.unsplash.com/photo-1558877385-81a1c7e67d72?w=600&q=80", Description = "Gấu Teddy khổng lồ cao 1m6, ôm trọn vòng tay. Quà tặng \"siêu to khổng lồ\" gây bất ngờ cho người nhận." }
        );
    }
}
