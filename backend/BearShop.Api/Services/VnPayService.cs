using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using BearShop.Api.Models;

namespace BearShop.Api.Services;

/// <summary>Tạo URL thanh toán VNPay và xác thực chữ ký khi VNPay redirect về.</summary>
public class VnPayService
{
    private readonly IConfiguration _config;
    public VnPayService(IConfiguration config) => _config = config;

    /// <summary>Tạo URL thanh toán cho 1 đơn hàng, ký bằng HMACSHA512 theo chuẩn VNPay.</summary>
    public string CreatePaymentUrl(Order order, string ipAddress)
    {
        var vnp = _config.GetSection("VnPay");
        var data = new SortedDictionary<string, string>(StringComparer.Ordinal)
        {
            ["vnp_Version"] = "2.1.0",
            ["vnp_Command"] = "pay",
            ["vnp_TmnCode"] = vnp["TmnCode"]!,
            ["vnp_Amount"] = ((long)(order.Total * 100)).ToString(),
            ["vnp_CurrCode"] = "VND",
            ["vnp_TxnRef"] = order.Code,
            ["vnp_OrderInfo"] = $"Thanh toan don hang {order.Code}",
            ["vnp_OrderType"] = "other",
            ["vnp_Locale"] = "vn",
            ["vnp_ReturnUrl"] = vnp["ReturnUrl"]!,
            ["vnp_IpAddr"] = ipAddress,
            ["vnp_CreateDate"] = DateTime.UtcNow.AddHours(7).ToString("yyyyMMddHHmmss"),
        };

        var query = new StringBuilder();
        foreach (var kv in data)
            query.Append(WebUtility.UrlEncode(kv.Key)).Append('=')
                 .Append(WebUtility.UrlEncode(kv.Value)).Append('&');
        var signData = query.ToString().TrimEnd('&');

        var secureHash = HmacSha512(vnp["HashSecret"]!, signData);
        return $"{vnp["BaseUrl"]}?{query}vnp_SecureHash={secureHash}";
    }

    /// <summary>Kiểm tra chữ ký hợp lệ khi VNPay redirect về (vnp_ReturnUrl).</summary>
    public bool ValidateSignature(IQueryCollection query)
    {
        var vnp = _config.GetSection("VnPay");
        var receivedHash = query["vnp_SecureHash"].ToString();
        if (string.IsNullOrEmpty(receivedHash)) return false;

        var data = new SortedDictionary<string, string>(StringComparer.Ordinal);
        foreach (var kv in query)
        {
            if (kv.Key is "vnp_SecureHash" or "vnp_SecureHashType") continue;
            data[kv.Key] = kv.Value.ToString();
        }

        var signQuery = new StringBuilder();
        foreach (var kv in data)
            signQuery.Append(WebUtility.UrlEncode(kv.Key)).Append('=')
                     .Append(WebUtility.UrlEncode(kv.Value)).Append('&');
        var signData = signQuery.ToString().TrimEnd('&');

        var computedHash = HmacSha512(vnp["HashSecret"]!, signData);
        return string.Equals(computedHash, receivedHash, StringComparison.OrdinalIgnoreCase);
    }

    private static string HmacSha512(string key, string input)
    {
        using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(key));
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
        var sb = new StringBuilder();
        foreach (var b in hash) sb.Append(b.ToString("x2", CultureInfo.InvariantCulture));
        return sb.ToString();
    }
}
