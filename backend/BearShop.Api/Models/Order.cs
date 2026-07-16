namespace BearShop.Api.Models;

/// <summary>Đơn hàng của người dùng.</summary>
public class Order
{
    public int Id { get; set; }
    public string Code { get; set; } = string.Empty; // mã đơn hiển thị, vd DH123
    public int UserId { get; set; }
    public User? User { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public double Total { get; set; }
    public string ReceiverName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public string Status { get; set; } = "pending";

    /// <summary>Trạng thái thanh toán online: "unpaid" | "paid" | "failed". Độc lập với Status (giao hàng).</summary>
    public string PaymentStatus { get; set; } = "unpaid";

    public List<OrderItem> Items { get; set; } = new();
}

/// <summary>Một dòng sản phẩm trong đơn hàng.</summary>
public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public Order? Order { get; set; }

    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public double Price { get; set; }
    public int Quantity { get; set; }
}
