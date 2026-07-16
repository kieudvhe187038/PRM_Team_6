namespace BearShop.Api.Dtos;

/// <summary>Yêu cầu tạo URL thanh toán VNPay cho 1 đơn hàng.</summary>
public class CreateVnPayUrlDto
{
    public int OrderId { get; set; }
}

/// <summary>URL thanh toán VNPay trả về cho client mở WebView.</summary>
public class VnPayUrlResponse
{
    public string PaymentUrl { get; set; } = string.Empty;
}
