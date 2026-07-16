using System.ComponentModel.DataAnnotations;

namespace BearShop.Api.Dtos;

/// <summary>Dữ liệu tạo/cập nhật sản phẩm (Admin) — có validation phía server.</summary>
public class ProductUpsertDto
{
    [Required(ErrorMessage = "Vui lòng nhập tên sản phẩm.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng chọn danh mục.")]
    public string Category { get; set; } = string.Empty;

    [Range(0, double.MaxValue, ErrorMessage = "Giá phải >= 0.")]
    public double Price { get; set; }

    [Range(0, int.MaxValue, ErrorMessage = "Tồn kho phải >= 0.")]
    public int Stock { get; set; }

    [Required(ErrorMessage = "Vui lòng nhập ảnh sản phẩm.")]
    public string ImageUrl { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;
}
