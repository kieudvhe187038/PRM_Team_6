using System.Net.Http.Headers;

namespace BearShop.Admin.Services;

/// <summary>Gắn header Authorization: Bearer &lt;token&gt; vào mọi request gọi BearShop.Api,
/// lấy token từ claim của người dùng admin đang đăng nhập (cookie) trong HttpContext hiện tại.</summary>
public class JwtAuthHandler(IHttpContextAccessor httpContextAccessor) : DelegatingHandler
{
    public const string TokenClaimType = "bearshop_api_token";

    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = httpContextAccessor.HttpContext?.User
            .FindFirst(TokenClaimType)?.Value;

        if (!string.IsNullOrEmpty(token))
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        return base.SendAsync(request, cancellationToken);
    }
}
