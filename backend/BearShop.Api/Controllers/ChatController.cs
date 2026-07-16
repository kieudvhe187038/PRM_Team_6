using System.Security.Claims;
using BearShop.Api.Data;
using BearShop.Api.Dtos;
using BearShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

/// <summary>Chat giữa khách hàng và shop (Admin). Mỗi khách có đúng 1 hội thoại.</summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChatController : ControllerBase
{
    private readonly AppDbContext _db;
    public ChatController(AppDbContext db) => _db = db;

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? User.FindFirstValue("sub")!);

    /// <summary>Khách hàng xem hội thoại của chính mình.</summary>
    [HttpGet("mine")]
    public async Task<ActionResult<List<ChatMessage>>> GetMine()
    {
        return await _db.ChatMessages
            .Where(m => m.CustomerId == CurrentUserId)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();
    }

    /// <summary>Khách hàng gửi tin nhắn cho shop.</summary>
    [HttpPost("mine")]
    public async Task<ActionResult<ChatMessage>> SendMine(SendChatDto dto)
    {
        var message = new ChatMessage
        {
            CustomerId = CurrentUserId,
            SenderRole = "Customer",
            Text = dto.Text.Trim(),
        };
        _db.ChatMessages.Add(message);
        await _db.SaveChangesAsync();
        return Ok(message);
    }

    /// <summary>Admin: danh sách hội thoại (theo từng khách hàng).</summary>
    [HttpGet("conversations")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<ConversationDto>>> GetConversations()
    {
        var groups = await _db.ChatMessages
            .GroupBy(m => m.CustomerId)
            .Select(g => new
            {
                CustomerId = g.Key,
                Last = g.OrderByDescending(m => m.CreatedAt).First(),
            })
            .ToListAsync();

        var customerIds = groups.Select(g => g.CustomerId).ToList();
        var names = await _db.Users
            .Where(u => customerIds.Contains(u.Id))
            .ToDictionaryAsync(u => u.Id, u => u.FullName);

        return groups
            .Select(g => new ConversationDto
            {
                CustomerId = g.CustomerId,
                CustomerName = names.GetValueOrDefault(g.CustomerId, "Khách hàng"),
                LastMessage = g.Last.Text,
                LastMessageAt = g.Last.CreatedAt,
            })
            .OrderByDescending(c => c.LastMessageAt)
            .ToList();
    }

    /// <summary>Admin: xem hội thoại với 1 khách hàng cụ thể.</summary>
    [HttpGet("{customerId:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<ChatMessage>>> GetConversation(int customerId)
    {
        return await _db.ChatMessages
            .Where(m => m.CustomerId == customerId)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();
    }

    /// <summary>Admin: trả lời 1 khách hàng cụ thể.</summary>
    [HttpPost("{customerId:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ChatMessage>> SendToCustomer(int customerId, SendChatDto dto)
    {
        var message = new ChatMessage
        {
            CustomerId = customerId,
            SenderRole = "Admin",
            Text = dto.Text.Trim(),
        };
        _db.ChatMessages.Add(message);
        await _db.SaveChangesAsync();
        return Ok(message);
    }
}
