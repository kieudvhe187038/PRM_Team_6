using System.ComponentModel.DataAnnotations;

namespace BearShop.Api.Dtos;

/// <summary>Dữ liệu gửi 1 tin nhắn chat.</summary>
public class SendChatDto
{
    [Required(ErrorMessage = "Nội dung tin nhắn không được để trống.")]
    public string Text { get; set; } = string.Empty;
}

/// <summary>Một hội thoại (khách hàng) hiển thị trong danh sách của Admin.</summary>
public class ConversationDto
{
    public int CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string LastMessage { get; set; } = string.Empty;
    public DateTime LastMessageAt { get; set; }
}
