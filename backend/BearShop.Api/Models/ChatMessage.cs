namespace BearShop.Api.Models;

/// <summary>Một tin nhắn trong hội thoại giữa 1 khách hàng và shop (Admin).</summary>
public class ChatMessage
{
    public int Id { get; set; }

    /// <summary>Hội thoại thuộc về khách hàng nào (dù người gửi là Customer hay Admin).</summary>
    public int CustomerId { get; set; }
    public User? Customer { get; set; }

    /// <summary>"Customer" hoặc "Admin" — ai là người gửi tin này.</summary>
    public string SenderRole { get; set; } = "Customer";

    public string Text { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
