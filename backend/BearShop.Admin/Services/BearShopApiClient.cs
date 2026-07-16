using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using BearShop.Admin.Dtos;

namespace BearShop.Admin.Services;

/// <summary>Client gọi BearShop.Api (cùng backend .NET, qua HTTP) cho toàn bộ nghiệp vụ
/// của trang quản trị. Token JWT được [JwtAuthHandler] tự gắn vào mỗi request.</summary>
public class BearShopApiClient(HttpClient http)
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    private async Task EnsureSuccessAsync(HttpResponseMessage response)
    {
        if (response.IsSuccessStatusCode) return;

        string? message = null;
        try
        {
            var body = await response.Content.ReadFromJsonAsync<JsonElement>();
            if (body.ValueKind == JsonValueKind.Object &&
                body.TryGetProperty("message", out var m))
                message = m.GetString();
        }
        catch (JsonException)
        {
            // Body không phải JSON hợp lệ — bỏ qua, dùng message mặc định bên dưới.
        }

        throw new ApiException(message ?? response.StatusCode switch
        {
            HttpStatusCode.Unauthorized => "Sai email hoặc mật khẩu.",
            HttpStatusCode.NotFound => "Không tìm thấy dữ liệu.",
            _ => "Không kết nối được máy chủ.",
        });
    }

    // ----- Auth -----

    public async Task<AuthResponse> LoginAsync(string email, string password)
    {
        var response = await http.PostAsJsonAsync("api/auth/login",
            new LoginRequest { Email = email, Password = password }, JsonOptions);
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<AuthResponse>(JsonOptions))!;
    }

    // ----- Dashboard -----

    public async Task<DashboardStatsDto> GetDashboardAsync()
    {
        var response = await http.GetAsync("api/dashboard");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<DashboardStatsDto>(JsonOptions))!;
    }

    // ----- Products -----

    public async Task<List<ProductDto>> GetProductsAsync()
    {
        var response = await http.GetAsync("api/products");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<List<ProductDto>>(JsonOptions))!;
    }

    public async Task<ProductDto> GetProductAsync(int id)
    {
        var response = await http.GetAsync($"api/products/{id}");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<ProductDto>(JsonOptions))!;
    }

    public async Task CreateProductAsync(ProductUpsertDto dto)
    {
        var response = await http.PostAsJsonAsync("api/products", dto, JsonOptions);
        await EnsureSuccessAsync(response);
    }

    public async Task UpdateProductAsync(int id, ProductUpsertDto dto)
    {
        var response = await http.PutAsJsonAsync($"api/products/{id}", dto, JsonOptions);
        await EnsureSuccessAsync(response);
    }

    public async Task DeleteProductAsync(int id)
    {
        var response = await http.DeleteAsync($"api/products/{id}");
        await EnsureSuccessAsync(response);
    }

    // ----- Orders -----

    public async Task<List<OrderDto>> GetAllOrdersAsync()
    {
        var response = await http.GetAsync("api/orders/all");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<List<OrderDto>>(JsonOptions))!;
    }

    public async Task UpdateOrderStatusAsync(int id, string status)
    {
        var response = await http.PutAsJsonAsync($"api/orders/{id}/status",
            new UpdateOrderStatusDto { Status = status }, JsonOptions);
        await EnsureSuccessAsync(response);
    }

    // ----- Users -----

    public async Task<List<UserSummaryDto>> GetUsersAsync()
    {
        var response = await http.GetAsync("api/users");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<List<UserSummaryDto>>(JsonOptions))!;
    }

    public async Task SetUserActiveAsync(int id, bool isActive)
    {
        var response = await http.PutAsJsonAsync($"api/users/{id}/status",
            new SetActiveDto { IsActive = isActive }, JsonOptions);
        await EnsureSuccessAsync(response);
    }

    // ----- Chat -----

    public async Task<List<ConversationDto>> GetConversationsAsync()
    {
        var response = await http.GetAsync("api/chat/conversations");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<List<ConversationDto>>(JsonOptions))!;
    }

    public async Task<List<ChatMessageDto>> GetConversationAsync(int customerId)
    {
        var response = await http.GetAsync($"api/chat/{customerId}");
        await EnsureSuccessAsync(response);
        return (await response.Content.ReadFromJsonAsync<List<ChatMessageDto>>(JsonOptions))!;
    }

    public async Task SendToCustomerAsync(int customerId, string text)
    {
        var response = await http.PostAsJsonAsync($"api/chat/{customerId}",
            new SendChatDto { Text = text }, JsonOptions);
        await EnsureSuccessAsync(response);
    }
}
