using System.Security.Claims;
using BearShop.Api.Data;
using BearShop.Api.Dtos;
using BearShop.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BearShop.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] // mọi endpoint yêu cầu JWT hợp lệ
public class OrdersController : ControllerBase
{
    private readonly AppDbContext _db;
    public OrdersController(AppDbContext db) => _db = db;

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? User.FindFirstValue("sub")!);

    /// <summary>Lấy lịch sử đơn hàng của người dùng đang đăng nhập.</summary>
    [HttpGet]
    public async Task<ActionResult<List<Order>>> GetMyOrders()
    {
        var userId = CurrentUserId;
        return await _db.Orders
            .Include(o => o.Items)
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    /// <summary>Tạo đơn hàng mới. Giá/tên/ảnh lấy từ CSDL theo ProductId — không
    /// tin dữ liệu giá do client gửi lên (tránh khách tự sửa giá trước khi đặt).</summary>
    [HttpPost]
    public async Task<ActionResult<Order>> Create(CreateOrderDto dto)
    {
        var userId = CurrentUserId;

        var productIds = dto.Items.Select(i => i.ProductId).Distinct().ToList();
        var products = await _db.Products
            .Where(p => productIds.Contains(p.Id))
            .ToDictionaryAsync(p => p.Id);

        var items = new List<OrderItem>();
        foreach (var i in dto.Items)
        {
            if (!products.TryGetValue(i.ProductId, out var product))
                return BadRequest(new { message = $"Sản phẩm id={i.ProductId} không tồn tại." });

            items.Add(new OrderItem
            {
                ProductId = product.Id,
                ProductName = product.Name,
                ImageUrl = product.ImageUrl,
                Price = product.Price,
                Quantity = i.Quantity,
            });
        }

        var total = items.Sum(i => i.Price * i.Quantity) + 30000; // + phí ship

        var order = new Order
        {
            Code = "DH" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            UserId = userId,
            CreatedAt = DateTime.UtcNow,
            Total = total,
            ReceiverName = dto.ReceiverName.Trim(),
            Address = dto.Address.Trim(),
            Phone = dto.Phone.Trim(),
            PaymentMethod = dto.PaymentMethod,
            Status = "pending",
            // Chuyển khoản ngân hàng coi như thanh toán ngay khi đặt (không qua cổng
            // trung gian để xác nhận như VNPay). COD chờ thu tiền khi giao nên vẫn "unpaid".
            PaymentStatus = dto.PaymentMethod == "Chuyển khoản ngân hàng" ? "paid" : "unpaid",
            Items = items,
        };

        _db.Orders.Add(order);
        await _db.SaveChangesAsync();
        return Ok(order);
    }

    /// <summary>Hủy đơn của chính mình khi thanh toán VNPay thất bại/bị hủy — đơn chưa
    /// thanh toán được xóa hẳn để không hiện trong lịch sử/đơn quản trị (coi như chưa từng đặt).
    /// Không cho hủy đơn đã "paid" để tránh mất dữ liệu đơn đã thanh toán thật.</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Cancel(int id)
    {
        var order = await _db.Orders.FirstOrDefaultAsync(o => o.Id == id);
        if (order == null) return NotFound();
        if (order.UserId != CurrentUserId) return Forbid();
        if (order.PaymentStatus == "paid")
            return BadRequest(new { message = "Đơn đã thanh toán, không thể hủy." });

        _db.Orders.Remove(order);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    /// <summary>Lấy tất cả đơn hàng của mọi khách hàng (Admin).</summary>
    [HttpGet("all")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<Order>>> GetAllOrders()
    {
        return await _db.Orders
            .Include(o => o.Items)
            .Include(o => o.User)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();
    }

    /// <summary>Cập nhật trạng thái đơn hàng (Admin).</summary>
    [HttpPut("{id:int}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<Order>> UpdateStatus(int id, UpdateOrderStatusDto dto)
    {
        var order = await _db.Orders.Include(o => o.Items).FirstOrDefaultAsync(o => o.Id == id);
        if (order == null) return NotFound();

        order.Status = dto.Status;
        await _db.SaveChangesAsync();
        return Ok(order);
    }
}
