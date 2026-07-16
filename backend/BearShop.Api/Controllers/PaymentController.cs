using System.Security.Claims;
using BearShop.Api.Data;
using BearShop.Api.Dtos;
using BearShop.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

/// <summary>Thanh toán online qua VNPay.</summary>
[ApiController]
[Route("api/[controller]")]
public class PaymentController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly VnPayService _vnPay;
    public PaymentController(AppDbContext db, VnPayService vnPay)
    {
        _db = db;
        _vnPay = vnPay;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? User.FindFirstValue("sub")!);

    /// <summary>Tạo URL thanh toán VNPay cho 1 đơn hàng của chính người dùng.</summary>
    [HttpPost("vnpay/create")]
    [Authorize]
    public async Task<ActionResult<VnPayUrlResponse>> CreateVnPayUrl(CreateVnPayUrlDto dto)
    {
        var order = await _db.Orders.FirstOrDefaultAsync(o => o.Id == dto.OrderId);
        if (order == null) return NotFound(new { message = "Không tìm thấy đơn hàng." });
        if (order.UserId != CurrentUserId) return Forbid();
        if (order.PaymentStatus == "paid")
            return BadRequest(new { message = "Đơn hàng này đã được thanh toán." });

        var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
        var url = _vnPay.CreatePaymentUrl(order, ip);
        return Ok(new VnPayUrlResponse { PaymentUrl = url });
    }

    /// <summary>VNPay redirect trình duyệt về đây sau khi khách thanh toán xong.</summary>
    [HttpGet("vnpay-return")]
    [AllowAnonymous]
    public async Task<ContentResult> VnPayReturn()
    {
        var valid = _vnPay.ValidateSignature(Request.Query);
        var responseCode = Request.Query["vnp_ResponseCode"].ToString();
        var txnRef = Request.Query["vnp_TxnRef"].ToString();

        var success = valid && responseCode == "00";
        var order = await _db.Orders.FirstOrDefaultAsync(o => o.Code == txnRef);
        // Không ghi đè nếu đơn đã "paid" — tránh 1 callback cũ/replay hạ trạng thái
        // xuống "failed" sau khi đơn đã thanh toán thành công.
        if (order != null && order.PaymentStatus != "paid")
        {
            order.PaymentStatus = success ? "paid" : "failed";
            await _db.SaveChangesAsync();
        }

        var title = success ? "Thanh toán thành công" : "Thanh toán thất bại";
        var html = $"""
            <html><head><meta charset="utf-8"><title>{title}</title></head>
            <body style="font-family:sans-serif;text-align:center;padding-top:60px;">
              <h2>{title}</h2>
              <p>Đơn hàng: {txnRef}</p>
              <p>Bạn có thể đóng cửa sổ này và quay lại ứng dụng.</p>
            </body></html>
            """;
        return Content(html, "text/html");
    }

    /// <summary>
    /// VNPay gọi server-to-server (IPN) để xác nhận kết quả thanh toán — nguồn cập nhật
    /// <see cref="Models.Order.PaymentStatus"/> đáng tin cậy, không phụ thuộc việc trình duyệt/app
    /// của khách có điều hướng về được <c>vnpay-return</c> hay không.
    /// Cần khai báo URL này (ví dụ https://{host}/api/payment/vnpay-ipn) trong Merchant Admin của VNPay.
    /// Định dạng phản hồi (RspCode/Message) theo đúng chuẩn VNPay, không theo camelCase mặc định của API.
    /// </summary>
    [HttpGet("vnpay-ipn")]
    [AllowAnonymous]
    public async Task<IActionResult> VnPayIpn()
    {
        if (!_vnPay.ValidateSignature(Request.Query))
            return IpnResult("97", "Invalid signature");

        var txnRef = Request.Query["vnp_TxnRef"].ToString();
        var order = await _db.Orders.FirstOrDefaultAsync(o => o.Code == txnRef);
        if (order == null)
            return IpnResult("01", "Order not found");

        if (!long.TryParse(Request.Query["vnp_Amount"].ToString(), out var vnpAmount)
            || vnpAmount != (long)(order.Total * 100))
            return IpnResult("04", "Invalid amount");

        if (order.PaymentStatus == "paid")
            return IpnResult("02", "Order already confirmed");

        order.PaymentStatus = Request.Query["vnp_ResponseCode"].ToString() == "00" ? "paid" : "failed";
        await _db.SaveChangesAsync();
        return IpnResult("00", "Confirm Success");
    }

    // Serialize thủ công (bỏ qua camelCase của AddJsonOptions) vì VNPay yêu cầu đúng "RspCode"/"Message".
    private ContentResult IpnResult(string rspCode, string message) =>
        Content(System.Text.Json.JsonSerializer.Serialize(new { RspCode = rspCode, Message = message }),
                "application/json");
}
