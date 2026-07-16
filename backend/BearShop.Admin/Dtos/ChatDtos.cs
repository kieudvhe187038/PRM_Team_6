using System.ComponentModel.DataAnnotations;

namespace BearShop.Admin.Dtos;

public class ChatMessageDto
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public string SenderRole { get; set; } = "Customer";
    public string Text { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class ConversationDto
{
    public int CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string LastMessage { get; set; } = string.Empty;
    public DateTime LastMessageAt { get; set; }
}

public class SendChatDto
{
    [Required(ErrorMessage = "Nội dung tin nhắn không được để trống.")]
    public string Text { get; set; } = string.Empty;
}
