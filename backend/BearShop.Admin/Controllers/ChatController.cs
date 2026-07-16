using BearShop.Admin.Services;
using Microsoft.AspNetCore.Mvc;

namespace BearShop.Admin.Controllers;

public class ChatController(BearShopApiClient api) : Controller
{
    public async Task<IActionResult> Index()
    {
        var conversations = await api.GetConversationsAsync();
        return View(conversations);
    }

    public async Task<IActionResult> Conversation(int customerId)
    {
        var messages = await api.GetConversationAsync(customerId);
        var conversations = await api.GetConversationsAsync();
        ViewData["CustomerName"] = conversations
            .FirstOrDefault(c => c.CustomerId == customerId)?.CustomerName ?? "Khách hàng";
        ViewData["CustomerId"] = customerId;
        return View(messages);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Reply(int customerId, string text)
    {
        if (!string.IsNullOrWhiteSpace(text))
        {
            try
            {
                await api.SendToCustomerAsync(customerId, text);
            }
            catch (ApiException ex)
            {
                TempData["Error"] = ex.Message;
            }
        }
        return RedirectToAction(nameof(Conversation), new { customerId });
    }
}
