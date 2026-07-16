using System.ComponentModel.DataAnnotations;

namespace BearShop.Api.Dtos;

/// <summary>Một dòng sản phẩm khi tạo đơn hàng.</summary>
public class OrderItemDto
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public double Price { get; set; }
    public int Quantity { get; set; }
}

/// <summary>Dữ liệu tạo đơn hàng — có validation phía server.</summary>
public class CreateOrderDto
{
    [Required(ErrorMessage = "Vui lòng nhập tên người nhận.")]
    public string ReceiverName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập số điện thoại.")]
    [RegularExpression(@"^(0|\+84)\d{9}$", ErrorMessage = "Số điện thoại không hợp lệ.")]
    public string Phone { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập địa chỉ.")]
    public string Address { get; set; } = string.Empty;

    [Required]
    public string PaymentMethod { get; set; } = string.Empty;

    [MinLength(1, ErrorMessage = "Đơn hàng phải có ít nhất 1 sản phẩm.")]
    public List<OrderItemDto> Items { get; set; } = new();
}

/// <summary>Dữ liệu cập nhật trạng thái đơn hàng (Admin).</summary>
public class UpdateOrderStatusDto
{
    [Required(ErrorMessage = "Vui lòng chọn trạng thái.")]
    public string Status { get; set; } = string.Empty;
}
