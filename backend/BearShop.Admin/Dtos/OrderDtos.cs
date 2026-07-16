using System.ComponentModel.DataAnnotations;

namespace BearShop.Admin.Dtos;

public class OrderItemDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public double Price { get; set; }
    public int Quantity { get; set; }
}

public class OrderDto
{
    public int Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public int UserId { get; set; }
    public DateTime CreatedAt { get; set; }
    public double Total { get; set; }
    public string ReceiverName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public string Status { get; set; } = "pending";
    public string PaymentStatus { get; set; } = "unpaid";
    public List<OrderItemDto> Items { get; set; } = [];
}

public class UpdateOrderStatusDto
{
    [Required(ErrorMessage = "Vui lòng chọn trạng thái.")]
    public string Status { get; set; } = string.Empty;
}

/// <summary>Trạng thái đơn hàng — khớp với enum OrderStatus phía trước đây dùng trong app Flutter.</summary>
public static class OrderStatuses
{
    public const string Pending = "pending";
    public const string Shipping = "shipping";
    public const string Completed = "completed";
    public const string Cancelled = "cancelled";

    public static readonly string[] All = [Pending, Shipping, Completed, Cancelled];

    public static string Label(string status) => status switch
    {
        Shipping => "Xác nhận",
        Completed => "Giao thành công",
        Cancelled => "Hủy đơn",
        _ => "Chờ xác nhận",
    };

    public static string BadgeClass(string status) => status switch
    {
        Shipping => "text-bg-primary",
        Completed => "text-bg-success",
        Cancelled => "text-bg-danger",
        _ => "text-bg-warning",
    };
}
