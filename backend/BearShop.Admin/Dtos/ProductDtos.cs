using System.ComponentModel.DataAnnotations;

namespace BearShop.Admin.Dtos;

public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public double Price { get; set; }
    public double Rating { get; set; }
    public int Sold { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Stock { get; set; }
}

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

public class ProductEditViewModel : ProductUpsertDto
{
    public int Id { get; set; }
}

public static class ProductCategories
{
    public static readonly string[] All =
    [
        "Gấu Teddy",
        "Gấu nâu",
        "Thú bông",
        "Gấu mini",
    ];
}
